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

    var textVC: TextViewController!
    var webVC: WebViewController!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer else {
            return
        }
        scrollView.panGestureRecognizer.require(toFail: popGestureRecognizer)
    }
    
    @IBAction func preview(_ sender: Any) {
        scrollView.setContentOffset(CGPoint(x: windowWidth,y: 0) , animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ConfigureViewController {
            vc.preferredContentSize = CGSize(width: 200, height: 300)
        } else if let vc = segue.destination as? TextViewController {
            textVC = vc
        } else if let vc = segue.destination as? WebViewController {
            webVC = vc
        }
    }
}
