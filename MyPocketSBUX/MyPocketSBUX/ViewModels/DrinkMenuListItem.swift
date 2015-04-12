//
//  DrinkMenuListItem.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class DrinkMenuListItem: MenuListItem {
    
    override func sectionCategory() -> String {
        return MenuSectionItem.SectionCategory.product
    }
    
    override func productCategory() -> String {
        return MenuSectionItem.ProductCategory.drink
    }
    
    override func subCategory() -> String {
        return self.entityDirectly()?.category ?? ""
    }
    
    func entityDirectly() -> Drink? {
        return self.entity as? Drink
    }
}
