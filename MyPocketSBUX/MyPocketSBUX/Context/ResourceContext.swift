//
//  ResourceContext.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ResourceContext: NSObject {
    static var instance : ResourceContext = ResourceContext()
    
    func serviceHost() -> String {
        return "localhost"
    }
    
    func servicePort() -> Int {
        return 3000
    }
}
