//
//  ParseFilePathManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/28.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation
/// 解析文件路径管理
class ParseFilePathManager {
    
    private var locaPathManger = KRPathsDataSavaDB.pathsDataSavaDB
    
    /// 默认本地源文件
    lazy private var _locationPaths: LocationPaths = {
        let pathDBM = KRPathsDataSavaDB.pathsDataSavaDB
        return LocationPaths(
            detail: pathDBM.getPath(.LocationPathsDetail),
            gov: pathDBM.getPath(.LocationPathsGov),
            popSite: pathDBM.getPath(.LocationPathsPopSite))
    }()
    
    /// 默认本地源文件
    var locationPaths: LocationPaths {
        get {
            return _locationPaths
        }
        set {
            if _locationPaths.detail != newValue.detail {
                locaPathManger.setPath(.LocationPathsDetail, newPath: newValue.detail)
            }
            if _locationPaths.gov != newValue.gov {
                locaPathManger.setPath(.LocationPathsGov, newPath: newValue.gov)
            }
            if _locationPaths.popSite != newValue.popSite {
                locaPathManger.setPath(.LocationPathsPopSite, newPath: newValue.popSite)
            }
            _locationPaths = newValue
        }
    }
    
    /// 默认细类源文件
    lazy private var _detailClassPaths: DetailClassPaths = {
        let pathDBM = KRPathsDataSavaDB.pathsDataSavaDB
        return DetailClassPaths(detail: pathDBM.getPath(.DetailClassPathsDetail))
    }()
    
    /// 默认细类源文件
    var detailClassPaths: DetailClassPaths {
        get {
            return _detailClassPaths
        }
        set {
            if newValue.detail != _detailClassPaths.detail {
                locaPathManger.setPath(.DetailClassPathsDetail, newPath: newValue.detail)
            }
            _detailClassPaths = newValue
        }
    }
    
    /// 默认头部源文件
    lazy private var _headerPaths: HeaderPaths = {
        let pathDBM = KRPathsDataSavaDB.pathsDataSavaDB
        return HeaderPaths(base: [
            pathDBM.getPath(.HeaderPathsBase1),
            pathDBM.getPath(.HeaderPathsBase2)])
    }()
    
    /// 默认头部源文件
    var headerPaths: HeaderPaths {
        get {
            return _headerPaths
        }
        set {
            if _headerPaths.base[0] != newValue.base[0] {
                locaPathManger.setPath(.HeaderPathsBase1, newPath: newValue.base[0])
            }
            if _headerPaths.base[1] != newValue.base[1] {
                locaPathManger.setPath(.HeaderPathsBase2, newPath: newValue.base[1])
            }
            _headerPaths = newValue
        }
    }
    
    /// 默认聚搜源数据
    lazy private var _aggreSearPaths: AggreSearPaths = {
        let pathDBM = KRPathsDataSavaDB.pathsDataSavaDB
        return AggreSearPaths(base: pathDBM.getPath(.AggreSearPathsBase))
    }()
    
    /// 默认聚搜源数据
    var aggreSearPaths: AggreSearPaths {
        get {
            return _aggreSearPaths
        }
        set {
            if _aggreSearPaths.base != newValue.base {
                locaPathManger.setPath(.AggreSearPathsBase, newPath: newValue.base)
            }
            _aggreSearPaths = newValue
        }
    }
    
    /// 默认分类源数据
    lazy private var _classificationrPaths: ClassificationrPaths = {
        let pathDBM = KRPathsDataSavaDB.pathsDataSavaDB
        return ClassificationrPaths(detail: pathDBM.getPath(.ClassificationrPathsDetail))
    }()
    
    /// 默认分类源数据
    var classificationrPaths: ClassificationrPaths {
        get {
            return _classificationrPaths
        }
        set {
            if _classificationrPaths.detail != newValue.detail {
                locaPathManger.setPath(.ClassificationrPathsDetail, newPath: newValue.detail)
            }
            _classificationrPaths = newValue
        }
    }
    
    /// 默认常用添加源数据
    lazy private var _commonAddPaths: CommonAddPaths = {
        let pathDBM = KRPathsDataSavaDB.pathsDataSavaDB
        return CommonAddPaths(detail: pathDBM.getPath(.CommonAddPathsDetai))
    }()
    
    /// 默认常用添加源数据
    var commonAddPaths: CommonAddPaths {
        get {
            return _commonAddPaths
        }
        set {
            if _commonAddPaths.detail != newValue.detail {
                locaPathManger.setPath(.CommonAddPathsDetai, newPath: newValue.detail)
            }
            _commonAddPaths = newValue
        }
    }
    
    /// 默认排序源文件<分类、常用添加、细类>
    lazy private var _sortDataPaths: SortDataPaths = {
        let pathDBM = KRPathsDataSavaDB.pathsDataSavaDB
        return SortDataPaths(sort: pathDBM.getPath(.SortDataPathsSort))
    }()
    
