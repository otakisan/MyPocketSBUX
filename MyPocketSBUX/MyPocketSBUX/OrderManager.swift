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
    func saveOrder(orderListItems : [(category : ProductCategory, orders: [OrderListItem])]) {
        // Order, OrderDetail, Customization
        
        // Order
        // 連番、登録日時、更新日時、店舗ID、合計金額（税抜）、合計金額（税込）、
        let now = NSDate()
        var order : Order = Orders.instance().createEntity()
        let orderId = Orders.sequenceNumber()
        order.id = orderId
        order.storeId = self.storeId()
        let totalPrice = PriceCalculator.totalPrice(OrderManager.instance.unionOrderListItem(orderListItems))
        order.taxExcludedTotalPrice = totalPrice.taxExcluded
        order.taxIncludedTotalPrice = totalPrice.taxIncluded
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
            orderDetail.ticket = ""
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
    
    func storeId() -> Int {
        return 380
    }
    
    func getAllOrderFromLocal() -> [Order] {
        return Orders.getAllOrderBy("allOrdersFetchRequest", orderKeys: [(columnName : "createdAt", ascending : true)])
    }

}
