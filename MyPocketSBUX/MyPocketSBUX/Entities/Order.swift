//
//  Order.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/03.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Order: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var id: NSNumber
    @NSManaged var remarks: String
    @NSManaged var storeId: NSNumber
    @NSManaged var taxExcludedTotalPrice: NSNumber
    @NSManaged var taxIncludedTotalPrice: NSNumber
    @NSManaged var updatedAt: NSDate
    @NSManaged var notes: String

}
