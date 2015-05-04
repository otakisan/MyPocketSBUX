//
//  Bean.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Bean: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var category: String
    @NSManaged var janCode: String
    @NSManaged var price: NSNumber
    @NSManaged var special: String
    @NSManaged var notes: String
    @NSManaged var notification: String
    @NSManaged var growingRegion: String
    @NSManaged var processingMethod: String
    @NSManaged var flavor: String
    @NSManaged var body: String
    @NSManaged var acidity: String
    @NSManaged var complementaryFlavors: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate

}
