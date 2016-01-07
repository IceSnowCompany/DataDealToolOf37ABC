//
//  KRClassificationrSourceToDB.swift
//  MACTool
//
//  Created by 王晶 on 15/12/24.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// Classificationr
class KRClassificationrSourceToDB: KRSourceToDB {
    //Base
    private let testClass = ZYClassificationDataManage("/Users/jingwang/Desktop/52/苹果数据")
    
    // Info
    // Detail
    lazy private var detailFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "title nvarchar NOT NULL",
        "name nvarchar NOT NULL",
        "url nvarchar NOT NULL"
    ]
    lazy private var detailFields = "title, name, url"
    
    // SortTwoLayer
    lazy private var sortTwoLayerFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "class nvarchar NOT NULL",
        "title nvarchar NOT NULL"
    ]
    lazy private var sortTwoLayerFields = "class, title"
    
    // SortOneLayer
    lazy private var sortOneLayerFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "name nvarchar NOT NULL",
        "sort integer NOT NULL",
        "image nvarchar"
    ]
    lazy private var sortOneLayerFields = "name, sort, image"
    
    // Recommend
    lazy private var recommendFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "title nvarchar NOT NULL",
        "name nvarchar NOT NULL"
    ]
    lazy private var recommendFields = "title, name"
    
    
    // Source File
    /// Base 源文件
    private var detailSourceFilePath: String {
        return pathManager.classificationrPaths.detail
    }
    
    init() {
        super.init(dnName: "ZYClassification")
    }
    // V1.0
    func startRun() {
        
        if !runFunctionManager.classification {
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
    // V1.1
    func startRun(dealTypes: [DealType], sTwoLayer: [Array<String>] = [], sOneLayer: [String] = [], recommendData: [String] = []) {
        inputLogText("start")
        
        if !dbManager.openDB() {
            inputLogText("打开数据库失败")
            return
        }
        
        for item in dealTypes {
            switch item {
            case .Detail:
                dealDetail()
            case .SortTwoLayer:
                dealSortTwoLayer(sTwoLayer)
            case .SortOneLayer:
                dealSortOneLayer(sOneLayer)
            case .Recommend:
                dealRecommend(recommendData)
            }
        }
        
        if !dbManager.closeDB() {
            inputLogText("关闭数据库失败")
            return
        }
        inputLogText("end")
    }
    
    enum DealType {
        case Detail, SortTwoLayer, SortOneLayer, Recommend
    }
    
    
}

// MARK: - Deal
private extension KRClassificationrSourceToDB {
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
    
    // SortTwoLayer
    func dealSortTwoLayer(sourceData: [Array<String>]) -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "SortTwoLayer",
            filePath: "",// 无需源数据
            fieldAndPros: sortTwoLayerFieldAndPros,
            fields: sortTwoLayerFields)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testClass.dealSortTwoLayerToDB(sourceData) { (simpleData, progress) -> () in
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
    
    //
    func dealSortOneLayer(sourceData: [String]) -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "SortOneLayer",
            filePath: "",// 无需源文件
            fieldAndPros: sortOneLayerFieldAndPros,
            fields: sortOneLayerFields)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testClass.dealSortOneLayerToDB(sourceData) { (simpleData, progress) -> () in
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
    
    func dealRecommend(sourceData: [String]) -> Bool {
        
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "Recommend",
            filePath: "",// 无需源文件
            fieldAndPros: recommendFieldAndPros,
            fields: recommendFields)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testClass.dealRecommendToDB(sourceData, getClassName: { (title) -> String in
            return self.getClassFromTitle(title)// 根据标签重DB中获取项名
            }) { (simpleData, progress) -> () in
                self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)// 写入DB
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
}
// MARK: - Tool
private extension KRClassificationrSourceToDB {
    /**
     通过标签获取所属类
     
     - parameter title: 标签
     
     - returns: 类名
     */
    func getClassFromTitle(title: String) -> String {
        let sql = "SELECT class FROM SortTwoLayer WHERE title LIKE '\(title)'"
        let rs = dbManager.db.executeQuery(sql, withArgumentsInArray: nil)
        
        if rs.columnCount() != 1 {
            inputLogText("SortTwoLayer 查询异常")
        }
        // 获取查询所得值
        var className: String = ""
        while rs.next() {
            className = rs.stringForColumn("class")
        }
        return className
    }
}
