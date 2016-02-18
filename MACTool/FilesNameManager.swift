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
    /// 遗忘文件名
    lazy private var ignoreFilesName: Set<String> = [".DS_Store"]
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
// MARK: - V1.2
extension FilesNameManager {
    /// 基本文件夹解析
    func parseFolderBase(folder: String, rootDirIgnore: Set<String>) -> [String: String] {
        let filesName = parseAllRootFileInFolder(folder)// 解析文件夹 获取根目录所有文件
        let filesNameOfClear = clearTexts(filesName!, ignoreTexts: rootDirIgnore)// 清洁根目录过滤文件
        // 解析文件名组
        var keyToPath: [String: String] = [:]
        let regular = regularExpression(maxtchStrOf53ClassFileName)!// 解析正则
        for item in filesNameOfClear {
            let dealed = parseFiles(item, regularEcpression: regular)
            let key = dealed[0]
            keyToPath[key] = folder + "/" + item
        }
        return keyToPath
    }
    /**
     根目录下的所有文件(不包含文件夹, 隐藏文件)
     
     - parameter folder: 文件夹路径
     
     - returns: 解析结果
     */
    func parseAllRootFileInFolder(folder: String) -> [String]? {
        
        let url = NSURL(fileURLWithPath: folder, isDirectory: true)// 本地URL
        let dirEnumerator = fm.enumeratorAtURL(url,
            includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey],
            options: [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles],
            errorHandler: nil)// 获取指定目录的枚举对象
        
        var allFilesName: [String] = []// 所有文件名组
        // 遍历所有对象
        for tempURL in dirEnumerator! {
            var isDir: AnyObject?// 是否为目录
            try! (tempURL as! NSURL).getResourceValue(&isDir, forKey: NSURLIsDirectoryKey)
            if !(isDir as! NSNumber).boolValue {
                var fileName: AnyObject?// 文件名
                try! (tempURL as! NSURL).getResourceValue(&fileName, forKey: NSURLNameKey)
                allFilesName.append(fileName as! String)
            }
        }
        return allFilesName
    }
}


/// 53个分类文件名中获取Key
let maxtchStrOf53ClassFileName = "((?<=_)|(?<=-)|^)([^-_\n]+)(?=\\.csv)"

private extension FilesNameManager {
    /// 正则解析文件名
    func parseFileName(fileName: String, regular: NSRegularExpression) {
        let dealed = parseFiles(fileName, regularEcpression: regular)
        print(dealed)
    }
    
    
    
    /**
     清除Ingore文件
     
     - parameter filesName: 文件名组
     
     - returns: 过滤后文件名组
     */
    func clearIngoreFileName(filesName: [String]) -> [String] {
        return clearFilesName(filesName, ignoreFiles: ignoreFilesName)
    }
    
    /**
     清理文件名
     
     - parameter sourceFiles: 源文件名组
     - parameter ignoreFiles: 过滤文件名组
     
     - returns: 过滤结果
     */
    func clearFilesName(sourceFiles: [String], ignoreFiles: Set<String>) -> [String] {
        return clearTexts(sourceFiles, ignoreTexts: ignoreFiles)
    }
    
    /**
     清理文本组
     
     - parameter texts:       文本组
     - parameter ignoreTexts: 过滤文本组
     
     - returns: 处理结果
     */
    func clearTexts(texts: [String], ignoreTexts: Set<String>) -> [String] {
        var result: [String] = []
        for item in texts {
            if !ignoreTexts.contains(item) {
                result.append(item)
            }
        }
        return result
    }
    
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
        return try? NSRegularExpression(pattern: matchStr, options: [.CaseInsensitive, .DotMatchesLineSeparators])
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