//
//  KRSortDataPathsView.swift
//  MACTool
//
//  Created by 王晶 on 15/12/29.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Cocoa

class KRSortDataPathsView: NSView {
    
    private var runFunctionManager = KRRunFunctionManger.runFunctionManger
    private var pathsManager = ParseFilePathManager.parseFilePathManager
    private var isFrsitOpen = true
    
    @IBOutlet weak var sourcePathTF: NSTextField!
    
    @IBOutlet weak var compleSettingButton: NSButton!
    
    func defaultSetup() {
        sourcePathTF.stringValue = pathsManager.sortDataPaths.sort
        
        sourcePathTF.delegate = self
        
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
    @IBAction func allAction(sender: NSButton) {
        runFunctionManager.sortData = Bool(sender.state)
    }
    
    @IBAction func compleSettingAction(sender: NSButton) {
        let sourceP = sourcePathTF.stringValue
        
        var compleSet = true
        if !pathIsFile(sourceP) {
            inputLogText("Source 路径异常")
            compleSet = false
        } else {
            pathsManager.sortDataPaths.sort = sourceP
        }
        if compleSet {
            compleSettingButton.hidden = true
            sourcePathTF.window?.makeFirstResponder(nil)
            inputLogText("SortData 路径设置完成")
        }
    }
}

extension KRSortDataPathsView: NSTextFieldDelegate {
    
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        compleSettingButton.hidden = false
        return true
    }
}
