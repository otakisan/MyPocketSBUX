//
//  Recommender.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Recommender: NSObject {
    static let drinkRecommender = DrinkRecommender()
    
    func topItems() -> [RecommendedItem] {
        return []
    }
}

class DrinkRecommender : Recommender {
    override func topItems() -> [RecommendedItem] {
        
        let logic = self.recommendLogic()
        
        return logic()
    }
    
    func recommendLogic() -> (() -> [RecommendedItem]) {
        // TODO: プリファレンスからロジックの選択もする
        // TODO: ロジックがプリファレンスを受け取り、算出する
        return self.lastOrdered
    }
    
    func lastOrdered() -> [RecommendedItem] {
        
        var recommendedItems : [DrinkRecommendedItem] = []
        if let orderDetail = OrderDetails.instance().getAllOrderBy([("createdAt", false)]).first as? OrderDetail {
            var lastOrder = DrinkRecommendedItem()
            lastOrder.janCode = orderDetail.productJanCode
            recommendedItems += [lastOrder]
        }
        
        return recommendedItems
    }
}

class RecommendedItem {
    var janCode: String = ""
}

class DrinkRecommendedItem : RecommendedItem {
    var customItems : [Ingredient] = []
}
