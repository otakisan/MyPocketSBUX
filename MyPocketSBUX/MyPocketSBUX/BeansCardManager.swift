//
//  BeansCardManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/08.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class BeansCardManager: NSObject {
    static let instance = BeansCardManager()
    
    func purchasedItems() -> [PurchasedBeanItem] {
        // TODO: Janコードで検索して、Beanと関連づくOrderDetailを取得
        // それらの合計をそのオーダーでの豆の購入金額とする
        // 普通にSQLでいくなら、ジョインかExsitsでいけるけど…
        
        var orderdetails = OrderDetails.instance().orderDetailsWithBean()
        
        var purchasedItems : [PurchasedBeanItem] = []
        var prevOrderId = -1
        for orderDetail in orderdetails {
            let orderId = Int(orderDetail.orderId)
            if orderId != prevOrderId {
                prevOrderId = orderId
                var listItem = PurchasedBeanItem()
                purchasedItems += [listItem]
            }
            
            purchasedItems.last?.details += [orderDetail]
            purchasedItems.last?.totolPrice += Int(orderDetail.taxExcludeTotalPrice)
        }
        
        // 全体の値からタイトルとポイントを決める
        for purchasedItem in purchasedItems {
            purchasedItem.title = purchasedItem.details.reduce("", combine: {$0 + ($0 == "" ? "" : ", ") + $1.productName})
            purchasedItem.beanPoint = self.numberOfBeansPoint(purchasedItem.totolPrice)
        }
        
        return purchasedItems
    }
    
    func numberOfBeansPoint(price: Int) -> Int {
        return price / 250
    }
}

class PurchasedBeanItem {
    var title = ""
    var totolPrice = 0
    var beanPoint = 0
    var orderId : Int = 0
    var details : [OrderDetail] = []
}
