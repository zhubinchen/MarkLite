//
//  Configure.swift
//  MarkLite
//
//  Created by zhubch on 2017/7/1.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

let defaultConfigure = Configure()

class Configure: NSObject {
    let currentFile: Variable<File?> = Variable(nil)
}
