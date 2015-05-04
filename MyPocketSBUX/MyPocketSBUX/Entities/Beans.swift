//
//  Beans.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Beans: DbContextBase {
    static var contextInstance : Beans = Beans()
    
    class func instance() -> Beans {
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Bean"
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        
        for newData in jsonObject {
            var entity : Bean = Beans.instance().createEntity()
            entity.id = (newData["id"] as? NSNumber) ?? 0
            entity.name = ((newData["name"] as? NSString) ?? "") as String
            entity.category = ((newData["category"] as? NSString) ?? "") as String
            entity.janCode = ((newData["jan_code"] as? NSString) ?? "") as String
            entity.price = (newData["price"] as? NSNumber) ?? 0
            entity.special = ((newData["special"] as? NSString) ?? "") as String
            entity.notes = ((newData["notes"] as? NSString) ?? "") as String
            entity.notification = ((newData["notification"] as? NSString) ?? "") as String
            entity.growingRegion = ((newData["growing_region"] as? NSString) ?? "") as String
            entity.processingMethod = ((newData["processing_method"] as? NSString) ?? "") as String
            entity.flavor = ((newData["flavor"] as? NSString) ?? "") as String
            entity.body = ((newData["body"] as? NSString) ?? "") as String
            entity.acidity = ((newData["acidity"] as? NSString) ?? "") as String
            entity.complementaryFlavors = ((newData["complementary_flavors"] as? NSString) ?? "") as String
            entity.createdAt = (newData["created_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = (newData["updated_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            
            Beans.insertEntity(entity)
        }
    }
    
    class func findByJanCode(janCode : String, orderKeys : [(columnName : String, ascending : Bool)]) -> [Bean] {
        var sortKeys : [AnyObject] = []
        for orderkey in orderKeys {
            sortKeys.append(NSSortDescriptor(key: orderkey.columnName, ascending: orderkey.ascending))
        }
        
        return findByFetchRequestTemplate(
            "findBeanByJanCodeFetchRequest",
            variables: ["janCode":janCode],
            sortDescriptors: sortKeys,
            limit: 0) as! [Bean]
    }
}
