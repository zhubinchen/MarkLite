//
//  KeyboardBarViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/10/30.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class KeyboardBarViewController: UIViewController {
    
    var buttons = [UIButton]()
    
    var last = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        
        view.setBackgroundColor(.background)
        
        setupUI()
    }
    
    func setupUI() {
        let items = KeyboardBar().items
        let totalWidth = view.w - 32.0
        let row = Int(totalWidth / 60)
        let w = totalWidth / CGFloat(row)
        let x = 16 + w * 0.1
        items.forEachEnumerated { (index, item) in
            let button = UIButton(type: .system)
            button.tintColor = .gray
            button.setBackgroundColor(.tableBackground)
            button.cornerRadius = 8
            _ = button.rx.observe(Int.self, "tag").subscribe(onNext: { i in
                UIView.animate(withDuration: 0.5) {
                    button.frame = CGRect(x: CGFloat(i! % row) * w + x, y: CGFloat(i! / row) * w + 60, w: w * 0.8, h: w * 0.8)
                }
                button.setTitle("\(i ?? 0)", for: .normal)
            })
            button.tag = index
            self.view.addSubview(button)
            self.buttons.append(button)
            let ges = UIPanGestureRecognizer(target: self, action: #selector(self.move(_:)))
            button.addGestureRecognizer(ges)
        }
    }
    
    @objc func move(_ ges: UIPanGestureRecognizer!) {
        guard let v = ges.view else { return }
        
        let totalWidth = view.w - 32.0
        let row = Int(totalWidth / 60)
        let w = totalWidth / CGFloat(row)
        let x = 16 + w * 0.1
        
        let trans = ges.translation(in: v)
        v.x = min(totalWidth, max(v.x + trans.x,16))
        v.y = min(CGFloat(buttons.count / row + 1) * w + 60, max(v.y + trans.y,60))
        ges.setTranslation(CGPoint(), in: v)

        let index = Int((v.x - x) / w + (v.y - 60.0) / w * CGFloat(row))
        print(index)
        if ges.state == .began {
            last = index
            buttons.remove(at: index)
        }
        if index < last {
            for i in index..<last {
                buttons[i].tag = buttons[i].tag + 1
            }
            last = index
        } else if index > last{
            for i in last..<index {
                buttons[i].tag = buttons[i].tag - 1
            }
            last = index
        }
        if ges.state == .cancelled || ges.state == .ended {
            v.tag = index
            buttons.append(v as! UIButton)
            buttons.sort{ $0.tag < $1.tag }
        }
    }
}
