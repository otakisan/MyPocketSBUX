//
//  PriceCalculator.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/25.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class PriceCalculator {
    
    var basePrice : Int = 0
    
    class func createPriceCalculatorForEntity(entity : AnyObject?, customizedOriginals : IngredientCollection?, customs : IngredientCollection?, discountFactors : [String], size : DrinkSize) -> PriceCalculator? {
        
        var calculator : PriceCalculator?
        if let janCode = entity?.valueForKey("janCode") as? String {
            let basePrice = (entity?.valueForKey("price") as? NSNumber ?? NSNumber(int: 0)).integerValue
            if entity is Drink {
                calculator = DrinkPriceCalculator(janCode: janCode, customizedOriginals: customizedOriginals, customs: customs, discountFactors: discountFactors, size: size)
            }
            else if entity is Food {
                calculator = FoodPriceCalculator(janCode: janCode, customizedOriginals: customizedOriginals, customs: customs, discountFactors: discountFactors)
            }
            
            calculator?.basePrice = basePrice
        }
        
        return calculator
    }
    
    class func totalPrice(orderItems : [OrderListItem]) -> (taxExcluded:Int, taxIncluded:Int) {
        let price = orderItems.reduce(0, combine: {
                $0 + $1.totalPrice
            })
        
        return (taxExcluded:price, taxIncluded:Int(Double(price) * 1.08))
    }
    
    func priceForTotal() -> Int {
        return 0
    }
    
    func priceForCustoms() -> Int {
        return 0
    }
}

class FoodPriceCalculator : PriceCalculator {
    init(janCode : String, customizedOriginals : IngredientCollection?, customs : IngredientCollection?, discountFactors : [String]){
        
    }
}

class DrinkPriceCalculator : PriceCalculator {
    
    struct Discount {
        static let reusableCup = (name: "reusableCup", discount: 20)
        static let oneMoreCoffee = (name: "oneMoreCoffee", discount: 100)
    }
    
    
    var baseIngredients : IngredientCollection!
    var customizedOriginals : IngredientCollection?
    var customs : IngredientCollection?
    var discountFactors : [String] = []
    var size: DrinkSize = .Tall
    
    init(janCode : String, customizedOriginals : IngredientCollection?, customs : IngredientCollection?, discountFactors : [String], size: DrinkSize){
        
        var baseIngredientCollection = IngredientCollection()
        baseIngredientCollection.ingredients = IngredientManager.instance.getAvailableCustomizationChoices(janCode).originals
        self.baseIngredients = baseIngredientCollection
        
        self.customizedOriginals = customizedOriginals
        self.customs = customs
        self.discountFactors = discountFactors
        self.size = size
    }
    
    // カスタムアイテムの計算仕様
    // シロップ、チップ、ホイップと種別ごとに小計を算出し、基本価格（Base Price）に合計する
    // セルの種類は、シロップ・ソース・チップ…という種類ごとでよい？
    // カスタムの要素と数量から、標準構成との差をとり、カスタムメニューの情報を表示する
    override func priceForTotal() -> Int {
        // JANコードからベース価格と標準構成を取得
        // 引数で渡されたカスタマイズ状態から価格を決定する
        
        
        // カスタム内容によらず無料のものは除外する
        // ショット、コーヒー、ホイップ、シロップ、チップ、ソイ、期間限定（ジェリー、プリン）
        // 期間限定ものは、それが始まってから随時対応する
        var total = max(0, self.basePrice + self.sizePrice() + self.priceForCustoms() - self.discountPrice() - self.couponPrice())
        
        return total
    }
    
    override func priceForCustoms() -> Int {
        var total = self.priceForEspresso() + self.priceForBrewedCoffee() + self.priceForWhippedCreme() + self.priceForSyrup() + self.priceForChips() + self.priceForMilk()
        
        return total
    }
    
    func sizePrice() -> Int {
        
        // TODO: ホットティーの場合は、ショートでも価格は同じ
        // ホットティーを表すJANコードの場合は、必ずプラス価格とする（トール基準）
        return self.size.priceForDelta()
    }
    
    func discountPrice() -> Int {
        // ワンモアがあれば、そちら。なければ、カップ値引き
        var discountPrice = 0
        if self.discountFactors.filter({$0 == Discount.oneMoreCoffee.name}).count > 0 {
            // ベース価格が100円（税抜）になるような割引価格を出す
            discountPrice = self.basePrice + self.sizePrice() - Discount.oneMoreCoffee.discount
        }
        else if self.discountFactors.filter({$0 == Discount.reusableCup.name}).count > 0 {
            discountPrice = Discount.reusableCup.discount
        }

        return discountPrice
        //return self.discountFactors.reduce(0, combine: {$0 + $1.discount})
    }
    
    func couponPrice() -> Int {
        // チケットは総額からの値引きになる
        return 0
    }
    
