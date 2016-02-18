//
//  KRTestManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/7.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation
/**
 正则库
 */
struct KRRegularLibrary {
    private var lib: [String: NSRegularExpression] = [:]
    
    subscript(mathStr: String) -> NSRegularExpression {
        mutating get {
            if lib[mathStr] == nil {
                let regular = try! NSRegularExpression(pattern: mathStr, options: [.CaseInsensitive])
                lib[mathStr] = regular
            }
            return lib[mathStr]!
        }
    }
}

class KRTextManager: ConstantLogClass {
    
    lazy private var newLineCharacterSet = NSCharacterSet(charactersInString: "\n")
    lazy private var commaCharacterSet = NSCharacterSet(charactersInString: ",")
    lazy private var commaSpanceCharacterSet = NSCharacterSet(charactersInString: ",\r ")
    /// 正则表达库
    private var regularLibrary: KRRegularLibrary = KRRegularLibrary()
    /// 缓存正则表达式
    //------------------------------------------------------------------------------------
    private var tempRegularExPression: (column: Int, regularExp: NSRegularExpression)?
    /// 单行首列
    lazy private var regularExpressionCellFrist =  {
        return try! NSRegularExpression(pattern: "^[^,]*", options: [.CaseInsensitive])
    }()
    /// 正则表达式 - 查找多余字符串
    lazy private var regularExpressionOfClearCharaters = {
        return try! NSRegularExpression(pattern: "[ \r\n]", options: .CaseInsensitive)
    }()
    /// 正则表达式 - 正常过滤字符串
    lazy private var regularExpressionOfNormalFilter = {
        return try! NSRegularExpression(pattern: "[ \r\n,]*", options: .CaseInsensitive)
    }()
    /// 正则表达式 - 过滤文件名后缀
    lazy private var regularExpressionOfClearSuffix: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "(.*)(?=.csv)", options: .CaseInsensitive)
    }()
    
    /// 正则表达式 - 解析CSV单元格数据
    lazy private var regularExpressionOfParseCSVText: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "(?<=(^|,))((\"[^\"]*(\"{2})*[^\"]*\")*[^,\n]*)", options: .CaseInsensitive)
    }()
    
    /// 正则表达式 - 解析单引号
    lazy private var regularExpressionOfSingleQuote: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "'", options: .CaseInsensitive)
    }()
    
    //------------------------------------------------------------------------------------
    /**
    单行文本清洁(首尾\r, 空格,)
    
    - parameter sText: 预处理文本
    
    - returns: 处理结果
    */
    func clearSimpleLine(sText: String) -> String {
        var result = ""
        result = sText.stringByTrimmingCharactersInSet(commaSpanceCharacterSet)
        result = result.stringByReplacingOccurrencesOfString(" ,", withString: ",")
        return result
    }
    
     /**
     分割文本(以换行方式)
     
     - parameter sText: 待处理的文本
     
     - returns: 分组
     */
    func splitTextInNewLine(sText: String) -> [String] {
        let dealed = sText.componentsSeparatedByCharactersInSet(newLineCharacterSet)
        return dealed
    }
    
    /// 正则分割文本 - 分割成数据条
    func splitTextInRelgular(sText: String, column: Int, usingEvery:(text: String) ->()) {
        if (tempRegularExPression == nil) || (tempRegularExPression!.column != column) {
            let regularMatch = regularExpressionMatch(column)
            let regular = regularExpression(regularMatch)!
            tempRegularExPression = (column, regular)
        }
        let textNS = NSString(string: sText)
        var locationR = 0
        let textRange = NSRange(location: 0, length: textNS.length)
        
        let totalMatchNumber = tempRegularExPression!.regularExp.numberOfMatchesInString(sText, options: NSMatchingOptions(), range: textRange)
        var indexMatch = 0
        
        tempRegularExPression!.regularExp.enumerateMatchesInString(sText,
            options: .ReportCompletion,
            range: textRange) { ( textCheckingResult: NSTextCheckingResult?, matchingFlags: NSMatchingFlags, stop:  UnsafeMutablePointer<ObjCBool>) -> Void in
                if textCheckingResult == nil { return }
                
                // 进度君
                indexMatch++
                self.inputLogText("\(indexMatch)" + "/" + "\(totalMatchNumber)")
                
                let textRange = textCheckingResult!.range
                
                // 打印过滤掉的部分
                if textRange.location != locationR {
                    let otherRange = NSRange(location: locationR, length: textRange.location - locationR)
                    let filterText = textNS.substringWithRange(otherRange)
                    if !self.isNormalFilter(filterText) {
                        self.inputLogText("不正常过滤字段：" + filterText)
                    }
                }
                locationR = textRange.location + textRange.length
                
                // 获取截取文本
                let text = textNS.substringWithRange(textRange)
                
                // 检查截取的文本
                if self.numberOfsearchClearCharaterInText(text) != 0 {
                    self.inputLogText("检查文本: " + text)
                }
                
                // 枚举
                usingEvery(text: text)
        }
        // 打印过滤掉的部分
        let otherRange = NSRange(location: locationR, length: textNS.length - locationR)
        let filterText = textNS.substringWithRange(otherRange)
        if !self.isNormalFilter(filterText) {
            inputLogText(filterText)
        }
    }
    
    /// 正则分割文本 - 分割成数据条
    func splitTextInRelgularAndPro(sText: String, column: Int, usingEvery:(text: String, progress: (index: Int, total: Int)) ->()) {
        if (tempRegularExPression == nil) || (tempRegularExPression!.column != column) {
            let regularMatch = regularExpressionMatch(column)
            let regular = regularExpression(regularMatch)!
            tempRegularExPression = (column, regular)
        }
        let textNS = NSString(string: sText)
        var locationR = 0
        let textRange = NSRange(location: 0, length: textNS.length)
        
        let totalMatchNumber = tempRegularExPression!.regularExp.numberOfMatchesInString(sText, options: NSMatchingOptions(), range: textRange)
        var indexMatch = 0
        
        tempRegularExPression!.regularExp.enumerateMatchesInString(sText,
            options: .ReportCompletion,
            range: textRange) { ( textCheckingResult: NSTextCheckingResult?, matchingFlags: NSMatchingFlags, stop:  UnsafeMutablePointer<ObjCBool>) -> Void in
                if textCheckingResult == nil { return }
                
                // 进度君 动起来
                indexMatch++
                
                let textRange = textCheckingResult!.range
                
                // 打印过滤掉的部分
                if textRange.location != locationR {
                    let otherRange = NSRange(location: locationR, length: textRange.location - locationR)
                    let filterText = textNS.substringWithRange(otherRange)
                    if !self.isNormalFilter(filterText) {
                        self.inputLogText("不正常过滤字段：" + filterText)
                    }
                }
                locationR = textRange.location + textRange.length
                
                // 获取截取文本
                let text = textNS.substringWithRange(textRange)
                
                // 检查截取的文本
                if self.numberOfsearchClearCharaterInText(text) != 0 {
                    self.inputLogText("检查文本: " + text)
                }
                
                // 枚举
                usingEvery(text: text, progress: (indexMatch, totalMatchNumber))
        }
        
        // 打印过滤掉的部分
        let otherRange = NSRange(location: locationR, length: textNS.length - locationR)
        let filterText = textNS.substringWithRange(otherRange)
        if !self.isNormalFilter(filterText) {
            inputLogText(filterText)
        }
    }
    
    /// 正则分割字符+过滤敏感词(根据第一个数据单元过滤)
    func splitTextInRelgular(aText: String, column: Int, clearHeadSet: Set<String>, usingEvery:(text: String) ->()) {
        splitTextInRelgular(aText, column: column) { (text) -> () in
            let head = self.parseCellFristcolumn(text)
            if !clearHeadSet.contains(head) {
                usingEvery(text: text)
            }
        }
    }
    
    /**
     数据库头部文本
     
     - parameter headGroup: 头部集
     
     - returns: 头部文本
     */
    func headGroupText(headGroup: [String]) -> String {
        let reduceStr = headGroup.reduce("") { (result, item) -> String in
            return result + item + ","
        }
        return reduceStr.stringByTrimmingCharactersInSet(commaCharacterSet)
    }
    
    /**
     单行解析第一个参数
     
     - parameter sText: 解析源文本
     
     - returns: 解析文本
     */
    func parseCellFristcolumn(sText: String) -> String {
        let textNS = NSString(string: sText)
        let head = regularExpressionCellFrist.firstMatchInString(sText, options: .ReportCompletion, range: NSRange(location: 0, length: textNS.length))!
        return (sText as NSString).substringWithRange(head.range)
    }
    
    /**
     分割单条CSV数据 -> 单个数据
     
     - parameter sText:      待解析的数据
     - parameter usingEvery: 枚举匹配
     */
    func splitCsvTextInSimpleLine(sText: String, usingEvery:(text: String) -> ()) {
        let uText = NSString(string: sText)
        regularExpressionOfParseCSVText.enumerateMatchesInString(sText, options: NSMatchingOptions(),
            range: NSRange(location: 0, length: uText.length)) { (textCheckingResult: NSTextCheckingResult?,
                matchingFlags: NSMatchingFlags,
                stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                
                guard let uTextCheckingResult = textCheckingResult else {
                    return
                }
                let parsedText = uText.substringWithRange(uTextCheckingResult.range)
                usingEvery(text: parsedText)
        }
    }
    
    /**
     匹配是否有单引号
     
     - parameter sText: 检查文本
     
     - returns: 检查结果
     */
    func hasSingleQuote(sText: String) -> Bool {
        let matchNum = regularExpressionOfSingleQuote.numberOfMatchesInString(sText,
            options: NSMatchingOptions(),
            range: NSRange(location: 0, length: NSString(string: sText).length))
        return matchNum != 0
    }
    
    /**
     正则匹配文本是否包含
     
     - parameter text:     待检查文本
     - parameter matchStr: 正则表达式
     
     - returns: 是否文本
     */
    func hasValue(text: String, matchStr: String) -> Bool {
        let textNS = NSString(string: matchStr)
        let regular = regularLibrary[matchStr]
        let matchNum = regular.numberOfMatchesInString(text, options: NSMatchingOptions(), range: NSRange(location: 0, length: textNS.length))
        return matchNum > 0
    }
    
    /**
    根据正则表达式解析文本
    
    - parameter text:     待解析文本
    - parameter matchStr: 正则表达式
    
    - returns: 解析结果
    */
    func parseText(text: String, matchStr: String) -> [String] {
        var result: [String] = []
        let textNS = NSString(string: text)
        let regular = regularLibrary[matchStr]
        regular.enumerateMatchesInString(text,
            options: NSMatchingOptions(),
            range: NSRange(location: 0, length: textNS.length)) {
                (textCheckingResult, matchingFlag, stop) -> Void in
                
                if textCheckingResult == nil { return }
                let range = textCheckingResult!.range
                let parseEleText = textNS.substringWithRange(range)
                result.append(parseEleText)
        }
        return result
    }
}
// MARK: - FileName
extension KRTextManager {
    enum KRMatchError: ErrorType {
        case NotMatch
    }
    
    
    /**
     解析文件名前缀
     
     - parameter sText: 文件名
     
     - throws: See: KRMatchError
     
     - returns: 解析的文件名(无后缀)
     */
    func parseFileNameSuffix(sText: String) throws -> String {
        let tText = NSString(string: sText)
        guard let matchResult = regularExpressionOfClearSuffix.firstMatchInString(sText, options: NSMatchingOptions(), range: NSRange(location: 0, length: tText.length)) else {
            throw KRMatchError.NotMatch
        }
        return tText.substringWithRange(matchResult.range)
    }
}

