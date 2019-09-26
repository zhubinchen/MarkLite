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
            if isViewLoaded {
                webView.scrollView.contentOffset = CGPoint(x: 0, y: offset * webView.scrollView.contentSize.height)
            }
        }
    }
    
    var htmlString = "" {
        didSet {
            print(htmlString)
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
            
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
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
//        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'")
//        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'black'")
//        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.background='#EFEFF4'")
    }
    
    deinit {
        print("deinit web_vc")
    }
}