    func priceForMilk() -> Int {
        // ノンミルク系ドリンクに追加 or ソイへ変更
        return (self.isDairy() || self.isBaseMilkChangedToSoy()) ? 50 : 0
    }
    
    func isDairy() -> Bool {
        let isNonMilk = (self.baseIngredients.ingredients.filter( { $0.type == CustomizationIngredientype.Milk } ).count == 0)
        let isDairyAdded = ((self.customs?.ingredients.filter({$0.type == CustomizationIngredientype.Milk}).count ?? 0) > 0)
        
        return isNonMilk && isDairyAdded
    }
    
    func isBaseMilkChangedToSoy() -> Bool {
        // 価格に関係する「豆乳」の観点は、ベース要素のミルクがそうであるか
        // 追加ミルクは一律で同一価格をプラスなので見ない
        return self.customizedOriginals?.ingredients.filter({$0.type == CustomizationIngredientype.Milk && $0.name == IngredientNames.soyMilk}).count > 0
    }
    
    func totalNumberOfTypes(type : CustomizationIngredientype) -> Int {
        return (self.customizedOriginals?.ingredients.filter({$0.type == type && $0.enable}).count ?? 0) + (self.customs?.ingredients.filter({$0.type == type}).count ?? 0)
    }
    
    func priceForChips() -> Int {
        //
        var baseNumberOfChipTypes = self.baseIngredients.categorized(.Chip).count
        var totalNumberOfChipTypes = self.totalNumberOfChipTypes()
        var addedNumberOfChipTypes = totalNumberOfChipTypes - baseNumberOfChipTypes
        
        // ベース以下のショット数にしても価格は同じ
        var price = max(0, addedNumberOfChipTypes * 50)
        
        return price
    }
    
    func totalNumberOfChipTypes() -> Int {
        return self.totalNumberOfTypes(.Chip)
    }
    
    func priceForWhippedCreme() -> Int {
        //
        var baseNumberOfWhippedCreamTypes = self.baseIngredients.categorized(.WhippedCreamDrink).count
        var totalNumberOfWhippedCreamTypes = self.totalNumberOfWhippedCreamTypes()
        var addedNumberOfWhippedCreamTypes = totalNumberOfWhippedCreamTypes - baseNumberOfWhippedCreamTypes
        
        // ベース以下のショット数にしても価格は同じ
        var price = max(0, addedNumberOfWhippedCreamTypes * 50)
        
        return price
    }
    
    func totalNumberOfWhippedCreamTypes() -> Int {
        return self.totalNumberOfTypes(.WhippedCreamDrink)
    }
    
    func priceForBrewedCoffee() -> Int {
        // 1が標準、2が増量
        var baseNumberOfCoffee = self.baseIngredients.categorized(.Coffee).count
        var totalNumberOfCoffee = self.totalNumberOfCoffee()
        var addedNumberOfCoffee = totalNumberOfCoffee - baseNumberOfCoffee
        
        // ベース以下のショット数にしても価格は同じ
        var price = max(0, addedNumberOfCoffee * 50)
        
        return price
    }
    
    func totalNumberOfCoffee() -> Int {
        return self.totalNumberOfTypes(.Coffee)
    }
    
    func priceForEspresso() -> Int {
        // ショット数の差分
        var baseNumberOfEspressoShots = self.baseIngredients.categorized(.Espresso).count
        var totalNumberOfEspressoShots = self.totalNumberOfEspressoShots()
        var addedNumberOfEspressoShots = totalNumberOfEspressoShots - baseNumberOfEspressoShots
        
        // ベース以下のショット数にしても価格は同じ
        var price = max(0, addedNumberOfEspressoShots * 50)
        
        return price
    }
    
    func totalNumberOfEspressoShots() -> Int {
        // オリジナルかカスタムかどちらか一方にしか存在しないはず
        return (self.customizedOriginals?.ingredients.filter({$0.type == .Espresso}).first?.quantity ?? 0) + (self.customs?.ingredients.filter({$0.type == .Espresso}).first?.quantity ?? 0)
    }
    
    func priceForSyrup() -> Int {
        // シロップの種類から
        var baseNumberOfSyrupTypes = self.baseIngredients.categorized(.Syrup).count
        var totalNumberOfSyrupTypes = self.totalNumberOfSyrupTypes()
        var addedNumberOfSyrupTypes = totalNumberOfSyrupTypes - baseNumberOfSyrupTypes
        
        // ベースが１種類、ノンシロップにしてもマイナスにはならない
        // 変更であれば、差分がゼロになる
        var price = max(0, addedNumberOfSyrupTypes * 50)
        
        return price
    }
    
    func totalNumberOfSyrupTypes() -> Int {
        // 画面上、選択項目から種類数を算出する
        return self.totalNumberOfTypes(.Syrup)
    }

}
