//
//  FoodMenuListItemTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class FoodMenuListItemTableViewCell: MenuListItemTableViewCell {
    override func configure(menuListItem : MenuListItem) {
        if let listItem = menuListItem as? FoodMenuListItem {
            self.textLabel?.text = listItem.entityDirectly()?.name
            self.multilineTextLabel()
        }
    }
}
