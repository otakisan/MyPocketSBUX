//
//  Pairings.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Pairings: DbContextBase {
    static var contextInstance : Pairings = Pairings()
    
    class func instance() -> Pairings{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Pairing"
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        
        for newData in jsonObject {
            var entity : Pairing = Pairings.instance().createEntity()
            entity.id = (newData["id"] as? NSNumber) ?? 0
            entity.beanId = (newData["bean_id"] as? NSNumber) ?? 0
            entity.foodId = (newData["food_id"] as? NSNumber) ?? 0
            entity.createdAt = (newData["created_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = (newData["updated_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            
            // 先に登録して、ManagedObjectContext配下に置かないとリレーション設定の際にエラーになる
            // （不正なコンテキスト、というエラー）
            Pairings.insertEntity(entity)
            if let bean : Bean = Beans.instance().findById(Int(entity.beanId)) {
                entity.bean = bean
            }
            if let food : Food = Foods.instance().findById(Int(entity.foodId)) {
                entity.food = food
            }
            
            Pairings.getManagedObjectContext().save(nil)
        }
    }
}
