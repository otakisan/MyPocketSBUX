//
//  OrderTableViewCell.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/14.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    var orderListItem : OrderListItem?
    var delegate : OrderTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func valueChangedOrderSwitch(sender: UISwitch) {
        self.orderListItem?.on = sender.on
        self.delegate?.valueChangedOrderSwitch(self, on: sender.on)
    }
    
    func touchUpInsideOrderEdit(cell : OrderTableViewCell){
        self.delegate?.touchUpInsideOrderEdit(self)
    }
    
    func configure(orderListItem : OrderListItem) {
        self.orderListItem = orderListItem
    }

}

protocol OrderTableViewCellDelegate : NSObjectProtocol {
    func valueChangedOrderSwitch(cell : OrderTableViewCell, on : Bool)
    func touchUpInsideOrderEdit(cell : OrderTableViewCell)
}
