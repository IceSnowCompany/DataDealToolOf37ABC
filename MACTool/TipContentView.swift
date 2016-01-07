//
//  TipContentView.swift
//  MACTool
//
//  Created by 王晶 on 15/12/2.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Cocoa

class TipContentView: NSView {
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        NSColor(calibratedWhite: 0.9, alpha: 0.9).set()
        NSRectFill(dirtyRect)
    }
}