//
//  ZYHeaderDataManagerTests.swift
//  MACTool
//
//  Created by 王晶 on 15/12/14.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import XCTest
@testable import MACTool

class ZYHeaderDataManagerTests: XCTestCase {
    let testClass = ZYHeaderDataManager("/Users/jingwang/Desktop/52/手机版通用数据")
    func testSS() {
        testClass.dealDefaultHeads(["/Users/jingwang/Desktop/52/手机版通用数据/1.首页默认头部手机版.csv", "/Users/jingwang/Desktop/52/苹果数据/3.苹果版53个分类里的头部.csv"])
    }
}
