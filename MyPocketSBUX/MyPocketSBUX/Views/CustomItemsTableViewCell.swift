//
//  CustomItemsTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/22.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class CustomItemsTableViewCell: UITableViewCell {

    var ingredient : Ingredient!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(ingredient : Ingredient, delegate : CustomItemsTableViewCellDelegate) {
        self.ingredient = ingredient
        self.textLabel?.text = ingredient.name
    }

}

protocol CustomItemsTableViewCellDelegate {
    
}

// TODO: スイッチがONなら、量を指定可能とする
class SyrupCustomItemsTableViewCell: CustomItemsTableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantitySegment: UISegmentedControl!
    
    @IBAction func valueChangedAdditionSwitch(sender: UISwitch) {
        self.delegate?.valueChangedAdditionSwitch(self, added: sender.on)
        self.changeStateQuantitySegment(sender.on)
    }
    
    @IBAction func valueChangedQuantitySegment(sender: UISegmentedControl) {
        self.delegate?.valueChangedQuantitySegment(self, type: QuantityType.fromNumeric(sender.selectedSegmentIndex))
    }
    
    var delegate : SyrupCustomItemsTableViewCellDelegate?
    
    override func configure(ingredient: Ingredient, delegate : CustomItemsTableViewCellDelegate) {
        self.ingredient = ingredient
        self.nameLabel.text = ingredient.name
        self.changeStateQuantitySegment(self.ingredient.quantity > 0)
        self.delegate = delegate as? SyrupCustomItemsTableViewCellDelegate
    }
    
    func changeStateQuantitySegment(on : Bool) {
        self.quantitySegment.enabled = on
    }
}

protocol SyrupCustomItemsTableViewCellDelegate : CustomItemsTableViewCellDelegate {
    func valueChangedAdditionSwitch(cell : SyrupCustomItemsTableViewCell, added : Bool)
    func valueChangedQuantitySegment(cell : SyrupCustomItemsTableViewCell, type : QuantityType)
}

enum QuantityType {
    case Less
    case Normal
    case More
    
    static func fromNumeric(typeValue : Int) -> QuantityType {
        var type = Normal
        switch typeValue {
        case 0:
            type = Less
        case 1:
            type = Normal
        case 2:
            type = More
        default:
            type = Normal
        }
        
        return type
    }
    
    func addQuantity(baseValue : Int) -> Int {
        return (self == Less ? baseValue - 1 : self == More ? baseValue + 1 : baseValue)
    }
    
    func quantityToAdd() -> Int {
        return (self == Less ? -1 : self == More ? 1 : 0)
    }
}