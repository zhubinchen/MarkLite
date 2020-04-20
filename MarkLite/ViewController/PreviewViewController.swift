//
//  PreviewViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/6/28.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import SnapKit

class PreviewViewController: UIViewController, UIScrollViewDelegate, WKNavigationDelegate {
    
    let webView = WKWebView(frame: CGRect())
    
    var contentOffset: CGPoint = CGPoint()
    
    var offset: CGFloat = 0 {
        didSet {
            var y = offset * (webHeight - webView.h)
            if y > webHeight - webView.h  {
                y = webHeight - webView.h
            }
            if y < 0 {
                y = 0
            }
            webView.scrollView.contentOffset = CGPoint(x: 0,y: y)
        }
    }
    
    var webHeight: CGFloat {
        return webView.scrollView.contentSize.height
    }
        
    var shouldRefresh = false
    
    var timer: Timer?

    var html: String = "" {
        didSet {
            if html != oldValue {
                shouldRefresh = true
            }
        }
    }
        
    var htmlURL: URL!
        
    var didScrollHandler: ((CGFloat)->Void)?
    
    let disposeBag = DisposeBag()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        view.addSubview(webView)
        
        webView.snp.makeConstraints { maker in
            maker.centerX.top.bottom.equalToSuperview()
            maker.left.equalToSuperview()
        }

        view.setBackgroundColor(.background)
                
        timer = Timer.runThisEvery(seconds: 0.5, handler: { [weak self] _ in
            if self?.shouldRefresh ?? false {
                self?.refresh()
            }
        })
        
        Configure.shared.contentInset.asObservable().subscribe(onNext: { [unowned self](enable) in
            let inset = enable ? max((self.view.w - 500) * 0.2,0) : 0
            self.webView.snp.updateConstraints { maker in
                maker.left.equalTo(inset)
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let inset = Configure.shared.contentInset.value ? max((self.view.w - 500) * 0.2,0) : 0
        self.webView.snp.updateConstraints { maker in
            maker.left.equalTo(inset)
        }
    }
    
    func showTOC(_ toc: TOCItem) {
        let js = "location.href=\"#toc_\(toc.idx)\""
        self.webView.evaluateJavaScript(js) { (_,error) in

        }
    }
    
    func refresh() {
        if html.length == 0 {
            return
        }
        shouldRefresh = false
        webView.stopLoading()
        if let snapshot = webView.snapshotView(afterScreenUpdates: true) {
            snapshot.frame = webView.frame
            snapshot.tag = 4654
            view.addSubview(snapshot)
        }
        contentOffset = webView.scrollView.contentOffset
        webView.loadHTMLString(html, baseURL: htmlURL)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            let offset = scrollView.contentOffset.y
            if webHeight - scrollView.h > 0 {
                didScrollHandler?(offset / (webHeight - scrollView.h))
            }
        }
        
        if Configure.shared.autoHideNavigationBar.value == false {
            return
        }
        
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -800 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 800 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let snapshot = view.viewWithTag(4654) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            webView.scrollView.contentOffset = self.contentOffset
            snapshot.removeFromSuperview()
        }
    }
    
    deinit {
        timer?.invalidate()
        webView.stopLoading()
        
        print("deinit web_vc")
    }
}
