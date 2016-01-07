//
//  KRLocationPathView.swift
//  MACTool
//
//  Created by 王晶 on 15/12/29.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Cocoa

class KRLocationPathView: NSView {
    
    private var runFunctionManager = KRRunFunctionManger.runFunctionManger
    private var pathsManager = ParseFilePathManager.parseFilePathManager
    private var isFrsitOpen = true
    
    @IBOutlet weak var detailPathTF: NSTextField!
    @IBOutlet weak var govPathTF: NSTextField!
    @IBOutlet weak var popSitePathTF: NSTextField!
    
     @IBOutlet weak var compleSettingButton: NSButton!
    
    func defaultSetup() {
        detailPathTF.stringValue = pathsManager.locationPaths.detail
        govPathTF.stringValue = pathsManager.locationPaths.gov
        popSitePathTF.stringValue = pathsManager.locationPaths.popSite
        
        detailPathTF.delegate = self
        govPathTF.delegate = self
        popSitePathTF.delegate = self
        
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
        runFunctionManager.location.detail = Bool(sender.state)
    }
    
    @IBAction func govAction(sender: NSButton) {
        runFunctionManager.location.gov = Bool(sender.state)
    }
    
    @IBAction func popSiteAction(sender: NSButton) {
        runFunctionManager.location.popSite = Bool(sender.state)
    }
    
    @IBAction func compleSettingAction(sender: NSButton) {
        let detailP = detailPathTF.stringValue
        let govP = govPathTF.stringValue
        let popSP = popSitePathTF.stringValue
        
        var compleSet = true
        if !pathIsFile(detailP) {
            inputLogText("Detail 路径异常")
            compleSet = false
        } else {
            pathsManager.locationPaths.detail = detailP
        }
        if !pathIsDir(govP){
            inputLogText("Gov 路径异常")
            compleSet = false
        } else {
            pathsManager.locationPaths.gov = govP
        }
        if !pathIsFile(popSP) {
            inputLogText("popSite 路径异常")
            compleSet = false
        } else {
            pathsManager.locationPaths.popSite = popSP
        }
        if compleSet {
            compleSettingButton.hidden = true
            detailPathTF.window?.makeFirstResponder(nil)
            inputLogText("Location 路径设置完成")
        }
    }
}



extension KRLocationPathView: NSTextFieldDelegate {
    
    func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        compleSettingButton.hidden = false
        return true
    }
}
