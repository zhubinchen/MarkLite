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
    
    var htmlString = "" {
        didSet {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    
    let disposeBag = DisposeBag()
    var fileDisposeBag: DisposeBag!
    
    let renderManager: RenderManager = RenderManager.default()

    let pdfRender = PdfRender()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderManager.markdownStyle = "GitHub2"
        renderManager.highlightStyle = "rainbow"

        Configure.shared.currentFile.asObservable().subscribe(onNext: { [weak self] (file) in
            guard let file = file, let this = self else { return }
            this.fileDisposeBag = DisposeBag()
            file.text.asObservable().map{ this.renderManager.render($0) ?? "" }.subscribe(onNext: { (html) in
                this.htmlString = html
            }).addDisposableTo(this.fileDisposeBag)
        }).addDisposableTo(disposeBag)
        
        webView.rx.didStartLoad.subscribe { [weak self] _ in
            self?.webView.startLoadingAnimation()
        }.addDisposableTo(disposeBag)
        webView.rx.didFailLoad.subscribe { [weak self] _ in
            self?.webView.stopLoadingAnimation()
        }.addDisposableTo(disposeBag)
        webView.rx.didFinishLoad.subscribe { [weak self] _ in
            self?.webView.stopLoadingAnimation()
        }.addDisposableTo(disposeBag)
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
        let name = Configure.shared.currentFile.value?.name ?? "temp"
        switch type {
        case .PDF:
            let data = pdfRender.render(html: htmlString)
            let path = Configure.shared.tempFolderPath + "/" + name + ".pdf"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        case .image:
            guard let img = webView.scrollView.snap, let data = UIImagePNGRepresentation(img) else { return nil }
            let path = Configure.shared.tempFolderPath + "/" + name + ".png"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        case .markdown:
            guard let path = Configure.shared.currentFile.value?.path else { return nil }
            return URL(fileURLWithPath: path)
        case .html:
            guard let data = htmlString.data(using: String.Encoding.utf8) else { return nil }
            let path = Configure.shared.tempFolderPath + "/" + name + ".html"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        }
    }
    
    func exportFile(_ url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        presentVC(vc)
    }
    
}
