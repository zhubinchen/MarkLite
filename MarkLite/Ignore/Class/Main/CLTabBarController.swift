//
//  CLTabBarController.swift
//  Sport-Swift
//
//  Created by 夜猫子 on 2017/5/10.
//  Copyright © 2017年 夜猫子. All rights reserved.
//

import UIKit

class CLTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.selectedIndex = 2
    }
    
}


// MARK: - 页面设置
extension CLTabBarController {
    
    fileprivate func setupUI() {
        //添加子控制器
        addChildViewControllers()
        //添加新特性
        addNewFratureAndWelcome()
    }
    
    /// 添加新特性页面和欢迎页面
    fileprivate func addNewFratureAndWelcome() {
        //取到版本号是否改变
        let isNewFeature = Bundle.main.isNewFeature
        if isNewFeature == true {
            let arr = ["1","2","3","4"]
            let newFeaure = CLNewFeatureView(imageNameArr: arr)
            self.view.addSubview(newFeaure)
        }

        
    }
    
    /// 添加子控制器
    fileprivate func addChildViewControllers() {
        if let url = Bundle.main.url(forResource: "main.json", withExtension: nil),
            let jsonData = try? Data(contentsOf: url),
            let objcet = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let dicArr = objcet as? [[String : Any]] {
            var controllers : [CLNavigationVC] = []
            for dict in dicArr {
                
                let nav = generateChileConteoller(dict: dict)
                controllers.append(nav!)
            }
            viewControllers = controllers
        }
        
    }
    
    fileprivate func generateChileConteoller(dict:[String:Any]) -> CLNavigationVC? {
        
        if let clsName = dict["clsName"] {
            let className = "SportSwift" + "." + "\(clsName as! String)"
            if let classVC = NSClassFromString(className) as? CLBaseVC.Type {
                
                let controller = classVC.init()
                controller.title = dict["title"] as? String
                controller.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : tabBarColor], for: .normal)
                controller.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : tabBarColor], for: .selected)
                controller.tabBarItem.image = UIImage(named: "ic_tab_\(dict["imageName"]!)_normal_22x22_")?.withRenderingMode(.alwaysOriginal)
                controller.tabBarItem.selectedImage = UIImage(named: "ic_tab_\(dict["imageName"]!)_selected_22x22_")?.withRenderingMode(.alwaysOriginal)
                
                let navController = CLNavigationVC(rootViewController: controller)
                return navController
            }
        }
        return nil
    }
    
    
}
