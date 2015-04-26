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
    
    func saveIngredients(ingredients : [Ingredient], orderDetailId : Int, isOriginal : Bool) {
        
        let isOriginalNumber = NSNumber(bool: isOriginal)
        for ingredient in ingredients {
            //            var ingredientEntity : Order = Ingredients.instance().createEntity()
            //            ingredientEntity.id = 0
            //            ingredientEntity.orderDetailId = orderDetailId
            //
            //            Ingredients.insertEntity(ingredientEntity)
        }
    }
    
    // originalIngredients : [Ingredient], customIngredients : [Ingredient]
    func saveOrder(orderListItems : [(category : ProductCategory, orders: [OrderListItem])]) {
        // Order, OrderDetail, Customization
        
        // Order
        // 連番、登録日時、更新日時、店舗ID、合計金額（税抜）、合計金額（税込）、
        //            var order : Order = Orders.instance().createEntity()
        //            order.id = 0
        //            Orders.insertEntity(order)
        
        for orderListItem in self.unionOrderListItem(orderListItems) {
            // OrderDetail
            //            var orderDetail : Order = OrderDetails.instance().createEntity()
            //            orderDetail.id = 0
            //            OrderDetail.orderId = order.id
//            OrderDetail.createdAt = (now as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            //            OrderDetails.insertEntity(order)
            
            // TODO: 標準構成の中の要素で変更が入ったものが分からない
            // カスタムをアクションとみなして、それを登録
            // DBから読み取ってリドゥする形がいいのかも
//            if let originals = orderListItem.originalItems {
//                self.saveIngredients(originals, orderDetailId: OrderDetail.orderId, isOriginal: true)
//            }
//            if let customs = orderListItem.customizationItems {
//                self.saveIngredients(customs, orderDetailId: OrderDetail.orderId, isOriginal: false)
//            }
        }
    }
    
}
