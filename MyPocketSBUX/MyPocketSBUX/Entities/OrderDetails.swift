//
//  OrderDetails.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/29.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderDetails: DbContextBase {
    static var contextInstance : OrderDetails = OrderDetails()
    
    class func instance() -> OrderDetails{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "OrderDetail"
    }
    
    class func sequenceNumber() -> Int {
        return Int(Double(NSDate().timeIntervalSince1970) * 1.0e6)
    }
    
    class func getOrderDetailsWithOrderId(orderId : Int, orderKeys : [(columnName : String, ascending : Bool)]) -> [OrderDetail] {
        
        var sortKeys : [AnyObject] = []
        for orderkey in orderKeys {
            sortKeys.append(NSSortDescriptor(key: orderkey.columnName, ascending: orderkey.ascending))
        }
        
        return findByFetchRequestTemplate(
            "orderDetailsWithOrderIdFetchRequest",
            variables: ["orderId":orderId],
            sortDescriptors: sortKeys,
            limit: 0) as! [OrderDetail]
    }

}
