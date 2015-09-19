//
//  Nutritions.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/03.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Nutritions: DbContextBase {
    static var contextInstance : Nutritions = Nutritions()
    
    class func instance() -> Nutritions {
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Nutrition"
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        
        for newFood in jsonObject {
            let entity : Nutrition = Nutritions.instance().createEntity()
            entity.id = (newFood["id"] as? NSNumber) ?? 0
            entity.janCode = ((newFood["jan_code"] as? NSString) ?? "") as String
            entity.size = ((newFood["size"] as? NSString) ?? "") as String
            entity.liquidTemperature = ((newFood["liquid_temperature"] as? NSString) ?? "") as String
            entity.milk = ((newFood["milk"] as? NSString) ?? "") as String
            entity.calorie = (newFood["calorie"] as? NSNumber) ?? 0
            entity.createdAt = (newFood["created_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = (newFood["updated_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            
            Nutritions.insertEntity(entity)
        }
    }
    
    class func findByJanCode(janCode : String, orderKeys : [(columnName : String, ascending : Bool)]) -> [Nutrition] {
        var sortKeys : [NSSortDescriptor] = []
        for orderkey in orderKeys {
            sortKeys.append(NSSortDescriptor(key: orderkey.columnName, ascending: orderkey.ascending))
        }
        
        return findByFetchRequestTemplate(
            "findNutritionByJanCodeFetchRequest",
            variables: ["janCode":janCode],
            sortDescriptors: sortKeys,
            limit: 0) as! [Nutrition]
    }

    class func findByJanCodeSizeMilkLiquidTemperature(janCode : String, size: String, milk: String, liquidTemperature : String) -> Nutrition? {
        
        return (findByFetchRequestTemplate(
            "findNutritionByJanCodeSizeMilkLiquidTemperatureFetchRequest",
            variables: ["janCode":janCode, "size":size, "milk":milk, "liquidTemperature":liquidTemperature],
            sortDescriptors: [],
            limit: 0) as! [Nutrition]).first
    }
   
}
