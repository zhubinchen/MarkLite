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
import Alamofire
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate!

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.shared = self
        #if DEBUG

        #else
            UMConfigure.initWithAppkey(umengKey, channel: "App Store")
            Bugly.start(withAppId: buglyId)
        #endif
        
        UIView.initializeOnceMethod()
        initialFolders()
        checkAppStore()
        setup()
        MDURLProtocol.startRegister()
        _ = IAPHelper.sharedInstance
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var fileURL = url
        if url.path.contains(inboxPath) {
            let fileName = url.lastPathComponent
            let newPath = documentPath + "/" + fileName
            let newURL = URL(fileURLWithPath: newPath.validPath)
            try! FileManager.default.moveItem(at: url, to: newURL)
            fileURL = newURL
        }
        if window?.rootViewController?.isViewLoaded ?? false {
            NotificationCenter.default.post(name: Notification.Name("RecievedNewFile"), object: fileURL)
        } else {
            Timer.runThisAfterDelay(seconds: 0.5) {
                NotificationCenter.default.post(name: Notification.Name("RecievedNewFile"), object: fileURL)
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
    
    func initialFolders() {
        try? FileManager.default.createDirectory(atPath: externalPath, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: locationPath, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.removeItem(atPath: tempPath)
        try? FileManager.default.createDirectory(atPath: tempPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    func setup() {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.isTranslucent = false
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        SVProgressHUD.setMaximumDismissTimeInterval(3)
        SVProgressHUD.setDefaultMaskType(.clear)
        Configure.shared.setup()
        
        _ = Configure.shared.theme.asObservable().subscribe(onNext: { (theme) in
            ColorCenter.shared.theme = theme
            UIApplication.shared.statusBarStyle = theme == .white ? .default : .lightContent
            if theme == .black {
                if Configure.shared.markdownStyle.value == "GitHub" {
                    Configure.shared.markdownStyle.value = "GitHub Dark"
                }
                if Configure.shared.markdownStyle.value == "tomorrow" {
                    Configure.shared.highlightStyle.value = "tomorrow-night"
                }
            } else {
                if Configure.shared.markdownStyle.value == "GitHub Dark" {
                    Configure.shared.markdownStyle.value = "GitHub"
                }
                if Configure.shared.markdownStyle.value == "tomorrow-night" {
                    Configure.shared.markdownStyle.value = "tomorrow"
                }
            }
        })
        
        _ = Configure.shared.darkOption.asObservable().subscribe(onNext: { (darkOption) in
            switch darkOption {
                case .dark:
                    Configure.shared.theme.value = .black
                case .light:
                    if Configure.shared.theme.value == .black {
                        Configure.shared.theme.value = .white
                    }
                case .system:
                    if #available(iOS 13.0, *) {
                        if UITraitCollection.current.userInterfaceStyle == .dark {
                            Configure.shared.theme.value = .black
                        } else if Configure.shared.theme.value == .black {
                            Configure.shared.theme.value = .white
                        }
                    } else {
                        SVProgressHUD.showError(withStatus: "Only Work on iPad OS / iOS 13")
                    }
            }
        })
        
        if #available(iOS 10.3, *) {
            let interval = Date().timeIntervalSince(Configure.shared.rateAlertDate)
            if interval > 3600 * 24 * 20 {
                Configure.shared.rateAlertDate = Date()
                Timer.runThisAfterDelay(seconds: 10) {
                    SKStoreReviewController.requestReview()
                }
            }
        }
    }
    
    private func checkAppStore() {
        var localizations = ""
        if Bundle.main.preferredLocalizations.first == "zh-Hans" {
            localizations = "cn/"
        }
        guard let url = try? "https://itunes.apple.com/\(localizations)lookup?id=\(appID)".asURL() else {
            return
        }
        request(url).responseJSON { response in
//            print(response.result.value ?? "")
            if let dic = response.result.value as? [String:Any] {
                self.showNewVersionAlert(requestData: dic)
            }
        }
    }
    
    private func showNewVersionAlert(requestData : [String:Any]) {
        guard let resultsDic = (requestData["results"] as? [Any])?.first as? [String:Any] else { return }
        let version = resultsDic["version"] as! NSString
        let oldVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! NSString
        
        guard let versionInt = Int(version.replacingOccurrences(of: ".", with: "")), let oldVersionInt = Int(oldVersion.replacingOccurrences(of: ".", with: "")) else {
            return
        }
        
        if oldVersionInt >= versionInt {
            return
        }
        
        let trackName = resultsDic["trackName"] as! String
        let trackViewUrl = resultsDic["trackViewUrl"] as! String
        let releaseNotes = resultsDic["releaseNotes"] as! String
        
        if !releaseNotes.hasPrefix("#") {
            return
        }
        
        let alert = UIAlertController(title: trackName, message: releaseNotes, preferredStyle: UIAlertControllerStyle.alert)
        let ation = UIAlertAction(title: /"Cancel", style: UIAlertActionStyle.default) { (at) in
            
        }
        let ation1 = UIAlertAction(title: /"Upgrade", style: UIAlertActionStyle.default) { (at) in
            let url = URL(string: trackViewUrl)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        alert.addAction(ation)
        alert.addAction(ation1)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
