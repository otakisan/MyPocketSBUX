//
//  Food.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Food: NSManagedObject {

    @NSManaged var updatedAt: NSDate
    @NSManaged var createdAt: NSDate
    @NSManaged var notification: String
    @NSManaged var notes: String
    @NSManaged var price: NSNumber
    @NSManaged var janCode: String
    @NSManaged var category: String
    @NSManaged var name: String
    @NSManaged var id: NSNumber
    @NSManaged var special: String

}
