//
//  EditViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import StoreKit
class EditViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    
    var webVC: WebViewController?
    var textVC: TextViewController?
    
    var showExport = true
    
    let bag = DisposeBag()
    let titleTextField = UITextField(x: 0, y: 0, w: 100, h: 30)
    let renderer = MarkdownRender.shared()
    
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
        }).disposed(by: bag)
        
        Configure.shared.editingFile.asObservable().map{ $0?.name ?? "" }.bind(to: self.rx.title).disposed(by: bag)
        
        textVC?.textChangedHandler = { [weak self] text in
            self?.webVC?.htmlString = self?.renderer?.renderMarkdown(text) ?? ""
        }
        
        textVC?.offsetChangedHandler = { [weak self] offset in
            self?.webVC?.offset = offset
        }
        
        navigationItem.titleView = titleTextField
        titleTextField.font = UIFont.font(ofSize: 18)
        titleTextField.textAlignment = .center
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
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: /"Preview", style: .plain, target: self, action: #selector(preview))
        }
    }
    
    @objc func showExportMenu(_ sender: Any) {
        textVC?.editView.resignFirstResponder()
        if isPad && Configure.shared.isLandscape.value == false {
            scrollView.setContentOffset(CGPoint(x:windowWidth , y:0), animated: true)
        }
        
        let items = [ExportType.markdown,.pdf,.html,.image]
        var pos = CGPoint(x: windowWidth - 140, y: 65)
        if let view = sender as? UIView {
            pos = view.origin
            if Configure.shared.isLandscape.value {
                pos.x += 44
            } else {
                pos.y += 44
            }
        }
        
        func export(_ index: Int) {
            guard let url = self.webVC?.url(for: items[index]) else { return }
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            vc.popoverPresentationController?.sourceView = sender as? UIView
            vc.popoverPresentationController?.sourceRect = (sender as? UIView)?.frame ?? CGRect(x: 62, y: 20, w: 44, h: 44)
            self.presentVC(vc)
        }
        
        MenuView(items: items.map{$0.displayName},
                 postion: pos) { (index) in
                    if index > 0 {
                        self.doIfPro {
                            export(index)
                        }
                    } else {
                        export(index)
                    }
            }.show()
    }
    
    @objc func preview() {
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
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
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

extension EditViewController: MPRendererDelegate,MPRendererDataSource {
    func rendererExtensions(_ renderer: MPRenderer!) -> Int32 {
        return MPPreferences.sharedInstance().extensionFlags
    }

    func rendererHasSmartyPants(_ renderer: MPRenderer!) -> Bool {
        return MPPreferences.sharedInstance().extensionSmartyPants
    }

    func rendererRendersTOC(_ renderer: MPRenderer!) -> Bool {
        return MPPreferences.sharedInstance().htmlRendersTOC
    }

    func rendererStyleName(_ renderer: MPRenderer!) -> String! {
        let name = Configure.shared.markdownStyle.value
        let path = stylePath + "/Styles/" + name + ".css"
        return path
    }

    func rendererDetectsFrontMatter(_ renderer: MPRenderer!) -> Bool {
        return MPPreferences.sharedInstance().htmlDetectFrontMatter
    }

    func rendererHasSyntaxHighlighting(_ renderer: MPRenderer!) -> Bool {
        return MPPreferences.sharedInstance().extensionHighlight
    }

    func rendererHasMermaid(_ renderer: MPRenderer!) -> Bool {
        return MPPreferences.sharedInstance().htmlMermaid
    }

    func rendererHasGraphviz(_ renderer: MPRenderer!) -> Bool {
        return MPPreferences.sharedInstance().htmlGraphviz
    }

    func rendererCodeBlockAccesory(_ renderer: MPRenderer!) -> MPCodeBlockAccessoryType {
        return MPCodeBlockAccessoryType(rawValue: UInt(MPPreferences.sharedInstance().htmlCodeBlockAccessory))!
    }

    func rendererHasMathJax(_ renderer: MPRenderer!) -> Bool {
        return MPPreferences.sharedInstance().htmlMathJax
    }

    func rendererHighlightingThemeName(_ renderer: MPRenderer!) -> String! {
        let name = Configure.shared.highlightStyle.value
        let path = stylePath + "/Highlight/highlight-style/" + name + ".css"
        return path
    }

    func renderer(_ renderer: MPRenderer!, didProduceHTMLOutput html: String!) {
        self.webVC?.htmlString = html
        print(html)
    }

    func rendererLoading() -> Bool {
        return false
    }

    func rendererMarkdown(_ renderer: MPRenderer!) -> String! {
        return self.textVC?.editView.text
    }

    func rendererHTMLTitle(_ renderer: MPRenderer!) -> String! {
        return self.titleTextField.text
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
            showAlert(title: /"FileNameError")
            textField.text = file.name
        }
    }
}
