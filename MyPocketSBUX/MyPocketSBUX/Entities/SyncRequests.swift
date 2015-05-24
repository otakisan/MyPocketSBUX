//
//  SyncRequests.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/24.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class SyncRequests: DbContextBase {
    static var contextInstance : SyncRequests = SyncRequests()
    
    class func instance() -> SyncRequests{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "SyncRequest"
    }
}
