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
import WebKit
import SnapKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    let webView = UIWebView(frame: CGRect())
    
    var offset: CGFloat = 0 {
        didSet {
            webView.scrollView.contentOffset = CGPoint(x: 0, y: offset * webView.scrollView.contentSize.height)
        }
    }
    
    var timer: Timer?
    
    var contentChanged = false
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(webView)
        self.webView.delegate = self
        self.webView.scalesPageToFit = true
        
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        webView.backgroundColor = .clear
        webView.isOpaque = false
        view.setBackgroundColor(.background)
        
        addNotificationObserver(Notification.Name.UIKeyboardWillChangeFrame.rawValue, selector: #selector(keyboardWillChange(_:)))
        
        timer = Timer.runThisEvery(seconds: 1) { [weak self] _ in
            guard let this = self else { return }
            if this.contentChanged {
                this.webView.reload()
                this.contentChanged = false
            }
        }
    }
    
    @objc func keyboardWillChange(_ noti: NSNotification) {
        guard let frame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        webView.snp.remakeConstraints { make in
            make.right.left.top.equalTo(0)
            make.bottom.equalTo(-max(self.view.h - frame.y + 50,0))
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
        webView.scrollView.contentOffset = CGPoint(x: 0, y: offset * webView.scrollView.contentSize.height)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
        webView.scrollView.contentOffset = CGPoint(x: 0, y: offset * webView.scrollView.contentSize.height)
//        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'")
//        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'black'")
//        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.background='#EFEFF4'")
    }
    
    deinit {
        timer?.invalidate()
        removeNotificationObserver()
        print("deinit web_vc")
    }
}
