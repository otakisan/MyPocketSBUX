//
//  OrderManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/26.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class OrderManager: NSObject {
    
    static let instance = OrderManager()
    
    func unionOrderListItem(orderListItems : [(category : ProductCategory, orders: [OrderListItem])]) -> [OrderListItem] {
        return orderListItems.map({$0.orders}).reduce([], combine: {$0 + $1})
    }
    
    func saveIngredients(ingredients : [Ingredient], orderId : Int, orderDetailId : Int, isCustom : Bool, now: NSDate) {
        
        for ingredient in ingredients {
            var ingredientEntity : ProductIngredient = ProductIngredients.instance().createEntity()
            ingredientEntity.id = ProductIngredients.sequenceNumber()
            ingredientEntity.orderId = orderId
            ingredientEntity.orderDetailId = orderDetailId
            ingredientEntity.isCustom = !ingredient.isPartOfOriginalIngredients
            ingredientEntity.name = ingredient.name
            ingredientEntity.type = ingredient.type.name()
            ingredientEntity.unitCalorie = ingredient.unitCalorie
            ingredientEntity.unitPrice = ingredient.unitPrice
            ingredientEntity.quantity = ingredient.quantity
            ingredientEntity.enabled = ingredient.enable
            ingredientEntity.quantityType = ingredient.quantityType.hashValue
            ingredientEntity.remarks = ""
            ingredientEntity.createdAt = now
            ingredientEntity.updatedAt = now
            
            ProductIngredients.insertEntity(ingredientEntity)
        }
    }
    
    // originalIngredients : [Ingredient], customIngredients : [Ingredient]
    func saveOrder(orderListItems : [(category : ProductCategory, orders: [OrderListItem])], orderHeader : OrderHeader?) {
        // TODO: オーダー項目なしの場合に登録を行わないように制御する
        
        // Order
        // 連番、登録日時、更新日時、店舗ID、合計金額（税抜）、合計金額（税込）、
        let now = NSDate()
        var order : Order = Orders.instance().createEntity()
        let orderId = Orders.sequenceNumber()
        order.id = orderId
        order.storeId = orderHeader?.store?.storeId ?? 0
        let totalPrice = PriceCalculator.totalPrice(OrderManager.instance.unionOrderListItem(orderListItems))
        order.taxExcludedTotalPrice = totalPrice.taxExcluded
        order.taxIncludedTotalPrice = totalPrice.taxIncluded
        order.notes = orderHeader?.notes ?? ""
        order.remarks = ""
        order.createdAt = now
        order.updatedAt = now
        Orders.insertEntity(order)
        
        for orderListItem in self.unionOrderListItem(orderListItems) {
            // OrderDetail
            var orderDetail : OrderDetail = OrderDetails.instance().createEntity()
            let orderDetailId = OrderDetails.sequenceNumber() // TODO: 秒単位だと重複する できればμs単位にしたい それか乱数
            orderDetail.id = orderDetailId
            orderDetail.orderId = orderId
            orderDetail.productName = orderListItem.productEntity?.valueForKey("name") as? String ?? ""
            orderDetail.productJanCode = orderListItem.productEntity?.valueForKey("janCode") as? String ?? ""
            orderDetail.size = orderListItem.size.name()
            orderDetail.hotOrIced = orderListItem.hotOrIce
            orderDetail.reusableCup = orderListItem.reusableCup
            orderDetail.ticket = self.ticketString(orderListItem)
            orderDetail.taxExcludeTotalPrice = orderListItem.totalPrice
            orderDetail.taxExcludeCustomPrice = orderListItem.customPrice
            orderDetail.totalCalorie = 0 // TODO
            orderDetail.customCalorie = 0
            orderDetail.remarks = ""
            orderDetail.createdAt = now
            orderDetail.updatedAt = now
            OrderDetails.insertEntity(orderDetail)
            
            // TODO: 標準構成の中の要素で変更が入ったものが分からない
            // カスタムをアクションとみなして、それを登録
            // DBから読み取ってリドゥする形がいいのかも
            if let originals = orderListItem.originalItems {
                self.saveIngredients(originals.ingredients, orderId: orderId, orderDetailId: orderDetailId, isCustom: false, now: now)
            }
            if let customs = orderListItem.customizationItems {
                self.saveIngredients(customs.ingredients, orderId: orderId, orderDetailId: orderDetailId, isCustom: true, now: now)
            }
        }
    }
    
    func ticketString(orderListItem : OrderListItem) -> String {
        // TODO: 5000入金チケット等も将来的に埋め込む
        return orderListItem.oneMoreCoffee ? "oneMoreCoffee" : ""
    }
    
    func oneMoreCoffee(ticketString : String) -> Bool {
        return ticketString.rangeOfString("oneMoreCoffee", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil) != nil
    }
    
    func productEntity(janCode : String) -> AnyObject? {
        // TODO: ドリンクにヒットしなかったら、フードも検索して、結果を返す
        var product : AnyObject? = Drinks.findByJanCode(janCode)
        if product == nil {
            product = Foods.findByJanCode(janCode)
        }
        if product == nil {
            product = Beans.findByJanCode(janCode, orderKeys: []).first
        }
        
        return product
    }
    
    func ingredient(productIngredient : ProductIngredient) -> Ingredient {
        var ingredient = Ingredient()
        ingredient.type = CustomizationIngredientype.fromString(productIngredient.type)
        ingredient.name = productIngredient.name
        ingredient.unitCalorie = Int(productIngredient.unitCalorie)
        ingredient.unitPrice = Int(productIngredient.unitPrice)
        ingredient.quantity = Int(productIngredient.quantity)
        ingredient.enable = Bool(productIngredient.enabled)
        ingredient.quantityType = QuantityType.fromNumeric(Int(productIngredient.quantityType))
        ingredient.isPartOfOriginalIngredients = !Bool(productIngredient.isCustom)
        
        return ingredient
    }
    
    func ingredientCollection(ingredientEntities : [ProductIngredient]) -> (originals:IngredientCollection, customs:IngredientCollection) {
        var ingredientCollectionOriginals = IngredientCollection()
        ingredientCollectionOriginals.ingredients = []
        var ingredientCollectionCustoms = IngredientCollection()
        ingredientCollectionCustoms.ingredients = []
        
        
        for entity in ingredientEntities {
            let ingredient = self.ingredient(entity)
            if ingredient.isPartOfOriginalIngredients {
                ingredientCollectionOriginals.ingredients += [self.ingredient(entity)]
            }
            else{
                ingredientCollectionCustoms.ingredients += [self.ingredient(entity)]
            }
        }
        
        return (ingredientCollectionOriginals, ingredientCollectionCustoms)
    }
    
    func loadOrder(order : Order, orderDetails : [OrderDetail]) -> (header: OrderHeader, details: [OrderListItem]) {
        var header = OrderHeader()
        header.store = Stores.findByStoreId(Int(order.storeId))
        header.notes = order.notes
        var details = self.loadOrder(orderDetails: orderDetails)
        
        return (header, details)
    }
    
    func loadOrder(#orderDetails : [OrderDetail]) -> [OrderListItem] {
        
        var orderListItems : [OrderListItem] = []
        for orderDetail in orderDetails {
            orderListItems += [self.loadOrder(orderDetail: orderDetail)]
        }
        
        return orderListItems
    }
    
    func loadOrder(#orderDetail : OrderDetail) -> OrderListItem {
        var orderListItem = OrderListItem()
        
        let ingredientEntities = ProductIngredients.findProductIngredientsByOrderIdAndOrderDetailIdFetchRequest(Int(orderDetail.orderId), orderDetailId: Int(orderDetail.id), orderKeys: [("id", true)])
        let ingredientCollection = self.ingredientCollection(ingredientEntities)
        
        orderListItem.on = self.oneMoreCoffee(orderDetail.ticket)
        orderListItem.productEntity = self.productEntity(orderDetail.productJanCode)
        orderListItem.customizationItems = ingredientCollection.customs
        orderListItem.originalItems = ingredientCollection.originals
        orderListItem.nutritionEntities = [] // TODO: 
        orderListItem.totalPrice = Int(orderDetail.taxExcludeTotalPrice)
        orderListItem.customPrice = Int(orderDetail.taxExcludeCustomPrice)
        orderListItem.size = DrinkSize.fromString(orderDetail.size)
        orderListItem.hotOrIce = orderDetail.hotOrIced
        orderListItem.reusableCup = Bool(orderDetail.reusableCup)
        orderListItem.oneMoreCoffee = self.oneMoreCoffee(orderDetail.ticket)
        
        return orderListItem
    }
    
    func getAllOrderFromLocal() -> [Order] {
        return Orders.getAllOrderBy("allOrdersFetchRequest", orderKeys: [(columnName : "createdAt", ascending : true)])
    }

}
