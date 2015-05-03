//
//  MenuListItem.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class MenuListItem: NSObject {
    var productEntity : AnyObject?
    var nutritionEntities : [Nutrition] = []
    var isOnOrderList : Bool = false
    
    func sectionCategory() -> String {
        return ""
    }
    
    func productCategory() -> String {
        return ""
    }
    
    func subCategory() -> String {
        return ""
    }
}
