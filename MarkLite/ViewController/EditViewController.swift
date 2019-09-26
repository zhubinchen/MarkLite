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

class EditViewController: UIViewController,ImageSaver {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    
    var file: File? {
        didSet {
            self.title = file?.name
        }
    }
    var timer: Timer?
    var markdownToRender: String?

    var webVC: WebViewController!
    var textVC: TextViewController!
    
    var showExport = true
    let bag = DisposeBag()
    let markdownRenderer = MarkdownRender.shared()
    let pdfRender = PdfRender()

    override var title: String? {
        didSet {
            markdownRenderer?.title = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
            scrollView.panGestureRecognizer.require(toFail: popGestureRecognizer)
        }
        
        if self.file != nil {
            setup()
        }
        
        if let splitViewController = self.splitViewController {
            let item = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_files"),
            landscapeImagePhone: #imageLiteral(resourceName: "nav_files"),
            style: .plain,
            target: splitViewController.displayModeButtonItem.target,
            action: splitViewController.displayModeButtonItem.action)
            navigationItem.leftBarButtonItem = item
            navigationItem.leftItemsSupplementBackButton = true
        }
        
        navBar?.setBarTintColor(.navBar)
        navBar?.setContentColor(.navBarTint)
        addNotificationObserver(NSNotification.Name.UIApplicationWillTerminate.rawValue, selector: #selector(applicationWillTerminate))
        addNotificationObserver(NSNotification.Name.UIApplicationDidEnterBackground.rawValue, selector: #selector(applicationWillTerminate))
        addNotificationObserver("FileLoadFinished", selector: #selector(fileLoadFinished(_:)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        file?.save()
    }
    
    @objc func applicationWillTerminate() {
        file?.save()
    }
    
    @objc func fileLoadFinished(_ noti: Notification) {
        guard let file = noti.object as? File else { return }
        self.file = file
    }
    
    func setup() {
        guard let file = self.file else {
            return
        }
        scrollView.rx.contentOffset.map{ $0.x > windowWidth - 10 }.subscribe(onNext: { [weak self] showExport in
            self?.toggleBarButton(showExport)
        }).disposed(by: bag)
                
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
                this.webVC.htmlString = this.markdownRenderer?.renderMarkdown(markdown) ?? ""
                this.markdownToRender = nil
            }
        }
        
        textVC.editView.text = file.text
        textVC.textChanged()
    }
    
    func toggleBarButton(_ showExport: Bool) {
        textVC.editView.resignFirstResponder()

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
        textVC.editView.resignFirstResponder()
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
            guard let url = self.url(for: items[index]) else { return }
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
                self.presentVC(nav)
            }
        }
    }
    
    func url(for type: ExportType) -> URL? {
        guard let file = self.file else { return nil }
        switch type {
        case .pdf:
            let data = pdfRender.render(html: self.webVC.htmlString)
            let path = tempPath + "/" + file.name + ".pdf"
            let url = URL(fileURLWithPath: path)
            do {
                try data.write(to: url)
            } catch {
                print(error.localizedDescription)
            }
            return url
        case .image:
            guard let img = self.webVC.webView.scrollView.snap, let _ = UIImagePNGRepresentation(img) else { return nil }
            saveImage(img)
            return nil
        case .markdown:
            return URL(fileURLWithPath: file.path)
        case .html:
            guard let data = self.webVC.htmlString.data(using: String.Encoding.utf8) else { return nil }
            let path = tempPath + "/" + file.name + ".html"
            let url = URL(fileURLWithPath: path)
            try? data.write(to: url)
            return url
        }
    }
    
    @objc func preview() {
        textVC.editView.resignFirstResponder()
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
        textViewWidth.priority = windowWidth > windowHeight ? UILayoutPriority.required : .defaultLow
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        file?.save()
    }
    
    deinit {
        timer?.invalidate()
        removeNotificationObserver()
        print("deinit edit_vc")
    }
}
