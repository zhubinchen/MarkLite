//
//  PreviewViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/6/28.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PreviewViewController: UIViewController, UIWebViewDelegate {
    
    let webView = UIWebView(frame: CGRect())
    let scrollView = UIScrollView(frame: CGRect())
    
    var offset: CGFloat = 0 {
        didSet {
            let y = offset * contentHeight - scrollView.h
            let canScroll = max(contentHeight - scrollView.h,0)
            scrollView.contentOffset = CGPoint(x: 0,y: min(y, canScroll))
        }
    }
    
    var contentHeight: CGFloat = 1000 {
        didSet {
            webView.frame = CGRect(x: 0, y: 0, w: scrollView.w, h: contentHeight)
            scrollView.contentSize = CGSize(width: 0,height: contentHeight)
        }
    }
    
    var keyboardHeight: CGFloat = 0
        
    var html: String = "" {
        didSet {
            refresh()
        }
    }
    
    var url: URL?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(webView)
        
        webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
                
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        view.setBackgroundColor(.background)
        
        addNotificationObserver(Notification.Name.UIKeyboardWillChangeFrame.rawValue, selector: #selector(keyboardWillChange(_:)))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateView()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let size = change?[NSKeyValueChangeKey.newKey] as? CGSize {
            if fabs(self.contentHeight - size.height) > 30 {
                self.contentHeight = size.height + 10
            }
        }
    }
    
    func updateView() {
        scrollView.frame = CGRect(x: 0, y: 0, w: view.w, h: view.h - keyboardHeight)
        contentHeight = scrollView.h
        refresh()
    }
    
    func refresh() {
        webView.loadHTMLString(html, baseURL: url)
    }
    
    @objc func keyboardWillChange(_ noti: NSNotification) {
        guard let frame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardHeight = max(windowHeight - frame.y,0)
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollView.h = self.view.size.height - self.keyboardHeight;
        })
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
    }
    
    deinit {
        removeNotificationObserver()
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
        print("deinit web_vc")
    }
}
