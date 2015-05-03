//
//  Nutrition.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/03.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Nutrition: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var janCode: String
    @NSManaged var size: String
    @NSManaged var liquidTemperature: String
    @NSManaged var milk: String
    @NSManaged var calorie: NSNumber
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate

}
