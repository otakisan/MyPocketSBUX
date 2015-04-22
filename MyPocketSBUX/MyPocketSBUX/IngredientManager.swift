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
        
        if let getMappings = self.availableChoiceMapping.mappings[janCode] {
            choices = getMappings()
        }
        
        return choices
    }
}

class IngredientNames {
    static let vanillaSyrup = "Vanilla Syrup"
    static let mochaSyrup = "Mocha Syrup"
    static let chaiSyrup = "Chai Syrup"
    static let wholeMilk = "Whole Milk"
    static let whippedCreamForFood = "Whipped Cream For Food"
    static let whippedCreamForDrink = "Whipped Cream For Drink"
}

// TODO: DB値から自動生成する
class IngredientJanCodes {
    static let vanillaSyrup = "4524785165939"
}

class AvailableChoiceMapping {
    
    // ミルクだけは商品によって分量が不定に変わるから、計算で算出できない。サイズと合わせ、カロリー表から取得するベース値に含める
    struct ProtoTypeIngredients {
        static let wholeMilk : Ingredient = Ingredient(type: .Milk, name: IngredientNames.wholeMilk, unitCalorie: 0, unitPrice: 50, quantity: 0)
        static let vanillaSyrup : Ingredient = Ingredient(type: .Syrup, name: IngredientNames.vanillaSyrup, unitCalorie: 19, unitPrice: 50, quantity: 0)
        static let mochaSyrup : Ingredient = Ingredient(type: .Syrup, name: IngredientNames.mochaSyrup, unitCalorie: 35, unitPrice: 50, quantity: 0)
        static let chaiSyrup : Ingredient = Ingredient(type: .Syrup, name: IngredientNames.chaiSyrup, unitCalorie: 35, unitPrice: 50, quantity: 0)
        static let whippedCreamForFood : Ingredient = Ingredient(type: .WhippedCreamFood, name: IngredientNames.whippedCreamForFood, unitCalorie: 83, unitPrice: 30, quantity: 0)
        static let whippedCreamForDrink : Ingredient = Ingredient(type: .WhippedCreamDrink, name: IngredientNames.whippedCreamForDrink, unitCalorie: 83, unitPrice: 50, quantity: 0)
    }
    
    typealias GetChoice = () -> (originals : [Ingredient], customs : [Ingredient])
    lazy var mappings : [String : GetChoice] = self.createMappings()
    
    func createMappings() -> [String : GetChoice] {
        var mappings = [String : GetChoice]()
        mappings[IngredientJanCodes.vanillaSyrup] = self.originalsAndCustomsOfVanillaFrappuccino
        
        return mappings
    }
    
    // カスタムの数だけ出てくるな…。自動生成スクリプトを組んだほうがいいか？
    func originalsAndCustomsOfVanillaFrappuccino() -> (originals : [Ingredient], customs : [Ingredient]) {
        
        // よく考えたら、数量はサイズに依存するな…
        let originals : [Ingredient] = [ProtoTypeIngredients.wholeMilk, ProtoTypeIngredients.vanillaSyrup, ProtoTypeIngredients.whippedCreamForDrink]
        
        let customs : [Ingredient] = self.frappuccinoCommonCustoms()
        
        return (originals, customs)
    }
    
    func frappuccinoCommonCustoms() -> [Ingredient] {
        // カスタム候補は全て数量ゼロでOK
        return [ProtoTypeIngredients.vanillaSyrup, ProtoTypeIngredients.mochaSyrup, ProtoTypeIngredients.chaiSyrup]
    }
}
