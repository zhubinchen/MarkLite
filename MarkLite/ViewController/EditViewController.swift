//
//  EditViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
            scrollView.panGestureRecognizer.require(toFail: popGestureRecognizer)
        }
        Configure.shared.currentFile.asObservable().map{$0?.name ?? ""}.bind(to: self.rx.title).addDisposableTo(disposeBag)
    }
    
    @IBAction func export(_ sender: UIButton) {
        let items = ["PDF","图片","markdown","html"]
        let pos = CGPoint(x: windowWidth - 140, y: 65)
        MenuView(items: items,
                 postion: pos) { (index) in
                    //
            }.show()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TextViewController {
            vc.previewHandler = { [unowned self] _ in
                self.scrollView.setContentOffset(CGPoint(x:windowWidth , y:0), animated: true)
            }
        }
    }
    
    override func shouldBack() -> Bool {
        if scrollView.contentOffset.x > 10 {
            scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
            return false
        }
        return true
    }
}
