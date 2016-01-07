//
//  ZYAggreSearDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/8.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// ZYAggreSear.db
class ZYAggreSearDataManager: KRDataManager {
    
    // DealDataName
    lazy private var dealDataNameDetail = "ZYAggreSear-Detail.csv"
    lazy private var dealDataNameFristLayer = "ZYAggreSear-FristLayer.csv"
    
    // Heads--------------------------------------------
    /// Heads - Detail
    lazy private var headsDetail = ["top_name", "cate_name", "name", "url", "s_url"]
    /// Heads - FristLayer
    lazy private var headsFristLayer = ["name", "hasSec"]
    /// Heads - FristLayer Sourch
    lazy private var headsFristLayerS = ["top_name", "cate_name"]
    
    /**
     处理Detail文件
     
     - parameter filePath: 文件路径
     */
    func dealDataOfDetail(filePath: String) {
        let sText = try! fileEngine.readStringFromFile(filePath)
        var dealStr = textEngine.headGroupText(headsDetail)
        textEngine.splitTextInRelgular(sText, column: headsDetail.count) { (text) -> () in
            
            // 过滤多余信息
            let fristPar = self.textEngine.parseCellFristcolumn(text)
            let clearPar = fristPar.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
            if clearPar.isEmpty {
                self.inputLogText("过滤数据："  + text)
            } else {
                dealStr += ("\n" + text)
            }
        }
        try! dealStr.writeToFile(toFolder + "/" + dealDataNameDetail, atomically: true, encoding: NSUTF8StringEncoding)
        inputLogText("写入成功：" + dealDataNameDetail)
    }
    // Deal FristLayer
    func dealDataOfFristLayer(filePath: String) {
        let parseObject = try! fileEngine.jsonObjectFromFile(filePath)// 解析JSON文件
        let parseArray = parseObject as! [Dictionary<String, String>]
        var topNames: [String] = []
        var topNamesDict: [String: Bool] = [:]
        for item in parseArray {
            let topName = item[headsFristLayerS[0]]!
            let cateName = item[headsFristLayerS[1]]!
            if topNamesDict[topName] == nil {
                topNames.append(topName)
            }
            topNamesDict[topName] = (cateName != "0")
        }
        var resultStr = textEngine.headGroupText(headsFristLayer)
        for topName in topNames {
            let nextStatus = topNamesDict[topName]!
            resultStr += ("\n" + topName + "," + (nextStatus ? "1": "0"))
        }
        try! resultStr.writeToFile(toFolder + "/" + dealDataNameFristLayer, atomically: true, encoding: NSUTF8StringEncoding)
    }
}

extension ZYAggreSearDataManager {
     /**
     处理Detail文件(To DB)
     
     - parameter filePath:  文件路径
     - parameter splitText: 分割操作
     */
    func dealDetailOfSourceData(filePath: String, splitText: EnumerateSplitTextAndProValueFunc) {
        var totalLineData = 0
        parseFileText(filePath, fieldCount: headsDetail.count, isClearSpanceLine: true) { (simpleData, progress) -> () in
            totalLineData = progress.total
            // 过滤多余信息
            let fristPar = self.textEngine.parseCellFristcolumn(simpleData)
            let clearPar = fristPar.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
            if clearPar.isEmpty {
                self.inputLogText("过滤数据："  + simpleData)
            } else {
                let currentPro =  (Double(progress.index)/Double(progress.total))// 进度条
                splitText(simpleData: simpleData, progress: currentPro)
            }
        }
        inputLogText("数据总量：\(totalLineData)")
    }
}


