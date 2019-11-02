//
//  ExportActivity.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/10/31.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

protocol ExportDataSource {
    func url(for type: ExportType) -> URL?
}

class ExportActivity: UIActivity {
    
    var exportType: ExportType
    var dataSource: ExportDataSource
    
    init(exportType: ExportType, dataSource: ExportDataSource) {
        self.exportType = exportType
        self.dataSource = dataSource
        super.init()
    }
    
    override var activityType: UIActivityType? {
        return nil
    }
    
    override var activityTitle: String? {
        return exportType.displayName
    }
    
    override var activityImage: UIImage? {
        return nil
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        
    }
    
    override func perform() {

    }
    
    override func activityDidFinish(_ completed: Bool) {
        
    }
    
    override var activityViewController: UIViewController? {
        return nil
    }

}
