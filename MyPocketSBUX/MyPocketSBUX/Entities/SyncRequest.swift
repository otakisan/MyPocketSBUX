//
//  SyncRequest.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/24.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import CoreData

class SyncRequest: NSManagedObject {

    @NSManaged var entityTypeName: String
    @NSManaged var entityPk: NSNumber
    @NSManaged var entityGlobalID: NSNumber

}
