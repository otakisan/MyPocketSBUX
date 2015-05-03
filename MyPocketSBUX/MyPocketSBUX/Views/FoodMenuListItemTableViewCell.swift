//
//  FoodMenuListItemTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class FoodMenuListItemTableViewCell: MenuListItemTableViewCell {
    @IBOutlet weak var orderSwitch: UISwitch!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBAction override func valueChangedOrderSwitch(sender: UISwitch) {
        super.valueChangedOrderSwitch(sender)
    }
    
    override func configure(menuListItem : MenuListItem) {
        if let listItem = menuListItem as? FoodMenuListItem {
            self.menuListItem = menuListItem
            
            if let entity = listItem.entityDirectly() {
                self.productNameLabel.text = entity.name
                self.productNameLabel.numberOfLines = 0
                self.productNameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                self.productNameLabel.sizeToFit()
                
                self.priceLabel.text = "¥\(entity.price ?? 0)"
                self.calorieLabel.text = "\((self.menuListItem!.nutritionEntities.first?.calorie ?? 0)) kcal"
                self.orderSwitch.on = self.menuListItem?.isOnOrderList ?? false
            }
        }
    }
}
