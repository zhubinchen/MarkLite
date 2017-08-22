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
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    
    var webVC: WebViewController?
    var textVC: TextViewController?
    
    var showExport = true
    
    let disposeBag = DisposeBag()
    let titleTextField = UITextField(x: 0, y: 0, w: 100, h: 30)
    
    override var title: String? {
        didSet {
            titleTextField.text = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
            scrollView.panGestureRecognizer.require(toFail: popGestureRecognizer)
        }
        
        scrollView.rx.contentOffset.map{ $0.x > windowWidth - 10 }.subscribe(onNext: { [weak self] showExport in
            self?.toggleBarButton(showExport)
        }).addDisposableTo(disposeBag)
        
        Configure.shared.editingFile.asObservable().map{ $0?.name ?? "" }.bind(to: self.rx.title).addDisposableTo(disposeBag)
        
        Configure.shared.editingFile.value?.readText{ [weak self] text in
            self?.webVC?.text = text
        }
        
        textVC?.textChangedHandler = { [weak self] text in
            self?.webVC?.text = text
        }
        
        textVC?.offsetChangedHandler = { [weak self] offset in
            self?.webVC?.offset = offset
        }
        
        navigationItem.titleView = titleTextField
        titleTextField.font = UIFont.font(ofSize: 18)
        titleTextField.setTextColor(.navBarTint)
        titleTextField.delegate = self
    }
    
    func toggleBarButton(_ showExport: Bool) {
        textVC?.editView.resignFirstResponder()

        if self.showExport == showExport {
            return
        }
        self.showExport = showExport
        if showExport {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "export"), style: .plain, target: self, action: #selector(showExportMenu(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(preview))
        }
    }
    
    func showExportMenu(_ sender: Any) {
        textVC?.editView.resignFirstResponder()
        if isPad && Configure.shared.isLandscape.value == false {
            scrollView.setContentOffset(CGPoint(x:windowWidth , y:0), animated: true)
        }
        
        let items = [ExportType.PDF,.markdown,.html,.image]
        var pos = CGPoint(x: windowWidth - 140, y: 65)
        if let view = sender as? UIView {
            pos = view.origin
            if Configure.shared.isLandscape.value {
                pos.x += 44
            } else {
                pos.y += 44
            }
        }
        MenuView(items: items.map{$0.rawValue},
                 postion: pos) { (index) in
                    guard let url = self.webVC?.url(for: items[index]) else { return }
                    let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    self.presentVC(vc)
            }.show()
    }
    
    func preview() {
        textVC?.editView.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x:windowWidth , y:0), animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TextViewController {
            textVC = vc
        } else if let vc = segue.destination as? WebViewController {
            webVC = vc
        }
    }
    
    override func shouldBack() -> Bool {
        if scrollView.contentOffset.x > 10 {
            scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
            return false
        }
        return true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textViewWidth.constant = windowWidth > windowHeight ? (windowWidth - 64) * 0.5 : windowWidth
    }
    
    deinit {
        print("deinit edit_vc")
    }
}

extension EditViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let file = Configure.shared.editingFile.value else { return }
        let text = textField.text ?? ""
        let name = text.trimmed()
        let pattern = "^[^\\.\\*\\:/]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        if predicate.evaluate(with: name) {
            file.rename(to: name)
            textField.text = file.name
        } else {
            showAlert(title: "请输入正确的文件名")
            textField.text = file.name
        }
    }
}
