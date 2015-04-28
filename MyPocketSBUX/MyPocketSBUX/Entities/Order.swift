//
//  Order.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Order: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var storeId: NSNumber
    @NSManaged var taxExcludedTotalPrice: NSNumber
    @NSManaged var taxIncludedTotalPrice: NSNumber
    @NSManaged var remarks: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate

}
