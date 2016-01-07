//
//  KRRunFunctionManger.swift
//  MACTool
//
//  Created by 王晶 on 15/12/29.
//  Copyright © 2015年 Kirin. All rights reserved.
//

import Foundation

/// 执行方法
class KRRunFunctionManger {
    
    lazy var location = LocationFunc()
    lazy var detailClass = true
    lazy var header = true
    lazy var aggreSear = true
    lazy var classification = true
    lazy var commonAdd = true
    lazy var sortData = true
    
    struct Inner {
        static var instance: KRRunFunctionManger?
        static var token: dispatch_once_t = 0
    }
    /// 单例类属性
    class var runFunctionManger: KRRunFunctionManger {
        dispatch_once(&Inner.token) { () -> Void in
            Inner.instance = KRRunFunctionManger()
        }
        return Inner.instance!
    }
    
}

extension KRRunFunctionManger {
    struct LocationFunc {
        var detail = true
        var gov = true
        var popSite = true
        
        /// 是否需要执行
        func hasRun() -> Bool {
            return detail || gov || popSite
        }
    }
}