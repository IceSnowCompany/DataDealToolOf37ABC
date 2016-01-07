//
//  CommandAddManger.swift
//  MACTool
//
//  Created by 王晶 on 15/10/15.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

private let sourceJSONFileName = "sucai"
private let oldJSONFileName = "MainSort"

class CommandAddDataManager {
}

extension CommandAddDataManager {
    
    /// 从数据中获取指定元素
    func searchEleFromColloction(colloction: Array<[String: String]>, title: String) -> (Int, Dictionary<String, String>) {
        var index: Int = 0
        for ele in colloction {
            if ele["name"]  == title {
                return (index, ele)
            }
            index++
        }
        return (-1, [:])
    }
    
    
    /**
    获取并解析json数据错误状态
    
    - NotExistFile: 文件不存在
    - InvalidFile:  无效文件
    - AnalysisFail: 解析失败
    */
    enum DealJSONErrorType: ErrorType {
        case NotExistFile, InvalidFile, AnalysisFail
    }
}

private extension CommandAddDataManager {
    
    /**
    解析JSON文件
    
    - parameter fileName: 文件名
    
    - throws: DealJSONErrorType
    
    - returns: 解析结果
    */
    func readJSON(fileName: String) throws -> AnyObject {
        guard let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") else {
            throw DealJSONErrorType.NotExistFile
        }
        
        guard let data = NSData(contentsOfFile: filePath) else {
            throw DealJSONErrorType.InvalidFile
        }
        do {
            let result = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves)
            return result
        } catch {
            throw DealJSONErrorType.AnalysisFail
        }
    }
    
    /// 对象转Data
    func objectToJSONData(object: AnyObject) -> NSData?  {
        return try? NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
    }
    
    /// 写入数据到文件
    func writeDataInFile(fileName: String, type: String, data: NSData, dire: String) -> Bool {
       let paths = NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)
        let path = paths[0] + "/" + dire + "/" + fileName + "." + type
        return data.writeToFile(path, atomically: true)
    }
}