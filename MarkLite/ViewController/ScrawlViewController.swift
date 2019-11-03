//
//  ScrawlViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/11/2.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class ScrawlViewController: UIViewController, DrawViewDelegate {
    
    let drawView = DrawView()
    
    let undoButton = UIButton(type: .system)
    let redoButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        view.setBackgroundColor(.background)
        view.setTintColor(.tint)
        
        drawView.layer.borderWidth = 1
        drawView.delegate = self
        self.view.addSubview(drawView)
        
        drawView.snp.makeConstraints { maker in
            maker.top.left.right.bottom.equalTo(0)
        }
        
        undoButton.setTitle(/"Undo", for: .normal)
        redoButton.setTitle(/"Redo", for: .normal)
        self.view.addSubview(undoButton)
        self.view.addSubview(redoButton)
        
        redoButton.snp.makeConstraints { maker in
            maker.bottom.right.equalTo(0)
        }
        undoButton.snp.makeConstraints { maker in
            maker.bottom.equalTo(0)
            maker.right.equalTo(undoButton.left)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
    }
    
    @objc func close() {
        impactIfAllow()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func didBeginDraw() {
        redoButton.isEnabled = false
        undoButton.isEnabled = true
    }
    
    @objc func undo() {
        redoButton.isEnabled = true
        undoButton.isEnabled = self.drawView.backToLastStep()
    }
    
    @objc func redo() {
        undoButton.isEnabled = true
        redoButton.isEnabled = self.drawView.forwardNextStep()
    }
}
