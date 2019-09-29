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

class WebViewController: UIViewController, UIWebViewDelegate {
    
    let webView = UIWebView(frame: CGRect())
    let scrollView = UIScrollView(frame: CGRect())
    
    var offset: CGFloat = 0 {
        didSet {
            let y = offset * contentHeight
            scrollView.contentOffset = CGPoint(x: 0,y: y)
        }
    }
    
    var contentHeight: CGFloat = 1000 {
        didSet {
            webView.frame = CGRect(x: 0, y: 0, w: scrollView.w, h: contentHeight)
            scrollView.contentSize = CGSize(width: 0,height: contentHeight)
        }
    }
    
    var timer: Timer?
    
    var contentChanged = false {
        didSet {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refresh), userInfo: nil, repeats: false)
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(webView)
        
        webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
                
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        view.setBackgroundColor(.background)
        
        addNotificationObserver(Notification.Name.UIKeyboardWillChangeFrame.rawValue, selector: #selector(keyboardWillChange(_:)))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = self.view.bounds
        contentHeight = 1000
        refresh()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let size = change?[NSKeyValueChangeKey.newKey] as? CGSize {
            if fabs(self.contentHeight - size.height) > 60 {
                self.contentHeight = size.height
            }
        }
    }
    
    @objc func refresh() {
        if contentChanged {
            webView.reload()
        }
    }
    
    @objc func keyboardWillChange(_ noti: NSNotification) {
        guard let frame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        UIView.animate(withDuration: 0.5, animations: {
            self.webView.h = self.view.size.height - max(self.view.h - frame.y + 50,0);
        })
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
    }
    
    deinit {
        timer?.invalidate()
        removeNotificationObserver()
        print("deinit web_vc")
    }
}
