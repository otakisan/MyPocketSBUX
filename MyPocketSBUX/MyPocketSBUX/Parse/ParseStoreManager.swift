//
//  ParseStoreManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse

class ParseStoreManager: StoreManager {

    override func updateStoreLocalDb(completion: (() -> Void)?) {
        
        // 最新の登録日時以降のものを取得する
        let maxCreatedAt = Stores.instance().maxCreatedAt()
        
        let query = PFQuery(className: Stores.instance().entityName())
        query.whereKey("createdAt", greaterThanOrEqualTo: maxCreatedAt)
        query.orderByAscending("createdAt")
        query.skip = 0
        query.limit = 1000
        self.fetchAndStoreRecursively(query, completion: completion)
    }
    
    private func fetchAndStoreRecursively(query: PFQuery, completion: (() -> Void)?) {
        query.findObjectsInBackgroundWithBlock { (newStores, error) -> Void in
            if let newStores = newStores {
                newStores.forEach{pfObject in
                    let store : Store = Stores.instance().createEntity()
                    let propNames = store.propertyNames()
                    for propName in propNames {
                        if [/*"id",*/ "createdAt", "updatedAt"].contains({el in el == propName}) {
                            continue
                        }
                        
                        if var propValue: AnyObject = pfObject.valueForKey(propName) {
                            if propValue is String {
                                propValue = ContentsManager.instance.typeConvert(store.propertyTypeName(propName), propValue: propValue as! String)
                            }
                            store.setValue(propValue, forKey: propName)
                        }
                    }
                    
                    store.createdAt = pfObject.createdAt ?? DateUtility.minimumDate()
                    store.updatedAt = pfObject.updatedAt ?? DateUtility.minimumDate()
                    
                    Stores.insertEntity(store)
                }
                
                if newStores.count < query.limit {
                    completion?()
                } else {
                    query.skip += query.limit
                    self.fetchAndStoreRecursively(query, completion: completion)
                }
            }
        }
    }
}
