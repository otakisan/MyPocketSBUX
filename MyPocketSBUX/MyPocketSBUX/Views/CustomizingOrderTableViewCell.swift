//
//  CustomizingOrderTableViewCell.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/19.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class CustomizingOrderTableViewCell: UITableViewCell {
    struct CellIds {
        static let base = "defaultCustomizingOrderTableViewCell"
        static let productName = "nameCustomizingOrderTableViewCell"
        static let price = "priceCustomizingOrderTableViewCell"
        static let calorie = "calorieCustomizingOrderTableViewCell"
        static let size = "sizeCustomizingOrderTableViewCell"
        static let hotOrIced = "hotOrIcedCustomizingOrderTableViewCell"
        static let reusableCup = "reusableCupCustomizingOrderTableViewCell"
        static let oneMoreCoffee = "oneMoreCoffeeCustomizingOrderTableViewCell"
        static let ticket = "ticketCustomizingOrderTableViewCell"
        static let customItem = "customItemCustomizingOrderTableViewCell"
        static let addCustomItem = "addCustomItemCustomizingOrderTableViewCell"
        static let customItemAdded = "customItemCustomizingOrderTableViewCell"
    }
    
    var orderListItem : OrderListItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(orderListItem : OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        self.orderListItem = orderListItem
    }

}

protocol CustomizingOrderTableViewCellDelegate : NSObjectProtocol {
}


class NameCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)

        self.nameLabel.text = orderListItem.productEntity?.valueForKey("name") as? String ?? ""
    }
}

class PriceCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)
        
        var price = orderListItem.totalPrice
        self.priceLabel.text = "¥\(price)"
    }
}

class CalorieCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    @IBOutlet weak var calorieLabel: UILabel!
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)

        var calorie = 0
        for nutrition in orderListItem.nutritionEntities {
            calorie += ((nutrition.valueForKey("calorie") as? NSNumber)?.integerValue ?? 0)
        }
        self.calorieLabel.text = "\(calorie) kcal"
    }
}

class SizeCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    var delegate : SizeCustomizingOrderTableViewCellDelegate?
    let sizes : [DrinkSize] = [.Short, .Tall, .Grande, .Venti]
    
    @IBOutlet weak var sizeSegment: UISegmentedControl!
    
    @IBAction func valueChangedSizeSegment(sender: UISegmentedControl) {
        self.delegate?.valueChangedSizeSegment(self, size: self.sizes[sender.selectedSegmentIndex])
    }
    
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)
        
        self.delegate = delegate as? SizeCustomizingOrderTableViewCellDelegate

        for segmentIndex in 0..<self.sizeSegment.numberOfSegments {
            if let title = self.sizeSegment.titleForSegmentAtIndex(segmentIndex) {
                
                // exist, infexOfをもっと簡単に使えないかな
                if let range = title.rangeOfString(orderListItem.size.name(), options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil){
                    self.sizeSegment.selectedSegmentIndex = segmentIndex
                    break
                }
            }
        }
    }
}

protocol SizeCustomizingOrderTableViewCellDelegate : CustomizingOrderTableViewCellDelegate {
    func valueChangedSizeSegment(cell : SizeCustomizingOrderTableViewCell, size : DrinkSize)
}

enum DrinkSize : String {
    case Short = "Short"
    case Tall = "Tall"
    case Grande = "Grande"
    case Venti = "Venti®"
    case Solo = "Solo"
    case Doppio = "Doppio"
    
    func priceForDelta() -> Int {
        var delta = 0
        switch self {
        case Short, Solo:
            delta = -40
        case Tall, Doppio:
            delta = 0
        case Grande:
            delta = 40
        case Venti:
            delta = 80
        default:
            delta = 0
        }
        
        return delta
    }
    
    func name() -> String {
        return self.rawValue
    }
}

class HotOrIcedCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    let hotOrIcedNames : [String] = ["Hot", "Iced"]
    
    @IBOutlet weak var hotOrIcedSegment: UISegmentedControl!
    
    @IBAction func valueChangedHotOrIcedSegment(sender: UISegmentedControl) {
        self.orderListItem?.hotOrIce = self.hotOrIcedNames[sender.selectedSegmentIndex]
    }
    
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)
        
        for segmentIndex in 0..<self.hotOrIcedSegment.numberOfSegments {
            if let title = self.hotOrIcedSegment.titleForSegmentAtIndex(segmentIndex) {
                
                if let range = title.rangeOfString(orderListItem.hotOrIce, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil){
                    self.hotOrIcedSegment.selectedSegmentIndex = segmentIndex
                    break
                }
            }
        }
    }
}

class ReusableCupCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    var delegate : ReusableCupCustomizingOrderTableViewCellDelegate?
    
    @IBOutlet weak var reusableCupSwitch: UISwitch!
    
    @IBAction func valueChangedReusableCupSwitch(sender: UISwitch) {
        self.delegate?.valueChangedReusableCupSwitch(self, on : sender.on)
    }
    
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)
        self.reusableCupSwitch.on = orderListItem.reusableCup
        self.delegate = delegate as? ReusableCupCustomizingOrderTableViewCellDelegate
    }
}

protocol ReusableCupCustomizingOrderTableViewCellDelegate : CustomizingOrderTableViewCellDelegate {
    func valueChangedReusableCupSwitch(cell : ReusableCupCustomizingOrderTableViewCell, on : Bool)
}

class OneMoreCoffeeCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    var delegate : OneMoreCoffeeCustomizingOrderTableViewCellDelegate?
    
    @IBOutlet weak var oneMoreCoffeeSwitch: UISwitch!
    
    @IBAction func valueChangedOneMoreCoffeeSwitch(sender: UISwitch) {
        self.delegate?.valueChangedOneMoreCoffeeSwitch(self, on: sender.on)
    }
    
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)
        self.oneMoreCoffeeSwitch.enabled = self.orderListItem?.productEntity?.valueForKey("janCode") as? String == "4524785000018"
        self.oneMoreCoffeeSwitch.on = self.oneMoreCoffeeSwitch.enabled && orderListItem.oneMoreCoffee
        self.delegate = delegate as? OneMoreCoffeeCustomizingOrderTableViewCellDelegate
    }
}

protocol OneMoreCoffeeCustomizingOrderTableViewCellDelegate : CustomizingOrderTableViewCellDelegate {
    func valueChangedOneMoreCoffeeSwitch(cell : OneMoreCoffeeCustomizingOrderTableViewCell, on : Bool)
}

class TicketCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)
    }
}

class CustomItemCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityType: UILabel!
    
    @IBAction func touchUpInsideEditButton(sender: UIButton) {
        self.delegate?.touchUpInsideEditButton(self)
    }
    
    var delegate : CustomItemCustomizingOrderTableViewCellDelegate?
    var ingredient : Ingredient?
    
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)
        self.delegate = delegate as? CustomItemCustomizingOrderTableViewCellDelegate
        
        if let ingredient = indexPath.section == CustomizingOrderTableViewController.SectionIndex.Original ? orderListItem.originalItems?.ingredients[indexPath.row] : orderListItem.customizationItems?.ingredients[indexPath.row] {

            // TODO: 元々入っている要素の場合は値段を表記しないほうがすっきりするけど、ショットみたいに数量で変わる場合は表記する？
            // それとも、アドショットというくくりでカスタムアイテムのセクションに追加するか。
            self.ingredient = ingredient
            self.nameLabel.text = ingredient.name
            self.priceLabel.text = "¥\(ingredient.price())"
            self.quantityType.text = (ingredient.enable ? ingredient.quantityType.typeName() : "Non")
        }
    }
}

protocol CustomItemCustomizingOrderTableViewCellDelegate : CustomizingOrderTableViewCellDelegate {
    func touchUpInsideEditButton(cell : CustomItemCustomizingOrderTableViewCell)
}

class AddCustomItemCustomizingOrderTableViewCell : CustomizingOrderTableViewCell {
    
    var delegate : AddCustomItemCustomizingOrderTableViewCellDelegate?

    @IBAction func touchUpInsideAddCustomItemButton(sender: UIButton) {
        self.delegate?.touchUpInsideAddCustomItemButton(self)
    }
    
    override func configure(orderListItem: OrderListItem, delegate : CustomizingOrderTableViewCellDelegate?, indexPath : NSIndexPath) {
        super.configure(orderListItem, delegate: delegate, indexPath: indexPath)
        self.delegate = delegate as? AddCustomItemCustomizingOrderTableViewCellDelegate
    }
}

protocol AddCustomItemCustomizingOrderTableViewCellDelegate : CustomizingOrderTableViewCellDelegate {
    func touchUpInsideAddCustomItemButton(cell : AddCustomItemCustomizingOrderTableViewCell)
}

