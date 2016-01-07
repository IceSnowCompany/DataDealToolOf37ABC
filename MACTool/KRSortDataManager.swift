//
//  KRSortDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/10.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

class KRSortDataManager: KRDataManager {
    enum ParseDataSortType {
        case ClassPop, TotalClass, ClassToDetail, CommandAdd, NotVaild
        
        init(title: String) {
            switch  title {
                case "分类推荐":
                    self = .ClassPop
                case "8个大项顺序":
                    self = .TotalClass
                case "首页添加里的顺序":
                    self = .CommandAdd
                case "":
                    self = .NotVaild
                default:
                    self = .ClassToDetail
            }
        }
    }
    
    var replaceTitle = ["社区游戏": "社区交友"]
    var clearContents: Set<String> = ["游戏", "应用"]
    
    /// Sort 当条数据解析
    func parseSimpleData(textData: String, usingEvery: (fristEle: String, sqlValues: [String]) -> ()) {
        var isNeed = true // 是否需要回传
        var indexEle = 0 // 是否是第一个元素
        var sqlValues: [String] = []// sql语句值部分
        var fristELe: String = ""// 第一个元素记录
        textEngine.splitCsvTextInSimpleLine(textData, usingEvery: { (text) -> () in
            
            indexEle++// 第几位元素
            let clearSESpnse = text.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))// 处理前后空格
            if !isNeed { return }// 不需要的数据，不解析
            
            // 第一个参数处理(空的)
            if indexEle == 2 && clearSESpnse.isEmpty {
                isNeed = false
                return
            }
            
            // 记录第一个元素
            if indexEle == 1 { fristELe = clearSESpnse }
            
            sqlValues += [clearSESpnse]
            
            /*
            // 是否有单引号
            if self.textEngine.hasSingleQuote(clearSESpnse) {
                sqlValues += "\"\(clearSESpnse)\","
            } else {
                sqlValues += "'\(clearSESpnse)',"
            }*/
            
        }) // 解析单条数据成insert语句所需样式
        
        // 枚举回调
        if isNeed {
//            sqlValues = sqlValues.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ","))// 清除尾部多余符号
            usingEvery(fristEle: fristELe, sqlValues: sqlValues)// 回调
        }
    }
    /// 分类推荐
    let dKAggreTop = "aggreTop"
    /// 8个大项顺序
    let dkAggreClassTSort = "aggreClassTSort"
    /// 分类详细排序
    let dkAggreClassDSort = "aggreClassDSort"
    /// 常用添加排序
    let dkCommandAddSort = "commandAddSort"
    
    func parseDataToDB(filePath: String) {
        let resultSet = parseSortFile(filePath)
        
        // ClassificationrSourceToDB
        let sTwoLayer = resultSet[dkAggreClassDSort] as! [Array<String>]
        let sOneLayer = resultSet[dkAggreClassTSort] as! [String]
        let recommendData = resultSet[dKAggreTop] as! [String]
        KRClassificationrSourceToDB().startRun([.SortTwoLayer, .SortOneLayer, .Recommend], sTwoLayer: sTwoLayer, sOneLayer: sOneLayer, recommendData: recommendData)
        
        // CommonAdd&ZYDetailClass
        let czSData = resultSet[dkCommandAddSort] as! [String]
        KRComonAddSourceToDB().startRun([.MainSort], mainSortData: czSData) // CommonAdd
        KRDetailClassSourceToDB().startRun([.MainSort], mainSortSData: czSData)//ZYDetailClass
    }
    
    /// 分割和解析排序文件<基本>
    func parseSortFile(filePath: String, usingEvery: (fristEle: String, sqlValues: [String]) ->()) {
        let sText = try! fileEngine.readStringFromFile(filePath)
        textEngine.splitTextInRelgularAndPro(sText, column: 3) { (text, progress) -> () in
            // 分解&解析
            self.parseSimpleData(text, usingEvery: usingEvery)
        }
    }
    
    /// 合成推荐分类列表
    func synClassPopResult(sData: [String], synSData: [String: String]) -> String {
        var synResult = ""
        for item in sData {
            let headT = synSData[item]!
            synResult += ("\n" + headT + "," + item)
        }
        return synResult
    }
    
    /// 合成分类数据第一层数据组合
    func synSortOneLayerData(newSData: [String]) -> String {
        let constainImageData = getConstainImageData()
        var synStr = ""
        for (index, item) in newSData.enumerate() {
            synStr += ("\n" + item + "," + "\(index + 1)" + "," + constainImageData[item]!)
        }
        if newSData.count != constainImageData.count { inputLogText("SortOneLayer 合成需校验") }
        return synStr
    }
    
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
    
    //MARK: - V1.1
    
    /**
    解析排序文件
    
    - parameter filePath: 文件路径
    
    - returns: 解析结果
    */
    func parseSortFile(filePath: String) -> [String: AnyObject] {
        var aggreTop: [String] = [] //  分类推荐
        var aggreClassTSort: [String] = []// 8个大项顺序
        var aggreClassDSort: [Array<String>] = []// 分类详细排序
        var commandAddSort: [String] = []// 常用添加排序
        
        var isENd = false// 是否结束解析
        parseSortFile(filePath) { (fristEle, sqlValues) -> () in
            let secondE = sqlValues[1]
            switch fristEle {
            case "分类推荐":
                // 清洁
                if !self.isClearContent(secondE) {
                    aggreTop.append(secondE)
                }
            case "8个大项顺序":
                let useTitle = self.getAppleToTitle(secondE)
                aggreClassTSort.append(useTitle)
            case "首页添加里的顺序":
                isENd = true// 解析本组完即停止
                if !self.isClearContent(secondE) {
                    commandAddSort.append(secondE)
                }
            default:
                if isENd { return }// 解析完最后一组就不解析
                let fristE = self.getAppleToTitle(sqlValues[0])
                // 清洁
                if !self.isClearContent(secondE) {
                    aggreClassDSort.append([fristE, secondE])
                }
            }
        }
        return [dKAggreTop: aggreTop,
            dkAggreClassTSort: aggreClassTSort,
            dkAggreClassDSort: aggreClassDSort,
            dkCommandAddSort: commandAddSort
        ]
    }
    
    /**
     是否为过滤文本
     
     - parameter item: 待检查文本
     
     - returns: 是否为过滤文本
     */
    func isClearContent(item: String) -> Bool {
        return clearContents.contains(item)
    }
    
    /**
     获取内部标签
     
     - parameter csvValue: DB标签名
     
     - returns: 使用标签
     */
    func getAppleToTitle(csvValue: String) -> String {
        guard let newTitle = replaceTitle[csvValue] else {
            return csvValue
        }
        return newTitle
    }
}