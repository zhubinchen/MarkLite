//
//  Syntax.swift
//  MarkLite
//
//  Created by zhubch on 2017/7/1.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class HighlightStyle {
    
    var textColor: UIColor = .black
    var backgroudColor: UIColor = .clear
    var italic: Bool = false
    var bold: Bool = false
    var deletionLine: Bool = false
    var size: CGFloat = 17

    var attrs: [String : Any] {
        let fontName = "KaiTi_GB2312"
        
        var font: UIFont?
        if (italic) {
            let x = tanh(CGFloat.pi / 180 * 15)
            let matrix = CGAffineTransform(a: 1, b: 0, c: x, d: 1, tx: 0, ty: 0)
            let desc = UIFontDescriptor(name: fontName, matrix: matrix)
            font = UIFont(descriptor: desc, size: size)
        }
        if (bold) {
            if let desc = UIFontDescriptor(name: fontName, size: size).withSymbolicTraits(.traitBold) {
                font = UIFont(descriptor: desc, size: size)
            }
        }
        return [NSFontAttributeName : font ?? UIFont.font(ofSize:size),
                NSForegroundColorAttributeName : textColor,
                NSBackgroundColorAttributeName : backgroudColor,
                NSStrikethroughStyleAttributeName : deletionLine ? NSUnderlineStyle.styleSingle.rawValue :  NSUnderlineStyle.styleNone.rawValue,
                NSStrikethroughColorAttributeName : textColor
        ]
    }
}

struct Syntax {
    let expression: NSRegularExpression
    let style: HighlightStyle = HighlightStyle()
    
    init(_ pattern: String, _ options: NSRegularExpression.Options = .caseInsensitive, _ styleConfigure: (HighlightStyle)->Void = {_ in }) {
        expression = try! NSRegularExpression(pattern: pattern, options: options)
        styleConfigure(style)
    }
    
    func matchsInText(_ string: String ) -> [NSRange] {
        return expression.matches(in: string, options: .reportCompletion, range: range(0, string.length)).map{ $0.range }
    }
}

struct MarkdownHighlightManager {
    let syntaxArray: [Syntax] = [
        Syntax("^#{1,6} .*", .anchorsMatchLines) {
            $0.bold = true
            $0.textColor = rgb(33,47,63)
        },//header
        Syntax(".*\\n=+[(\\s)|=]+") {
            $0.bold = true
            $0.textColor = rgb(33,47,63)
        },//Title
        Syntax("^[\\s]*[-\\*\\+] +(.*)", .anchorsMatchLines),//ULLists://无序列表
        Syntax("^[\\s]*[0-9]+\\.(.*)", .anchorsMatchLines),//OLLists有序列表
        Syntax("(\\[.+\\]\\([^\\)]+\\))|(<.+>)") {
            $0.textColor = rgb(50,90,160)
        },//Links
        Syntax("!\\[[^\\]]+\\]\\([^\\)]+\\)") {
            $0.textColor = rgb(50,90,160)
        },//Images
        Syntax("(\\*\\*|__)(.*?)\\1") {
            $0.bold = true
        },//Bold
        Syntax("(\\*|_)(.*?)\\1") {
            $0.bold = true
        },//Emphasis
        Syntax("~~(.*?)~~") {
            $0.textColor = rgb(129,140,140)
            $0.deletionLine = true
        },//Deletions
        Syntax("\\:\\\"(.*?)\\\"\\:"),//Quotes
        Syntax("`{1,2}[^`](.*?)`{1,2}") {
            $0.textColor = rgb(71,91,98)
            $0.backgroudColor = rgb(246,246,246)
        },//InlineCode
        Syntax("\n(&gt;|\\>)(.*)"),//Blockquotes://引用块
        Syntax("^-+$", .anchorsMatchLines),//Separate://分割线
        Syntax("```([\\s\\S]*?)```[\\s]?") {
            $0.textColor = rgb(71,91,98)
            $0.backgroudColor = rgb(246,246,246)
        },//CodeBlock```包围的代码块
        Syntax("^\n[\\f\\r\\t\\v]*(( {4}|\\t).*(\\n|\\z))+", .anchorsMatchLines) {
            $0.textColor = rgb(71,91,98)
            $0.backgroudColor = rgb(246,246,246)
        },//ImplicitCodeBlock4个缩进也算代码块
    ]

    
    func highlight(_ string: String) -> NSAttributedString {
        let result = NSMutableAttributedString(string: string)
        result.addAttributes([NSFontAttributeName : UIFont.font(ofSize:17),
                              NSForegroundColorAttributeName : rgb(33,47,63)], range: range(0,string.length))
        syntaxArray.forEach { (syntax) in
            syntax.matchsInText(string).forEach({ (range) in
                result.addAttributes(syntax.style.attrs, range: range)
            })
        }
        return result
    }
}





