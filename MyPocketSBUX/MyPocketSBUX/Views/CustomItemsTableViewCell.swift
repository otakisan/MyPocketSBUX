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
    
    @IBOutlet weak var additionSwitch: UISwitch!
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
        //self.changeStateQuantitySegment(self.ingredient.quantity > 0)
        self.delegate = delegate as? SyrupCustomItemsTableViewCellDelegate
        
        // オリジナルの場合、ON固定
        
        // 初期選択
        self.additionSwitch.on = self.ingredient.enable
        self.quantitySegment.selectedSegmentIndex = self.ingredient.quantityType.hashValue
        
        // ON/OFFイベント
        self.valueChangedAdditionSwitch(self.additionSwitch)
    }
    
    func changeStateQuantitySegment(on : Bool) {
        self.quantitySegment.enabled = on
    }
}

protocol SyrupCustomItemsTableViewCellDelegate : CustomItemsTableViewCellDelegate {
    func valueChangedAdditionSwitch(cell : SyrupCustomItemsTableViewCell, added : Bool)
    func valueChangedQuantitySegment(cell : SyrupCustomItemsTableViewCell, type : QuantityType)
}

class WhippedCreamCustomItemsTableViewCell: CustomItemsTableViewCell {
    
    @IBOutlet weak var additionSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantitySegment: UISegmentedControl!
    
    @IBAction func valueChangedAdditionSwitch(sender: UISwitch) {
        self.delegate?.valueChangedWhippedCreamAdditionSwitch(self, added: sender.on)
        self.changeStateQuantitySegment(sender.on)
    }
    
    @IBAction func valueChangedQuantitySegment(sender: UISegmentedControl) {
        self.delegate?.valueChangedWhippedCreamQuantitySegment(self, type: QuantityType.fromNumeric(sender.selectedSegmentIndex))
    }
    
    var delegate : WhippedCreamCustomItemsTableViewCellDelegate?
    
    override func configure(ingredient: Ingredient, delegate : CustomItemsTableViewCellDelegate) {
        self.ingredient = ingredient
        
        // 名称はドリンク・フード共通にするため、個別の名称は設定しない
        //self.nameLabel.text = ingredient.name
        self.delegate = delegate as? WhippedCreamCustomItemsTableViewCellDelegate
        
        // 初期選択
        self.additionSwitch.on = self.ingredient.enable
        self.quantitySegment.selectedSegmentIndex = self.ingredient.quantityType.hashValue
        
        // ON/OFFイベント
        self.valueChangedAdditionSwitch(self.additionSwitch)
    }
    
    func changeStateQuantitySegment(on : Bool) {
        self.quantitySegment.enabled = on
    }
}

protocol WhippedCreamCustomItemsTableViewCellDelegate : CustomItemsTableViewCellDelegate {
    // TODO: Xcode 6.3 だと引数が異なっても、ビルドエラーになってしまうため、暫定的に固有の名称を付与する
    func valueChangedWhippedCreamAdditionSwitch(cell : WhippedCreamCustomItemsTableViewCell, added : Bool)
    func valueChangedWhippedCreamQuantitySegment(cell : WhippedCreamCustomItemsTableViewCell, type : QuantityType)
}

// TODO: 名称、数量セグメント、追加スイッチの構成の場合は、共通クラス化できるけど、具体的なコントロールとの紐付けを動的にやる必要があるかも
// 名称は個別に設定できる形で。
class SauceCustomItemsTableViewCell: CustomItemsTableViewCell {
    
    @IBOutlet weak var additionSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantitySegment: UISegmentedControl!
    
    @IBAction func valueChangedAdditionSwitch(sender: UISwitch) {
        self.delegate?.valueChangedSauceAdditionSwitch(self, added: sender.on)
        self.changeStateQuantitySegment(sender.on)
    }
    
    @IBAction func valueChangedQuantitySegment(sender: UISegmentedControl) {
        self.delegate?.valueChangedSauceQuantitySegment(self, type: QuantityType.fromNumeric(sender.selectedSegmentIndex))
    }
    
    var delegate : SauceCustomItemsTableViewCellDelegate?
    
    override func configure(ingredient: Ingredient, delegate : CustomItemsTableViewCellDelegate) {
        
        // メンバを初期化
        self.ingredient = ingredient
        self.nameLabel.text = ingredient.name
        self.delegate = delegate as? SauceCustomItemsTableViewCellDelegate
        
        // 初期選択
        self.additionSwitch.on = self.ingredient.enable
        self.quantitySegment.selectedSegmentIndex = self.ingredient.quantityType.hashValue
        
        // ON/OFFイベント
        self.valueChangedAdditionSwitch(self.additionSwitch)
    }
    
    func changeStateQuantitySegment(on : Bool) {
        self.quantitySegment.enabled = on
    }
}

