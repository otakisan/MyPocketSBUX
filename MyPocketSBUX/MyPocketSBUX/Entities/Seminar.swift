//
//  Seminar.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/05/14.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Seminar: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var edition: String
    @NSManaged var startTime: NSDate
    @NSManaged var endTime: NSDate
    @NSManaged var dayOfWeek: NSNumber
    @NSManaged var capacity: NSNumber
    @NSManaged var deadline: NSDate
    @NSManaged var status: String
    @NSManaged var entryUrl: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var store: Store?

}
