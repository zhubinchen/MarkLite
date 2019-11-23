//
//  PNGRender.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/11/23.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit
import WebKit

class PNGRender: UIPrintPageRenderer {
 
     private var formatter: UIPrintFormatter
     
     private var contentSize: CGSize
     
     required init(formatter: UIPrintFormatter, contentSize: CGSize) {
        self.formatter = formatter
        self.contentSize = contentSize
        super.init()
        self.addPrintFormatter(formatter, startingAtPageAt: 0)
     }
     
     override var paperRect: CGRect {
        return CGRect.init(origin: .zero, size: contentSize)
     }
     
     override var printableRect: CGRect {
        return CGRect.init(origin: .zero, size: contentSize)
     }
     
     private func printContentToPDFPage() -> CGPDFPage? {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, self.paperRect, nil)
         self.prepare(forDrawingPages: NSMakeRange(0, 1))
         let bounds = UIGraphicsGetPDFContextBounds()
         UIGraphicsBeginPDFPage()
         self.drawPage(at: 0, in: bounds)
         UIGraphicsEndPDFContext()
        
         let cfData = data as CFData
         guard let provider = CGDataProvider.init(data: cfData) else {
          return nil
         }
         let pdfDocument = CGPDFDocument.init(provider)
         let pdfPage = pdfDocument?.page(at: 1)
        
         return pdfPage
    }

    private func covertPDFPageToImage(_ pdfPage: CGPDFPage) -> UIImage? {
        let pageRect = pdfPage.getBoxRect(.trimBox)
         let contentSize = CGSize.init(width: floor(pageRect.size.width), height: floor(pageRect.size.height))
        
         UIGraphicsBeginImageContextWithOptions(contentSize, true, 2.0)
         guard let context = UIGraphicsGetCurrentContext() else {
          return nil
         }
        
         context.setFillColor(UIColor.white.cgColor)
         context.setStrokeColor(UIColor.white.cgColor)
         context.fill(pageRect)
        
         context.saveGState()
         context.translateBy(x: 0, y: contentSize.height)
         context.scaleBy(x: 1.0, y: -1.0)
        
         context.interpolationQuality = .low
         context.setRenderingIntent(.defaultIntent)
         context.drawPDFPage(pdfPage)
         context.restoreGState()
        
         let image = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
        
         return image
    }

    internal func printContentToImage() -> UIImage? {
        guard let pdfPage = self.printContentToPDFPage() else { return nil }
    
        let image = self.covertPDFPageToImage(pdfPage)
        return image
    }
}
 
extension WKWebView {
    public func takeScreenshotOfFullContent(_ completion: @escaping ((UIImage?) -> Void)) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            let renderer = PNGRender(formatter: self.viewPrintFormatter(), contentSize: self.scrollView.contentSize)
            let image = renderer.printContentToImage()
            completion(image)
        }
    }
}

