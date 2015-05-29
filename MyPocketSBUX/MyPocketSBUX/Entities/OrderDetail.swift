//
//  OrderDetail.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class OrderDetail: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var orderId: NSNumber
    @NSManaged var productName: String
    @NSManaged var productJanCode: String
    @NSManaged var size: String
    @NSManaged var hotOrIced: String
    @NSManaged var reusableCup: NSNumber
    @NSManaged var ticket: String
    @NSManaged var taxExcludeTotalPrice: NSNumber
    @NSManaged var taxExcludeCustomPrice: NSNumber
    @NSManaged var totalCalorie: NSNumber
    @NSManaged var customCalorie: NSNumber
    @NSManaged var remarks: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var order: Order?
    @NSManaged var productIngredients: NSSet

}
