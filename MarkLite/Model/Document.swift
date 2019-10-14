//
//  Document.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/10/4.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    var text = ""

    override func contents(forType typeName: String) throws -> Any {
        return text.data(using: .utf8) ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            text = String(data: data, encoding: .utf8) ?? ""
        }
    }
}
