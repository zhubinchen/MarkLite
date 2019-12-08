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

class PreviewViewController: UIViewController, UIScrollViewDelegate {
    
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
            scrollView.contentSize = CGSize(width: 0,height: webHeight)
            webView.frame = CGRect(x: 0, y: 0, w: scrollView.w, h: webHeight)
        }
    }
    
    var keyboardHeight: CGFloat = 0 {
        didSet {
            if keyboardHeight == oldValue {
                return
            }
            let h = view.h - max(keyboardHeight,0)
            UIView.animate(withDuration: 0.5, animations: {
                self.scrollView.h = h
            })
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
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.backgroundColor = .clear
        webView.isOpaque = false
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let h = view.h - max(keyboardHeight - bottomInset,0)
        scrollView.frame = CGRect(x: 0, y: 0, w: view.w, h: h)
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
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return webView
    }
    
    deinit {
        timer?.invalidate()
        webView.stopLoading()
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
        removeNotificationObserver()
        
        print("deinit web_vc")
    }
}
