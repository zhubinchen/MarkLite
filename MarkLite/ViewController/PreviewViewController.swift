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
    let scrollView = UIScrollView(frame: CGRect())
    
    var offset: CGFloat = 0 {
        didSet {
            var y = offset * (webHeight - scrollView.h)
            if y > webHeight - scrollView.h  {
                y = webHeight - scrollView.h
            }
            if y < 0 {
                y = 0
            }
            scrollView.contentOffset = CGPoint(x: 0,y: y)
        }
    }
    
    var webHeight: CGFloat = windowHeight {
        didSet {
            scrollView.contentSize = CGSize(width: 0, height: webHeight)
            let inset = Configure.shared.contentInset.value ? max((self.view.w - 500) * 0.2,0) : 0
            webView.frame = CGRect(x: inset, y: 0, w: scrollView.w - inset * 2, h: webHeight)
        }
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
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2
        view.addSubview(scrollView)
        scrollView.addSubview(webView)

        view.setBackgroundColor(.background)
                
        timer = Timer.runThisEvery(seconds: 0.5, handler: { [weak self] _ in
            if self?.shouldRefresh ?? false {
                self?.refresh()
            }
        })
        
        Configure.shared.contentInset.asObservable().subscribe(onNext: { [unowned self](enable) in
            self.webHeight += CGFloat.leastNonzeroMagnitude
        }).disposed(by: disposeBag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = self.view.bounds
        offset += CGFloat.leastNonzeroMagnitude
        if fabs(scrollView.w - webView.w) > 10 {
            webHeight = 100
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let size = change?[NSKeyValueChangeKey.newKey] as? CGSize {
            if fabs(webHeight - size.height) > 10 {
                webHeight = size.height
            }
        }
    }
    
    func showTOC(_ toc: TOCItem) {
        scrollView.contentOffset = CGPoint()
        webView.frame = CGRect(x: webView.x, y: 0, w: webView.w, h: scrollView.h)
        webView.scrollView.isScrollEnabled = true
        scrollView.isScrollEnabled = false
        let js = "location.href=\"#toc_\(toc.idx)\""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.webView.evaluateJavaScript(js) { (_,error) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.webView.scrollView.isScrollEnabled = false
                    self.scrollView.isScrollEnabled = true
                    let offset = self.webView.scrollView.contentOffset
                    self.scrollView.contentOffset = offset
                    self.webView.frame = CGRect(x: self.webView.x, y: 0, w: self.webView.w, h: self.webHeight)
                    print(offset)
                }
            }
        }
    }
    
    func refresh() {
        if html.length == 0 {
            return
        }
        shouldRefresh = false
        webView.stopLoading()
        webView.loadHTMLString(html, baseURL: htmlURL)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            let offset = scrollView.contentOffset.y
            if webHeight - scrollView.h > 0 {
                didScrollHandler?(offset / (webHeight - scrollView.h))
            }
        }
        
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -800 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 800 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
    
    deinit {
        timer?.invalidate()
        webView.stopLoading()
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
        removeNotificationObserver()
        
        print("deinit web_vc")
    }
}
