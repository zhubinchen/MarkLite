//
//  WebDAVViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/10/10.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class WebDAVViewController: UIViewController, GCDWebUploaderDelegate {
    
    let server = GCDWebUploader(uploadDirectory: documentPath)
    
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var urlButton: UIButton!

    @IBOutlet weak var logLabel: UILabel!
    
    var changed = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "WebDAV"
        
        server.title = "Markdown"
        server.allowHiddenItems = false
        server.prologue = /"欢迎使用Markdown文件管理平台"
        server.delegate = self
        
        view.setBackgroundColor(.background)
        view.setTintColor(.tint)
        statusLabel.setTextColor(.primary)
        logLabel.setTextColor(.primary)
        
        statusLabel.text = /"ServerLoading"
        if server.start(withPort: 80, bonjourName: "markdown") {
            statusLabel.text = /"ServerStarted"
            urlButton.setTitle(server.serverURL?.absoluteString, for: .normal)
        } else {
            statusLabel.text = /"ServerNotRunning"
        }
    }
    
    @IBAction func copyAddress(_ sender: UIButton!) {
        UIPasteboard.general.string = sender.currentTitle
        SVProgressHUD.showSuccess(withStatus: /"CopiedAddress")
    }
    
    deinit {
        server.stop()
        if changed {
            NotificationCenter.default.post(name: Notification.Name("LocalChanged"), object: nil)
        }
    }
    
    func webServerDidStart(_ server: GCDWebServer) {
        logLabel.text = logLabel.text! + "\n\n[Started,Waiting for connecting]"
    }
    
    func webServerDidConnect(_ server: GCDWebServer) {
        logLabel.text = logLabel.text! + "\n\n[Connected]"
    }
    
    func webServerDidDisconnect(_ server: GCDWebServer) {
        logLabel.text = logLabel.text! + "\n\n[Disconnected]"
    }
    
    func webServerDidStop(_ server: GCDWebServer) {
        logLabel.text = logLabel.text! + "\n\n[Stoped]"
    }
    
    func webServerDidCompleteBonjourRegistration(_ server: GCDWebServer) {
        urlButton.setTitle(server.bonjourServerURL?.absoluteString, for: .normal)
    }
    
    func webUploader(_ uploader: GCDWebUploader, didDeleteItemAtPath path: String) {
        logLabel.text = logLabel.text! + "\n\n[Deleted: \(relativePath(path))]"
        changed = true
    }
    
    func webUploader(_ uploader: GCDWebUploader, didDownloadFileAtPath path: String) {
        logLabel.text = logLabel.text! + "\n\n[Downloaded: \(relativePath(path))]"
    }
    
    func webUploader(_ uploader: GCDWebUploader, didCreateDirectoryAtPath path: String) {
        logLabel.text = logLabel.text! + "\n\n[Created Directory: \(relativePath(path))]"
        changed = true
    }
    
    func webUploader(_ uploader: GCDWebUploader, didMoveItemFromPath fromPath: String, toPath: String) {
        logLabel.text = logLabel.text! + "\n\n[Moved: \(relativePath(fromPath)) to \(relativePath(toPath))]"
        changed = true
    }
    
    func webUploader(_ uploader: GCDWebUploader, didUploadFileAtPath path: String) {
        logLabel.text = logLabel.text! + "\n\n[Uploaded: \(relativePath(path))]"
        changed = true
    }
    
    func relativePath(_ path: String) -> String {
        return path.replacingOccurrences(of: documentPath, with: "")
    }
}
