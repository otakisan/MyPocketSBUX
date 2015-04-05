//
//  Store.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Store: NSManagedObject {

    @NSManaged var storeId: NSNumber
    @NSManaged var name: String
    @NSManaged var address: String
    @NSManaged var phoneNumber: String
    @NSManaged var holiday: String
    @NSManaged var access: String
    @NSManaged var openingTimeWeekday: NSDate
    @NSManaged var closingTimeWeekday: NSDate
    @NSManaged var openingTimeSaturday: NSDate
    @NSManaged var closingTimeSaturday: NSDate
    @NSManaged var openingTimeHoliday: NSDate
    @NSManaged var closingTimeHoliday: NSDate
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var notes: String
    @NSManaged var prefId: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate

}
