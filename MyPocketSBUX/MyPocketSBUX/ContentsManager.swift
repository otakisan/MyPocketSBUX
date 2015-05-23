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
    
    static let instance = ContentsManager()
    
    func fetchContentsFromWeb(entityName : String, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?){
        
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
        else {
            fatalError("invalid entityName : \(entityName)")
        }
        
        return dbContext!
        
//        return (NSClassFromString("\(entityName)s")() as NSObject.Type)() as! DbContextBase
    }

    func fetchEntitiesFromLocalDb(entityName : String, orderKeys : [(columnName : String, ascending : Bool)]) -> [NSManagedObject] {
        
        var entities : [NSManagedObject] = self.getProductsAllOrderBy(entityName, orderKeys: orderKeys)
        
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
        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
        
        for entityName in entityNames {
            dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            let dbContext = self.getDbContext(entityName)
            var count = dbContext.countByFetchRequestTemplate([NSObject:AnyObject]())
            if count == 0 {
                self.fetchContentsFromWeb(entityName, completionHandler: { data, res, error in
                    
                    if var productsJson = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray {
                        dbContext.insertEntityFromJsonObject(productsJson)
                    }
                    
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
            for index in 0..<semaphoreCount {
                dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            }
            // 解放しないとアベンドする
            for index in 0..<semaphoreCount {
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
        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
        
        // ウェブに最新版を取得しに行き、通信に成功した場合には該当テーブルをクリアして、挿入、データをフェッチして返す
        // 失敗した場合には、テーブルには触れず、既存のデータをフェッチして返す。いずれもステータス（成功・失敗）を返却する。
        for entityName in entityNames {
            dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            self.fetchContentsFromWeb(entityName, completionHandler: { data, res, error in
                
                if error == nil {
                    if var productsJson = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray {
                        let dbContext = self.getDbContext(entityName)
                        dbContext.clearAllEntities()
                        dbContext.insertEntityFromJsonObject(productsJson)
                    }
                }
                
                // ローカルDBのキャッシュデータを取得
                fetchResults += [(entityName: entityName, entities: self.fetchEntitiesFromLocalDb(entityName, orderKeys: orderKeys))]
                
                // 解放
                dispatch_semaphore_signal(semaphore)
            })
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // 待機
            for index in 0..<semaphoreCount {
                dispatch_semaphore_wait(semaphore, timeout/*DISPATCH_TIME_FOREVER*/)
            }
            // 解放しないとアベンドする
            for index in 0..<semaphoreCount {
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

        var url = NSURL(string: "http://localhost:3000/tasting_logs")
        var request = NSMutableURLRequest(URL: url!)
        
        // この下二行を見つけるのに、少々てこずりました。
        request.HTTPMethod = "POST"
        request.HTTPBody = strData
        
        if var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil) {
            if var dic = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: nil) as? NSDictionary {
                print(dic.count)
            }
        }
    }
    
    func postJsonContentsToWeb(dataObject: NSObject) -> Bool {
        
        var isSuccess = false
            
        // まずPOSTで送信したい情報をセット。
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
                    }else{
                        topObject.updateValue(dataObject.valueForKey(propName)!, forKey: snakeCasePropName)
                    }
                }
            }
        }
        
//        var topObject3 : [String:AnyObject] =
//            [
//                "title":"test json log from ios",
//                "tag":"test json tag",
//                "tasting_at":"2005/02/01 05:15:10 -1000",
//                "detail":"test json detail",
//                "store_id":2154,
//                "order_id":0
//            ]
    
        var strData = NSJSONSerialization.dataWithJSONObject(topObject as NSDictionary, options: nil, error: nil)
        var logString = NSString(data: strData!, encoding: NSUTF8StringEncoding)
        print(logString!)
        
        var url = NSURL(string: "http://localhost:3000/tasting_logs.json")
        var request = NSMutableURLRequest(URL: url!)
        
        // この下二行を見つけるのに、少々てこずりました。
        // .jsonに要求を出すときは、content-typeの指定が必要。指定しないと適切に処理されない
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.HTTPBody = strData
        
        var error: NSError?
        if var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: &error) {
            if var dic = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: &error) as? NSDictionary {
                isSuccess = true
                print(dic.count)
            }
        }
        
        return isSuccess
    }
}
