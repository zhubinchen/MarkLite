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
    @IBOutlet weak var webView: UIWebView!
    
    var text = "" {
        didSet {
            htmlString = renderManager.render(text)
        }
    }
    
    var offset: CGFloat = 0 {
        didSet {
            if isViewLoaded {
                webView.scrollView.contentOffset = CGPoint(x: 0, y: offset * webView.scrollView.contentSize.height)
            }
        }
    }
    
    var htmlString = "" {
        didSet {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    let bag = DisposeBag()
    
    let renderManager: RenderManager = RenderManager.default

    let pdfRender = PdfRender()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRx()
    }
    
    func setupRx() {
        webView.rx.didStartLoad.subscribe { [weak self] _ in
            self?.webView.startLoadingAnimation()
            }.disposed(by: bag)
        
        webView.rx.didFailLoad.subscribe { [weak self] _ in
            self?.webView.stopLoadingAnimation()
            }.disposed(by: bag)
        
        webView.rx.didFinishLoad.subscribe { [weak self] _ in
            self?.webView.stopLoadingAnimation()
            }.disposed(by: bag)
        
        Configure.shared.markdownStyle.asObservable().subscribe(onNext: { [unowned self] (style) in
            self.renderManager.markdownStyle = style
            self.htmlString = self.renderManager.render(self.text)
        }).disposed(by: bag)
        
        Configure.shared.highlightStyle.asObservable().subscribe(onNext: { [unowned self] (style) in
            self.renderManager.highlightStyle = style
            self.htmlString = self.renderManager.render(self.text)
        }).disposed(by: bag)
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
            guard let img = webView.scrollView.snap, let data = UIImagePNGRepresentation(img) else { return nil }
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
