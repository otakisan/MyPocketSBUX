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
    
    @IBAction func valueChangedOrderSwitch(sender: UISwitch) {
        //println("valueChanged : \(sender.on)")
        self.menuListItem?.isOnOrderList = sender.on
        self.delegate?.valueChangedOrderSwitch(self, on: sender.on)
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
                
                var range = entity.size.rangeOfString("Tall", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
                var sizeText = ""
                if range != nil {
                   sizeText = "(Tall) "
                }
                
                self.priceLabel.text = "\(sizeText)¥\(entity.price ?? 0)"
                self.calorieLabel.text = "0 kcal"
                self.orderSwitch.on = self.menuListItem?.isOnOrderList ?? false
                
                //self.multilineTextLabel()
            }
        }
    }
}
