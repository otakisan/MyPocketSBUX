//
//  DrinkMenuListItemTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class DrinkMenuListItemTableViewCell: MenuListItemTableViewCell {
    @IBOutlet weak var orderSwitch: UISwitch!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBAction override func valueChangedOrderSwitch(sender: UISwitch) {
        super.valueChangedOrderSwitch(sender)
    }
    
    func tableView() -> UITableView? {
        var tableView : UIView? = self.superview
        while tableView != nil && !(tableView is UITableView) {
            tableView = tableView!.superview
        }
        
        return tableView as? UITableView
    }
    
    override func configure(menuListItem : MenuListItem) {
        if let listItem = menuListItem as? DrinkMenuListItem {
            self.menuListItem = menuListItem
            
            if let entity = listItem.entityDirectly() {
                self.productNameLabel.text = entity.name
                self.productNameLabel.numberOfLines = 0
                self.productNameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                self.productNameLabel.sizeToFit()
                
                let range = entity.size.rangeOfString("Tall", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
                var sizeText = ""
                if range != nil {
                   sizeText = "(Tall) "
                }
                
                self.priceLabel.text = "\(sizeText)¥\(entity.price ?? 0)"
//                self.menuListItem?.nutritionEntities.filter({nutrition in (nutrition.size == "Tall" || nutrition.size == "Doppio") && (nutrition.milk == "whole" || nutrition.milk == "na")}).first?.calorie
                let calorie = self.menuListItem?.nutritionEntities.filter({$0.size == "Tall" || $0.size == "Doppio"}).filter({$0.milk == "whole" || $0.milk == "na"}).first?.calorie ?? 0
                self.calorieLabel.text = "\(calorie) kcal"
                self.orderSwitch.on = self.menuListItem?.isOnOrderList ?? false
            }
        }
    }
}
