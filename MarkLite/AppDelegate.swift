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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIView.initializeOnceMethod()
        UMConfigure.initWithAppkey(umengKey, channel: "App Store")
        Bugly.start(withAppId: buglyId)
        setup()
        
        try? FileManager.default.createDirectory(atPath: inboxPath, withIntermediateDirectories: true, attributes: nil)
        _ = IAPHelper.sharedInstance
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
        
        loadData()
    }
    
    private func loadData() {
        guard let url = try? "http://itunes.apple.com/cn/lookup?id=\(appID)".asURL() else {
            return
        }
        request(url).responseJSON { response in
            print(response.result.value ?? "")
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
        
        let alert = UIAlertController(title: trackName, message: releaseNotes, preferredStyle: UIAlertControllerStyle.alert)
        let ation = UIAlertAction(title: /"Cancel", style: UIAlertActionStyle.default) { (at) in
            
        }
        let ation1 = UIAlertAction(title: /"Upgrade", style: UIAlertActionStyle.default) { (at) in
            UIApplication.shared.openURL(NSURL(fileURLWithPath: trackViewUrl) as URL)
        }
        alert.addAction(ation)
        alert.addAction(ation1)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

