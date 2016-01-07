//
//  FilesNameManager.swift
//  MACTool
//
//  Created by 王晶 on 15/10/19.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// 文件名管理
class FilesNameManager {
    
    lazy private var fm = NSFileManager.defaultManager()
    lazy private var dc = DirectoryColloction()
    /// 源文件
    let sourchPath = "sourcePath"
    /// 处理的关键字
    let dealedKey = "parseKey"
    /**
     解析文件夹
     
     - parameter path: 文件夹路径
     
     - returns: 解析结果
     */
    func parseFolderFileName(path: String) -> [Dictionary<String, String>]? {
        let pathPro = isFolder(path)
        if pathPro.isExist && pathPro.isDir! {
            let rootDirFiles = readFilesOfDirPathRoot(path)
            var files: [Dictionary<String, String>] = []
            let regular = regularExpression(maxtchStrOf53ClassFileName)!
            for fileName in rootDirFiles {
                let dealed = parseFiles(fileName, regularEcpression: regular)
                if dealed.count == 1 {
                    files.append([sourchPath: fileName, dealedKey: dealed[0]])
                    continue
                }
            }
            return files
        }
        return nil
    }
    
    /**
     解析文件夹错误
     
     - NotFoundPath: 不存在的路径
     - NotIsDir:     不是目录
     */
    enum ParseFolderError: ErrorType {
        case NotFoundPath
        case NotIsDir
    }
    
    /**
     解析文件夹路径
     
     - parameter folderPath: 解析目录
     
     - throws: See: ParseFolderError
     
     - returns: 解析到的文件
     */
    func parseFolderFilesName(folderPath: String) throws -> [String] {
        let pathPro = isFolder(folderPath)
        if pathPro.isExist && pathPro.isDir! {
            return readFilesOfDirPathRoot(folderPath)
        } else if (!pathPro.isExist) {
            throw ParseFolderError.NotFoundPath
        } else {
            throw ParseFolderError.NotIsDir
        }
    }
    
}
/// 53个分类文件名中获取Key
let maxtchStrOf53ClassFileName = "((?<=_)|(?<=-)|^)([^-_\n]+)(?=\\.csv)"

private extension FilesNameManager {
    /**
     解析文件名(支持清空ignore文件)
     
     - parameter filesName:         文件名
     - parameter regularEcpression: 正则解析实例
     
     - returns: 解析结果
     */
    func parseFiles(filesName: String, regularEcpression: NSRegularExpression) -> [String]  {
        var matchStr: [String] = []
        let range = NSRange(location: 0, length: NSString(string: filesName).length)
        regularEcpression.enumerateMatchesInString(filesName,
            options: .ReportCompletion,
            range: range) {
                (textCheckingResult: NSTextCheckingResult?, mathchingFlags: NSMatchingFlags, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
                if textCheckingResult == nil { return }
                let text = (filesName as NSString).substringWithRange(textCheckingResult!.range)
                matchStr.append(text)
        }
        return matchStr
    }
}


private extension FilesNameManager {
    
    /**
     正则表达式
     
     - parameter matchStr: 匹配字符串
     
     - returns: 正则表达式
     */
    func regularExpression(matchStr: String) -> NSRegularExpression? {
        return try? NSRegularExpression(pattern: maxtchStrOf53ClassFileName, options: [.CaseInsensitive, .DotMatchesLineSeparators])
    }
    
    /**
     读取目录下的文件
     
     - parameter dirPath: 文件夹目录
     
     - returns: 文件夹根目录下的文件
     */
    func readFilesOfDirPathRoot(dirPath: String) -> [String] {
        
        var files = [String]()
        do {
            let paths = try fm.subpathsOfDirectoryAtPath(dirPath)
            files = paths
        } catch {
            return []
        }
        // 分拆文件 文件夹
        let separResult = separationFileAndFolder(dirPath, paths: files, isClearIgnoreFile: true)
        return separResult.files
    }
    
    /**
     路径检查
     
     - parameter path: 路径
     
     - returns: (是否存在, 是否是目录)
     */
    func isFolder(path: String) -> (isExist: Bool, isDir: Bool?) {
        var isDir = ObjCBool(false)
        
        let exists = fm.fileExistsAtPath(path, isDirectory: &isDir)
        if exists {
            return (true, isDir.boolValue)
        }
        return (false, nil)
    }
    
}

private extension FilesNameManager {
    /**
    分拆文件&文件夹
    
    - parameter basicPath: 所在路径
    - parameter paths:     路径下的子路径集
    
    - returns: (文件集, 文件夹集)
    */
    func separationFileAndFolder(basicPath: String, paths: [String], isClearIgnoreFile: Bool = false) -> (files: [String], folders: [String]) {
        
        let ignoreFiles = dc.ignoreFiles
        var result = [String]()// 文件
        var folders = [String]()// 其他路径
        var dirInfo = (false, "")// 文件夹信息
        for item in paths {
            // 判断是否是某文件下的路径
            let prefix = dirInfo.1 + "/"
            if dirInfo.0 && item.hasPrefix(prefix) {
                continue
            }
            dirInfo.0 = false
            // 判断是否是文件路径
            let path = basicPath + "/" + item
            var isDir = ObjCBool(false)
            if fm.fileExistsAtPath(path, isDirectory: &isDir) {
                if isDir.boolValue {
                    dirInfo.0 = true
                    dirInfo.1 = item
                    folders.append(item)
                    continue
                }
                // 清洁服务
                if !isClearIgnoreFile || !ignoreFiles.contains(item) {
                    result.append(item)
                }
            }
        }
        return (result, folders)
    }
    
    /**
    清理忽略文件
    
    - parameter files: 待清理文件集
    
    - returns: 清理后文件
    */
    func clearIngoreFiles(files: [String]) -> [String] {
        let ignoreFiles = dc.ignoreFiles
        var result = [String]()
        for item in files {
            if !ignoreFiles.contains(item) {
                result.append(item)
            }
        }
        return result
    }
}



/// 目录集
class DirectoryColloction {
    
    /// 桌面目录
     lazy var desktopDir: [String] = {
        return  NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)
    }()
    
    /// 忽略文件集
    lazy var ignoreFiles: Set<String> = {
        return [".DS_Store"]
    }()
}