//
//  KRComonAddSourceToDB.swift
//  MACTool
//
//  Created by 王晶 on 15/12/24.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// ComonAdd
class KRComonAddSourceToDB: KRSourceToDB {
    //Base
    private let testClass = ZYComonAddDataManager("/Users/jingwang/Desktop/52/苹果数据")
    
    // Info
    // Detail
    lazy private var detailFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "title varchar NOT NULL",
        "name varchar NOT NULL",
        "image varchar",
        "url varchar NOT NULL"
    ]
    lazy private var detailFields = "title, name, image, url"
    
    // MainSort
    lazy private var mainSortFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "name nvarchar NOT NULL",
        "image nvarchar",
        "sort integer NOT NULL"
    ]
    lazy private var mainSortFields = "name, image, sort"
    
    // Source File
    /// Detail 源文件
    private var detailSourceFilePath: String {
        return pathManager.commonAddPaths.detail
    }
    
    
    init() {
        super.init(dnName: "ZYComonAdd")
    }
    
    func startRun() {
        
        if !runFunctionManager.commonAdd {
            return
        }
        
        inputLogText("start")
        
        if !dbManager.openDB() {
            inputLogText("打开数据库失败")
            return
        }
        
        dealDetail()
        
        if !dbManager.closeDB() {
            inputLogText("关闭数据库失败")
            return
        }
        inputLogText("end")
    }
    
    func startRun(dealTypes: [DealType], mainSortData: [String] = []) {
        inputLogText("start")
        
        if !dbManager.openDB() {
            inputLogText("打开数据库失败")
            return
        }
        
        for item in dealTypes {
            switch item {
            case .Detail:
                dealDetail()// Detail
            case .MainSort:
                dealMainSort(mainSortData)// MainSort
            }
        }
        
        if !dbManager.closeDB() {
            inputLogText("关闭数据库失败")
            return
        }
        inputLogText("end")
    }
    
    enum DealType {
        case Detail, MainSort
    }
}

private extension KRComonAddSourceToDB {
    // Detail
    func dealDetail() -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "Detail",
            filePath: detailSourceFilePath,
            fieldAndPros: detailFieldAndPros,
            fields: detailFields)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testClass.dealDetailDataToDB(toDBInfo.filePath) { (simpleData, progress) -> () in
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
    
    // MainSort
    func dealMainSort(souceData: [String]) -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "MainSort",
            filePath: "",// 无需文件
            fieldAndPros: mainSortFieldAndPros,
            fields: mainSortFields)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testClass.dealMainSortToDB(souceData) { (simpleData, progress) -> () in
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
}