protocol SauceCustomItemsTableViewCellDelegate : CustomItemsTableViewCellDelegate {
    func valueChangedSauceAdditionSwitch(cell : SauceCustomItemsTableViewCell, added : Bool)
    func valueChangedSauceQuantitySegment(cell : SauceCustomItemsTableViewCell, type : QuantityType)
}

class MilkCustomItemsTableViewCell: CustomItemsTableViewCell {
    
    @IBOutlet weak var quantitySegment: UISegmentedControl!
    @IBOutlet weak var additionSwitch: UISwitch!
    @IBOutlet weak var milkSegment: UISegmentedControl!
    
    @IBAction func valueChangedQuantitySegment(sender: UISegmentedControl) {
        self.delegate?.valueChangedMilkQuantitySegment(self, type: QuantityType.fromNumeric(sender.selectedSegmentIndex))
    }
    
    @IBAction func valueChangedAdditionSwitch(sender: UISwitch) {
        self.delegate?.valueChangedMilkAdditionSwitch(self, added: sender.on)
        self.changeStateMilkSegment(sender.on)
        self.changeStateQuantitySegment(sender.on)
    }
    
    @IBAction func valueChangedMilkSegment(sender: UISegmentedControl) {
        self.delegate?.valueChangedMilkSegment(self, type: MilkType.fromNumeric(sender.selectedSegmentIndex))
    }
    
    var delegate : MilkCustomItemsTableViewCellDelegate?
    
    override func configure(ingredient: Ingredient, delegate : CustomItemsTableViewCellDelegate) {
        self.ingredient = ingredient
        self.delegate = delegate as? MilkCustomItemsTableViewCellDelegate
        
        // オリジナルの場合、ON固定
        self.additionSwitch.on = self.ingredient.enable
        self.additionSwitch.enabled = !self.ingredient.isPartOfOriginalIngredients
        self.changeStateMilkSegment(self.additionSwitch.on)
        self.changeStateQuantitySegment(self.additionSwitch.on)
        
        // 初期選択
        self.quantitySegment.selectedSegmentIndex = self.ingredient.quantityType.hashValue
        self.milkSegment.selectedSegmentIndex = MilkType.fromString(self.ingredient.name).hashValue
        
        // ON/OFFイベント
        self.valueChangedAdditionSwitch(self.additionSwitch)
    }
    
    func changeStateMilkSegment(on : Bool) {
        self.milkSegment.enabled = on
    }
    
    func changeStateQuantitySegment(on : Bool) {
        self.quantitySegment.enabled = on
    }
}

protocol MilkCustomItemsTableViewCellDelegate : CustomItemsTableViewCellDelegate {
    // TODO: Xcode 6.3 だと引数が異なっても、ビルドエラーになってしまうため、暫定的に固有の名称を付与する
    func valueChangedMilkAdditionSwitch(cell : MilkCustomItemsTableViewCell, added : Bool)
    func valueChangedMilkSegment(cell : MilkCustomItemsTableViewCell, type : MilkType)
    func valueChangedMilkQuantitySegment(cell : MilkCustomItemsTableViewCell, type : QuantityType)
}

enum MilkType {
    case Whole
    case TwoPercent
    case NonFat
    case Soy
    
    static func fromNumeric(typeValue : Int) -> MilkType {
        var type = Whole
        switch typeValue {
        case 0:
            type = Whole
        case 1:
            type = TwoPercent
        case 2:
            type = NonFat
        case 3:
            type = Soy
        default:
            type = Whole
        }
        
        return type
    }
    
    static func fromString(milkName : String) -> MilkType {
        var type = Whole
        switch milkName {
        case IngredientNames.wholeMilk:
            type = Whole
        case IngredientNames.twoPercentMilk:
            type = TwoPercent
        case IngredientNames.nonFatMilk:
            type = NonFat
        case IngredientNames.soyMilk:
            type = Soy
        default:
            type = Whole
        }
        
        return type
    }
}

enum QuantityType {
    case Light
    case Normal
    case Extra
    
    static func fromNumeric(typeValue : Int) -> QuantityType {
        var type = Normal
        switch typeValue {
        case 0:
            type = Light
        case 1:
            type = Normal
        case 2:
            type = Extra
        default:
            type = Normal
        }
        
        return type
    }
    
    func typeName() -> String {
        var name = ""
        switch self {
        case Light:
            name = "Light"
        case Normal:
            name = ""
        case Extra:
            name = "Extra"
        default:
            name = ""
        }
        
        return name
    }
    
    /**
    数量タイプを考慮した数量の加算 量の増減という観点から、ゼロはない。
    ゼロの場合は、カスタマイズ項目から外す
    標準要素であっても、一覧上に表示され、スイッチオフによりノンシロップ等を表現する
    */
    func addQuantity(baseValue : Int) -> Int {
        return max(1, (self == Light ? baseValue - 1 : self == Extra ? baseValue + 1 : baseValue))
    }
    
    func quantityToAdd() -> Int {
        return (self == Light ? -1 : self == Extra ? 1 : 0)
    }
}