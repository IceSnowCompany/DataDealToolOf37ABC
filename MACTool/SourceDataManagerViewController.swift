//
//  SourceDataManagerViewController.swift
//  MACTool
//
//  Created by 王晶 on 15/10/13.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Cocoa

/// 通知名
let KRNotificationNameOfProgress = "KRNotificationNameOfProgress"
let KRNotificationNameOfLog = "KRNotificationNameOfLog"

class SourceDataManagerViewController: NSViewController {
    
    @IBOutlet weak var dataSelectTabView: KRSelectTabView!
    @IBOutlet weak var inputDBFolderTextField: NSTextField!
    
    @IBOutlet weak var dealtaskProgress: NSProgressIndicator!
    
    @IBOutlet weak var setInputEndButton: NSButton!
    @IBOutlet var logTextView: NSTextView!
    
    @IBOutlet weak var runningButton: NSButtonCell!
    
    
    let pathManager = ParseFilePathManager.parseFilePathManager
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dealtaskProgress.usesThreadedAnimation = true
        inputDBFolderTextField.stringValue = pathManager.inputDBFolderPath
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "progressNotificationAction:", name: KRNotificationNameOfProgress, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logNotificationAction:", name: KRNotificationNameOfLog, object: nil)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension SourceDataManagerViewController {
    
    @IBAction func runningAction(sender: NSButton) {
        sender.enabled = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            self.startParseFileToDB()// 开始解析文件
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                sender.enabled = true
            })
        }
    }
    
    @IBAction func inputFolderEditEndAction(sender: NSButton) {
        
        let inputFolder = inputDBFolderTextField.stringValue
        var isDir: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(inputFolder, isDirectory: &isDir) && isDir  {
            view.window?.endEditingFor(inputDBFolderTextField)
            setInputEndButton.enabled = false
            setInputEndButton.hidden = true
            runningButton.enabled = true // 可以解析
            pathManager.inputDBFolderPath = inputFolder
            setLogToShowView("设置inputDBFolder成功")
            return
        }
        setLogToShowView("路径出错")
    }
    
    // Notification Action
    func progressNotificationAction(notification: NSNotification) {
        
        let progressValue = (notification.userInfo!["pro"] as! NSNumber).doubleValue
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.dealtaskProgress.animator().doubleValue = progressValue*100
            if progressValue*100 == 100 {
                self.dealtaskProgress.doubleValue = 0
            }
        })
    }
    
    // Notification Action
    func logNotificationAction(notification: NSNotification) {
        let logText = notification.userInfo!["content"] as! String
        setLogToShowView(logText)
    }
    /// 显示到LogView
    func setLogToShowView(log: String = "", isClear: Bool = false) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if isClear {
                self.logTextView.string = ""
            } else {
                self.logTextView.string! += log + "\n"
            }
        }
    }
}

// MARK: - NSTextFieldDelegate
extension SourceDataManagerViewController: NSTextFieldDelegate {
    
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        runningButton.enabled = false
        setInputEndButton.enabled = true
        setInputEndButton.hidden = false
        return true
    }
}
// MARK: - Menu
private extension SourceDataManagerViewController {
    
    func zhengyangTxT(path: String) {
        let string = try? String(contentsOfFile: path)
        let textClass = TxtText(text: string!)
        textClass.writeFile(path+".txt")
        
    }
    
    // 开始解析
    func startParseFileToDB() {
        setLogToShowView(isClear: true)
        switch dataSelectTabView.currentSelectIndex {
        case 0:
            KRLocationSourceToDB().startRun()
        case 1:
            KRDetailClassSourceToDB().startRun()
        case 2:
            KRHeaderSourceToDB().startRun()
        case 3:
            KRAggreSearSourceToDB().startRun()
        case 4:
            KRClassificationrSourceToDB().startRun()
        case 5:
            KRComonAddSourceToDB().startRun()
        case 6:
            KRSortDataSourceToDB().startRun()
        default:
            setLogToShowView("意外的结果， 请自行处理")
        }
    }
}

