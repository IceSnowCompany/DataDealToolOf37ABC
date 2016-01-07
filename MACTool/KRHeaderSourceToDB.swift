//
//  KRHeaderSourceToDB.swift
//  MACTool
//
//  Created by 王晶 on 15/12/24.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// ZYHeader
class KRHeaderSourceToDB: KRSourceToDB {
    
    //Base
    private let testClass = ZYHeaderDataManager("/Users/jingwang/Desktop/52/手机版通用数据")
    
    // Info
    // Base
    lazy private var baseFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "cate_name nvarchar NOT NULL",
        "name nvarchar NOT NULL",
        "url nvarchar",
        "search_url nvarchar"
    ]
    lazy private var baseFields = "cate_name, name, url, search_url"
    
    // Hot
    lazy private var hotFieldAndPros = [
        "id integer PRIMARY KEY NOT NULL",
        "cate_name nvarchar NOT NULL",
        "name nvarchar NOT NULL",
        "url nvarchar",
        "search_url nvarchar"
    ]
    lazy private var hotFields = ""
    
    // Source File 
    /// Base 源文件
    private var baseFilesPath: [String] {
        return pathManager.headerPaths.base
    }
    
    init() {
        super.init(dnName: "ZYHeader")
    }
    
    func startRun() {
        
        if !runFunctionManager.header {
            return
        }
        
        inputLogText("start")
        
        if !dbManager.openDB() {
            inputLogText("打开数据库失败")
            return
        }
        
        dealBase()
        
        if !dbManager.closeDB() {
            inputLogText("关闭数据库失败")
            return
        }
        inputLogText("end")
    }
}

private extension KRHeaderSourceToDB {
    func dealBase() -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName: "base",
            filesPath: baseFilesPath,
            fieldAndPros: baseFieldAndPros,
            fields: baseFields)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testClass.dealDefaultHeads(toDBInfo.filesPath!) { (simpleData, progress) -> () in
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
        
    }
}
