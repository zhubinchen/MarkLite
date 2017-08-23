//
//  AppDelegate.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/20.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SideMenu
import RxSwift
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setup()
        checkVersion()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
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
    
    func checkVersion() {

        let url = URL(string: checkVersionUrl)
        guard let data = try? Data(contentsOf: url!),
            let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
            let dict = json as? Dictionary<String, Any> else { return }
        
        var latestVersion = "1.0"
        
        guard let resultArray = dict["results"] as? Array<Dictionary<String, Any>> else { return }
        for config in resultArray {
            latestVersion = config["version"] as? String ?? ""
        }
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        if latestVersion != currentVersion {
            Configure.shared.newVersionAvaliable = true
        }
    }
    
    func setup() {
        let navigationBar = UINavigationBar.appearance()
        
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage(color: .clear, size: CGSize(width: 1000, height: 64))
        let backImage = #imageLiteral(resourceName: "nav_back")
        
        navigationBar.backIndicatorImage = backImage
        navigationBar.backIndicatorTransitionMaskImage = backImage
        
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuWidth = isPad ? 400 : 300
        SideMenuManager.menuPushStyle = .subMenu
        SideMenuManager.menuPresentMode = isPhone ? .viewSlideOut : .menuSlideIn
        DropboxClientsManager.setupWithAppKey(dropboxKey)

        Configure.shared.setup()
        
        _ = Configure.shared.theme.asObservable().subscribe(onNext: { (theme) in
            ColorCenter.shared.theme = theme
        })
        
        _ = Observable.combineLatest(Configure.shared.theme.asObservable(), Configure.shared.isLandscape.asObservable()){ $0 == .black || ($0 != .white && !$1) }.subscribe(onNext: { (light) in
            UIApplication.shared.statusBarStyle = light ? .lightContent : .default
        })
    }
}

