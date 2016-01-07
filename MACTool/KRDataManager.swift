//
//  KRDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/7.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// 带进度值0...1
typealias EnumerateSplitTextAndProValueFunc = (simpleData: String, progress: Double) -> ()

class KRDataManager: ConstantLogClass {
    // Engine
    /// 文件管理
    lazy var fileEngine = KRFileWriteReadManager()
    /// 文本管理
    lazy var textEngine = KRTextManager()
    lazy var fileNameEngine = FilesNameManager()
    
    // Pro
    /// 保存文件夹
    var toFolder: String
    
    init(_ toFolder: String) {
        self.toFolder = toFolder
    }
    
     /**
     解析文件文本<V1.0>
     
     - parameter filePath: 解析文件路径
     - parameter column:   解析的列数
     
     - returns: 解析结果(头行带\n)
     */
    func parseText(filePath: String, column: Int)  -> String {
        let sText = try! fileEngine.readStringFromFile(filePath)
        var resultStr = ""
        textEngine.splitTextInRelgular(sText, column: column) { (text) -> () in
            resultStr += ("\n" + text)
        }
        return resultStr
    }
}
// MARK: - ToDB V1.1
extension KRDataManager {
     /**
     解析批量同类型文件文本(to DB)<V2.0>
     
     - parameter filesPath:   同类型文件路径组
     - parameter fieldCount:  字段个数
     - parameter splitAction: 分割动作
     */
    func parseFiles(filesPath: [String], fieldCount: Int, splitAction: EnumerateSplitTextAndProValueFunc) {
        for (index, filePath) in filesPath.enumerate() {
            let itemPro = 1 / Double(filesPath.count)
            parseFileText(filePath, fieldCount: fieldCount, splitText: { (simpleData, progress) -> () in
                let totalPro = itemPro*(Double(index) +  (Double(progress.index)/Double(progress.total)))
                splitAction(simpleData: simpleData, progress: totalPro)
            })
        }
    }
    
    /// 解析文件文本 (to DB)<+清空空白数据><V2.0>
    func parseFileText(filePath: String, fieldCount: Int, isClearSpanceLine: Bool = false, splitText: (simpleData: String, progress: (index: Int, total: Int)) -> ()) {
        let sText = try! fileEngine.readStringFromFile(filePath)
        textEngine.splitTextInRelgularAndPro(sText, column: fieldCount) { (text, progress) -> () in
            var isNeed = true
            var isFristEle = true
            var sqlValues: String = ""
            // 分割元素
            self.textEngine.splitCsvTextInSimpleLine(text, usingEvery: { (text) -> () in
                let clearSESpnse = text.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))// 处理前后空格
                
                // 不需要的轮空
                if isClearSpanceLine && (!isNeed) {
                    return
                }
                
                // 清洁(第一个参数空白)
                if isClearSpanceLine && isFristEle {
                    if clearSESpnse.isEmpty {
                        isNeed = false
                        return
                    }
                    isFristEle = false
                }
                
                // 是否有单引号
                if self.textEngine.hasSingleQuote(clearSESpnse) {
                    sqlValues += "\"\(clearSESpnse)\","
                } else {
                    sqlValues += "'\(clearSESpnse)',"
                }
            })
            // 不需要的不回递
            if isClearSpanceLine && (!isNeed) {
                self.inputLogText("空白列： \(text)")
                return
            }
            
            sqlValues = sqlValues.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ","))
            splitText(simpleData: sqlValues, progress: progress)
        }
    }
    
    /// 解析文件文本 (to DB)<+过滤数据><V2.0>
    func parseFileText(filePath: String, fieldCount: Int, clearTitles: Set<String>, splitText: (simpleData: String, progress: (index: Int, total: Int)) -> ()) {
        let sText = try! fileEngine.readStringFromFile(filePath)
        textEngine.splitTextInRelgularAndPro(sText, column: fieldCount) { (text, progress) -> () in
            var isNeed = true
            var isFristEle = true
            var sqlValues: String = ""
            // 分割元素
            self.textEngine.splitCsvTextInSimpleLine(text, usingEvery: { (text) -> () in
                let clearSESpnse = text.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))// 处理前后空格
                
                // 不需要的轮空
                if !isNeed {
                    return
                }
                
                // 清洁(第一个参数空白)
                if isFristEle {
                    if clearTitles.contains(clearSESpnse) {
                        isNeed = false
                        return
                    }
                    isFristEle = false
                }
                
                // 是否有单引号
                if self.textEngine.hasSingleQuote(clearSESpnse) {
                    sqlValues += "\"\(clearSESpnse)\","
                } else {
                    sqlValues += "'\(clearSESpnse)',"
                }
            })
            // 不需要的不回递
            if !isNeed {
                self.inputLogText("过滤列： \(text)")
                return
            }
            
            sqlValues = sqlValues.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ","))
            splitText(simpleData: sqlValues, progress: progress)
        }
    }
    
    /**
     解析源数据 (to DB)<V2.0>
     
     - parameter sData:        源数据
     - parameter enuParseText: 枚举解析的数据
     */
    func paresDataSet(sData: [Array<String>], enuParseText: (simpleData: String, progress: (index: Int, total: Int)) -> ()) {
        let totalCount = sData.count
        for (index, item) in sData.enumerate() {
            var dealItem = item.reduce("", combine: { (sqlValues, itemStr) -> String in
                let clearSESpnse = itemStr.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))// 处理前后空格
                // 是否有单引号
                if self.textEngine.hasSingleQuote(clearSESpnse) {
                    return sqlValues + "\"\(clearSESpnse)\","
                } else {
                    return sqlValues + "'\(clearSESpnse)',"
                }
            })
            dealItem = dealItem.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ","))
            enuParseText(simpleData: dealItem, progress: (index + 1, totalCount))
        }
    }
}
