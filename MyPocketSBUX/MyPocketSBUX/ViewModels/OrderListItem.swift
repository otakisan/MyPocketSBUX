//
//  OrderListItem.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/13.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

// 同一構成のオーダーでも別インスタンスにする
// インスタンスが実際の商品と対応する形
class OrderListItem: NSObject {
    var on : Bool = false
    var productEntity : AnyObject?
    var customizationItems : IngredientCollection?
    var originalItems : IngredientCollection?
    var nutritionEntities : [Nutrition] = []

    var totalPrice : Int = 0
    var customPrice : Int = 0
    var size : DrinkSize = .Tall
    var hotOrIce : String = ""
    var reusableCup : Bool = false
    
    // TODO: One More Coffeeをカスタムにするかメニューにするか
    var oneMoreCoffee : Bool = false
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let newOrderListItem = OrderListItem()
        newOrderListItem.on = self.on
        newOrderListItem.productEntity = self.productEntity // マスタデータなので、あえて参照コピー
        newOrderListItem.customizationItems = self.customizationItems?.copyWithZone(zone) as? IngredientCollection
        newOrderListItem.originalItems = self.originalItems?.copyWithZone(zone) as? IngredientCollection
        newOrderListItem.nutritionEntities = self.nutritionEntities
        newOrderListItem.totalPrice = self.totalPrice
        newOrderListItem.customPrice = self.customPrice
        newOrderListItem.size = self.size
        newOrderListItem.hotOrIce = self.hotOrIce
        newOrderListItem.reusableCup = self.reusableCup
        newOrderListItem.oneMoreCoffee = self.oneMoreCoffee
        
        return newOrderListItem
    }
}

class OrderHeader: NSObject {
    var store : Store?
    var notes : String = ""
}