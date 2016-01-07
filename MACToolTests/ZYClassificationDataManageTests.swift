//
//  ZYClassificationDataManageTests.swift
//  MACTool
//
//  Created by 王晶 on 15/12/7.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import XCTest
@testable import MACTool

class ZYClassificationDataManageTests: XCTestCase {
    
    let testClass = ZYClassificationDataManage("/Users/jingwang/Desktop/52/苹果数据")
    func testDeal() {
        testClass.dealDetailData("/Users/jingwang/Desktop/52/苹果数据/2.首页分类里的数据.csv")
    }

}
