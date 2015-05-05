//
//  Pairing.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class Pairing: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var beanId: NSNumber
    @NSManaged var foodId: NSNumber
    @NSManaged var createdAt: NSDate
    @NSManaged var updatedAt: NSDate
    @NSManaged var bean: Bean?
    @NSManaged var food: Food?

}
