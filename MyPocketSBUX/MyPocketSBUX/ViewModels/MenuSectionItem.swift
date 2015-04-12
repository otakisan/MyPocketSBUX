//
//  MenuSectionItem.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class MenuSectionItem: NSObject {
    
    struct SectionCategory {
        static let order = "order"
        static let product = "product"
    }

    struct ProductCategory {
        static let drink = "drink"
        static let food = "food"
    }

    var sectionCategory : String = ""
    var productCategory : String = ""
    var subCategory : String = ""
    var listItems : [MenuListItem] = []
    
    var sectionName : String {
        return "\(self.sectionCategory) \(self.productCategory) \(self.subCategory)"
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return (object is MenuSectionItem)
            && self.sectionCategory == (object as! MenuSectionItem).sectionCategory
            && self.productCategory == (object as! MenuSectionItem).productCategory
            && self.subCategory == (object as! MenuSectionItem).subCategory
    }
}
