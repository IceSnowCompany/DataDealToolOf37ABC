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
}
