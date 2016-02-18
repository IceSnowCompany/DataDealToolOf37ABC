//
//  KRDetailClassSourceToDB.swift
//  MACTool
//
//  Created by 王晶 on 15/12/24.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// DetailClassSourceToDB
class KRDetailClassSourceToDB: KRSourceToDB {
    
    //Base
    private let  testclass = MoreClassDataManager()
    
    // Info
    // Detail
    lazy private var detailFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "class nvarchar NOT NULL",
        "head nvarchar NOT NULL",
        "title nvarchar NOT NULL",
        "url nvarchar NOT NULL"
    ]
    lazy private var detailFields = "class, head, title, url"
    
    // Detail
    lazy private var mainSortFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "name nvarchar NOT NULL",
        "image nvarchar",
        "sort integer NOT NULL"
    ]
    lazy private var mainSortFields = "name, image, sort"
    
    // Source File Path
    /// Detail 源文件夹
    private var detailFolderPath: String {
        return pathManager.detailClassPaths.detail
    }
    /// Detail 特殊文件夹
    private var detailSpecialFolderPath: String {
        return pathManager.detailClassPaths.detailSpecial
    }
    /// 进度信息
    private var progressInfo = (total: 0, index: 0)
    
    init() {
        super.init(dnName: "ZYDetailClass")
    }
    
    func startRun() {
        
        if !runFunctionManager.detailClass {
            return
        }
        
        inputLogText("start")
        if !dbManager.openDB() {
            inputLogText("打开数据库失败")
            return
        }
        
        progressInfo = (1, 0)// 重置进度信息
        dealDetail()
        
        
        
        
        if !dbManager.closeDB() {
            inputLogText("关闭数据库失败")
            return
        }
        inputLogText("end")
    }
    
    func startRun(dealTypes: [DealType], mainSortSData: [String] = []) {
        inputLogText("start")
        
        if !dbManager.openDB() {
            inputLogText("打开数据库失败")
            return
        }
        
        progressInfo = (dealTypes.count, 0)// 重置进度信息
        /**
        执行任务
        */
        for item in dealTypes {
            switch item {
            case .Detail:
                dealDetail()
            case .MainSort:
                dealMainSort(mainSortSData)
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

private extension KRDetailClassSourceToDB {
    // 解析所有Detail
    func dealDetail() -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "Detail",
            filePath: detailFolderPath,
            fieldAndPros: detailFieldAndPros,
            fields: detailFields)
        
        // 进度信息
        let itemPro = 1 / Double(progressInfo.total)// 单元进度
        let proED = Double(progressInfo.index) / Double(progressInfo.total)// 已处理进度
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        testclass.parseFoldersToDB(detailFolderPath,
            special: detailSpecialFolderPath) { (simpleData, progress) -> () in
                let pro = proED + itemPro * progress// 于本类中进度
                self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: pro)
        }
        
        // 进度信息更新
        progressInfo.index++
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
    
    /// 解析MainSort
    func dealMainSort(sourceData: [String]) -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "MainSort",
            filePath: "",// 无源文件
            fieldAndPros: mainSortFieldAndPros,
            fields: mainSortFields)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 进度信息
        let itemPro = 1 / Double(progressInfo.total)// 单元进度
        let proED = Double(progressInfo.index) / Double(progressInfo.total)// 已处理进度
        
        //  处理数据
        testclass.dealMainSortToDB(sourceData) { (simpleData, progress) -> () in
            let pro = proED + itemPro * progress// 于本类中进度
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: pro)
        }
        
        // 进度信息更新
        progressInfo.index++
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
}

