//
//  OrderMenuListItemTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderMenuListItemTableViewCell: MenuListItemTableViewCell {
    override func configure(menuListItem : MenuListItem) {
        if let name = menuListItem.entity?.valueForKey("name") as? String {
            self.textLabel?.text = "\(menuListItem.productCategory()) \(name)"
        }
    }
}
