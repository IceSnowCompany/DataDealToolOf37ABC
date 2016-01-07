//
//  FilesNameManagerTests.swift
//  MACTool
//
//  Created by 王晶 on 15/12/9.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import XCTest
@testable import MACTool

class FilesNameManagerTests: XCTestCase {
    let testClass = FilesNameManager()
    
    func testParseFolderFilesName() {
        try! testClass.parseFolderFilesName("/Users/jingwang/Desktop/52/省政府机构")
    }
}
