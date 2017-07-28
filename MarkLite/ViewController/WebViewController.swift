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

class WebViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    var htmlString: String?
    
    let disposeBag = DisposeBag()
    
    let renderManager: RenderManager = RenderManager.default()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderManager.markdownStyle = "GitHub2"
        renderManager.highlightStyle = "rainbow"

        Configure.shared.currentFile.asObservable().subscribe(onNext: { [weak self] (file) in
            guard let file = file, let this = self else { return }
            file.text.asObservable().subscribe(onNext: { (string) in
                DispatchQueue.global().async {
                    let html = this.renderManager.render(string) ?? string
                    DispatchQueue.main.async {
                        this.webView.loadHTMLString(html, baseURL: nil)
                    }
                }
            }).addDisposableTo(this.disposeBag)
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

}
