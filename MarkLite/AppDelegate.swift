//
//  AppDelegate.swift
//  Markdown
//
//  Created by zhubch on 2017/6/20.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SideMenu
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIView.initializeOnceMethod()
        UMConfigure.initWithAppkey(umengKey, channel: "App Store")
        setup()

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if FileManager.default.fileExists(atPath: url.path) {
            let oldPath = url.path
            let fileName = oldPath.components(separatedBy: "/").last ?? /"Untitled"
            let recievedPath = documentPath + "/" + /"ReceivedFiles"
            let newPath = recievedPath + "/" + fileName
            if oldPath.contains(documentPath) {
                return true
            }
            do {
                try FileManager.default.createDirectory(atPath: recievedPath, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.moveItem(atPath: oldPath, toPath: newPath)
                RecievedNewFile.post(info: newPath)
            } catch {
                print(error.localizedDescription)
            }
        }
        return true
    }
    

    func applicationDidEnterBackground(_ application: UIApplication) {
        ApplicationWillTerminate.post(info: nil)
        Configure.shared.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        ApplicationWillTerminate.post(info: nil)
        Configure.shared.save()
    }
    
    func setup() {
        let navigationBar = UINavigationBar.appearance()
        
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage(color: .clear, size: CGSize(width: 1000, height: 64))
        let backImage = #imageLiteral(resourceName: "nav_back")
        
        navigationBar.backIndicatorImage = backImage
        navigationBar.backIndicatorTransitionMaskImage = backImage
        
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuWidth = isPad ? 400 : 300
        SideMenuManager.default.menuPushStyle = .subMenu
        SideMenuManager.default.menuPresentMode = isPhone ? .viewSlideOut : .menuSlideIn

        Configure.shared.setup()
        
        _ = Configure.shared.theme.asObservable().subscribe(onNext: { (theme) in
            ColorCenter.shared.theme = theme
        })
        
        _ = Observable.combineLatest(Configure.shared.theme.asObservable(), Configure.shared.isLandscape.asObservable()){ $0 == .black || ($0 != .white && !$1) }.subscribe(onNext: { (light) in
            UIApplication.shared.statusBarStyle = light ? .lightContent : .default
        })
    }
}

