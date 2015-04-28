//
//  ProductIngredient.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class ProductIngredient: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var orderId: NSNumber
    @NSManaged var orderDetailId: NSNumber
    @NSManaged var isCustom: NSNumber
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var unitCalorie: NSNumber
    @NSManaged var unitPrice: NSNumber
    @NSManaged var quantity: NSNumber
    @NSManaged var enabled: NSNumber
    @NSManaged var quantityType: NSNumber
    @NSManaged var remarks: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate

}
