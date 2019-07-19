//
//  CLAfter_Time.swift
//  Sport-Swift
//
//  Created by 夜猫子 on 2017/5/17.
//  Copyright © 2017年 夜猫子. All rights reserved.
//

import UIKit

//MARK: - 延迟执行的全局的方法
/// 延迟执行的方法
///
/// - Parameters:
///   - seconds: 秒数
///   - afterToDo: 需要延迟执行的闭包(就是需要延迟执行的那件事)
func after(_ seconds: Int, _ afterToDo: @escaping ()->()) {
    let deadlineTime = DispatchTime.now() + .seconds(seconds)
    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        afterToDo()
    }
}

