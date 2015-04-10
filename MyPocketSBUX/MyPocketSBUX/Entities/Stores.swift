//
//  Stores.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class Stores: DbContextBase {
    
    static var contextInstance : Stores = Stores()
    
    class func instance() -> Stores{
        return contextInstance
    }

    override func entityName() -> String {
        return "Store"
    }
}
