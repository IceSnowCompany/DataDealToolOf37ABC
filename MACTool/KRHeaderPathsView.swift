//
//  KRHeaderPathsView.swift
//  MACTool
//
//  Created by 王晶 on 15/12/29.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Cocoa

class KRHeaderPathsView: NSView {
    
    private var runFunctionManager = KRRunFunctionManger.runFunctionManger
    private var pathsManager = ParseFilePathManager.parseFilePathManager
    private var isFrsitOpen = true
    
    @IBOutlet weak var base1PathTF: NSTextField!
    @IBOutlet weak var base2PathTF: NSTextField!
    
    @IBOutlet weak var compleSettingButton: NSButton!
    
    func defaultSetup() {
        base1PathTF.stringValue = pathsManager.headerPaths.base[0]
        base2PathTF.stringValue = pathsManager.headerPaths.base[1]
        
        base1PathTF.delegate = self
        base2PathTF.delegate = self
        
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
    
    @IBAction func baseAction(sender: NSButton) {
        runFunctionManager.header = Bool(sender.state)
    }
    
    @IBAction func compleSettingAction(sender: NSButton) {
        let base1 = base1PathTF.stringValue
        let base2 = base2PathTF.stringValue

        
        var compleSet = true
        if !pathIsFile(base1) {
            inputLogText("base1 路径异常")
            compleSet = false
        } else {
            pathsManager.headerPaths.base[0] = base1
        }
        if !pathIsFile(base2) {
            inputLogText("base2 路径异常")
            compleSet = false
        } else {
            pathsManager.headerPaths.base[1] = base2
        }
        if compleSet {
            compleSettingButton.hidden = true
            base1PathTF.window?.makeFirstResponder(nil)
            inputLogText("Header 路径设置完成")
        }
    }
}

extension KRHeaderPathsView: NSTextFieldDelegate {
    
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        compleSettingButton.hidden = false
        return true
    }
}
