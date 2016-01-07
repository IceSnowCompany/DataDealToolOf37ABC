//
//  ZYClassificationDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/7.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

class ZYClassificationDataManage: KRDataManager {
    
    lazy private var headDetail = ["title", "name", "url"]
    lazy private var clearHeadWords: Set<String> = ["游戏", "应用"]
    
    /// 处理 DetailData
    func dealDetailData(filePath: String) {
        let text = try! fileEngine.readStringFromFile(filePath)
        var resultStr = textEngine.headGroupText(headDetail)
        textEngine.splitTextInRelgular(text,
            column: headDetail.count,
            clearHeadSet: clearHeadWords) { (text) -> () in
                resultStr += ("\n" + text)
        }
        try! resultStr.writeToFile(toFolder + "/" + "dealDetail.csv", atomically: true, encoding: NSUTF8StringEncoding)
    }
    
    /**
     处理Detail数据(to DB)
     
     - parameter filePath:  源文件路径
     - parameter splitText: 分割操作
     */
    func dealDetailDataToDB(filePath: String, splitText: EnumerateSplitTextAndProValueFunc) {
        var totalLineData = 0
        parseFileText(filePath, fieldCount: headDetail.count, clearTitles: clearHeadWords) { (simpleData, progress) -> () in
            totalLineData = progress.total// 记录总数据数
            let currentPro =  (Double(progress.index)/Double(progress.total))// 进度条
            splitText(simpleData: simpleData, progress: currentPro)
        }
        inputLogText("数据总量：\(totalLineData)")
    }
    
    /**
     处理SortTwoLayer源数据(To DB)
     
     - parameter sData:     源数据
     - parameter splitText: 枚举操作
     */
    func dealSortTwoLayerToDB(sData: [Array<String>], splitText: EnumerateSplitTextAndProValueFunc) {
        var totalLineData = 0
        paresDataSet(sData) { (simpleData, progress) -> () in
            totalLineData = progress.total// 记录总数据数
            let currentPro =  (Double(progress.index)/Double(progress.total))// 进度条
            splitText(simpleData: simpleData, progress: currentPro)
        }
        inputLogText("数据总量：\(totalLineData)")
    }
    
    /**
     处理SortOneLayer源数据(To DB)
     
     - parameter sData:     源数据
     - parameter splitText: 枚举操作
     */
    func dealSortOneLayerToDB(sData: [String], splitText: EnumerateSplitTextAndProValueFunc)  {
        let keyToImageDict = getConstainImageData()
        let totalCount = sData.count// 数据总数
        for (index, item) in sData.enumerate() {
            let image = keyToImageDict[item]!// 图片名称
            let progress = Double(index)/Double(totalCount)// 进度
            let sqlValues = ("'\(item)'" + "," + "\(index+1)" + "," + "'\(image)'")
            splitText(simpleData: sqlValues, progress: progress)
        }
        inputLogText("数据总量：\(totalCount)")
    }
    
    /**
     处理Recommend源数据(To DB)
     
     - parameter sData:        源数据
     - parameter getClassName: 获取对应项名
     - parameter splitText:    枚举解析结果
     */
    func dealRecommendToDB(sData: [String], getClassName: (title: String) -> String, splitText: EnumerateSplitTextAndProValueFunc) {
        let totalCount = sData.count
        for (index, item) in sData.enumerate() {
            let className = getClassName(title: item)
            let sqlValues = "'\(className)'" + "," + "'\(item)'"
            let progress = Double(index)/Double(totalCount)// 进度
            splitText(simpleData: sqlValues, progress: progress)
        }
        inputLogText("数据总量：\(totalCount)")
    }
    
    
}

private extension ZYClassificationDataManage {
    /// 获取包含图片数据
    func getConstainImageData() -> Dictionary<String, String> {
        let constainImageDataPath = NSBundle.mainBundle().pathForResource("SortOneLayer", ofType: "json")!
        let constainImageData = try! fileEngine.jsonObjectFromFile(constainImageDataPath) as! [Dictionary<String, String>]
        var result: [String: String] = [:]
        for item in constainImageData {
            let name = item["name"]!
            let image = item["image"]!
            result[name] = image
        }
        return result
    }
}
