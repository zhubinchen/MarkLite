//
//  Syntax.swift
//  Markdown
//
//  Created by zhubch on 2017/7/1.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class HighlightOperation: Operation {
    
    let text: String
    let syntaxArray: [Syntax]
    var result: NSAttributedString?
    
    init(text:String, syntaxArray: [Syntax]) {
        self.text = text
        self.syntaxArray = syntaxArray
    }
    
    override func cancel() {
        super.cancel()
    }
    
    override func main() {
        let nomarlColor = Configure.shared.theme.value == .black ? rgb(180,180,170) : rgb(53,57,63)
        let result = NSMutableAttributedString(string: text)
        result.addAttributes([NSAttributedStringKey.font : UIFont.font(ofSize:17),
                              NSAttributedStringKey.foregroundColor : nomarlColor], range: range(0,text.length))
        if isCancelled {
            return
        }
        syntaxArray.forEach { (syntax) in
            if isCancelled {
                return
            }
            syntax.expression.enumerateMatches(in: text, options: .reportCompletion, range: range(0, text.length), using: { (match, _, stop) in
                if let range = match?.range {
                    result.addAttributes(syntax.style.attrs, range: range)
                }
                if isCancelled {
                    stop.pointee = true
                }
            })
        }
        if isCancelled {
            return
        }
        self.result = result
    }
}

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
    
    let queue = OperationQueue()
    
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
        Syntax("^[\\s]*[-\\*\\+] +", .anchorsMatchLines){
            $0.textColor = rgb(66,110,169)
        },//ULLists://无序列表
        Syntax("^[\\s]*[0-9]+\\.", .anchorsMatchLines){
            $0.textColor = rgb(236,90,103)
        },//OLLists有序列表
        Syntax("- \\[( |x|X)\\] .*",.anchorsMatchLines){
            $0.textColor = rgb(255,0,0)
        },//TodoList
        Syntax("(\\[.+\\]\\([^\\)]+\\))|(<.+>)") {
            $0.textColor = rgb(11,188,214)
        },//Links
        Syntax("!\\[[^\\]]+\\]\\([^\\)]+\\)") {
            $0.textColor = rgb(50,90,160)
        },//Images
        Syntax("(\\*|_)(.+?)\\1") {
            $0.textColor = Configure.shared.theme.value == .black ? rgb(210,200,190) : rgb(23,27,33)
            $0.italic = true
        },//Emphasis
        Syntax("(\\*\\*|__)(.+?)\\1") {
            $0.textColor = Configure.shared.theme.value == .black ? rgb(210,200,190) : rgb(23,27,33)
            $0.bold = true
        },//Bold
        Syntax("~~(.+?)~~") {
            $0.textColor = rgb(129,140,140)
            $0.deletionLine = true
        },//Deletions
        Syntax("\\$.*\\$") {
            $0.textColor = rgb(139,69,19)
        },//数学公式
        Syntax("\\:\\\"(.*?)\\\"\\:"),//Quotes
        Syntax("`{1,2}[^`](.*?)`{1,2}") {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
            $0.size = 16
        },//InlineCode
        Syntax("^(\\>)(.*)\n",.anchorsMatchLines) {
            $0.textColor = rgb(129,140,140)
        },//Blockquotes://引用块
        Syntax("^-+$", .anchorsMatchLines){
            $0.textColor = rgb(129,140,140)
        },//Separate://分割线
        Syntax("```([\\s\\S]*?)```[\\s]?") {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
            $0.size = 16
        },//CodeBlock```包围的代码块
        Syntax("^\n[\\f\\r\\t\\v]*(( {4}|\\t).*(\\n|\\z))+", .anchorsMatchLines) {
            $0.textColor = rgb(71,91,98)
            $0.backgroundColor = Configure.shared.theme.value == .black ? rgb(50,50,50) : rgb(246,246,246)
            $0.size = 16
        },//ImplicitCodeBlock4个缩进也算代码块
    ]

    
    func highlight(_ text: String, completion:@escaping (NSAttributedString)->Void) {
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
        completion(result)
    }
}
