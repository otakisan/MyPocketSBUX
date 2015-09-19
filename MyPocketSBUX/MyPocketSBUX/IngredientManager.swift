//
//  IngredientManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/22.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class IngredientManager: NSObject {
    static var instance : IngredientManager = IngredientManager()
    
    var availableChoiceMapping : AvailableChoiceMapping = AvailableChoiceMapping()
    
    func getAvailableCustomizationChoices(janCode : String) -> (originals : [Ingredient], customs : [Ingredient]) {
        var choices = ([Ingredient](), [Ingredient]())
        
        if let availableChoice = self.availableChoiceMapping.mappings[janCode] {
            choices = availableChoice()
        }
        
        return choices
    }
    
    func milk(milkType : MilkType) -> Ingredient {
        var ingredient : Ingredient!
        switch milkType {
        case .Whole:
            ingredient = ProtoTypeIngredients.wholeMilk.clone()
        case .TwoPercent:
            ingredient = ProtoTypeIngredients.twoPercentMilk.clone()
        case .NonFat:
            ingredient = ProtoTypeIngredients.nonFatMilk.clone()
        case .Soy:
            ingredient = ProtoTypeIngredients.soyMilk.clone()
        default:
            ingredient = ProtoTypeIngredients.wholeMilk.clone()
        }
        
        return ingredient
    }
}

class IngredientNames {
    static let vanillaSyrup = "Vanilla Syrup"
    static let mochaSyrup = "Mocha Syrup"
    static let chaiSyrup = "Chai Syrup"
    static let wholeMilk = "Whole Milk"
    static let twoPercentMilk = "Two Percent Milk"
    static let nonFatMilk = "Non Fat Milk"
    static let soyMilk = "Soy Milk"
    static let whippedCreamForFood = "Whipped Cream For Food"
    static let whippedCreamForDrink = "Whipped Cream For Drink"
    static let caramelSauce = "Caramel Sauce"
    static let chocolateSauce = "Chocolate Sauce"
}

// TODO: DB値から自動生成する
// 本来はDBから適用可能なカスタムアイテムを取ってくるんだろうけど
class ProductJanCodes {
    static let vanillaCreamFrappuccino = "4524785165939"
    static let amricanWaffle = "4524785261297"
}

// ミルクだけは商品によって分量が不定に変わるから、計算で算出できない。サイズと合わせ、カロリー表から取得するベース値に含める
// コピー可能とするためstruct
struct ProtoTypeIngredients {
    static let wholeMilk : Ingredient = Ingredient(type: .Milk, name: IngredientNames.wholeMilk, unitCalorie: 0, unitPrice: 50, quantity: 0, enable: false, quantityType: .Normal, isPartOfOriginalIngredients: false)
    static let twoPercentMilk : Ingredient = Ingredient(type: .Milk, name: IngredientNames.twoPercentMilk, unitCalorie: 0, unitPrice: 50, quantity: 0, enable: false, quantityType: .Normal, isPartOfOriginalIngredients: false)
    static let nonFatMilk : Ingredient = Ingredient(type: .Milk, name: IngredientNames.nonFatMilk, unitCalorie: 0, unitPrice: 50, quantity: 0, enable: false, quantityType: .Normal, isPartOfOriginalIngredients: false)
    static let soyMilk : Ingredient = Ingredient(type: .Milk, name: IngredientNames.soyMilk, unitCalorie: 0, unitPrice: 50, quantity: 0, enable: false, quantityType: .Normal, isPartOfOriginalIngredients: false)
    static let vanillaSyrup : Ingredient = Ingredient(type: .Syrup, name: IngredientNames.vanillaSyrup, unitCalorie: 19, unitPrice: 50, quantity: 0, enable : false, quantityType : .Normal, isPartOfOriginalIngredients: false)
    static let mochaSyrup : Ingredient = Ingredient(type: .Syrup, name: IngredientNames.mochaSyrup, unitCalorie: 35, unitPrice: 50, quantity: 0, enable : false, quantityType : .Normal, isPartOfOriginalIngredients: false)
    static let chaiSyrup : Ingredient = Ingredient(type: .Syrup, name: IngredientNames.chaiSyrup, unitCalorie: 35, unitPrice: 50, quantity: 0, enable : false, quantityType : .Normal, isPartOfOriginalIngredients: false)
    static let whippedCreamForFood : Ingredient = Ingredient(type: .WhippedCreamFood, name: IngredientNames.whippedCreamForFood, unitCalorie: 83, unitPrice: 30, quantity: 0, enable : false, quantityType : .Normal, isPartOfOriginalIngredients: false)
    static let whippedCreamForDrink : Ingredient = Ingredient(type: .WhippedCreamDrink, name: IngredientNames.whippedCreamForDrink, unitCalorie: 83, unitPrice: 50, quantity: 0, enable : false, quantityType : .Normal, isPartOfOriginalIngredients: false)
    static let caramelSauce : Ingredient = Ingredient(type: .Sauce, name: IngredientNames.caramelSauce, unitCalorie: 22, unitPrice: 0, quantity: 0, enable : false, quantityType : .Normal, isPartOfOriginalIngredients: false)
    static let chocolateSauce : Ingredient = Ingredient(type: .Sauce, name: IngredientNames.chocolateSauce, unitCalorie: 9, unitPrice: 0, quantity: 0, enable : false, quantityType : .Normal, isPartOfOriginalIngredients: false)
}

