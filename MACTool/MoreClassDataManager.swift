//
//  MoreClassDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/4.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// ZYDetailClass.db
/// 51个分类数据管理
class MoreClassDataManager: KRDataManager {
    /// mainSort Head
    lazy var mainSortHead = ["name", "image", "sort"]
    /// detail Head
    lazy var detailHead = ["class", "head", "title", "url"]
    
    /// 文本管理
    lazy var textManager: KRTextManager = KRTextManager()
    /// 文件管理
    lazy var fileManager: KRFileWriteReadManager = KRFileWriteReadManager()
    
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
