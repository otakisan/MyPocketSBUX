//
//  ProductsForSaleListItem.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/08.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class ProductsForSaleListItem: NSObject {
    var productEntity : NSManagedObject!
    var isOnOrderList : Bool = false
}
