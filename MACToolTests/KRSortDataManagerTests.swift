//
//  KRSortDataManagerTests.swift
//  MACTool
//
//  Created by 王晶 on 15/12/10.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import XCTest
@testable import MACTool

class KRSortDataManagerTests: XCTestCase {
    
    let testClass = KRSortDataManager("/Users/jingwang/Desktop/52/手机版通用数据")
    
    func testExp() {
        testClass.parseData("/Users/jingwang/Desktop/52/手机版通用数据/首页分类排序.csv")
    }
}
