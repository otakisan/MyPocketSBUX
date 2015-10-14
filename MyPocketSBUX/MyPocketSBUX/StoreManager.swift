//
//  StoreManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class StoreManager: NSObject {
    static var instance: StoreManager = BaseFactory.instance.createStoreManager()
    
    func updateStoreLocalDb(completion: (() -> Void)?){
        
        // 最新版を取得
        let nextSn = self.maxStoreSeqId() + 1
        
        // TODO: 通信処理で共通化できる部分は専用のクラスにまとめる
        if let url  = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):3000/stores.json/?type=range&key=id&sortdirection=ASC&from=\(nextSn)") {
            
            // TODO: defaultSessionConfigurationはデフォルト設定でインスタンスを生成するので、毎回設定する必要あり
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.timeoutIntervalForResource = 10
            config.timeoutIntervalForRequest = 10
            let session = NSURLSession(configuration: config)
            let task    = session.dataTaskWithURL(url, completionHandler: {
                (data, resp, err) in
                
                if let data = data, let newsData = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
                    
                    self.insertNewStoreToLocal(newsData)
                }
                
                completion?()
            })
            
            task.resume()
        }
    }
    
    private func maxStoreSeqId() -> Int {
        return Stores.instance().maxId()
    }

    private func insertNewStoreToLocal(newStoreData : NSArray) {
        
        for newStore in newStoreData {
            let entity : Store = Stores.instance().createEntity()
            entity.id = (newStore["id"] as? NSNumber) ?? 0
            entity.storeId = (newStore["store_id"] as? NSNumber) ?? 0
            entity.name = ((newStore["name"] as? NSString) ?? "") as String
            entity.address = ((newStore["address"] as? NSString) ?? "") as String
            entity.phoneNumber = ((newStore["phone_number"] as? NSString) ?? "") as String
            entity.holiday = ((newStore["holiday"] as? NSString) ?? "") as String
            entity.access = ((newStore["access"] as? NSString) ?? "") as String
            entity.openingTimeWeekday = DateUtility.dateFromSqliteDateTimeString(newStore["opening_time_weekday"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.closingTimeWeekday = DateUtility.dateFromSqliteDateTimeString(newStore["closing_time_weekday"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.openingTimeSaturday = DateUtility.dateFromSqliteDateTimeString(newStore["opening_time_saturday"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.closingTimeSaturday = DateUtility.dateFromSqliteDateTimeString(newStore["closing_time_saturday"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.openingTimeHoliday = DateUtility.dateFromSqliteDateTimeString(newStore["opening_time_holiday"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.closingTimeHoliday = DateUtility.dateFromSqliteDateTimeString(newStore["closing_time_holiday"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.latitude = (newStore["latitude"] as? NSNumber) ?? 0
            entity.longitude = (newStore["longitude"] as? NSNumber) ?? 0
            entity.notes = ((newStore["notes"] as? NSString) ?? "") as String
            entity.prefId = (newStore["pref_id"] as? NSNumber) ?? 0
            entity.createdAt = DateUtility.dateFromSqliteDateTimeString(newStore["created_at"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = DateUtility.dateFromSqliteDateTimeString(newStore["updated_at"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            
            Stores.insertEntity(entity)
        }
    }

}
