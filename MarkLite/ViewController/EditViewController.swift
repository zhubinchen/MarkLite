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

enum ExportType: String {
    case pdf
    case html
    case image
    case markdown
    
    var displayName: String {
        switch self {
        case .pdf:
            return /"PDF"
        case .html:
            return /"WebPage"
        case .image:
            return /"Image"
        default:
            return /"Markdown"
        }
    }
}

class EditViewController: UIViewController, UIScrollViewDelegate,UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet var textViewWidth: NSLayoutConstraint!
    
    var file: File? {
        didSet {
            title = file?.displayName ?? file?.name
            setup()
        }
    }
    
    var landscape: Bool {
        return windowWidth > windowHeight * 0.8
    }
    
    var split: Bool {
        if Configure.shared.splitOption.value == .always {
            return true
        }
        if Configure.shared.splitOption.value == .never {
            return false
        }
        return self.view.w > self.view.h * 0.6
    }
            
    var previewVC: PreviewViewController!
    var textVC: TextViewController!

    var webVisible = true
    let bag = DisposeBag()
    
    let markdownRenderer = MarkdownRender.shared()
    let highlightmanager = MarkdownHighlightManager()
    let pdfRender = PDFRender()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
                
        if file == nil {
            if landscape == false {
                splitViewController?.preferredDisplayMode = .primaryOverlay
            }
        } else {
            setup()
        }
                
        Configure.shared.splitOption.asObservable().subscribe(onNext: { [unowned self] _ in
            self.textViewWidth.isActive = self.split
            self.textVC.seperator.isHidden = self.split == false
            self.toggleRightBarButton()
        }).disposed(by: bag)
        
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        emptyImageView.tintImage = emptyImageView.image
        emptyImageView.setTintColor(.secondary)
        emptyLabel.setTextColor(.secondary)
        emptyLabel.text = /"NoEditingFile"
        view.setBackgroundColor(.background)
        
        addNotificationObserver(Notification.Name.UIApplicationWillChangeStatusBarOrientation.rawValue, selector: #selector(deviceOrientationWillChange))
        addNotificationObserver(Notification.Name.UIKeyboardWillChangeFrame.rawValue, selector: #selector(keyboardHeightWillChange(_:)))
        addNotificationObserver("FileLoadFinished", selector: #selector(fileLoadFinished(_:)))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textViewWidth.isActive = split
        textVC.seperator.isHidden = split == false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toggleRightBarButton()
        if splitViewController?.isCollapsed ?? false {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = landscape ? fullscreenButton : filelistButton
        }
    }
    
    func setup() {
        guard let file = self.file else {
            return
        }
            
        if isViewLoaded == false {
            return
        }
        
        emptyView.isHidden = true

        previewVC.prepare(URL(fileURLWithPath: file.path).deletingLastPathComponent())
            
        textVC.assistBar.file = file
        textVC.textChangedHandler = { [weak self] (text) in
            file.text = text
            let html = self?.markdownRenderer?.renderMarkdown(text) ?? ""
            self?.previewVC.html = html
        }
        
        textVC.didScrollHandler = { [weak self] offset in
            self?.previewVC.offset = offset
        }
        
        previewVC.didScrollHandler = { [weak self] offset in
            self?.textVC.offset = offset
        }

        Configure.shared.markdownStyle.asObservable().subscribe(onNext: { [weak self] (style) in
            self?.markdownRenderer?.styleName = style
            let html = self?.markdownRenderer?.renderMarkdown(file.text) ?? ""
            self?.previewVC.html = html
        }).disposed(by: bag)
        
        Configure.shared.highlightStyle.asObservable().subscribe(onNext: { [weak self] (style) in
            self?.markdownRenderer?.highlightName = style
            let html = self?.markdownRenderer?.renderMarkdown(file.text) ?? ""
            self?.previewVC.html = html
        }).disposed(by: bag)
             
        textVC.editView.text = file.text
        if (file.text?.count ?? 0) == 0 {
            textVC.editView.becomeFirstResponder()
        }
        textVC.textViewDidChange(textVC.editView)
    }
    
    @objc func keyboardHeightWillChange(_ noti: NSNotification) {
        guard let frame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let h = textVC.editView.isFirstResponder ? frame.y : windowHeight
        textVC.keyboardHeight = h
        previewVC.keyboardHeight = h
    }
    
    @objc func deviceOrientationWillChange() {
        splitViewController?.preferredDisplayMode = .automatic
    }
    
    @objc func fileLoadFinished(_ noti: Notification) {
        guard let file = noti.object as? File else { return }
        self.file = file
    }
    
    @objc func showStylesView(_ sender: UIBarButtonItem) {
        impactIfAllow()
        guard let styleVC = self.styleVC, let popoverVC = styleVC.popoverPresentationController else {
            return
        }
        popoverVC.backgroundColor = UIColor.white
        popoverVC.delegate = self
        popoverVC.barButtonItem = sender
        present(styleVC, animated: true, completion: nil)
    }
    
    @objc func preview() {
        impactIfAllow()
        textVC.editView.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x:self.view.w , y:0), animated: true)
        toggleRightBarButton()
    }
    
    @objc func showFileList() {
        impactIfAllow()
        splitViewController?.preferredDisplayMode = .primaryOverlay
    }
    
    @objc func fullscreen() {
        impactIfAllow()
        UIView.animate(withDuration: 0.5) {
            if self.splitViewController?.preferredDisplayMode != .primaryHidden {
                self.splitViewController?.preferredDisplayMode = .primaryHidden
                self.navigationItem.leftBarButtonItem = self.exitFullscreenButton
            } else {
                self.splitViewController?.preferredDisplayMode = .allVisible
                self.navigationItem.leftBarButtonItem = self.fullscreenButton
            }
        }
    }
    
    func toggleRightBarButton() {
        webVisible = scrollView.contentOffset.x > view.w - 10
        
        if webVisible && split == false {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            navigationController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        } else {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            navigationController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
        
        if webVisible || split {
            navigationItem.rightBarButtonItems = [exportButton,styleButton]
        } else {
            navigationItem.rightBarButtonItems = [previewButton]
        }
    }
    
    @objc func showExportMenu(_ sender: Any) {
        impactIfAllow()
        textVC.editView.resignFirstResponder()
        
        let items = [ExportType.markdown,.pdf,.html,.image]
        var pos = CGPoint(x: windowWidth - 150, y: 45 + topInset)
        
        func export(_ index: Int) {
            guard let url = self.url(for: items[index]) else { return }
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            vc.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            self.presentVC(vc)
        }
        
        MenuView(items: items.map{($0.displayName,!($0 == .markdown || Configure.shared.isPro))},
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
    
    func doIfPro(_ task: (() -> Void)) {
        if Configure.shared.isPro {
            task()
            return
        }
        showAlert(title: /"PremiumOnly", message: /"PremiumTips", actionTitles: [/"SubscribeNow",/"Cancel"], textFieldconfigurationHandler: nil) { [unowned self](index) in
            if index == 0 {
                let sb = UIStoryboard(name: "Settings", bundle: Bundle.main)
                let vc = sb.instantiateVC(PurchaseViewController.self)!
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .formSheet
                self.presentVC(nav)
            }
        }
    }
    
    func url(for type: ExportType) -> URL? {
        guard let file = self.file else { return nil }
        switch type {
        case .pdf:
            let data = pdfRender.render(formatter: self.previewVC.webView.viewPrintFormatter())
            let path = tempPath + "/" + file.displayName + ".pdf"
            try? FileManager.default.removeItem(atPath: path)
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
            let url = URL(fileURLWithPath: path)
            return url
        case .image:
            guard let img = self.previewVC.webView.scrollView.snap, let data = UIImagePNGRepresentation(img) else { return nil }
            let path = tempPath + "/" + file.displayName + ".png"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        case .markdown:
            return URL(fileURLWithPath: file.path)
        case .html:
            let path = tempPath + "/" + file.displayName + ".html"
            let url = URL(fileURLWithPath: path)
            guard let data = previewVC.html.data(using: String.Encoding.utf8) else { return nil }
            try? data.write(to: url)
            return url
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TextViewController {
            textVC = vc
        } else if let vc = segue.destination as? PreviewViewController {
            previewVC = vc
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        toggleRightBarButton()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        impactIfAllow()
        toggleRightBarButton()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
        
    deinit {
        removeNotificationObserver()
        print("deinit edit_vc")
    }
    
    override var title: String? {
           didSet {
               markdownRenderer?.title = title
           }
       }
       
    lazy var exportButton: UIBarButtonItem = {
            let export = UIBarButtonItem(image: #imageLiteral(resourceName: "export"), style: .plain, target: self, action: #selector(showExportMenu(_:)))
            return export
        }()
       
    lazy var styleButton: UIBarButtonItem = {
           let export = UIBarButtonItem(image: #imageLiteral(resourceName: "style"), style: .plain, target: self, action: #selector(showStylesView(_:)))
           return export
       }()
       
    lazy var previewButton: UIBarButtonItem = {
           let button = UIBarButtonItem(image: #imageLiteral(resourceName: "preview"), style: .plain, target: self, action: #selector(preview))
           return button
       }()
       
    lazy var fullscreenButton: UIBarButtonItem = {
           let button = UIBarButtonItem(image: #imageLiteral(resourceName: "fullscreen"), style: .plain, target: self, action: #selector(fullscreen))
           return button
       }()
       
    lazy var exitFullscreenButton: UIBarButtonItem = {
           let button = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_files"), style: .plain, target: self, action: #selector(fullscreen))
           return button
       }()
       
    lazy var filelistButton: UIBarButtonItem = {
           let export = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_files"),
                       landscapeImagePhone: #imageLiteral(resourceName: "nav_files"),
                       style: .plain,
                       target: self,
                       action: #selector(showFileList))
           return export
       }()
       
    lazy var styleVC: UIViewController? = {
           let path = resourcesPath + "/Styles/"
           
           guard let subPaths = FileManager.default.subpaths(atPath: path) else { return nil}
           
           let items = subPaths.map{ $0.replacingOccurrences(of: ".css", with: "")}.filter{!$0.hasPrefix(".")}.sorted(by: >)
           let index = items.index{ Configure.shared.markdownStyle.value == $0 }
           let wraper = OptionsWraper(selectedIndex: index, editable: true, title: /"Style", items: items) {
               Configure.shared.markdownStyle.value = $0.toString
           }

           let vc = OptionsViewController()
           vc.options = wraper
           
           let nav = UINavigationController(rootViewController: vc)
           nav.preferredContentSize = CGSize(width:300, height:400)
           nav.modalPresentationStyle = .popover

           return nav
       }()
}
