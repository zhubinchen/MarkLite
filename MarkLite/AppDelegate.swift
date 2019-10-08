//
//  AppDelegate.swift
//  Markdown
//
//  Created by zhubch on 2017/6/20.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIView.initializeOnceMethod()
        UMConfigure.initWithAppkey(umengKey, channel: "App Store")
        Bugly.start(withAppId: buglyId)
        setup()
        
        try? FileManager.default.createDirectory(atPath: inboxPath, withIntermediateDirectories: true, attributes: nil)
    
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        if url.startAccessingSecurityScopedResource() && FileManager.default.fileExists(atPath: url.path) {
            let oldPath = url.path
            let fileName = oldPath.components(separatedBy: "/").last ?? /"Untitled"
            let newPath = inboxPath + "/" + fileName
            if oldPath.contains(documentPath) {
                return true
            }
            do {
                try FileManager.default.moveItem(atPath: oldPath, toPath: newPath)
                RecievedNewFile.post(info: newPath)
            } catch {
                print(error.localizedDescription)
            }
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Configure.shared.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Configure.shared.save()
    }
    
    func setup() {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.isTranslucent = false
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        }
        Configure.shared.setup()
        
        _ = Configure.shared.theme.asObservable().subscribe(onNext: { (theme) in
            ColorCenter.shared.theme = theme
            UIApplication.shared.statusBarStyle = theme == .black ? .lightContent : .default
        })
    }
    
}

