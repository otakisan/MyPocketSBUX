//
//  TastingLog.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class TastingLog: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var tag: String
    @NSManaged var tastingAt: NSDate
    @NSManaged var storeId: NSNumber
    @NSManaged var detail: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var store: Store?

}
