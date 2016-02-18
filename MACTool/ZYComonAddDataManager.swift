//
//  ZYComonAddDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/7.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// 常用添加管理
class ZYComonAddDataManager: KRDataManager {
    
    // Pro
    /// 详细页头部
    private var DetailHead = ["title", "name", "image", "url"]
    private var clearKeys: Set<String> = {
        var temp: Set<String> = ["游戏", "应用"]
        for item in moreClassIgnoreClassData {
            temp.insert(item)
        }
        return temp
    }()
    /// 详细过滤
    lazy private var clearDetail: Set<String> = {
        
        let locaPath = NSBundle.mainBundle().pathForResource("CommandAddCleard", ofType: "plist")!
        let clearArr = NSArray(contentsOfFile: locaPath) as! [String]
        return Set(clearArr)
    }()
    
    /**
     处理Detail数据
     
     - parameter filePath: 原始文件
     - parameter toFolder: 解析文件保存文件夹
     */
    func dealDetailData(filePath: String) {
        let text = try! fileEngine.readStringFromFile(filePath)// 读取文件
        
        var result: String = textEngine.headGroupText(DetailHead)
        textEngine.splitTextInRelgular(text, column: DetailHead.count) { (text) -> () in
            let head = self.textEngine.parseCellFristcolumn(text)
            if !self.clearKeys.contains(head) {
                result += ("\n" + text)
            }
        }
        
        try! result.writeToFile(toFolder + "/" + "dealCommanAdd-Detail.csv", atomically: true, encoding: NSUTF8StringEncoding)
        inputLogText("写入成功：" + "dealCommanAdd-Detail.csv")
    }
    

    
    /// MainSort页表头
    private lazy var headMainSort = ["name", "image", "sort"]
    /// New To MainSort的表头
    private lazy var headDetailTitle = "title"

    
}
// MARK: - V1.1
extension ZYComonAddDataManager {
    /**
     处理Detail数据
     
     - parameter filePath: 原始文件
     - parameter toFolder: 解析文件保存文件夹
     */
    func dealDetailDataToDB(filePath: String, splitText: EnumerateSplitTextAndProValueFunc) {
        var totalLineData = 0
        parseFileText(filePath,
            fieldCount: DetailHead.count,
            clearTitles: clearKeys,
            clearDetail: clearDetail) { (simpleData, progress) -> () in
                totalLineData = progress.total// 记录总数据数
                let currentPro =  (Double(progress.index)/Double(progress.total))// 进度条
                splitText(simpleData: simpleData, progress: currentPro)
        }
        inputLogText("数据总量：\(totalLineData)")
    }
    
    /**
    处理MainSort数据
    
    - parameter sData:     源数据
    - parameter splitText: 枚举解析结果
    */
    func dealMainSortToDB(sData: [String], splitText: EnumerateSplitTextAndProValueFunc) {
        let titleToImage = titleToImageDict// 标签To图Dict
        
        // 推荐<预配>
        let newArr = ["推荐"] + sData
        
        // 处理解析
        let totalCount = newArr.count
        for (index, item) in newArr.enumerate() {
            var imageName = ""
            if let oImage = titleToImage[item] {
                imageName = oImage
            }
            let sqlValue = "'\(item)'" + "," + "'\(imageName)'" + "," + "\(index+1)"
            let progress = Double(index)/Double(totalCount)// 进度
            splitText(simpleData: sqlValue, progress: progress)// 枚举处理结果
        }
        inputLogText("数据总量：\(totalCount)")
    }
}
private extension ZYComonAddDataManager {
    /// 旧的标签To图片字典
    var titleToImageDict: [String: String] {
        let titleToImageFilePath = NSBundle.mainBundle().pathForResource("CA_MainSort", ofType: "json")!// 源文件路径
        let titleToImageData = parseSourceJSONData(titleToImageFilePath)
        return titleToImageData
    }
    
    /**
     解析源JSON数据
     
     - parameter filePath: 源数据路径
     
     - returns: 解析的数据
     */
    func parseSourceJSONData(filePath: String) -> [String: String] {
        // 源数据
        let resultS = parseJSONFile(filePath)
        var keyToImage: [String: String] = [:]
        for item in resultS {
            let name = item[headMainSort[0]]!
            let image =  item[headMainSort[1]]!
            if !image.isEmpty {
                keyToImage[name] = image
            }
        }
        return keyToImage
    }
    
    /**
     解析新JSON数据
     
     - parameter filePath: 新JSON数据路径
     
     - returns: 解析的数据
     */
    func parseNewJSONData(filePath: String, keyToImage: [String: String]) -> [Dictionary<String, String>] {
        let resultN = parseJSONFile(filePath)
        var resultData: [Dictionary<String, String>] = []
        for (index, item) in resultN.enumerate() {
            let title = item[headDetailTitle]!
            if clearKeys.contains(title) { continue } // 过滤违规字段
            var image = ""
            if let imageS = keyToImage[title]  {
                image = imageS
            }
            let dict = [headMainSort[0]: title, headMainSort[1]: image, headMainSort[2]: "\(index + 1)"]
            resultData.append(dict)
        }
        return resultData
    }
    /// 解析新的数据并合并旧数据的图片
    func parseNewMainSort(ndData: [String], titleToImage: [String: String]) -> String {
        var resultData: String = headMainSort[0] + "," + headMainSort[1] + "," + headMainSort[2]
        
        // +推荐
        resultData += "\n推荐,,1"
        
        for (index, item) in ndData.enumerate() {
            if clearKeys.contains(item) {
                self.inputLogText("过滤违规字段: \(item)")
                continue
            } // 过滤违规字段
            var image = ""
            if let imageS = titleToImage[item]  {
                image = imageS
            }
            resultData += ("\n" + item + "," + image + "," + "\(index + 2)")
        }
        return resultData
    }
    
    
    /**
     解析JSON文件
     
     - parameter filePath: JSON文件路径
     
     - returns: 解析的文件
     */
    func parseJSONFile(filePath: String) -> [Dictionary<String, String>] {
        let data = NSData(contentsOfFile: filePath)!
        let resultS = try! NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! [Dictionary<String, String>]
        return resultS
    }
}