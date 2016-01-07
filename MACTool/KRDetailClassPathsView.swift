//
//  KRDetailClassPathsView.swift
//  MACTool
//
//  Created by 王晶 on 15/12/29.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Cocoa

class KRDetailClassPathsView: NSView {
    
    private var runFunctionManager = KRRunFunctionManger.runFunctionManger
    private var pathsManager = ParseFilePathManager.parseFilePathManager
    private var isFrsitOpen = true
    
    @IBOutlet weak var detailPathTF: NSTextField!
    
    @IBOutlet weak var compleSettingButton: NSButton!
    
    func defaultSetup() {
        detailPathTF.stringValue = pathsManager.detailClassPaths.detail
        
        detailPathTF.delegate = self
        
        compleSettingButton.hidden = true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        // 预设
        if isFrsitOpen {
            defaultSetup()
            isFrsitOpen = false
        }
    }
    
    @IBAction func detailAction(sender: NSButton) {
        runFunctionManager.detailClass = Bool(sender.state)
    }
    @IBAction func compleSettingAction(sender: NSButton) {
        let detailP = detailPathTF.stringValue
        
        var compleSet = true
        if !pathIsDir(detailP) {
            inputLogText("Detail 路径异常")
            compleSet = false
        } else {
            pathsManager.detailClassPaths.detail = detailP
        }
        if compleSet {
            compleSettingButton.hidden = true
            detailPathTF.window?.makeFirstResponder(nil)
            inputLogText("DetailClass 路径设置完成")
        }
    }
}

extension KRDetailClassPathsView: NSTextFieldDelegate {
    
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        compleSettingButton.hidden = false
        return true
    }
}
