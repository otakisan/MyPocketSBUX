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
        else {
            fatalError("invalid entityName : \(entityName)")
        }
        
        return dbContext!
        
//        return (NSClassFromString("\(entityName)s")() as NSObject.Type)() as! DbContextBase
    }

    func fetchEntitiesFromLocalDb(entityName : String) -> [NSManagedObject] {
        
        // TODO: ソート順の指定 下記は暫定
        var entities : [NSManagedObject] = self.getProductsAllOrderBy(entityName, orderKeys: [(columnName : "category", ascending : true), (columnName : "name", ascending : true)])
        
        return entities
    }
    
    func getProductsAllOrderBy(productCategory : String, orderKeys : [(columnName : String, ascending : Bool)]) -> [NSManagedObject] {
        return self.getDbContext(productCategory).getAllOrderBy(orderKeys)
    }
    
    func fetchContents(entityNames : [String], completionHandler: ([(entityName: String, entities: [NSManagedObject])] -> Void)?) {
        
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
                    fetchResults += [(entityName: entityName, entities: self.fetchEntitiesFromLocalDb(entityName))]
                    
                    // 解放
                    dispatch_semaphore_signal(semaphore)
                })
            }
            else{
                fetchResults += [(entityName: entityName, entities: self.fetchEntitiesFromLocalDb(entityName))]
                
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

}
