//
//  Foods.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/12.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Foods: DbContextBase {
    static var contextInstance : Foods = Foods()
    
    class func instance() -> Foods {
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Food"
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        
        for newFood in jsonObject {
            var entity : Food = Foods.instance().createEntity()
            entity.id = (newFood["id"] as? NSNumber) ?? 0
            entity.name = ((newFood["name"] as? NSString) ?? "") as String
            entity.category = ((newFood["category"] as? NSString) ?? "") as String
            entity.janCode = ((newFood["jan_code"] as? NSString) ?? "") as String
            entity.price = (newFood["price"] as? NSNumber) ?? 0
            entity.special = ((newFood["special"] as? NSString) ?? "") as String
            entity.notes = ((newFood["notes"] as? NSString) ?? "") as String
            entity.notification = ((newFood["notification"] as? NSString) ?? "") as String
            entity.createdAt = (newFood["created_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = (newFood["updated_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            
            Foods.insertEntity(entity)
        }
    }

}
