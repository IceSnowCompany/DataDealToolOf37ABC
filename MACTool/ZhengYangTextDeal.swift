//
//  TextDeal.swift
//  MACTool
//
//  Created by 王晶 on 15/12/2.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

class TxtText {
    
    var text: String
    var result: String = ""
    init(text: String) {
        
        self.text = text.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
        self.text = self.text.stringByReplacingOccurrencesOfString("\r", withString: "")
        let texts = self.text.componentsSeparatedByString("\n")
        var resultString = ""
        for item in texts {
            if !item.isEmpty {
                if let num = Double(item) {
                    var addtext = "\(num)"
                    if addtext.hasSuffix(".0") {
                        addtext = addtext.stringByReplacingOccurrencesOfString(".0", withString: "")
                    }
                    resultString += (addtext + "\n")
                }
            }
        }
        resultString = resultString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\n"))
        result = resultString
    }
    
    // 写入文件
    func writeFile(path: String) -> Bool {
        do {
            try result.writeToFile(path+"new", atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch {
            return false
        }
    }
}