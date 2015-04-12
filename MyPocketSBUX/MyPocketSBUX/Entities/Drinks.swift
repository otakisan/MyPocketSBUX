//
//  Drinks.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Drinks: DbContextBase {
    static var contextInstance : Drinks = Drinks()
    
    class func instance() -> Drinks {
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Drink"
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        
        for jsonEntity in jsonObject {
            var entity : Drink = Drinks.instance().createEntity()
            entity.id = (jsonEntity["id"] as? NSNumber) ?? 0
            entity.name = ((jsonEntity["name"] as? NSString) ?? "") as String
            entity.category = ((jsonEntity["category"] as? NSString) ?? "") as String
            entity.janCode = ((jsonEntity["jan_code"] as? NSString) ?? "") as String
            entity.price = (jsonEntity["price"] as? NSNumber) ?? 0
            entity.special = ((jsonEntity["special"] as? NSString) ?? "") as String
            entity.notes = ((jsonEntity["notes"] as? NSString) ?? "") as String
            entity.notification = ((jsonEntity["notification"] as? NSString) ?? "") as String
            entity.createdAt = (jsonEntity["created_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = (jsonEntity["updated_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.size = ((jsonEntity["size"] as? NSString) ?? "") as String
            entity.milk = ((jsonEntity["milk"] as? NSString) ?? "") as String
            
            Foods.insertEntity(entity)
        }
    }
}