    /// 默认排序源文件<分类、常用添加、细类>
    var sortDataPaths: SortDataPaths {
        get {
            return _sortDataPaths
        }
        set {
            if _sortDataPaths.sort != newValue.sort {
                locaPathManger.setPath(.SortDataPathsSort, newPath: newValue.sort)
            }
            _sortDataPaths = newValue
        }
    }
    
    /// 默认输出DB目录
    lazy private var _inputDBFolderPath: String = {
        let pathDBM = KRPathsDataSavaDB.pathsDataSavaDB
        return pathDBM.getPath(.InputDBFolderPath)
    }()
    
    /// 默认输出DB目录
    var inputDBFolderPath: String {
        get {
            return _inputDBFolderPath
        }
        set {
            if _inputDBFolderPath != newValue {
                locaPathManger.setPath(.InputDBFolderPath, newPath: newValue)
            }
            _inputDBFolderPath = newValue
        }
    }
    
    struct Inner {
        static var instance: ParseFilePathManager?
        static var token: dispatch_once_t = 0
    }
    /// 单例类属性
    class var parseFilePathManager: ParseFilePathManager {
        dispatch_once(&Inner.token) { () -> Void in
            Inner.instance = ParseFilePathManager()
        }
        return Inner.instance!
    }
    
}

extension ParseFilePathManager {
    /// 本地源数据
    struct LocationPaths {
        var detail: String
        var gov: String
        var popSite: String
    }
    
    /**
     细类数据
     */
    struct DetailClassPaths {
        var detail: String
    }
    
    /**
     头部源数据
     */
    struct HeaderPaths {
        var base: [String]
    }
    /**
     聚搜源数据
     */
    struct AggreSearPaths {
        var base: String
    }
    /**
     分类源数据
     */
    struct ClassificationrPaths {
        var detail: String
    }
    /**
     常用添加源数据
     */
    struct CommonAddPaths {
        var detail: String
    }
    /**
     排序源数据<分类、常用添加、细类>
     */
    struct SortDataPaths {
        var sort: String
    }
}

enum KRPathsDataSavaDBKeyType: Int {
    case LocationPathsDetail = 1
    case LocationPathsGov
    case LocationPathsPopSite
    case DetailClassPathsDetail
    case HeaderPathsBase1
    case HeaderPathsBase2
    case AggreSearPathsBase
    case ClassificationrPathsDetail
    case CommonAddPathsDetai
    case SortDataPathsSort
    case InputDBFolderPath
}

/// 路径本地管理
class KRPathsDataSavaDB {
    
    let KEYLocationPathsDetail          = "LocationPathsDetail"
    let KEYLocationPathsGov             = "LocationPathsGov"
    let KEYLocationPathsPopSite         = "LocationPathsPopSite"
    let KEYDetailClassPathsDetail       = "DetailClassPathsDetail"
    let KEYHeaderPathsBase1             = "HeaderPathsBase1"
    let KEYHeaderPathsBase2             = "HeaderPathsBase2"
    let KEYAggreSearPathsBase           = "AggreSearPathsBase"
    let KEYClassificationrPathsDetail   = "ClassificationrPathsDetail"
    let KEYCommonAddPathsDetai          = "CommonAddPathsDetail"
    let KEYSortDataPathsSort            = "SortDataPathsSort"
    let KEYInputDBFolderPath            = "InputDBFolderPath"
    
    let fileName = "ParseSettingPaths"
    
    private var dbManger: FMDBUseClass
    private let tableNameOfContent = "locaSetPaths"
    
    var filePath: String
    
    struct Inner {
        static var instance: KRPathsDataSavaDB?
        static var token: dispatch_once_t = 0
    }
    
    class var pathsDataSavaDB: KRPathsDataSavaDB {
        dispatch_once(&Inner.token) { () -> Void in
            Inner.instance = KRPathsDataSavaDB()
        }
        return Inner.instance!
    }
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let bundleIdentifierStr = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as! String
        let suppPath = paths[0] + "/" + bundleIdentifierStr
        
