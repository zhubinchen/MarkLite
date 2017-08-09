//
//  RenderManager.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/2.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class RenderManager: NSObject {
    
    static let `default` = RenderManager()
    
    var markdownStyle: String! {
        didSet {
            let path = documentPath + "/style/markdown-style/" + markdownStyle + ".css"
            htmlStyleURL = URL(fileURLWithPath:path).absoluteString
        }
    }
    
    var highlightStyle: String! {
        didSet {
            let path = documentPath + "/style/style/highlight-style/" + highlightStyle + ".css"
            highlightStyleURL = URL(fileURLWithPath:path).absoluteString
        }
    }
    
    fileprivate let htmlRender = CreateHTMLRenderer()
    fileprivate let tocRender = CreateHTMLTOCRenderer()
    
    fileprivate var htmlStyleURL: String = ""
    fileprivate var highlightStyleURL: String = ""
    fileprivate var highlightjs1URL: String = {
        let path = documentPath + "style/highlightjs/highlight.min.js"
        return URL(fileURLWithPath:path).absoluteString
    }()
    fileprivate var highlightjs2URL: String = {
        let path = documentPath + "style/highlightjs/swift.min.js"
        return URL(fileURLWithPath:path).absoluteString
    }()
    
    
    func render(_ markdown: String) -> String {

        guard let body = HTMLFromMarkdown(markdown, htmlRender, tocRender) else { return "" }
        return String(format: htmlFormat,
                      htmlStyleURL,
                      highlightStyleURL,
                      highlightjs1URL,
                      highlightjs2URL,
                      body)

    }
}

fileprivate let htmlFormat = "<html lang=\"zh-CN\"><head><meta charset=\"UTF-8\"><style type=\"text/css\"></style><link rel=\"stylesheet\" href=\"%@\"></style><link rel=\"stylesheet\" href=\"%@\"><script src=\"%@\"></script><script src=\"%@\"></script><script>hljs.initHighlightingOnLoad();</script></head><body>%@</body></html>"
