//
//  Orders.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/29.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Orders: DbContextBase {
    static var contextInstance : Orders = Orders()
    
    class func instance() -> Orders{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Order"
    }
    
    class func sequenceNumber() -> Int {
        // TODO: IDの採番
        return Orders.instance().maxId() + 1
        //return Int(Double(NSDate().timeIntervalSince1970) * 1.0e6)
    }
}