        filePath = suppPath + "/" + fileName + ".db"
        dbManger = FMDBUseClass(basePath: suppPath, dbName: fileName)
        // 不存在则创建默认
        if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            defaultSetting()
        }
    }
    
    /**
     初始化
     */
    func defaultSetting() {
        
        dbManger.openDB()// 打开数据库
        
        // 建表
        dbManger.createTable(tableNameOfContent, fieldAndPros: [
            "name varchar PRIMARY KEY NOT NULL",
            "path varchar NOT NULL"
            ])
        
        let keyToPaths = [
            KEYLocationPathsDetail: "/Users/jingwang/Documents/SVN/37abc Data/手机版/手机版通用数据/首页本地数据手机版.csv",
            KEYLocationPathsGov: "/Users/jingwang/Documents/SVN/37abc Data/手机版/省政府机构",
            KEYLocationPathsPopSite: "/Users/jingwang/Documents/SVN/37abc Data/手机版/手机版通用数据/本地名站手机版.csv",
            KEYDetailClassPathsDetail: "/Users/jingwang/Desktop/52/53",
            KEYHeaderPathsBase1: "/Users/jingwang/Documents/SVN/37abc Data/手机版/手机版通用数据/1.首页默认头部手机版.csv",
            KEYHeaderPathsBase2: "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据/3.苹果版53个分类里的头部.csv",
            KEYAggreSearPathsBase: "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据/4.苹果版聚搜里的数据.csv",
            KEYClassificationrPathsDetail: "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据/2.首页分类里的数据.csv",
            KEYCommonAddPathsDetai: "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据/1.首页常用添加里的数据.csv",
            KEYSortDataPathsSort: "/Users/jingwang/Documents/SVN/37abc Data/手机版/手机版通用数据/首页分类排序.csv",
            KEYInputDBFolderPath: "/Users/jingwang/Desktop/52"
        ]
        
        // 整合值
        var values: [String] = []
        for (key, value) in keyToPaths {
            let sqlValues = "\"\(key)\", \"\(value)\""
            values.append(sqlValues)
        }
        
        let fields = "name, path"
        var success = true
        
        for value in values {
            let status = dbManger.insertData(tableNameOfContent, fields: fields, values: value)
            if success && !status {
                success = false
            }
        }
        dbManger.closeDB() // 关闭数据库
        print("初始化" + (success ? "成功" : "失败"))
    }
    
     /**
     获取路径
     
     - parameter pathType: 路径类型
     
     - returns: 路径
     */
    func getPath(pathType: KRPathsDataSavaDBKeyType) -> String {
        let identifier = getKeyIdentifier(pathType)
        let path = queryPathFromDB(identifier)
        return path!
    }
    
    /**
     更新路径
     
     - parameter pathType: 路径类型
     - parameter newPath:  新路径
     
     - returns: 更新结果
     */
    func setPath(pathType: KRPathsDataSavaDBKeyType, newPath: String) -> Bool {
        let identifier = getKeyIdentifier(pathType)
        let updateStatus = updatePathTiDB(identifier, newPath: newPath)
        print("更新" + (updateStatus ? "成功" : "失败"))
        return updateStatus
    }
}

private extension KRPathsDataSavaDB {
    /**
     通过路径类型获取Identifier
     
     - parameter pathType: 路径类型
     
     - returns: Identifier
     */
    func getKeyIdentifier(pathType: KRPathsDataSavaDBKeyType) -> String {
        var key: String
        switch pathType {
        case .AggreSearPathsBase:
            key = KEYAggreSearPathsBase
        case .ClassificationrPathsDetail:
            key = KEYClassificationrPathsDetail
        case .CommonAddPathsDetai:
            key = KEYCommonAddPathsDetai
        case .DetailClassPathsDetail:
            key = KEYDetailClassPathsDetail
        case .HeaderPathsBase1:
            key = KEYHeaderPathsBase1
        case .HeaderPathsBase2:
            key = KEYHeaderPathsBase2
        case .InputDBFolderPath:
            key = KEYInputDBFolderPath
        case .LocationPathsDetail:
            key = KEYLocationPathsDetail
        case .LocationPathsGov:
            key = KEYLocationPathsGov
        case .LocationPathsPopSite:
            key = KEYLocationPathsPopSite
        case .SortDataPathsSort:
            key = KEYSortDataPathsSort
        }
        return key
    }
    
    /**
     从数据库获取路径
     
     - parameter identifier: 路径标记
     
     - returns: 路径
     */
    func queryPathFromDB(identifier: String) -> String?  {
        
        // 查询数据库
        let sql = "SELECT path FROM locaSetPaths WHERE name like '\(identifier)'"
        dbManger.openDB()
        let rs = dbManger.db.executeQuery(sql, withArgumentsInArray: [])
        
        // 获取解析结果
        var path: String?
        while rs.next() {
            if let tempPath = rs.stringForColumn("path") {
                path = tempPath
            }
        }
        return path
    }
    
    /**
     更新路径到数据库
     
     - parameter identifier: 标记
     - parameter newPath:    新路径
     
     - returns: 更新结果
     */
    func updatePathTiDB(identifier: String, newPath: String) -> Bool {
        dbManger.openDB()
        let sql = "UPDATE locaSetPaths SET path = '\(newPath)' WHERE name = '\(identifier)'"
        let updateStatus = dbManger.db.executeUpdate(sql, withArgumentsInArray: [])
        dbManger.closeDB()
        return updateStatus
    }
}
