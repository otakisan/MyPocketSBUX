//
//  DrinkOrderTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/18.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class DrinkOrderTableViewCell: OrderTableViewCell {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var orderSwitch: UISwitch!
    
    @IBOutlet weak var calorieLabel: UILabel!
    
    @IBAction override func valueChangedOrderSwitch(sender: UISwitch) {
        super.valueChangedOrderSwitch(sender)
    }
    
    @IBAction func touchUpInsideEditButton(sender: UIButton) {
        super.touchUpInsideOrderEdit(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure(orderListItem: OrderListItem) {
        super.configure(orderListItem)
        
        if let entity = orderListItem.productEntity as? Drink {
            self.productNameLabel?.text = entity.name
            self.productNameLabel?.numberOfLines = 1
            self.productNameLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            self.productNameLabel?.sizeToFit()

            self.priceLable.text = "\(self.orderListItem?.totalPrice ?? 0)"
            self.orderSwitch.on = orderListItem.on
            
            self.calorieLabel.text = "\(self.calorieForOrder())"
        }
    }
    
    func calorieForOrder() -> Int {
        var calorie = 0
        
        // カロリーはサイズ・ホット／アイス・ミルクでベースが決まり、そこにカスタマイズ分が乗る
        var nutInfo = self.orderListItem?.nutritionEntities.filter({$0.valueForKey("size") as? String == self.orderListItem?.size.name()})
        if nutInfo?.count > 0 {
            calorie = (nutInfo?.first?.valueForKey("calorie") as? NSNumber)?.integerValue ?? 0
        }
        
        return calorie
    }
}
