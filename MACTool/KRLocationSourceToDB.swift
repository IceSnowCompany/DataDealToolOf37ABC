//
//  KRLocationSourceToDB.swift
//  MACTool
//
//  Created by 王晶 on 15/12/23.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// Location
class KRLocationSourceToDB: KRSourceToDB {
    
    private let  testclass = ZYLoctionDataManager("/Users/jingwang/Desktop/52/手机版通用数据")
    
    init() {
        super.init(dnName: "ZYLoction")
    }
    
    // Detail
    lazy private var detailFieldAndPro = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "cate_name char NOT NULL",
        "name varchar NOT NULL",
        "url nvarchar NOT NULL"
    ]
    lazy private var detailField = "cate_name, name, url"
    // Gov
    lazy private var govFieldAndPro = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "city char NOT NULL",
        "name varchar NOT NULL",
        "url nvarchar NOT NULL"
    ]
    lazy private var govField = "name, city, url"
    // PopSite
    lazy private var popSiteFieldAndPro = [
        "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
        "city nvarchar NOT NULL",
        "name nvarchar NOT NULL",
        "url nvarchar NOT NULL"
    ]
    lazy private var popSiteField = "city, name, url"
    // --------
    
    // NewFilePath
    /// Detail 源文件
    private var detailDataFilePath: String {
        return pathManager.locationPaths.detail
    }
    
    /// Gov 源文件夹
    private var govDataFolderPath: String {
        return pathManager.locationPaths.gov
    }
    /// PopSite 源文件
    private var popSiteFilePath: String {
        return pathManager.locationPaths.popSite
    }
    
    
    func startRun() {
        
        if !runFunctionManager.location.hasRun() {
            return
        }
        
        inputLogText("start")
        if !dbManager.openDB() {
            inputLogText("打开数据库失败")
            return
        }
        
        if runFunctionManager.location.detail {
            dealDetail()
        }
        if runFunctionManager.location.gov {
            dealGov()
        }
        if runFunctionManager.location.detail {
            dealPopSite()
        }
        
        if !dbManager.closeDB() {
            inputLogText("关闭数据库失败")
            return
        }
        inputLogText("end")
    }
}

private extension KRLocationSourceToDB {
    // GOV
    func dealGov() -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "Gov",
            filePath: govDataFolderPath,
            fieldAndPros: govFieldAndPro,
            fields: govField)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testclass.parseGov(toDBInfo.filePath) { (simpleData, progress) -> () in
            self.dealSimpleInMoreLineData(toDBInfo, simpleData: simpleData, progress: progress)
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
    
    // Detail
    func dealDetail() -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "Detail",
            filePath: detailDataFilePath,
            fieldAndPros: detailFieldAndPro,
            fields: detailField)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testclass.parseDetail(toDBInfo.filePath) { (simpleData, progress) -> () in
            if !self.dbManager.insertData(toDBInfo.tableName,
                fields: toDBInfo.fields,
                values: simpleData) {
                self.inputLogText(simpleData + "插入失败")
            }
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
    
    // PopSite
    func dealPopSite() -> Bool {
        let toDBInfo = SourceDataToDBInfo(
            tableName:  "popSite",
            filePath: popSiteFilePath,
            fieldAndPros: popSiteFieldAndPro,
            fields: popSiteField)
        
        // 重建表
        if !reCreateTable(toDBInfo.tableName, fieldAndPros: toDBInfo.fieldAndPros) {
            return false
        }
        
        // 处理数据
        testclass.parseDetail(toDBInfo.filePath) { (simpleData, progress) -> () in
            if !self.dbManager.insertData(toDBInfo.tableName,
                fields: toDBInfo.fields,
                values: simpleData) {
                self.inputLogText(simpleData + "插入失败")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let progress = Double(progress.0) / Double(progress.1)
                let userInfo = ["pro": NSNumber(double: progress)]
                let notificationObject = NSNotification(name: KRNotificationNameOfProgress, object: nil, userInfo: userInfo)
                NSNotificationCenter.defaultCenter().postNotification(notificationObject)
            })
        }
        
        inputLogText(__FUNCTION__ + " end")
        return true
    }
}

/// 源文件到DB基类
class KRSourceToDB: ConstantLogClass {
    /// 执行方法管理
    let runFunctionManager = KRRunFunctionManger.runFunctionManger
    /// 源文件路径管理
    let pathManager: ParseFilePathManager
    
    /**
     源数据到DB所需信息
     */
    struct SourceDataToDBInfo {
        /// 表名
        let tableName: String
        /// 源文件所在文件夹或目录
        let filePath: String
        /// 源文件路径集合
        let filesPath: [String]?
        /// 字段和属性组
        let fieldAndPros: [String]
        /// 写入数据字段
        let fields: String
        
        init(tableName: String, filePath: String = "", filesPath: [String]? = nil, fieldAndPros: [String], fields: String) {
            self.tableName = tableName
            self.filePath = filePath
            self.fieldAndPros = fieldAndPros
            self.fields = fields
            self.filesPath = filesPath
        }
    }
    
    let dbManager: FMDBUseClass
    
    init(dnName: String) {
        dbManager = FMDBUseClass(dbName: dnName)
        pathManager = ParseFilePathManager.parseFilePathManager
    }
    
    /// 插入单条数据(针对多文件)
    func dealSimpleInMoreLineData(toDBInfo: SourceDataToDBInfo,simpleData: String, progress: Double) {
        if !self.dbManager.insertData(toDBInfo.tableName,
            fields: toDBInfo.fields,
            values: simpleData) {
                inputLogText(simpleData + "插入失败")
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let userInfo = ["pro": NSNumber(double: progress)]
            let notificationObject = NSNotification(name: KRNotificationNameOfProgress, object: nil, userInfo: userInfo)
            NSNotificationCenter.defaultCenter().postNotification(notificationObject)
        })
    }
    
    /**
     重设表
     
     - parameter tableName:    表名
     - parameter fieldAndPros: 字段和属性
     
     - returns: 重设结果状态
     */
    func reCreateTable(tableName: String, fieldAndPros: [String]) -> Bool {
        // 删除旧表
        if !dbManager.dropTable(tableName) {
            //            return false
        }
        
        // 创建表
        if !dbManager.createTable(tableName, fieldAndPros: fieldAndPros) {
            inputLogText("建表失败")
            return false
        }
        inputLogText("重建表 \(tableName) 成功")
        return true
    }
}
