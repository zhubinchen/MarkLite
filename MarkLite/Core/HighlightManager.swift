//
//  Syntax.swift
//  Markdown
//
//  Created by zhubch on 2017/7/1.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

let paragraphStyle = { () -> NSMutableParagraphStyle in
    let paraStyle = NSMutableParagraphStyle()
    paraStyle.maximumLineHeight = 23
    paraStyle.minimumLineHeight = 23
    paraStyle.lineSpacing = 3
    return paraStyle
}()

class HighlightStyle {
    static var boldFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(Configure.shared.fontSize.value), weight: UIFont.Weight.medium)
    static var normalFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(Configure.shared.fontSize.value), weight: UIFont.Weight.regular)
    
    var textColor: UIColor = Configure.shared.theme.value == .black ? rgb(200,200,190) : rgb(54,54,64)
    var backgroundColor: UIColor = .clear
    var italic: Bool = false
    var bold: Bool = false
    var deletionLine: Bool = false

    var attrs: [NSAttributedStringKey : Any] {
        
        return [NSAttributedStringKey.font : bold ? HighlightStyle.boldFont : HighlightStyle.normalFont,
                NSAttributedStringKey.obliqueness : italic ? 0.3 : 0,
                NSAttributedStringKey.foregroundColor : textColor,
                NSAttributedStringKey.backgroundColor : backgroundColor,
                NSAttributedStringKey.strikethroughStyle : deletionLine ? NSUnderlineStyle.styleSingle.rawValue :  NSUnderlineStyle.styleNone.rawValue,
                NSAttributedStringKey.strikethroughColor : textColor,
                NSAttributedStringKey.paragraphStyle : paragraphStyle
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
        Syntax("^.*\\n={2,}$", .anchorsMatchLines) {
            $0.bold = true
            $0.textColor = rgb(89,89,184)
        },//Title1
        Syntax("^.*\\n-{2,}$", .anchorsMatchLines) {
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
        Syntax("(\\*|_)[^*`\\n\\s]([^*`\\n]*)(\\*|_)") {
            $0.textColor = Configure.shared.theme.value == .black ? rgb(210,200,190) : rgb(23,27,33)
            $0.italic = true
        },//Emphasis
        Syntax("(\\*\\*|__)[^*`\\n\\s]([^*`\\n]*)(\\*\\*|__)") {
            $0.textColor = Configure.shared.theme.value == .black ? rgb(210,200,190) : rgb(23,27,33)
            $0.bold = true
        },//Bold
        Syntax("~~[^~`\\n\\s]([^~`\\n]*)~~") {
            $0.textColor = rgb(129,140,140)
            $0.deletionLine = true
        },//Deletions
        Syntax("==[^=`\\n\\s]([^=`\\n]*)==") {
            $0.textColor = rgb(54,54,64)
            $0.backgroundColor = rgb(240,240,20)
        },//Highlight
        Syntax("\\$([^`\\n\\$]+)\\$") {
            $0.textColor = rgb(139,69,19)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
        },//数学公式
        Syntax("\\$\\$([^`\\$]+?)[\\s\\S]*?\\$\\$[\\s]?",.anchorsMatchLines) {
            $0.textColor = rgb(139,69,19)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
        },//多行数学公式
        Syntax("\\:\\\"(.*?)\\\"\\:"),//Quotes
        Syntax("`{1,2}[^`](.*?)`{1,2}") {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
        },//InlineCode
        Syntax("^[ \\t]*(\\>)(.*)\n",.anchorsMatchLines) {
            $0.textColor = rgb(129,140,140)
        },//Blockquotes://引用块
        Syntax("^([-\\+\\*]\\s?){3,}\n", .anchorsMatchLines){
            $0.bold = true
            $0.textColor = rgb(89,89,184)
        },//Separate://分割线
        Syntax("^[ \\t]*\\n```([\\s\\S]*?)```[\\s]?",.anchorsMatchLines) {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
        },//CodeBlock```包围的代码块
        Syntax("^[ \\t]*(\\n( {4}|\\t).+)+[\\s]?",.anchorsMatchLines) {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
        },//ImplicitCodeBlock4个缩进也算代码块
    ]

    func highlight(_ text: NSTextStorage, visibleRange: NSRange?) {
        let len = (text.string as NSString).length
        var validRange = NSMakeRange(0, len)
        if let visibleRange = visibleRange  {
            let begin = max(visibleRange.location - visibleRange.length * 2, 0)
            let end = min(visibleRange.location + visibleRange.length * 3, len)
            validRange.location = begin
            validRange.length = end - begin
        }
        
        let nomarlColor = Configure.shared.theme.value == .black ? rgb(160,160,160) : rgb(54,54,64)

        text.setAttributes([NSAttributedStringKey.font : HighlightStyle.normalFont,
                              NSAttributedStringKey.paragraphStyle : paragraphStyle,
                              NSAttributedStringKey.foregroundColor : nomarlColor], range: validRange)
        syntaxArray.forEach { (syntax) in
            syntax.expression.enumerateMatches(in: text.string, options: .reportCompletion, range: validRange, using: { (match, _, _) in
                if let range = match?.range {
                    text.addAttributes(syntax.style.attrs, range: range)
                }
            })
        }
    }
}
