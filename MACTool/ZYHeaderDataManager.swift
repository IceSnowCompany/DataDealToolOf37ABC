//
//  ZYHeaderDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/14.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

class ZYHeaderDataManager: KRDataManager {
    
    // FileName
    lazy private var fileNameOfSomeHeads = "ZYHeader-base.csv"
    
    // Heads
    lazy private var headsOfDefult = ["cate_name", "name", "url", "search_url"]
}
// MARK: - To DB
extension ZYHeaderDataManager {
     /**
     解析头部数据(To DB)
     
     - parameter filesPath:   源文件路径组
     - parameter splitAction: 分割操作
     */
    func dealDefaultHeads(filesPath: [String], splitAction: EnumerateSplitTextAndProValueFunc) {
        parseFiles(filesPath, fieldCount: headsOfDefult.count, splitAction: splitAction)
    }
}
