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
    /// 默认本地源文件
    lazy var locationPaths: LocationPaths = {
        return LocationPaths(
            detail: "/Users/jingwang/Documents/SVN/37abc Data/手机版/手机版通用数据/首页本地数据手机版.csv",
            gov: "/Users/jingwang/Documents/SVN/37abc Data/手机版/省政府机构",
            popSite: "/Users/jingwang/Documents/SVN/37abc Data/手机版/手机版通用数据/本地名站手机版.csv")
    }()
    
    /// 默认细类源文件
    lazy var detailClassPaths: DetailClassPaths = {
        return DetailClassPaths(detail: "/Users/jingwang/Desktop/52/53")
    }()
    
    /// 默认头部源文件
    lazy var headerPaths: HeaderPaths = {
        return HeaderPaths(base: [
            "/Users/jingwang/Documents/SVN/37abc Data/手机版/手机版通用数据/1.首页默认头部手机版.csv",
            "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据/3.苹果版53个分类里的头部.csv"])
    }()
    
    /// 默认聚搜源数据
    lazy var aggreSearPaths: AggreSearPaths = {
        return AggreSearPaths(base: "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据/4.苹果版聚搜里的数据.csv")
    }()
    
    /// 默认分类源数据
    lazy var classificationrPaths: ClassificationrPaths = {
        return ClassificationrPaths(detail: "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据/2.首页分类里的数据.csv")
    }()
    
    /// 默认常用添加源数据
    lazy var commonAddPaths: CommonAddPaths = {
        return CommonAddPaths(detail: "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据/1.首页常用添加里的数据.csv")
    }()
    
    /// 默认排序源文件<分类、常用添加、细类>
    lazy var sortDataPaths: SortDataPaths = {
        return SortDataPaths(sort: "/Users/jingwang/Documents/SVN/37abc Data/手机版/手机版通用数据/首页分类排序.csv")
    }()
    /// 默认输出DB目录
    lazy var inputDBFolderPath = "/Users/jingwang/Desktop/52"
    
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

extension ParseFilePathManager {
    func readFile() {
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let bundleIdentifierStr = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as! String
        let suppPath = paths[0] + "/" + bundleIdentifierStr
        print(suppPath)
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
    var data: PathsData!
    var filePath: String
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let bundleIdentifierStr = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"] as! String
        let suppPath = paths[0] + "/" + bundleIdentifierStr
        filePath = suppPath + "/" + fileName + ".plist"
        if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            defaultSetting()
            updateFile()
        } else {
            let fileData = NSDictionary(contentsOfFile: filePath)!
            data = PathsData(lcoationData: fileData)
        }
    }
    
    func read() {
        
    }
    
    func write(path: String, type: KRPathsDataSavaDBKeyType) {
        var key: String
        switch type {
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
            
        case .InputDBFolderPath:
        case .LocationPathsDetail:
        case .LocationPathsGov:
        case .LocationPathsPopSite:
        case .SortDataPathsSort:
        }
    }
    
    /**
     更新本地文件
     */
    func updateFile() {
        (data.synNSDict() as NSDictionary).writeToFile(filePath, atomically: true)
    }
    /**
     初始化
     */
    func defaultSetting() {
        let defaultData = PathsData(version: "1",
            data: [
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
            ])
        data = defaultData
    }
    
    struct PathsData {
        var version: String
        var data: [String: String]
        
        init(version: String, data: [String: String]) {
            self.version = version
            self.data = data
        }
        
        init(lcoationData: NSDictionary) {
            version = lcoationData["version"] as! String
            data = lcoationData["data"] as! [String: String]
        }
        
        func synNSDict() -> [String: AnyObject] {
            return ["version": version, "data": data]
        }
        
    }
}
