//
//  KRSortDataSourceToDB.swift
//  MACTool
//
//  Created by 王晶 on 15/12/24.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// SortData
class KRSortDataSourceToDB: KRSourceToDB {
    
    //Base
    private let testClass = KRSortDataManager("/Users/jingwang/Desktop/52/手机版通用数据")
    
    // Source File
    /// Base 源文件
    private var sortSourceFilePath: String {
        return pathManager.sortDataPaths.sort
    }
    
    init() {
        super.init(dnName: "Sort")
    }
    
    func startRun() {
        
        if !runFunctionManager.sortData {
            return
        }
        
        inputLogText("SortData start")
        
        dealSortData()
        
        inputLogText("SortData end")
    }
}

private extension KRSortDataSourceToDB {
    func dealSortData() {
        testClass.parseDataToDB(sortSourceFilePath)
    }
}

