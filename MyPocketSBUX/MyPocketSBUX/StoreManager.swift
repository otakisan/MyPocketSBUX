//
//  StoreManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import MapKit

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
    
    func storesFromHereWithin(distance : Double, stores : [Store], completion : ([Store], [NSError]?) -> Void) -> Bool {
        
        var hasHereInfo = false
        if let hereCoordinate = LocationContext.current.coordinate {
            hasHereInfo = true
            
            self.storesWithin((hereCoordinate.latitude, hereCoordinate.longitude), distance: distance, stores: stores, completion: completion)
        }
        
        return hasHereInfo
    }
    
    // distanceはメートル
    func storesWithin(fromCoordinate : (latitude : Double, longitude : Double), distance : Double, stores : [Store], completion : ([Store], [NSError]?) -> Void) {
        
        // ワーカースレッドに移行し、そこで距離によるフィルタを行う
        // 全件完了するまで待機し、完了後、コールバックする
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            // １次フィルタ（直線距離）
            let storesFilteredStep1 = stores.filter({ (store) -> Bool in
                return LocationCalculator.instance.locationDistance(
                    CLLocationCoordinate2D(latitude: fromCoordinate.latitude, longitude: fromCoordinate.longitude),
                    loc2: CLLocationCoordinate2D(latitude: Double(store.latitude), longitude: Double(store.longitude))) < distance
            })
            
            // ２次フィルタ（経路探索）
            // 件数が多いと捌ききれないので一定数未満の場合のみ実施
            // TODO: ２次フィルタの対象とする上限値は、様子を見て設定画面より変更可能とする
            var storeFiltered : [Store] = []
            var errors : [NSError]?
            if storesFilteredStep1.count < 25 {
                let locationDistanceQueue = NSOperationQueue()
                let addStoreQueue = NSOperationQueue()
                addStoreQueue.maxConcurrentOperationCount = 1
                
                for storeFilteredStep1 in storesFilteredStep1 {
                    locationDistanceQueue.addOperationWithBlock({ () -> Void in
                        let result = LocationCalculator.instance.locationDistanceRouteSync(CLLocationCoordinate2D(latitude: fromCoordinate.latitude, longitude: fromCoordinate.longitude), toCoordinate: CLLocationCoordinate2D(latitude: Double(storeFilteredStep1.latitude), longitude: Double(storeFilteredStep1.longitude)))
                        
                        if let errorInfo = result.error {
                            addStoreQueue.addOperationWithBlock({ () -> Void in
                                errors = errors ?? [NSError]()
                                errors?.append(errorInfo)
                            })
                        }
                        else if result.error == nil && result.distance < distance {
                            addStoreQueue.addOperationWithBlock({ () -> Void in
                                storeFiltered.append(storeFilteredStep1)
                            })
                        }
                    })
                }
                
                locationDistanceQueue.waitUntilAllOperationsAreFinished()
                addStoreQueue.waitUntilAllOperationsAreFinished()
            }
            else{
                storeFiltered = storesFilteredStep1
            }
            
            completion(storeFiltered, errors)
        }
        
    }

}
