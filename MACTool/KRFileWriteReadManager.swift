//
//  KRFileWriteRead.swift
//  MACTool
//
//  Created by 王晶 on 15/12/7.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

class KRFileWriteReadManager {
    /// 支持的编码方式
    lazy private var supportEncodes: [NSStringEncoding] = {
        let gbk = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        return [gbk, NSUTF8StringEncoding]
    }()
    
     /**
     读取文本错误
     
     - NotSupportEncoding:   不支持的文件编码
     - ReadJSONDataError:    读取JSON文件Data错误
     - ParseJSONObjectError: 解析JSONData错误
     */
    enum KRReadFileError: ErrorType {
        case NotSupportEncoding
        case ReadJSONDataError
        case ParseJSONObjectError
    }
    
    /**
     从文件中获取字符串
     
     - parameter filePath: 文件路径
     
     - returns: 字符串
     */
     /**
     从文件中获取字符串
     
     - parameter filePath: 文件路径
     
     - throws: See: KRReadStringError
     
     - returns: 字符串
     */
    func readStringFromFile(filePath: String) throws -> String {
        for encoding in supportEncodes {
            guard let contentStr = try? String(contentsOfFile: filePath, encoding: encoding) else {
                continue
            }
            return contentStr
        }
        throw KRReadFileError.NotSupportEncoding
    }
    
    /**
     读取JSON数据对象
     
     - parameter filePath: JSON文件路径
     
     - throws: See：KRReadFileError
     
     - returns: 解析的对象
     */
    func jsonObjectFromFile(filePath: String) throws -> AnyObject {
        guard let jsonData = NSData(contentsOfFile: filePath) else {
            throw KRReadFileError.ReadJSONDataError
        }
        guard let result = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) else {
            throw KRReadFileError.ParseJSONObjectError
        }
        return result
    }
}
// MARK: - Write
extension KRFileWriteReadManager {
    /**
     写入文件错误
     
     - WriteError: 写入错误
     */
    enum KRWriteFileError: ErrorType {
        case WriteError
    }
    
    /**
     文本写入操作
     
     - parameter text:     写入的文本
     - parameter toFolder: 写入到文件夹
     - parameter fileName: 文件名
     
     - throws: See: KRWriteFileError
     */
    func writeText(text: String, toFolder: String, fileName: String) throws {
        do {
            try text.writeToFile(toFolder + "/" + fileName, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            throw KRWriteFileError.WriteError
        }
    }
}
