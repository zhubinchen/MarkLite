//
//  ServerInfo.swift
//  Markdown
//
//  Created by 朱炳程 on 2020/2/24.
//  Copyright © 2020 zhubch. All rights reserved.
//

import UIKit

class ServerInfo {
    
    var user: String

    var password: String
    
    var url: String
    
    init(url:String,user:String,password:String) {
        self.url = url
        self.user = user
        self.password = password
    }
}
