//
//  MoreClassDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/4.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation
/// 多类过滤组
let moreClassIgnoreClassData: Set<String> = ["彩票"]

/// ZYDetailClass.db
/// 51个分类数据管理
class MoreClassDataManager: KRDataManager {
    /// mainSort Head
    lazy var mainSortHead = ["name", "image", "sort"]
    /// detail Head
    lazy var detailHead = ["class", "head", "title", "url"]
    
    
    /// 根目录过滤文件组
    lazy var rootIgnoreFilesName: Set<String> = ["55.手机网页版聚搜里的数据.csv"]
    /// 某类过滤文件组
    lazy var ignoreClassData: Set<String> = moreClassIgnoreClassData
    
    /// 文本管理
    lazy var textManager: KRTextManager = KRTextManager()
    /// 文件管理
    lazy var fileManager: KRFileWriteReadManager = KRFileWriteReadManager()
    /// 文件名管理
    private lazy var filesNameEngine = FilesNameManager()
    
    init() {
        super.init("/Users/jingwang/Desktop/52/53/setting")
    }
    
    // 解析51个分类文件夹
    func parseFileOfFolder(path: String) -> Bool {
        // 解析文件夹
        let filesNameEngine = FilesNameManager()
        guard let parseFolder = filesNameEngine.parseFolderFileName(path) else {
            return false
        }
        // Head Colum
        let totalHead = detailHead.reduce("") { (result :String, item:String) -> String in
            return result + (result.isEmpty ? "" : ",") + item
        }
        let keyToImageHead = mainSortHead.reduce("") { (result :String, item:String) -> String in
            return result + (result.isEmpty ? "" : ",") + item
        }
        
        // 获取键图组
        guard let keyToImageSource = dealKeyToImage() else {
            return false
        }
        
        // 组合所有文件资料
        var dealData: String = totalHead + "\n"
        var keyToImageNew = keyToImageHead + "\n"
        
        for (index, item) in parseFolder.enumerate() {
            let dealKey = item[filesNameEngine.dealedKey]!
            // 处理键图数据
            let imageName = keyToImageSource[dealKey]
            keyToImageNew += (dealKey + "," + (imageName == nil ? "": imageName!) + "," + "\(index + 1)" + "\n")
            
            // 解析单个文件
            guard let dealResult = dealDataOfFile(path+"/"+item[filesNameEngine.sourchPath]!, key: dealKey) else {
                continue
            }
            dealData += dealResult
        }
        dealData = dealData.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\n"))
        keyToImageNew = keyToImageNew.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\n"))
        
        let writeStatus1 = writeDataToPath(path, fileName: "resultData.csv", writeString:  dealData)
        if !writeStatus1 {
            return false
        }
        return writeDataToPath(path, fileName: "KeyToImmage.csv", writeString: keyToImageNew)
    }
    

}

// MARK: - V1.1
extension MoreClassDataManager {
    /**
     解析More分类文件夹(ToDB)
     
     - parameter path:      源文件文件夹
     - parameter splitText: 分割的文本
     
     - returns: 解析结果
     */
    func parseFileOfFolderToDB(path: String, splitText: EnumerateSplitTextAndProValueFunc) -> Bool {
        // 解析文件夹
        let filesNameEngine = FilesNameManager()
        guard let parseFolder = filesNameEngine.parseFolderFileName(path) else {
            return false
        }
        var totalLine = 0
        for (index, item) in parseFolder.enumerate() {
            let itemPro = 1 / Double(parseFolder.count)
            let dealKey = item[filesNameEngine.dealedKey]!
            var simpeFileLine = 0
            
            // ----------------------------- dealData
            parseFileText(path+"/"+item[filesNameEngine.sourchPath]!, fieldCount: detailHead.count-1, splitText: { (simpleData, progress) -> () in
                simpeFileLine = progress.total
                let totalPro = itemPro*(Double(index) +  (Double(progress.index)/Double(progress.total)))// 进度条
                let newSimpleData = "'\(dealKey)', " + simpleData// 添加头数据
                splitText(simpleData: newSimpleData, progress: totalPro)
            })
            totalLine += simpeFileLine
        }
        inputLogText("总共 \(totalLine) 条数据")
        return true
    }
    
    /**
    解析文件夹<Use>
    
    - parameter base:      基本文件夹
    - parameter special:   特殊文件文件夹
    - parameter splitText: 分割动作
    */
    func parseFoldersToDB(base: String, special: String, splitText: EnumerateSplitTextAndProValueFunc? = nil) {
        
        let rootFolderR = parseRootFolder(base) // 根目录解析
        let specialFolderR = parseSpecialFolder(special)// 特殊目录文件解析
        
        // 遍历
        let specialKeys = specialFolderR.keys
        var indexDeal = 0//  处理文件位置
        let itemPro = 1 / Double(rootFolderR.count)
        var allFilesDataLine = 0
        // 遍历文件组
        for (key, value) in rootFolderR {
            // 记录进度
            let dealedFilesPro = Double(indexDeal) * itemPro// 已处理文件进度
            
            // 查看是否需要过滤
            if ignoreClassData.contains(key) {
                inputLogText("过滤大类数据 > " + key)
            } else {
                let tempUsingPath = specialKeys.contains(key) ? specialFolderR[key]! : value//  调用特殊文件
                
                // 解析文件
                let fileDataLine =
                parseFileText(key, filePath: tempUsingPath, splitText: { (simpleData, progress) -> () in
                    let pro = dealedFilesPro + itemPro * progress
                    splitText?(simpleData: simpleData, progress: pro)
                })
                allFilesDataLine += fileDataLine// 记录数据总条数
            }
            // 记录进度
            indexDeal++// 处理文件位置
        }
        inputLogText("总共 \(allFilesDataLine) 条数据")
    }
    