private extension KRTextManager {
    /**
     搜索字符串中包含的多余字符串的个数
     
     - parameter sText: 检查的文本
     
     - returns: 查到的数量
     */
    func numberOfsearchClearCharaterInText(sText: String) -> Int {
        return regularExpressionOfClearCharaters.numberOfMatchesInString(sText, options: NSMatchingOptions(), range: NSRange(location: 0, length: NSString(string: sText).length))
    }
    /**
     是否为正常过滤
     
     - parameter sText: 过滤文本
     
     - returns: true: 正常过滤， false: 非正常过滤
     */
    func isNormalFilter(sText: String) -> Bool {
        let sTextNS = NSString(string: sText)
        guard let frist = regularExpressionOfNormalFilter.firstMatchInString(sText, options: NSMatchingOptions(), range: NSRange(location: 0, length: sTextNS.length)) else {
            return false
        }
        return sTextNS.length == frist.range.length
    }
}

private extension KRTextManager {
    
    /**
     正则表达式
     
     - parameter colum: 行数（大于1）
     
     - returns: 正则表达式
     */
    func regularExpressionMatch(colum: Int) -> String {
        return "^((\"[^\"]*(\"{2})*[^\"]*\")*[^,]*,){\(colum - 1)}((\"[^\"]*(\"{2})*[^\"]*\")*[^,\n\r]*)"
    }
    
    /**
     正则表达式
     
     - parameter matchStr: 匹配字符串
     
     - returns: 正则表达式
     */
    func regularExpression(matchStr: String) -> NSRegularExpression? {
        return try? NSRegularExpression(pattern: matchStr, options: [.CaseInsensitive, .AnchorsMatchLines])
    }
}


