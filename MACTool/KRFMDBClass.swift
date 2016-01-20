//
//  KRFMDBClass.swift
//  MACTool
//
//  Created by 王晶 on 16/1/20.
//  Copyright © 2016年 Kirin. All rights reserved.
//

import Foundation

/// 时间格式
private let myDateFormat = "yyyy-MM-dd HH:mm:ss"

class FMDBUseClass: ConstantLogClass {
    
    let db: FMDatabase
    
    init(dbName: String) {
        let defaultInputFolder = ParseFilePathManager.parseFilePathManager.inputDBFolderPath
        db = FMDatabase(path:defaultInputFolder + "/" + "\(dbName).db")
    }
    
    init(basePath: String, dbName: String) {
        db = FMDatabase(path:basePath + "/" + "\(dbName).db")
    }
    
    func createDB() {
        
        
        if db.open() {
            // Drop table
            let sqlDeleteTable = "DROP TABLE MainSort"
            let deleteStatus = db.executeStatements(sqlDeleteTable)
            inputLogText(deleteStatus ? "删除成功" : "删除失败")
            
            // Create table
            let createStatus = createTable("MainSort", fieldAndPros: [
                "id integer PRIMARY KEY AUTOINCREMENT NOT NULL",
                "name nvarchar NOT NULL",
                "image nvarchar",
                "sort integer NOT NULL"])
            
            inputLogText(createStatus ? "创建成功" : "创建失败")
            
            inputLogText(db.close() ? "关闭成功" : "关闭失败")
        }
    }
    
    /**
     插入数据
     
     - parameter fields: 插入数据的字段集合(多个中间逗号隔开)
     - parameter values: 插入字段的数据(多个中间逗号隔开)
     
     - returns: 操作成功状态
     */
    func insertData(tableName: String, fields: String, values: String) -> Bool {
        let sqlInsertData = "INSERT INTO \(tableName) (\(fields)) VALUES (\(values))"
        return db.executeStatements(sqlInsertData)
    }
    
    /**
     删除表(结构和数据)
     
     - parameter tableName: 表名
     
     - returns: 删除状态
     */
    func dropTable(tableName: String) -> Bool {
        // Drop table
        let sqlDropTable = "DROP TABLE \(tableName)"
        let dropStatus = db.executeStatements(sqlDropTable)
        return dropStatus
    }
    
    /**
     创建表
     
     - parameter name:         表名
     - parameter fieldAndPros: 字段和属性列表
     
     - returns: 执行结果状态
     */
    func createTable(name: String, fieldAndPros: [String]) -> Bool {
        // 合成字段字符串
        var fieldStr = fieldAndPros.reduce("") { (synStr, para) -> String in
            return synStr + "," + para
        }
        // 去除头部逗号
        fieldStr = fieldStr.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ","))
        // Create table
        let sqlCreateTable = "CREATE TABLE \(name) (\(fieldStr))"
        let createStatus = db.executeStatements(sqlCreateTable)
        return createStatus
    }
    /**
     打开数据库连接
     
     - returns: 打开结果
     */
    func openDB() -> Bool {
        return db.open()
    }
    
    /**
     关闭数据库连接
     
     - returns: 关闭结果
     */
    func closeDB() -> Bool {
        return db.close()
    }
}
// MARK: - 1.1
extension FMDBUseClass {
    /**
     判断表是否存在
     
     - parameter tableName: 表名
     
     - returns: 存在状态
     */
    func hasTable(tableName: String) -> Bool {
        let rs = db.executeQuery("SELECT sql FROM sqlite_master WHERE type LIKE 'table' AND tbl_name LIKE '\(tableName)'", withArgumentsInArray: [])
        return rs.columnCount() > 0
    }
}

/// 带打印log
class ConstantLogClass {
    /**
     输出Log日志
     
     - parameter log: 日志
     */
    func inputLogText(log: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let userInfo = ["content": log]
            let notificationObject = NSNotification(name: KRNotificationNameOfLog, object: nil, userInfo: userInfo)
            NSNotificationCenter.defaultCenter().postNotification(notificationObject)
        })
    }
}

import Cocoa

extension NSView {
    /**
     输出Log日志
     
     - parameter log: 日志
     */
    func inputLogText(log: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let userInfo = ["content": log]
            let notificationObject = NSNotification(name: KRNotificationNameOfLog, object: nil, userInfo: userInfo)
            NSNotificationCenter.defaultCenter().postNotification(notificationObject)
        })
    }
    
    /// 路径是否为目录
    func pathIsDir(path: String) -> Bool {
        var isDir: ObjCBool = false
        return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) && isDir
    }
    
    /// 路径是否为文件
    func pathIsFile(path: String) -> Bool {
        var isDir: ObjCBool = false
        return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) && !isDir
    }
}
