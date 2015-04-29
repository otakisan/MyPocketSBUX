//
//  ProductIngredients.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/29.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ProductIngredients: DbContextBase {
    static var contextInstance : ProductIngredients = ProductIngredients()
    
    class func instance() -> ProductIngredients{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "ProductIngredient"
    }
    
    class func sequenceNumber() -> Int {
        return Int(Double(NSDate().timeIntervalSince1970) * 1.0e6)
    }
    
    class func findProductIngredientsByOrderIdAndOrderDetailIdFetchRequest(orderId : Int, orderDetailId : Int, orderKeys : [(columnName : String, ascending : Bool)]) -> [ProductIngredient] {
        
        var sortKeys : [AnyObject] = []
        for orderkey in orderKeys {
            sortKeys.append(NSSortDescriptor(key: orderkey.columnName, ascending: orderkey.ascending))
        }
        
        return findByFetchRequestTemplate(
            "findProductIngredientsByOrderIdAndOrderDetailIdFetchRequest",
            variables: ["orderId":orderId, "orderDetailId":orderDetailId],
            sortDescriptors: sortKeys,
            limit: 0) as! [ProductIngredient]
    }

}
