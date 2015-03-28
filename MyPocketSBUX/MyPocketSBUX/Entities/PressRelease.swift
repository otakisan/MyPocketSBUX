//
//  PressRelease.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class PressRelease: NSManagedObject {

    @NSManaged var fiscalYear: NSNumber
    @NSManaged var pressReleaseSn: NSNumber
    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate

}
