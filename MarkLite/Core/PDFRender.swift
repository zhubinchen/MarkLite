//
//  PDFRender.swift
//  Markdown
//
//  Created by zhubch on 2017/7/31.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class PDFRender: UIPrintPageRenderer {
    
    let pageSize: CGSize
    
    let padding: CGFloat
    
    override var paperRect: CGRect {
        
        return CGRect(x: 0, y: 0, w: pageSize.width, h: pageSize.height)
    }
    
    override var printableRect: CGRect {
        return CGRect(x: 20, y: 20, w: pageSize.width - 20, h: pageSize.height - 20 - footerHeight)
    }
    
    init(pageSize: CGSize = CGSize(width: 595.2, height: 841.8) , padding: CGFloat = 20) {
        self.pageSize = pageSize
        self.padding = padding
        super.init()
        self.headerHeight = 0.0
        self.footerHeight = 40.0
    }
    
    func render(formatter: UIViewPrintFormatter) -> Data {
        
//        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        addPrintFormatter(formatter, startingAtPageAt: 0)
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect(), nil)
        prepare(forDrawingPages: NSRange(location:0, length: numberOfPages))
        for i in 0..<numberOfPages {
            UIGraphicsBeginPDFPage()
            let bounds = UIGraphicsGetPDFContextBounds()
            drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext()
        
        return data as Data
    }
    

    override func drawFooterForPage(at pageIndex: Int, in footerRect: CGRect) {
        let font = UIFont(name: "HelveticaNeue", size: 18)
        let attr: [NSAttributedStringKey : NSObject] = [
            NSAttributedStringKey.font : font ?? UIFont.font(ofSize: 18),
            NSAttributedStringKey.foregroundColor : rgb("0f2f2f")!
        ]
        
        let text = (pageIndex + 1).toString as NSString
        let textSize = text.size(withAttributes: attr)
        let rect = CGRect(x: (pageSize.width - textSize.width) * 0.5,
                          y: footerRect.origin.y + 15 - textSize.height * 0.5,
                          w: textSize.width,
                          h: textSize.height)
        text.draw(in: rect, withAttributes: attr)
    }
    
}
