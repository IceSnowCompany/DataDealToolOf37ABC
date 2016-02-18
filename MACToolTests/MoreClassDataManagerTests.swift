//
//  MoreClassDataManagerTests.swift
//  MACTool
//
//  Created by 王晶 on 15/12/16.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import XCTest
@testable import MACTool

class MoreClassDataManagerTests: XCTestCase {
    let testClass = MoreClassDataManager()
    
    func testParseFileOfFolder() {
        testClass.parseFileOfFolder("/Users/jingwang/Desktop/52/53")
    }
    
    func testParseFoldersToDB() {
        testClass.parseFoldersToDB("/Users/jingwang/Documents/SVN/37abc Data/手机版", special: "/Users/jingwang/Documents/SVN/37abc Data/手机版/苹果数据") { (simpleData, progress) -> () in
            
        }
    }
}
