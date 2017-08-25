
//
//  EventBus.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/22.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

public protocol EventBus {
    associatedtype InfoType
    static var name: Notification.Name { get }
    static var infoKey: String { get }
    static func observe(eventBlock: @escaping (InfoType) -> ()) -> Any
    static func post(info: InfoType?)
}

extension EventBus {
    static var infoKey: String {
        return "infoKey"
    }
    
    @discardableResult static func observe(eventBlock: @escaping (InfoType) -> ()) -> Any {
        return NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { notification in
            if let userInfo = notification.userInfo {
                eventBlock((userInfo[infoKey] as? InfoType)!)
            }
        }
    }
    
    static func removeObserver(_ ob: Any) {
        NotificationCenter.default.removeObserver(ob)
    }
    
    static func post(info: InfoType? = nil) {
        let userInfo: [AnyHashable : Any] = [infoKey : info ?? ""]
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
}

class ApplicationWillTerminate: EventBus{
    
    typealias InfoType = Void
    static var name = Notification.Name("ApplicationWillTerminate")
}

class RecievedNewFile: EventBus{
    
    typealias InfoType = String
    static var name = Notification.Name("RecievedNewFile")
}
