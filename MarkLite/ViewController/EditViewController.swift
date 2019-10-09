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

class EditViewController: UIViewController, ImageSaver, UIScrollViewDelegate,UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var textViewWidth: NSLayoutConstraint!
    
    var file: File? {
        didSet {
            self.title = file?.name
            self.setup()
        }
    }
    
    var landscape: Bool {
        return windowWidth > windowHeight
    }
    
    var split: Bool {
        if Configure.shared.splitOption.value == .always {
            return true
        }
        if Configure.shared.splitOption.value == .never {
            return false
        }
        return landscape
    }
    
    var timer: Timer?
    var markdownToRender: String?

    var webVC: WebViewController!
    var textVC: TextViewController!

    var webVisible = true
    var htmlURL: URL?
    let bag = DisposeBag()
    let markdownRenderer = MarkdownRender.shared()
    let pdfRender = PdfRender()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
        
        if let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
            scrollView.panGestureRecognizer.require(toFail: popGestureRecognizer)
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
        
        navBar?.setTintColor(.tint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.primary)
        
        addNotificationObserver(NSNotification.Name.UIApplicationWillTerminate.rawValue, selector: #selector(applicationWillTerminate))
        addNotificationObserver(NSNotification.Name.UIApplicationDidEnterBackground.rawValue, selector: #selector(applicationWillTerminate))
        addNotificationObserver(Notification.Name.UIApplicationWillChangeStatusBarOrientation.rawValue, selector: #selector(deviceOrientationWillChange))
        addNotificationObserver("FileLoadFinished", selector: #selector(fileLoadFinished(_:)))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textViewWidth.isActive = split
        textVC.seperator.isHidden = split == false
        toggleRightBarButton()
        if isPad {
            navigationItem.leftBarButtonItem = landscape ? fullscreenButton : filelistButton
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        file?.save()
    }
    
    func setup() {
        guard let file = self.file else {
            return
        }
        
        if isViewLoaded == false {
            return
        }
        
        let path = tempPath + "/" + file.name + ".html"
        htmlURL = URL(fileURLWithPath: path)
        webVC.webView.loadRequest(URLRequest(url:htmlURL!))
        
        textVC.textChangedHandler = { [weak self] text in
            file.text = text
            self?.markdownToRender = text
        }
        
        textVC.offsetChangedHandler = { [weak self] offset in
            self?.webVC.offset = offset
        }

        Configure.shared.markdownStyle.asObservable().subscribe(onNext: { [unowned self] (style) in
            self.markdownRenderer?.styleName = style
            self.markdownToRender = file.text
        }).disposed(by: bag)
        
        Configure.shared.highlightStyle.asObservable().subscribe(onNext: { [unowned self] (style) in
            self.markdownRenderer?.highlightName = style
            self.markdownToRender = file.text
        }).disposed(by: bag)
        
        timer = Timer.runThisEvery(seconds: 0.05) { [weak self] _ in
            guard let this = self else { return }
            if let markdown = this.markdownToRender {
                let html = this.markdownRenderer?.renderMarkdown(markdown) ?? ""
                this.markdownToRender = nil
                guard let url = this.htmlURL, let data = html.data(using: String.Encoding.utf8) else { return }
                try? data.write(to: url)
                this.webVC.contentChanged = true
            }
        }
        
        textVC.editView.text = file.text
        textVC.textViewDidChange(textVC.editView)
    }
    
    @objc func applicationWillTerminate() {
        file?.save()
    }
    
    @objc func deviceOrientationWillChange() {
        splitViewController?.preferredDisplayMode = .automatic
    }
    
    @objc func fileLoadFinished(_ noti: Notification) {
        guard let file = noti.object as? File else { return }
        self.file = file
    }
    
    @objc func showStylesView(_ sender: UIBarButtonItem) {
        guard let styleVC = self.styleVC, let popoverVC = styleVC.popoverPresentationController else {
            return
        }
        popoverVC.backgroundColor = UIColor.white
        popoverVC.delegate = self
        popoverVC.barButtonItem = sender
        present(styleVC, animated: true, completion: nil)
    }
    
    @objc func preview() {
        textVC.editView.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x:windowWidth , y:0), animated: true)
        toggleRightBarButton()
    }
    
    @objc func fullscreen() {
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
        webVisible = scrollView.contentOffset.x > windowWidth - 10
        
        if webVisible && split == false {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        } else {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
        
        if webVisible || split {
            navigationItem.rightBarButtonItems = [exportButton,styleButton]
        } else {
            navigationItem.rightBarButtonItems = [previewButton]
        }
    }
    
    @objc func showExportMenu(_ sender: Any) {
        textVC.editView.resignFirstResponder()
        
        file?.save()

        let items = [ExportType.markdown,.pdf,.html,.image]
        var pos = CGPoint(x: windowWidth - 140, y: 65)
        
        func export(_ index: Int) {
            guard let url = self.url(for: items[index]) else { return }
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            vc.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
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
                nav.modalPresentationStyle = .fullScreen
                let date = Date(fromString: "2019-10-04", format: "yyyy-MM-dd")!
                let now = Date()
                if now > date {
                    nav.modalPresentationStyle = .formSheet
                }
                self.presentVC(nav)
            }
        }
    }
    
    func url(for type: ExportType) -> URL? {
        guard let file = self.file else { return nil }
        switch type {
        case .pdf:
            let data = pdfRender.render(formatter: self.webVC.webView.viewPrintFormatter())
            let path = tempPath + "/" + file.name + ".pdf"
            try? FileManager.default.removeItem(atPath: path)
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
            let url = URL(fileURLWithPath: path)
            return url
        case .image:
            guard let img = self.webVC.webView.scrollView.snap, let _ = UIImagePNGRepresentation(img) else { return nil }
            saveImage(img)
            return nil
        case .markdown:
            return URL(fileURLWithPath: file.path)
        case .html:
            return self.htmlURL
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TextViewController {
            textVC = vc
        } else if let vc = segue.destination as? WebViewController {
            webVC = vc
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        file?.save()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        toggleRightBarButton()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        toggleRightBarButton()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
        
    deinit {
        timer?.invalidate()
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
                       target: splitViewController?.displayModeButtonItem.target,
                       action: splitViewController?.displayModeButtonItem.action)
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
