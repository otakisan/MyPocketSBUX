//
//  TastingLog.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class TastingLog: NSManagedObject {

    @NSManaged var createdAt: NSDate
    @NSManaged var detail: String
    @NSManaged var id: NSNumber
    @NSManaged var myPocketId: String
    @NSManaged var tag: String
    @NSManaged var tastingAt: NSDate
    @NSManaged var title: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var store: Store?
    @NSManaged var order: Order?
    @NSManaged var photo: NSData?
}
