//
//  WebViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/28.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum ExportType: String {
    case PDF
    case html
    case image
    case markdown
}

class WebViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    var text = "" {
        didSet {
            htmlString = renderManager.render(text)
        }
    }
    
    var htmlString = "" {
        didSet {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    let disposeBag = DisposeBag()
    
    let renderManager: RenderManager = RenderManager.default

    let pdfRender = PdfRender()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.rx.didStartLoad.subscribe { [weak self] _ in
            self?.webView.startLoadingAnimation()
        }.addDisposableTo(disposeBag)
        webView.rx.didFailLoad.subscribe { [weak self] _ in
            self?.webView.stopLoadingAnimation()
        }.addDisposableTo(disposeBag)
        webView.rx.didFinishLoad.subscribe { [weak self] _ in
            self?.webView.stopLoadingAnimation()
        }.addDisposableTo(disposeBag)
        
        Configure.shared.markdownStyle.asObservable().subscribe(onNext: { [unowned self] (style) in
            self.renderManager.markdownStyle = style
            self.htmlString = self.renderManager.render(self.text)
        }).addDisposableTo(disposeBag)
        Configure.shared.highlightStyle.asObservable().subscribe(onNext: { [unowned self] (style) in
            self.renderManager.highlightStyle = style
            self.htmlString = self.renderManager.render(self.text)
        }).addDisposableTo(disposeBag)
    }
    
    func showExportMenu() {
        let items = [ExportType.PDF,.markdown,.html,.image]
        let pos = CGPoint(x: windowWidth - 140, y: 65)
        MenuView(items: items.map{$0.rawValue},
                 postion: pos) { (index) in
                    guard let url = self.url(for: items[index]) else { return }
                    self.exportFile(url)
            }.show()
    }
    
    func url(for type: ExportType) -> URL? {
        guard let file = Configure.shared.currentFile.value else { return nil }
        switch type {
        case .PDF:
            let data = pdfRender.render(html: htmlString)
            let path = Configure.shared.tempFolderPath + "/" + file.name + ".pdf"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        case .image:
            guard let img = webView.scrollView.snap, let data = UIImagePNGRepresentation(img) else { return nil }
            let path = Configure.shared.tempFolderPath + "/" + file.name + ".png"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        case .markdown:
            return URL(fileURLWithPath: file.path)
        case .html:
            guard let data = htmlString.data(using: String.Encoding.utf8) else { return nil }
            let path = Configure.shared.tempFolderPath + "/" + file.name + ".html"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        }
    }
    
    func exportFile(_ url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        presentVC(vc)
    }
    
    deinit {
        print("deinit web_vc")
    }
}
