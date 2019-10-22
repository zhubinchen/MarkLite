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
import SnapKit

class PreviewViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {
    
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
            webView.loadHTMLString(html, baseURL: url)
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
        webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.addSubview(webView)
        
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
            if fabs(self.contentHeight - size.height) > 10 {
                self.contentHeight = size.height
            }
        }
    }
    
    func updateView() {
        if fabs(view.w - scrollView.w) > 100 {
            webView.loadHTMLString(html, baseURL: url)
        }
        scrollView.frame = CGRect(x: 0, y: 0, w: view.w, h: view.h - keyboardHeight)
        contentHeight = scrollView.h
    }
    
    @objc func keyboardWillChange(_ noti: NSNotification) {
        guard let frame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardHeight = max(windowHeight - frame.y - bottomInset, 0)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -10 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 10 { self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    deinit {
        removeNotificationObserver()
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
        print("deinit web_vc")
    }
}
