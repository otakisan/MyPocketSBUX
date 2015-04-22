//
//  CustomItemsTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/22.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class CustomItemsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(ingredient : Ingredient) {
        self.textLabel?.text = ingredient.name
    }

}

class SyrupCustomItemsTableViewCell: CustomItemsTableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func configure(ingredient: Ingredient) {
        self.nameLabel.text = ingredient.name
    }
}