class AvailableChoiceMapping {
    
    
    typealias GetChoice = () -> (originals : [Ingredient], customs : [Ingredient])
    lazy var mappings : [String : GetChoice] = self.createMappings()
    
    func createMappings() -> [String : GetChoice] {
        var mappings = [String : GetChoice]()
        
        // TODO: 商品ごとのカスタマイズ項目列挙も自動生成か何か効率化したいところ
        mappings[ProductJanCodes.vanillaCreamFrappuccino] = self.originalsAndCustomsOfVanillaFrappuccino
        mappings[ProductJanCodes.amricanWaffle] = self.originalsAndCustomsOfFood
        
        return mappings
    }
    
    // カスタムの数だけ出てくるな…。自動生成スクリプトを組んだほうがいいか？
    func originalsAndCustomsOfVanillaFrappuccino() -> (originals : [Ingredient], customs : [Ingredient]) {
        
        // よく考えたら、数量はサイズに依存するな…
        let originals : [Ingredient] = [
            ProtoTypeIngredients.wholeMilk.clone(),
            ProtoTypeIngredients.vanillaSyrup.clone(),
            ProtoTypeIngredients.whippedCreamForDrink.clone()
        ]
        
        // 有効フラグとオリジナル構成であるフラグを立てる
        for org in originals {
            org.enable = true
            org.unitPrice = 0 // 元々の価格に含まれているため
            org.isPartOfOriginalIngredients = true
        }
        
        var customs : [Ingredient] = self.frappuccinoCommonCustoms()
        
        // 重複ものを外す
        customs = customs.filter { customItem in !originals.contains({original in original.name == customItem.name }) }
        
        return (originals, customs)
    }

    func originalsAndCustomsOfFood() -> (originals : [Ingredient], customs : [Ingredient]) {
        
        // フードはもともとの要素にカスタマイズできるものはない
        let originals : [Ingredient] = [
        ]
        
        // 有効フラグとオリジナル構成であるフラグを立てる
        for org in originals {
            org.enable = true
            org.unitPrice = 0 // 元々の価格に含まれているため
            org.isPartOfOriginalIngredients = true
        }
        
        var customs : [Ingredient] = self.foodCommonCustoms()
        
        // 重複ものを外す
        customs = customs.filter { customItem in !originals.contains({original in original.name == customItem.name }) }
        
        return (originals, customs)
    }

    func foodCommonCustoms() -> [Ingredient] {
        // カスタム候補は全て数量ゼロでOK
        return [
            ProtoTypeIngredients.caramelSauce.clone(),
            ProtoTypeIngredients.chocolateSauce.clone(),
            ProtoTypeIngredients.whippedCreamForFood.clone()
        ]
    }

    func frappuccinoCommonCustoms() -> [Ingredient] {
        // カスタム候補は全て数量ゼロでOK
        return [
            ProtoTypeIngredients.vanillaSyrup.clone(),
            ProtoTypeIngredients.mochaSyrup.clone(),
            ProtoTypeIngredients.chaiSyrup.clone(),
            ProtoTypeIngredients.caramelSauce.clone(),
            ProtoTypeIngredients.chocolateSauce.clone()
        ]
    }
}
