//
//  ZYAggreSearDataManagerTests.swift
//  MACTool
//
//  Created by 王晶 on 15/12/8.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import XCTest
@testable import MACTool

class ZYAggreSearDataManagerTests: XCTestCase {
    
    let testClass = ZYAggreSearDataManager("/Users/jingwang/Desktop/52/苹果数据")
    
    func testDealDataOfDetail() {
        testClass.dealDataOfDetail("/Users/jingwang/Desktop/52/苹果数据/4.苹果版聚搜里的数据.csv")
    }
    
    func testDealDataOfFristLayer() {
        testClass.dealDataOfFristLayer("/Users/jingwang/Desktop/52/苹果数据/FristLayer-ASS.json")
    }
}