    /**
     解析单个文件文本
     
     - parameter key:       处理文件Key
     - parameter filePath:  文件路径
     - parameter splitText: 分解文本操作
     
     - returns: 处理数据条数
     */
    func parseFileText(key: String, filePath: String, splitText: EnumerateSplitTextAndProValueFunc) -> Int {
        var simpeFileLine = 0// 记录数据条数
        parseFileText(filePath, fieldCount: detailHead.count-1, splitText: { (simpleData, progress) -> () in
            simpeFileLine++// 记录数据条数
            let newSimpleData = "'\(key)', " + simpleData// 添加头数据
            let pro = Double(progress.index) / Double(progress.total)
            splitText(simpleData: newSimpleData, progress: pro)
        })
        return simpeFileLine
    }
    
    /// 根目录解析
    func parseRootFolder(folder: String) -> [String: String] {
        // 解析文件夹
        return filesNameEngine.parseFolderBase(folder, rootDirIgnore: rootIgnoreFilesName)
    }
    
    /// 特殊路径解析
    func parseSpecialFolder(folder: String) -> [String: String] {
        let result = filesNameEngine.parseAllRootFileInFolder(folder)// 获取根目录下文件名
        // 筛选
        var usingKeyToPath: [String: String] = [:]//筛选结果
        let matchStr = "(?<=-手机-苹果版)([^.]+)(?=.csv)"//特殊文件匹配
        for item in result! {
            let parseResult = textEngine.parseText(item, matchStr: matchStr)
            if parseResult.count > 0 {
                usingKeyToPath[parseResult[0]] = folder + "/" + item
            }
        }
        return usingKeyToPath
    }
    
    /**
     处理MainSort数据
     
     - parameter sData:     源数据
     - parameter splitText: 枚举解析结果
     */
    func dealMainSortToDB(sData: [String], splitText: EnumerateSplitTextAndProValueFunc) {
        let titleToImage = dealKeyToImage()!// 标签To图Dict
        
        // 处理解析
        let totalCount = sData.count
        for (index, item) in sData.enumerate() {
            var imageName = ""
            if let oImage = titleToImage[item] {
                imageName = oImage
            }
            let sqlValue = "'\(item)'" + "," + "'\(imageName)'" + "," + "\(index+1)"
            let progress = Double(index+1)/Double(totalCount)// 进度
            splitText(simpleData: sqlValue, progress: progress)// 枚举处理结果
        }
        inputLogText("数据总量：\(totalCount)")
    }
}

private extension MoreClassDataManager {
    
    func writeAllFile(path: String, files: [(fileName: String, dataStr: String)]) -> Bool {
        for file in files {
            let writeStatus1 = writeDataToPath(path, fileName: file.fileName, writeString:  file.dataStr)
            if !writeStatus1 {
                return false
            }
        }
        return true
    }
    
    /**
     写入字符串至路径
     
     - parameter path:        路径
     - parameter fileName:    文件名
     - parameter writeString: 写入的文件
     */
    func writeDataToPath(basePath: String, fileName: String, writeString: String) -> Bool {
        do {
            try writeString.writeToFile(basePath + "/setting/" + fileName, atomically: true, encoding: NSUTF8StringEncoding)
            inputLogText(fileName + ": 写入成功")
            return true
        } catch {
            inputLogText(fileName + ": 写入失败")
            return false
        }
    }
    
    
    /**
    处理键值对应图片
    
    - returns: 键对图组
    */
    func dealKeyToImage() -> [String: String]? {
        guard let sourceKeyToImagejson = NSBundle.mainBundle().pathForResource("MainSort", ofType: "json") else {
            return nil
        }
        guard let jsonData = NSData(contentsOfFile: sourceKeyToImagejson) else {
            return nil
        }
        guard let result = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) else {
            return nil
        }
        
        guard let deadResult = result as? [Dictionary<String, String>] else {
            return nil
        }
        
        var parseKeyToImage: [String: String] = [:]
        for item in deadResult {
            let name = item[mainSortHead[0]]!
            let image = item[mainSortHead[1]]!
            if !image.isEmpty {
                parseKeyToImage[name] = image
            }
        }
        return parseKeyToImage
    }
    
    /**
     处理文件数据
     
     - parameter filePath: 文件路径
     - parameter key:      添加的关键字
     
     - returns: 处理结果
     */
    func dealDataOfFile(filePath: String, key: String) -> String? {
        guard let contentStr = try? fileManager.readStringFromFile(filePath) else {
            return nil
        }
        let dealed = textManager.splitTextInNewLine(contentStr)
        return addKeyToLineHead(key, willDealStrings: dealed)
    }
    
    /**
     添加关键字至头部(+清空空白数据)
     
     - parameter key:             将添加的关键字
     - parameter willDealStrings: 将处理的字符串组
     */
    func addKeyToLineHead(key: String, willDealStrings: [String]) -> String {
        var dealed: String = ""
        for lineStr in willDealStrings {
            if !lineStr.isEmpty {
                // 清洁文本
                let clearStr = textManager.clearSimpleLine(lineStr)
                
                dealed += key + "," + clearStr + "\n"
                continue
            }
            inputLogText("额外处理：" + lineStr)
        }
        return dealed
    }
}
