//
//  JSONUtility.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/06/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class JSONUtility: NSObject {
    
    class func jsonData(dataObject: NSObject) -> NSData? {
        
        let topObject = jsonObject(dataObject)
        
        return try? NSJSONSerialization.dataWithJSONObject(topObject as NSDictionary, options: [])
    }
    
    class func jsonObject(dataObject: NSObject) -> [String:AnyObject] {
        
        var topObject : [String:AnyObject] = [:]
        let propNames = dataObject.propertyNames()
        for propName in propNames {
            // TODO: 一般的には、\Lで小文字に変換できる？
            let snakeCasePropName = propName.stringByReplacingOccurrencesOfString("([A-Z])", withString:"_$1", options:NSStringCompareOptions.RegularExpressionSearch, range: nil).lowercaseString
            if let valueData: AnyObject = dataObject.valueForKey(propName) {
                if ["id", "created_at", "updated_at"].filter({$0 == snakeCasePropName}).count == 0 {
                    // プロパティがオブジェクトの場合はリレーションとみなし、idを設定する
                    if valueData is NSManagedObject {
                        topObject.updateValue(valueData.valueForKey("id") as! NSNumber, forKey: "\(snakeCasePropName)_id")
                    }else if valueData is NSDate {
                        // TODO: ひとまず、日本での時差で固定 サマータイムだと+0800になる？？
                        topObject.updateValue(DateUtility.railsLocalDateString(valueData as! NSDate) + "+0900", forKey: snakeCasePropName)
                    }else if valueData is NSSet {
                        topObject.updateValue(jsonObjects((valueData as! NSSet).allObjects as! [NSObject]), forKey: "\(snakeCasePropName)_attributes")
                    }else{
                        topObject.updateValue(dataObject.valueForKey(propName)!, forKey: snakeCasePropName)
                    }
                }
            }
        }
        
        return topObject
    }
    
    //    func jsonObjects(dataObjects: [NSObject]) -> NSArray {
    //        var objects: [[String:AnyObject]] = []
    //        for dataObject in dataObjects {
    //            objects += [jsonObject(dataObject)]
    //        }
    //
    //        return objects
    //    }
    
    class func jsonObjects(dataObjects: [NSObject]) -> [String:AnyObject] {
        var objects: [String:AnyObject] = [:]
        
        for index in 0..<dataObjects.count {
            objects["\(index)"] = jsonObject(dataObjects[index])
        }
        
        return objects
    }
    
    class func printJsonData(jsonData: NSData) {
        if let logString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
            print(logString)
        }
    }
    
    class func objectFromJsonObject<TObject: NSObject>(jsonObject: NSDictionary) -> TObject {
        let newObject: TObject = TObject()
        let propNames = newObject.propertyNames()
        for propName in propNames {
            newObject.setValue(jsonObject.valueForKey(propName.snakeCase()), forKey: propName)
        }
        
        return newObject
    }
}
