//
//  WebViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/6/28.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import SnapKit

enum ExportType: String {
    case pdf
    case html
    case image
    case markdown
    
    var displayName: String {
        switch self {
        case .pdf:
            return /"PDF"
        case .html:
            return /"WebPage"
        case .image:
            return /"Image"
        default:
            return /"Markdown"
        }
    }
}

class WebViewController: UIViewController, ImageSaver {
    
    let webView = WKWebView(frame: CGRect())
    
    var offset: CGFloat = 0 {
        didSet {
            if isViewLoaded {
                webView.scrollView.contentOffset = CGPoint(x: 0, y: offset * webView.scrollView.contentSize.height)
            }
        }
    }
    
    var htmlString = "" {
        didSet {
            print(htmlString)
            webView.loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: stylePath, isDirectory: true))
        }
    }
    
    let bag = DisposeBag()
    
    let pdfRender = PdfRender()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func url(for type: ExportType) -> URL? {
        guard let file = Configure.shared.editingFile.value else { return nil }
        switch type {
        case .pdf:
            let data = pdfRender.render(html: htmlString)
            let path = tempPath + "/" + file.name + ".pdf"
            let url = URL(fileURLWithPath: path)
            do {
                try data.write(to: url)
            } catch {
                print(error.localizedDescription)
            }
            return url
        case .image:
            guard let img = webView.scrollView.snap, let _ = UIImagePNGRepresentation(img) else { return nil }
            saveImage(img)
//            let path = tempFolderPath + "/" + file.name + ".png"
//            let url = URL(fileURLWithPath: path)
//            try? data.write(to: url)
            return nil
        case .markdown:
            return URL(fileURLWithPath: file.path)
        case .html:
            guard let data = htmlString.data(using: String.Encoding.utf8) else { return nil }
            let path = tempPath + "/" + file.name + ".html"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        }
    }
    
    deinit {
        print("deinit web_vc")
    }
}

extension WebViewController: WKNavigationDelegate,WKUIDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.startLoadingAnimation()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.stopLoadingAnimation()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
