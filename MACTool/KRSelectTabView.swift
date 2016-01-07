//
//  KRSelectTabView.swift
//  MACTool
//
//  Created by 王晶 on 15/12/28.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Cocoa

class KRSelectTabView: NSTabView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        delegate = self
    }
    
    var currentSelectIndex: Int = 0
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}

extension KRSelectTabView: NSTabViewDelegate {
    func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        let index = tabView.indexOfTabViewItem(tabViewItem!)
        currentSelectIndex = index
    }
}



