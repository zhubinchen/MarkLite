//
//  Syntax.swift
//  Markdown
//
//  Created by zhubch on 2017/7/1.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class HighlightStyle {
    
    var textColor: UIColor = Configure.shared.theme.value == .black ? rgb(200,200,190) : rgb(53,57,63)
    var backgroundColor: UIColor = .clear
    var italic: Bool = false
    var bold: Bool = false
    var deletionLine: Bool = false
    var size: CGFloat = 17

    var attrs: [NSAttributedStringKey : Any] {
        
        var font: UIFont = UIFont.font(ofSize: size, bold: bold)
        if (italic) {
            let fontName = "Helvetica-Nenu"
            let x = tanh(CGFloat.pi / 180 * 15)
            let matrix = CGAffineTransform(a: 1, b: 0, c: x, d: 1, tx: 0, ty: 0)
            let desc = UIFontDescriptor(name: fontName, matrix: matrix)
            font = UIFont(descriptor: desc, size: size)
        }
        return [NSAttributedStringKey.font : font,
                NSAttributedStringKey.foregroundColor : textColor,
                NSAttributedStringKey.backgroundColor : backgroundColor,
                NSAttributedStringKey.strikethroughStyle : NSNumber(value: deletionLine ? NSUnderlineStyle.styleSingle.rawValue :  NSUnderlineStyle.styleNone.rawValue),
                NSAttributedStringKey.strikethroughColor : textColor
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
}

struct MarkdownHighlightManager {
            
    let syntaxArray: [Syntax] = [
        Syntax("^#{1,6} .*", .anchorsMatchLines) {
            $0.bold = true
            $0.textColor = rgb(89,89,184)
        },//header
        Syntax(".*\\n==+[(\\s)|=]+") {
            $0.bold = true
            $0.textColor = rgb(89,89,184)
        },//Title1
        Syntax(".*\\n--+[(\\s)|-]+") {
            $0.bold = true
            $0.textColor = rgb(89,89,184)
        },//Title2
        Syntax("^[\\s]*(-|\\*|\\+|([0-9]+\\.)) ", .anchorsMatchLines){
            $0.textColor = rgb(236,90,103)
        },//Lists
        Syntax("- \\[( |x)\\] .*",.anchorsMatchLines){
            $0.textColor = rgb(6,82,120)
        },//TodoList
        Syntax("(\\[.+\\]\\([^\\)]+\\))|(<.+>)") {
            $0.textColor = rgb(66,110,179)
        },//Links
        Syntax("!\\[[^\\]]+\\]\\([^\\)]+\\)") {
            $0.textColor = rgb(50,90,170)
        },//Images
        Syntax("(\\*|_)([^*\\n]+?)(\\*|_)") {
            $0.textColor = Configure.shared.theme.value == .black ? rgb(210,200,190) : rgb(23,27,33)
            $0.italic = true
        },//Emphasis
        Syntax("(\\*\\*|__)([^*\\n]+?)(\\*\\*|__)") {
            $0.textColor = Configure.shared.theme.value == .black ? rgb(210,200,190) : rgb(23,27,33)
            $0.bold = true
        },//Bold
        Syntax("~~\\S([^~\\n]+?)~~") {
            $0.textColor = rgb(129,140,140)
            $0.deletionLine = true
        },//Deletions
        Syntax("==\\S([^=\\n]+?)==") {
            $0.backgroundColor = rgb(240,240,10)
        },//Highlight
        Syntax("\\$([^`\\n\\$]+?)\\$") {
            $0.textColor = rgb(139,69,19)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
        },//数学公式
        Syntax("\\$\\$([^`\\$]+?)[\\s\\S]*?\\$\\$",.anchorsMatchLines) {
            $0.textColor = rgb(139,69,19)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
        },//多行数学公式
        Syntax("\\:\\\"(.*?)\\\"\\:"),//Quotes
        Syntax("`{1,2}[^`](.*?)`{1,2}") {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
            $0.size = 17
        },//InlineCode
        Syntax("^[ \\t]*(\\>)(.*)\n",.anchorsMatchLines) {
            $0.textColor = rgb(129,140,140)
        },//Blockquotes://引用块
        Syntax("^[-\\+\\*]{3,}\n", .anchorsMatchLines){
            $0.bold = true
            $0.textColor = rgb(89,89,184)
        },//Separate://分割线
        Syntax("^[ \\t]*\\n```([\\s\\S]*?)```[\\s]?",.anchorsMatchLines) {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
            $0.size = 17
        },//CodeBlock```包围的代码块
        Syntax("^[ \\t]*(\\n( {4}|\\t).+)+[\\s]?",.anchorsMatchLines) {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
            $0.size = 17
        },//ImplicitCodeBlock4个缩进也算代码块
    ]

    func highlight(_ text: String) -> NSAttributedString {
        let nomarlColor = Configure.shared.theme.value == .black ? rgb(180,180,170) : rgb(53,57,63)
        let result = NSMutableAttributedString(string: text)
        result.addAttributes([NSAttributedStringKey.font : UIFont.font(ofSize:17),
                              NSAttributedStringKey.foregroundColor : nomarlColor], range: range(0,text.length))
        syntaxArray.forEach { (syntax) in
            syntax.expression.enumerateMatches(in: text, options: .reportCompletion, range: range(0, text.length), using: { (match, _, _) in
                if let range = match?.range {
                    result.addAttributes(syntax.style.attrs, range: range)
                }
            })
        }
        return result
    }
}
