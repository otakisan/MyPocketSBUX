//
//  ContentsManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class ContentsManager: NSObject {
    
    static let instance = BaseFactory.instance.createContentsManager()
    let timeoutInSeconds = 30.0
    
    func fetchContentsFromWebAndStoreLocalDb(entityName : String, isRefresh: Bool, completionHandler: (() -> Void)){
        self.fetchContentsFromWeb(entityName, completionHandler: { data, res, error in
            
            if error == nil, let productsJson = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
                let dbContext = self.getDbContext(entityName)
                if isRefresh {
                    dbContext.clearAllEntitiesExceptForUnsyncData()
                }
                dbContext.insertEntityFromJsonObject(productsJson)
            }
            
            completionHandler()
        })
    }
    
    private func fetchContentsFromWeb(entityName : String, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)){
        
        // 全件を取得
        if let url  = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):\(ResourceContext.instance.servicePort())/\(entityName)s.json") {
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task    = session.dataTaskWithURL(url, completionHandler: completionHandler)
            
            task.resume()
        }
    }
    
    func getDbContext(entityName : String) -> DbContextBase {
        // TODO: ウェブリソース名(Rails)とCoreDataでのエンティティ名を区別する必要あり
        // エンティティ名はクラス名、ウェブリソースはその名称にしたほうがいいかもしれない
        var dbContext : DbContextBase?
        if entityName == MenuSectionItem.ProductCategory.drink {
            dbContext = Drinks.instance()
        }
        else if entityName == MenuSectionItem.ProductCategory.food {
            dbContext = Foods.instance()
        }
        else if entityName == "nutrition" {
            dbContext = Nutritions.instance()
        }
        else if entityName == "bean" {
            dbContext = Beans.instance()
        }
        else if entityName == "pairing" {
            dbContext = Pairings.instance()
        }
        else if entityName == "tasting_log" {
            dbContext = TastingLogs.instance()
        }
        else if entityName == "tune" {
            dbContext = Tunes.instance()
        }
        else if entityName == "seminar" {
            dbContext = Seminars.instance()
        }
        else if entityName == "store" {
            dbContext = Stores.instance()
        }
        else if entityName == "order" {
            dbContext = Orders.instance()
        }
        else {
            fatalError("invalid entityName : \(entityName)")
        }
        
        return dbContext!
        
//        return (NSClassFromString("\(entityName)s")() as NSObject.Type)() as! DbContextBase
    }

    func fetchEntitiesFromLocalDb(entityName : String, orderKeys : [(columnName : String, ascending : Bool)]) -> [NSManagedObject] {
        
        let entities : [NSManagedObject] = self.getProductsAllOrderBy(entityName, orderKeys: orderKeys)
        
        return entities
    }
    
    func getProductsAllOrderBy(productCategory : String, orderKeys : [(columnName : String, ascending : Bool)]) -> [NSManagedObject] {
        return self.getDbContext(productCategory).getAllOrderBy(orderKeys)
    }
    
    // TODO: 現状だと、全て同じソート条件で全て同じエンティティを検索する
    // [(entityName: String, orderKeys: [(columnName : String, ascending : Bool)])]のセットで受け取るようにする
    func fetchContents(entityNames : [String], orderKeys : [(columnName : String, ascending : Bool)], completionHandler: ([(entityName: String, entities: [NSManagedObject])] -> Void)?) {
        
        var fetchResults : [(entityName: String, entities: [NSManagedObject])] = []
        
        // ローカルDBにデータが存在するかどうかチェックしなければ、Webより取得
        // 存在すれば、DBから取得
        // dispatch_group_t = dispatch_group_create() -> 通信部分で非同期になってしまうため不採用
        // 同期的にセマフォを取得し、取得処理完了後にハンドラを起動する
        let semaphoreCount = entityNames.count
        let semaphore = dispatch_semaphore_create(semaphoreCount)
        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(self.timeoutInSeconds * Double(NSEC_PER_SEC)))
        
        for entityName in entityNames {
            dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            let dbContext = self.getDbContext(entityName)
            let count = dbContext.countByFetchRequestTemplate([String:AnyObject]())
            if count == 0 {
                self.fetchContentsFromWebAndStoreLocalDb(entityName, isRefresh: false, completionHandler: {
                    
                    // TODO: セクションごとのカテゴライズは別で行う
                    // ローカルDBのキャッシュデータを取得
                    fetchResults += [(entityName: entityName, entities: self.fetchEntitiesFromLocalDb(entityName, orderKeys: orderKeys))]
                    
                    // 解放
                    dispatch_semaphore_signal(semaphore)
                })
            }
            else{
                fetchResults += [(entityName: entityName, entities: self.fetchEntitiesFromLocalDb(entityName, orderKeys: orderKeys))]
                
                // 解放
                dispatch_semaphore_signal(semaphore)
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // 待機
            for _ in 0..<semaphoreCount {
                dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            }
            // 解放しないとアベンドする
            for _ in 0..<semaphoreCount {
                dispatch_semaphore_signal(semaphore)
            }
            
            completionHandler?(fetchResults)
        })
    }

    func refreshContents(entityNames : [String], orderKeys : [(columnName : String, ascending : Bool)], completionHandler: ([(entityName: String, entities: [NSManagedObject])] -> Void)?) {
        
        var fetchResults : [(entityName: String, entities: [NSManagedObject])] = []
        
        // TODO: 外枠の同期の仕組みは共通化できそうだけど…。
        // 同期的にセマフォを取得し、取得処理完了後にハンドラを起動する
        let semaphoreCount = entityNames.count
        let semaphore = dispatch_semaphore_create(semaphoreCount)
        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(self.timeoutInSeconds * Double(NSEC_PER_SEC)))
        
        // ウェブに最新版を取得しに行き、通信に成功した場合には該当テーブルをクリアして、挿入、データをフェッチして返す
        // 失敗した場合には、テーブルには触れず、既存のデータをフェッチして返す。いずれもステータス（成功・失敗）を返却する。
        for entityName in entityNames {
            dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            self.fetchContentsFromWebAndStoreLocalDb(entityName, isRefresh: true, completionHandler: {
                
                // ローカルDBのキャッシュデータを取得
                fetchResults += [(entityName: entityName, entities: self.fetchEntitiesFromLocalDb(entityName, orderKeys: orderKeys))]
                
                // 解放
                dispatch_semaphore_signal(semaphore)
            })
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // 待機
            for _ in 0..<semaphoreCount {
                dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            }
            // 解放しないとアベンドする
            for _ in 0..<semaphoreCount {
                dispatch_semaphore_signal(semaphore)
            }
            
            completionHandler?(fetchResults)
        })
    }

    //func postContentsToWeb(entityName : String, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?){
        func postContentsToWeb(){
        
        // まずPOSTで送信したい情報をセット。
            let str = "tasting_log[title]=test log from ios&tasting_log[tag]=test tag&tasting_log[tasting_at(1i)]=2015&tasting_log[tasting_at(2i)]=5&tasting_log[tasting_at(3i)]=19&tasting_log[tasting_at(4i)]=22&tasting_log[tasting_at(5i)]=23&tasting_log[detail]=test detail&tasting_log[store_id]=2153&tasting_log[order_id]="
        let strData = str.dataUsingEncoding(NSUTF8StringEncoding)

        let url = NSURL(string: "http://localhost:3000/tasting_logs")
        let request = NSMutableURLRequest(URL: url!)
        
        // この下二行を見つけるのに、少々てこずりました。
        request.HTTPMethod = "POST"
        request.HTTPBody = strData
        
        if let data = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
            if let dic = (try? NSJSONSerialization.JSONObjectWithData(data, options:[])) as? NSDictionary {
                print(dic.count, terminator: "")
            }
        }
    }
    
    func postJsonContentsToWeb(dataObject: NSManagedObject, entityName: String) -> Bool {
        
        var isSuccess = false
            
        // まずPOSTで送信したい情報をセット。
        if let jsonData = self.jsonData(dataObject) {
            self.printJsonData(jsonData)
            
            let id = dataObject.valueForKey("id") as? NSNumber as? Int ?? 0
            let isNew = id == 0 ? true : false
            
            let url = NSURL(string: isNew ? "http://\(ResourceContext.instance.serviceHost()):\(ResourceContext.instance.servicePort())/\(entityName)s.json" : "http://\(ResourceContext.instance.serviceHost()):\(ResourceContext.instance.servicePort())/\(entityName)s/\(id).json")
            let request = NSMutableURLRequest(URL: url!)
            
            // この下二行を見つけるのに、少々てこずりました。
            // .jsonに要求を出すときは、content-typeの指定が必要。指定しないと適切に処理されない
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = isNew ? "POST" : "PATCH"
            request.HTTPBody = jsonData
            
            do {
                let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
                if let dic = try? NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    isSuccess = true
                    //print(dic.count)
                    
                    // ポストした情報がローカルキャッシュの場合には、サーバーの情報で更新する
                    // TODO: ここで状態を変えて保存してよいか
                    let propNames = dataObject.propertyNames()
                    for propName in propNames {
                        if var propValue: AnyObject = dic?.valueForKey(propName.snakeCase()) {
                            if propValue is String {
                                propValue = self.typeConvert(dataObject.propertyTypeName(propName), propValue: propValue as! String)
                            }
                            dataObject.setValue(propValue, forKey: propName)
                        }
                    }
                    
                    try DbContextBase.getManagedObjectContext().save()
                }
            } catch _ as NSError {
            }
        }
        
        return isSuccess
    }
    
    func deleteContentsToWeb(idOnWeb: Int, entityName: String) -> Bool {
        var isSuccess = false
        
        let url = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):\(ResourceContext.instance.servicePort())/\(entityName)s/\(idOnWeb).json")
        let request = NSMutableURLRequest(URL: url!)
        
        // .jsonに要求を出すときは、content-typeの指定が必要。指定しないと適切に処理されない
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "DELETE"
        
        do {
            _ = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
            isSuccess = true
        } catch _ as NSError {
        }
        
        return isSuccess
    }
    
    func typeConvert(propTypeName: String, propValue: String) -> AnyObject {
        var converted : AnyObject = propValue
        if propTypeName.contains("NSDate") {
            if let regex = try? NSRegularExpression(pattern: "^[0-9]{4}-[0-9]{2}-[0-9]{2}$", options: NSRegularExpressionOptions.CaseInsensitive)
                where regex.matchesInString(propValue, options: NSMatchingOptions(), range: NSMakeRange(0, propValue.characters.count)).count > 0 {
                converted = DateUtility.dateFromSqliteDateString(propValue) ?? DateUtility.minimumDate()
            }else{
                converted = DateUtility.dateFromSqliteDateTimeString(propValue) ?? DateUtility.minimumDate()
            }
        } else if propTypeName.contains("NSNumber") {
            converted = Int(propTypeName) ?? 0 as NSNumber
        }
        
        return converted
    }
    
    func jsonData(dataObject: NSObject) -> NSData? {
        
        let topObject = jsonObject(dataObject)
        
        return try? NSJSONSerialization.dataWithJSONObject(topObject as NSDictionary, options: [])
    }
    
    func jsonObject(dataObject: NSObject) -> [String:AnyObject] {
        
        var topObject : [String:AnyObject] = [:]
        let propNames = dataObject.propertyNames()
        for propName in propNames {
            // TODO: 一般的には、\Lで小文字に変換できる？
            let snakeCasePropName = propName.stringByReplacingOccurrencesOfString("([A-Z])", withString:"_$1", options:NSStringCompareOptions.RegularExpressionSearch, range: nil).lowercaseString
            if let valueData: AnyObject = dataObject.valueForKey(propName) {
                if ["id", "created_at", "updated_at"].filter({$0 == snakeCasePropName}).count == 0 {
                    // プロパティがオブジェクトの場合はリレーションとみなし、idを設定する
                    if valueData is NSManagedObject, let idValue = valueData.valueForKey("id") as? NSNumber {
                        topObject.updateValue(idValue, forKey: "\(snakeCasePropName)_id")
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
    
    func jsonObjects(dataObjects: [NSObject]) -> [String:AnyObject] {
        var objects: [String:AnyObject] = [:]
        
        for index in 0..<dataObjects.count {
            objects["\(index)"] = jsonObject(dataObjects[index])
        }
        
        return objects
    }
    
    func printJsonData(jsonData: NSData) {
        if let logString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
            print(logString, terminator: "")
        }
    }

    func nextId(entityName: String) -> Int {
        return 0
    }
}
