//
//  ZYLoctionDataManager.swift
//  MACTool
//
//  Created by 王晶 on 15/12/8.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

class ZYLoctionDataManager: KRDataManager {
    
    // FileName
    /// ZYLoction - Deal Detail
    lazy private var fileNameOfDetail = "ZYLoction-Detail.csv"
    lazy private var fileNameOfGov = "ZYLoction-Gov.csv"
    lazy private var fileNameOfPopSite = "ZYLoction-PopSite.csv"
    
    // Heads
    /// Heads - Detail
    lazy private var headsOfDetail = ["cate_name", "name", "url"]
    /// Heads - Gov
    lazy private var headsOfGov = ["name", "city", "url"]
    /// Heads - PopSite
    lazy private var headsOfPopSite = ["city", "name", "url"]
    
    /**
     解析SpecialKey数据
     
     - parameter filePath: 文件路径
     */
    func parseSpecialKey(folderPath: String) {
        let files = try! fileNameEngine.parseFolderFilesName(folderPath)
        
        var resultStr = textEngine.headGroupText(headsOfGov)
        for file in files {
            let tempText = parseText(folderPath + "/" + file, column: headsOfGov.count)
            resultStr += tempText
        }
        try! fileEngine.writeText(resultStr, toFolder: toFolder, fileName: fileNameOfGov)
    }
    
}

// MARK: - To BD
extension ZYLoctionDataManager {
    
    typealias EnumerateSplitTextFunc = (simpleData: String, progress: (index: Int, total: Int)) -> ()
    
    
    // 解析Detail
    func parseDetail(filePath: String, splitText: EnumerateSplitTextFunc) {
        parseFileText(filePath, fieldCount: headsOfDetail.count, splitText: splitText)
    }
    
    // 解析Gov 
    func parseGov(folderPath: String, splitText: EnumerateSplitTextAndProValueFunc) {
        let files = try! fileNameEngine.parseFolderFilesName(folderPath)
        for (index, file) in files.enumerate() {
            let itemPro = 1 / Double(files.count)
            parseFileText(folderPath + "/" + file, fieldCount: headsOfGov.count, splitText: { (simpleData, progress) -> () in
                let totalPro = itemPro*(Double(index) +  (Double(progress.index)/Double(progress.total)))
                splitText(simpleData: simpleData, progress: totalPro)
            })
        }
    }
    
}
