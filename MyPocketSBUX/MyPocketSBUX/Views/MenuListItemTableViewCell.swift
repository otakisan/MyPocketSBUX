//
//  MenuListItemTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class MenuListItemTableViewCell: UITableViewCell {
    
    var delegate : MenuListItemTableViewCellDelegate?
    var menuListItem : MenuListItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(menuListItem : MenuListItem) {
        fatalError("implement subclass method !")
    }
    
    func multilineTextLabel() {
        self.textLabel?.numberOfLines = 0
        self.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.textLabel?.sizeToFit()
    }

    func valueChangedOrderSwitch(sender: UISwitch) {
        self.menuListItem?.isOnOrderList = sender.on
        self.delegate?.valueChangedOrderSwitch(self, on: sender.on)
    }
}

protocol MenuListItemTableViewCellDelegate : NSObjectProtocol {
    func valueChangedOrderSwitch(cell : MenuListItemTableViewCell, on : Bool)
}