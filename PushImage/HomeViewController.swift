//
//  HomeViewController.swift
//  PushImage
//
//  Created by Lawrence Tan on 5/9/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import Cocoa
import Alamofire

class HomeViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var staticLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    //1
    @IBOutlet weak var dragView: DragView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    fileprivate func setupView() {
        progressIndicator.isHidden = true
        //2
        dragView.delegate = self        
    }
}

//3
extension HomeViewController: DragViewDelegate {
    func dragView(didDragFileWith URL: NSURL) {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self.view)
        staticLabel.isHidden = true
        
        Alamofire.upload(multipartFormData: { (data: MultipartFormData) in
            data.append(URL as URL, withName: "upload")
        }, to: "http://uploads.im/api?format=json") { [weak self] (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard
                        let dataDict = response.result.value as? NSDictionary,
                        let data = dataDict["data"] as? NSDictionary,
                        let imgUrl = data["img_url"] as? String else { return }
                    
                    self?.progressIndicator.isHidden = true
                    self?.progressIndicator.stopAnimation(self?.view)
                    self?.staticLabel.isHidden = false
                    self?.showSuccessAlert(url: imgUrl)
                }
            case .failure(let encodingError):
                self?.staticLabel.isHidden = false
                print(encodingError)
            }
        }
    }
    
    fileprivate func showSuccessAlert(url: String) {
        let alert = NSAlert()
        alert.messageText = url
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Copy to clipboard")
        let response = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            NSPasteboard.general().clearContents()
            NSPasteboard.general().setString(url, forType: NSPasteboardTypeString)
        }
    }
}
