//
//  KRAggreSearSourceToDB.swift
//  MACTool
//
//  Created by 王晶 on 15/12/24.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// AggreSear
class KRAggreSearSourceToDB: KRSourceToDB {
    //Base
    private let testClass = ZYAggreSearDataManager("/Users/jingwang/Desktop/52/苹果数据")
    
    // Info
    // Detail
    lazy private var detailFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "top_name char NOT NULL",
        "cate_name char NOT NULL",
        "name varchar NOT NULL",
        "sort integer",
        "url varchar",
        "s_url varchar"
    ]
    lazy private var detailFields = "top_name, cate_name, name, url, s_url"
    
    // Detail
    lazy private var fristLayerFieldAndPros = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "name nvarchar NOT NULL",
        "hasSec integer NOT NULL DEFAULT(0)"
    ]
    lazy private var fristLayerFields = "name, hasSec"
    
    // Source File
    /// Base 源文件
    private var detailSourceFilePath: String {
        return pathManager.aggreSearPaths.base
    }
    
    
    init() {
        super.init(dnName: "ZYAggreSear")
    }
    
    func startRun() {
        
        if !runFunctionManager.aggreSear {
            return
        }
        
        inputLogText("start")
        
        if !dbManager.openDB() {
            inputLogText("打开数据库失败")
            return
        }
        
        dealDetail()
        dealFristLayer()
        
        
        if !dbManager.closeDB() {
            inputLogText("关闭数据库失败")
            return
        }
        inputLogText("end")
    }
}

private extension KRAggreSearSourceToDB {
    
    // 更新Detail表
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
        testClass.dealDetailOfSourceData(toDBInfo.filePath) { (simpleData, progress) -> () in
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)
        }
        inputLogText(__FUNCTION__ + " end")
        return true
    }
    /// 处理FristLayer
    func dealFristLayer() -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "FristLayer",
            filePath: "",// 无需额外源数据
            fieldAndPros: fristLayerFieldAndPros,
            fields: fristLayerFields)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        getAllTopAndCate { (simpleData, progress) -> () in
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
}

private extension KRAggreSearSourceToDB {
    /**
     获取并解析所有Top数据
     
     - parameter enumerateAction: 枚举操作
     */
    func getAllTopAndCate(enumerateAction: EnumerateSplitTextAndProValueFunc) {
        // 获取源数据
        let rs = try! dbManager.db.executeQuery("SELECT DISTINCT top_name, cate_name FROM Detail", values: nil)
        
        // 解析源数据
        var result: [String] = []
        var tempDict: [String: Int] = [:]
        while rs.next() {
            let top = rs.stringForColumn("top_name")
            let cate = rs.stringForColumn("cate_name")
            // 没有项
            if tempDict[top] == nil {
                result.append(top)
                tempDict[top] = cate != "0" ? 1 : 0
            } else if (tempDict[top]! == 0 && cate != "0") {
                tempDict[top] = 1
            }
        }
        
        // 组合成表所需
        let totalNum = result.count
        for (index, item) in result.enumerate() {
            let progress = Double(index + 1)/Double(totalNum)
            let sqlValues = "'\(item)'" + "," + "\(tempDict[item]!)"
            enumerateAction(simpleData: sqlValues, progress: progress)
        }
        inputLogText("数据量：\(totalNum)")
    }
}


