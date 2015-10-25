//
//  ParseContentsManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/26.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import CoreData

class ParseContentsManager: ContentsManager {
    
    override func nextId(entityName: String) -> Int {
        return self.maxId(entityName) + 1
    }

    private func maxId(entityName: String) -> Int {
        let query = PFQuery(className: entityName)
        query.limit = 1
        query.orderByDescending("id")
        let results = try? query.findObjects()
        return results?.count == 0 ? 0 : Int(results?.first?["id"] as? NSNumber ?? 0)
    }

    override func fetchContentsFromWebAndStoreLocalDb(entityName: String, isRefresh: Bool, completionHandler: (() -> Void)) {
        
        // 外部結合等、関連のない単体エンティティでないものは、それぞれ振り分ける
        // TODO: 結合が必要な場合でも汎用化できると思うが、ひとまずの動作を目指すため置いておく
        let dbContext = self.getDbContext(entityName)
        if isRefresh {
            dbContext.clearAllEntitiesExceptForUnsyncData()
        }

        if entityName == "order" {
            self.fetchContentsFromWebAndStoreLocalDbForOrderAsync(entityName, completionHandler: completionHandler)
        } else {
            let query = PFQuery(className: dbContext.entityName())
            query.orderByAscending("createdAt")
            query.skip = 0
            query.limit = 1000
            // TODO: 本来はmyPocketIdカラムを保持しているものを動的に判定したいところ
            // REST APIにはSchema APIというのがあって、どんなカラムがあるのかわかる
            // ここでは一旦決め打ち
            if entityName == TastingLogManager.instance.entityResourceName() {
                query.whereKey("myPocketId", equalTo: IdentityContext.sharedInstance.currentUserID)
            }
            self.fetchAndStoreRecursively(query, entityName: entityName, completionHandler: completionHandler)
            
        }
    }
    
    override func postJsonContentsToWeb(dataObject: NSManagedObject, entityName: String) -> Bool {
        let propertyNames = dataObject.propertyNames()
        var pfObjectData : [NSObject:AnyObject] = [:]
        for propName in propertyNames {
            
            if ["createdAt", "updatedAt"].contains({el in el == propName}) {
                continue
            }
            
            if let propValue: AnyObject = dataObject.valueForKey(propName) {
                if propValue is NSManagedObject {
                    // PFObjectを取得
                    let query = PFQuery(className: propName.pascalCaseFromSnakeCase())
                    query.limit = 1
                    let key = propValue is Store ? "storeId" : "id"
                    let criteria = propValue.valueForKey(key) as? NSNumber ?? 0
                    query.whereKey(key, equalTo: criteria)
                    if let results = try? query.findObjects(), let associated = results.first {
                        pfObjectData["\(propName)ObjectId"] = associated
                        pfObjectData["\(propName)Id"] = associated["id"] as? NSNumber ?? 0
                    }
                }
                else if propValue is NSDate {
                    pfObjectData[propName] = DateUtility.utcDateStringFromDate(propValue as! NSDate)
                }else{
                    pfObjectData[propName] = propValue
                }
            }
        }
        
        let className = entityName.pascalCaseFromSnakeCase()
        do{
            if let id = dataObject.valueForKey("id") as? NSNumber where id != 0 {
                let query = PFQuery(className: className)
                query.limit = 1
                query.whereKey("id", equalTo: id)
                if let results = try? query.findObjects(), let resultObj = results.first {
                    for (key, value) in pfObjectData {
                        resultObj[key as! String] = value
                    }
                    try resultObj.save()
                }else{
                    try PFObject(className: className, dictionary: pfObjectData).save()
                }
            }else{
                try PFObject(className: className, dictionary: pfObjectData).save()
            }
        } catch let error1 as NSError {
            print(error1)
        }

        return true
    }
    
    // 丸ごとワーカースレッドでいくバージョン
    // 時間がすごくかかる感じがするが、画面はブロックしない。が、UIの操作によってはデータが二重で表示されたりするし、アベンドの可能性もある
    // 親エンティティ十数件で数十秒かかる感じ。リリース版ならもっと早いかもしれないけど、デバッグ版でもこなせるレベルでないとつらい範囲
    private func fetchContentsFromWebAndStoreLocalDbForOrderAsync(entityName: String, completionHandler: (() -> Void)){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let orderQuery = PFQuery(className: "Order")
            orderQuery.whereKey("myPocketId", equalTo: PFUser.currentUser()?.username ?? "")
            
            if let orders = try? orderQuery.findObjects() {
                orders.forEach({ (order) -> () in
                    let orderEntity : Order = Orders.instance().createEntity()
                    orderEntity.id = order["id"] as? NSNumber ?? 0
                    orderEntity.remarks = order["remarks"] as? String ?? ""
                    orderEntity.storeId = order["storeId"] as? NSNumber ?? 0
                    orderEntity.taxExcludedTotalPrice = order["taxExcludedTotalPrice"] as? NSNumber ?? 0
                    orderEntity.taxIncludedTotalPrice = order["taxIncludedTotalPrice"] as? NSNumber ?? 0
                    orderEntity.myPocketId = order["myPocketId"] as? String ?? ""
                    orderEntity.notes = order["notes"] as? String ?? ""
                    orderEntity.createdAt = order.createdAt ?? DateUtility.minimumDate()
                    orderEntity.updatedAt = order.updatedAt ?? DateUtility.minimumDate()
                    
                    // オフライン対応するため、webから保存する際にsaveEventuallyを使用している。
                    // webから保存する際にsaveEventuallyを使用すると、関連付けのうち、PointerはOKで、RelationはNG(*)になる
                    // そのため、ここではPointerを指定してデータを取得する
                    // (*)翌日にアクセスしたら、リレーションもできているような感じに見える。どこかでリトライしている？
                    let orderDetailQuery = PFQuery(className: "OrderDetail")
                    orderDetailQuery.whereKey("orderObjectId", equalTo: order)
                    if let orderDetails = try? orderDetailQuery.findObjects() {
                        
                        DbContextBase.registerEntity(orderEntity)
                        orderDetails.forEach({ (orderDetail) -> Void in
                            let orderDetailEntity : OrderDetail = OrderDetails.instance().createEntity()
                            orderDetailEntity.id = orderDetail["id"] as? NSNumber ?? 0
                            orderDetailEntity.orderId = orderEntity.id
                            orderDetailEntity.productName = orderDetail["productName"] as? String ?? ""
                            orderDetailEntity.productJanCode = orderDetail["productJanCode"] as? String ?? ""
                            orderDetailEntity.size = orderDetail["size"] as? String ?? ""
                            orderDetailEntity.hotOrIced = orderDetail["hotOrIced"] as? String ?? ""
                            orderDetailEntity.reusableCup = orderDetail["reusableCup"] as? NSNumber ?? 0
                            orderDetailEntity.ticket = orderDetail["ticket"] as? String ?? ""
                            orderDetailEntity.taxExcludeTotalPrice = orderDetail["taxExcludeTotalPrice"] as? NSNumber ?? 0
                            orderDetailEntity.taxExcludeCustomPrice = orderDetail["taxExcludeCustomPrice"] as? NSNumber ?? 0
                            orderDetailEntity.totalCalorie = orderDetail["totalCalorie"] as? NSNumber ?? 0
                            orderDetailEntity.customCalorie = orderDetail["customCalorie"] as? NSNumber ?? 0
                            orderDetailEntity.remarks = orderDetail["remarks"] as? String ?? ""
                            orderDetailEntity.createdAt = orderDetail.createdAt ?? DateUtility.minimumDate()
                            orderDetailEntity.updatedAt = orderDetail.updatedAt ?? DateUtility.minimumDate()
                            
                                DbContextBase.registerEntity(orderDetailEntity)
                            orderDetailEntity.order = orderEntity
                            
                            let piQuery = PFQuery(className: "ProductIngredient")
                            piQuery.whereKey("orderDetailObjectId", equalTo: orderDetail)
                            if let productIngredients = try? piQuery.findObjects() {
                                
                                productIngredients.forEach({ (productIngredient) -> Void in
                                    let productIngredientEntity : ProductIngredient = ProductIngredients.instance().createEntity()
                                    productIngredientEntity.id = productIngredient["id"] as? NSNumber ?? 0
                                    productIngredientEntity.orderDetailId = productIngredient["orderDetailId"] as? NSNumber ?? 0
                                    productIngredientEntity.isCustom = productIngredient["isCustom"] as? NSNumber ?? 0
                                    productIngredientEntity.name = productIngredient["name"] as? String ?? ""
                                    productIngredientEntity.milkType = productIngredient["milkType"] as? String ?? ""
                                    productIngredientEntity.unitCalorie = productIngredient["unitCalorie"] as? NSNumber ?? 0
                                    productIngredientEntity.unitPrice = productIngredient["unitPrice"] as? NSNumber ?? 0
                                    productIngredientEntity.quantity = productIngredient["quantity"] as? NSNumber ?? 0
                                    productIngredientEntity.enabled = productIngredient["enabled"] as? NSNumber ?? 0
                                    productIngredientEntity.quantityType = productIngredient["quantityType"] as? NSNumber ?? 0
                                    productIngredientEntity.remarks = productIngredient["remarks"] as? String ?? ""
                                    productIngredientEntity.createdAt = productIngredient.createdAt ?? DateUtility.minimumDate()
                                    productIngredientEntity.updatedAt = productIngredient.updatedAt ?? DateUtility.minimumDate()
                                    
                                    DbContextBase.registerEntity(productIngredientEntity)
                                    productIngredientEntity.orderDetail = orderDetailEntity
                                    
                                    DbContextBase.insertEntity(productIngredientEntity)
                                })
                            }
                            
                            DbContextBase.insertEntity(orderDetailEntity)
                        })
                    }
                    
                    DbContextBase.insertEntity(orderEntity)
                })
            }
            
            completionHandler()

        })
    }

    // findObjectsInBackgroundWithBlockのコールバックがメインスレッド上で実行されるため、UIがブロックされる
    // ただ、いっその事ブロックしちゃったほうがいいのかも。タイムアウトを明示した上なら。
    private func fetchContentsFromWebAndStoreLocalDbForOrder(entityName: String, completionHandler: (() -> Void)){
        // TODO: 取得の途中に接続状況が変化した場合の対応については、ひとまず置いておく
        // 関連があるときの取得では、親の単位で孫のほうまで一括で取得する形にし、オールorナッシングのほうが処理がシンプルになる。
        // 孫のほうまで個別取得になると、かなり大変
        let orderQuery = PFQuery(className: "Order")
        orderQuery.whereKey("myPocketId", equalTo: PFUser.currentUser()?.username ?? "")
        
        // 頭から完全にワーカースレッドに入ったほうがいいのかも。
        orderQuery.findObjectsInBackgroundWithBlock { (pfObjects, error) -> Void in
            
            if let orders = pfObjects {
                //let dbContext = self.getDbContext(entityName)
                
                orders.forEach({ (order) -> () in
                    let orderEntity : Order = Orders.instance().createEntity()
                    orderEntity.id = order["id"] as? NSNumber ?? 0
                    orderEntity.remarks = order["remarks"] as? String ?? ""
                    orderEntity.storeId = order["storeId"] as? NSNumber ?? 0
                    orderEntity.taxExcludedTotalPrice = order["taxExcludedTotalPrice"] as? NSNumber ?? 0
                    orderEntity.taxIncludedTotalPrice = order["taxIncludedTotalPrice"] as? NSNumber ?? 0
                    orderEntity.myPocketId = order["myPocketId"] as? String ?? ""
                    orderEntity.notes = order["notes"] as? String ?? ""
                    orderEntity.createdAt = order.createdAt ?? DateUtility.minimumDate()
                    orderEntity.updatedAt = order.updatedAt ?? DateUtility.minimumDate()
                    
                    // オフライン対応するため、webから保存する際にsaveEventuallyを使用している。
                    // webから保存する際にsaveEventuallyを使用すると、関連付けのうち、PointerはOKで、RelationはNG(*)になる
                    // そのため、ここではPointerを指定してデータを取得する
                    // (*)翌日にアクセスしたら、リレーションもできているような感じに見える。どこかでリトライしている？
                    let orderDetailQuery = PFQuery(className: "OrderDetail")
                    orderDetailQuery.whereKey("orderObjectId", equalTo: order)
                    if let orderDetails = try? orderDetailQuery.findObjects() {
                    //let orderDetailsRelation = order.relationForKey("orderDetails")
                    //if let orderDetailQuery = orderDetailsRelation.query(), let orderDetails = try? orderDetailQuery.findObjects() {
                        
                        DbContextBase.registerEntity(orderEntity)
                        orderDetails.forEach({ (orderDetail) -> Void in
                            let orderDetailEntity : OrderDetail = OrderDetails.instance().createEntity()
                            orderDetailEntity.id = orderDetail["id"] as? NSNumber ?? 0
                            orderDetailEntity.orderId = orderEntity.id
                            orderDetailEntity.productName = orderDetail["productName"] as? String ?? ""
                            orderDetailEntity.productJanCode = orderDetail["productJanCode"] as? String ?? ""
                            orderDetailEntity.size = orderDetail["size"] as? String ?? ""
                            orderDetailEntity.hotOrIced = orderDetail["hotOrIced"] as? String ?? ""
                            orderDetailEntity.reusableCup = orderDetail["reusableCup"] as? NSNumber ?? 0
                            orderDetailEntity.ticket = orderDetail["ticket"] as? String ?? ""
                            orderDetailEntity.taxExcludeTotalPrice = orderDetail["taxExcludeTotalPrice"] as? NSNumber ?? 0
                            orderDetailEntity.taxExcludeCustomPrice = orderDetail["taxExcludeCustomPrice"] as? NSNumber ?? 0
                            orderDetailEntity.totalCalorie = orderDetail["totalCalorie"] as? NSNumber ?? 0
                            orderDetailEntity.customCalorie = orderDetail["customCalorie"] as? NSNumber ?? 0
                            orderDetailEntity.remarks = orderDetail["remarks"] as? String ?? ""
                            orderDetailEntity.createdAt = orderDetail.createdAt ?? DateUtility.minimumDate()
                            orderDetailEntity.updatedAt = orderDetail.updatedAt ?? DateUtility.minimumDate()
                            
                            DbContextBase.registerEntity(orderDetailEntity)
                            orderDetailEntity.order = orderEntity
                            
//                            let productIngredientsRelation = orderDetail.relationForKey("productIngredients")
//                            if let piQuery = productIngredientsRelation.query(), let productIngredients = try? piQuery.findObjects() {
                            let piQuery = PFQuery(className: "ProductIngredient")
                            piQuery.whereKey("orderDetailObjectId", equalTo: orderDetail)
                            if let productIngredients = try? piQuery.findObjects() {
                            
                   
                                productIngredients.forEach({ (productIngredient) -> Void in
                                    let productIngredientEntity : ProductIngredient = ProductIngredients.instance().createEntity()
                                    productIngredientEntity.id = productIngredient["id"] as? NSNumber ?? 0
                                    productIngredientEntity.orderDetailId = productIngredient["orderDetailId"] as? NSNumber ?? 0
                                    productIngredientEntity.isCustom = productIngredient["isCustom"] as? NSNumber ?? 0
                                    productIngredientEntity.name = productIngredient["name"] as? String ?? ""
                                    productIngredientEntity.milkType = productIngredient["milkType"] as? String ?? ""
                                    productIngredientEntity.unitCalorie = productIngredient["unitCalorie"] as? NSNumber ?? 0
                                    productIngredientEntity.unitPrice = productIngredient["unitPrice"] as? NSNumber ?? 0
                                    productIngredientEntity.quantity = productIngredient["quantity"] as? NSNumber ?? 0
                                    productIngredientEntity.enabled = productIngredient["enabled"] as? NSNumber ?? 0
                                    productIngredientEntity.quantityType = productIngredient["quantityType"] as? NSNumber ?? 0
                                    productIngredientEntity.remarks = productIngredient["remarks"] as? String ?? ""
                                    productIngredientEntity.createdAt = productIngredient.createdAt ?? DateUtility.minimumDate()
                                    productIngredientEntity.updatedAt = productIngredient.updatedAt ?? DateUtility.minimumDate()
                                    
                                    DbContextBase.registerEntity(productIngredientEntity)
                                    productIngredientEntity.orderDetail = orderDetailEntity
                                    
                                    DbContextBase.insertEntity(productIngredientEntity)
                                })
                            }
                            
                            DbContextBase.insertEntity(orderDetailEntity)
                        })
                    }
                    
                    DbContextBase.insertEntity(orderEntity)
                })
            }
            
            completionHandler()
        }
    }

    private func fetchContentsFromWebAndStoreLocalDbForOrderProto2() {
        
        // 関係するオブジェクトも同時に取得するには、
        // 前提として、Pointer型のカラムに参照先のobjectIdの値が設定されている必要がある
        let orderDetailQuery = PFQuery(className: "OrderDetail")
        orderDetailQuery.includeKey("orderObjectId") // Pointer型カラム
        //orderDetailQuery.whereKey("orderObjectId", matchesQuery: orderQuery)
        //orderDetailQuery.orderByAscending("orderId")

        let orderQuery = PFQuery(className: "Order")
        orderQuery.whereKey("objectId", matchesKey: "orderObjectId", inQuery: orderDetailQuery)
        orderQuery.includeKey("objectId") // Pointer型カラム

        
        
//        let productIngredientQuery = PFQuery(className: "ProductIngredient")
//        productIngredientQuery.includeKey("orderDetailObjectId") // Pointer型カラム
//        productIngredientQuery.includeKey("orderDetailObjectId.orderObjectId") // ドットでつなぐと、先まで取得できる
//        productIngredientQuery.whereKey("orderDetailObjectId", matchesQuery: orderDetailQuery)
//        productIngredientQuery.orderByAscending("orderDetailId")
        
        let results0 = try! orderQuery.findObjects()
        for result0 in results0 {
            print(result0)
        }
        
        
//        let results = try! productIngredientQuery.findObjects()
//        for result in results {
//            print(result["orderDetailId"])
//            if let detailObj = result["orderDetailObjectId"] {
//                print(detailObj["orderId"])
//                //                if let orderObj = detailObj["orderObjectId"] as? PFObject {
//                //                    print(orderObj)
//                //                }
//            }
//        }
    }

    private func fetchContentsFromWebAndStoreLocalDbForOrderProto1() {

        // 関係するオブジェクトも同時に取得するには、
        // 前提として、Pointer型のカラムに参照先のobjectIdの値が設定されている必要がある
        let orderQuery = PFQuery(className: "Order")
        orderQuery.includeKey("orderDetailObjectId") // Pointer型カラム
        orderQuery.includeKey("orderDetailObjectId.orderObjectId") // ドットでつなぐと、先まで取得できる
        
        let orderDetailQuery = PFQuery(className: "OrderDetail")
        orderDetailQuery.includeKey("orderObjectId") // Pointer型カラム
        orderDetailQuery.whereKey("orderObjectId", matchesQuery: orderQuery)
        orderDetailQuery.orderByAscending("orderId")
        
        let productIngredientQuery = PFQuery(className: "ProductIngredient")
        productIngredientQuery.includeKey("orderDetailObjectId") // Pointer型カラム
        productIngredientQuery.includeKey("orderDetailObjectId.orderObjectId") // ドットでつなぐと、先まで取得できる
        productIngredientQuery.whereKey("orderDetailObjectId", matchesQuery: orderDetailQuery)
        productIngredientQuery.orderByAscending("orderDetailId")

        let results0 = try! orderQuery.findObjects()
        for result0 in results0 {
            print(result0)
        }
    

        let results = try! productIngredientQuery.findObjects()
        for result in results {
            print(result["orderDetailId"])
            if let detailObj = result["orderDetailObjectId"] {
                print(detailObj["orderId"])
//                if let orderObj = detailObj["orderObjectId"] as? PFObject {
//                    print(orderObj)
//                }
            }
        }
    }

    // TODO: 特殊系処理はそれぞれ固有のクラス・メソッドにマッピングする形とする
    private func fetchOrder() {

        let orderQuery = PFQuery(className: "Order")

        let orderDetailQuery = PFQuery(className: "OrderDetail")
        orderDetailQuery.includeKey("orderObjectId")
        //orderDetailQuery.whereKey("orderId", matchesKey: "id", inQuery: orderQuery)
        orderDetailQuery.whereKey("orderObjectId", matchesQuery: orderQuery)
        orderDetailQuery.orderByAscending("orderId")
        
        let productIngredientQuery = PFQuery(className: "ProductIngredient")
        productIngredientQuery.includeKey("orderDetailObjectId")
        productIngredientQuery.includeKey("orderDetailObjectId.orderObjectId") // ドットでつなぐと、先まで取得できる
        //productIngredientQuery.whereKey("orderDetailId", matchesKey: "orderDetailObjectId", inQuery: orderDetailQuery)
        //productIngredientQuery.whereKey("orderObjectId", matchesQuery: orderQuery)
        productIngredientQuery.whereKey("orderDetailObjectId", matchesQuery: orderDetailQuery)
        productIngredientQuery.orderByAscending("orderDetailId")
        
        let results = try! productIngredientQuery.findObjects()
        for result in results {
            print(result)
            if let detailObj = result["orderDetailObjectId"] {
                print(detailObj)
                if let orderObj = detailObj["orderObjectId"] as? PFObject {
                    print(orderObj)
                }
            }
        }
    }
    
    private func fetchAndStoreRecursively(query: PFQuery, entityName: String, completionHandler: (() -> Void)?) {
        query.findObjectsInBackgroundWithBlock({ (fetchedObjects, error) -> Void in
            let dbContext = self.getDbContext(entityName)
            if let fetchedObjects = fetchedObjects {
                var propertyNames : [String]? = nil
                fetchedObjects.forEach{pfObject in
                    let entity = dbContext.createEntity()
                    DbContextBase.registerEntity(entity)
                    
                    let propNames = propertyNames ?? ({() -> [String]? in
                        propertyNames = entity.propertyNames()
                        return propertyNames
                        }()
                    )
                    
                    for propName in propNames! {
                        if [/*"id", */"createdAt", "updatedAt"].contains({el in el == propName}) {
                            continue
                        }
                        
                        if var propValue: AnyObject = pfObject.valueForKey(propName) {
                            if propValue is String {
                                propValue = ContentsManager.instance.typeConvert(entity.propertyTypeName(propName), propValue: propValue as! String)
                            }
                            entity.setValue(propValue, forKey: propName)
                        } else if let pf = pfObject.valueForKey("\(propName)ObjectId") as? PFObject, let pfFilled = try?pf.fetchIfNeeded() {
                            
                            if let associated = self.getDbContext(propName.snakeCase()).findById(Int(pfFilled["id"] as? NSNumber ?? 0)) {
                                entity.setValue(associated, forKey: propName)
                            }
                        }
                    }
                    
                    entity.setValue(pfObject.createdAt ?? DateUtility.minimumDate(), forKey: "createdAt")
                    entity.setValue(pfObject.updatedAt ?? DateUtility.minimumDate(), forKey: "updatedAt")
                    
                    // ローカルのCoreDataに登録済みのオブジェクトと関連づける
                    //DbContextBase.registerEntity(entity)
                    dbContext.childRelations().forEach({relation in
                        if let foreignKeyValue : AnyObject = pfObject.valueForKey(relation.foreignKeyName) {
                            let relationDbContext = self.getDbContext(relation.destinationEntityName)
                            if let firstEntity = relationDbContext.findEntities([relation.destinationKeyName: foreignKeyValue], orderKeys: []).first {
                                entity.setValue(firstEntity, forKey: relation.entityPropertyName)
                            }
                        }
                    })
                    
                    DbContextBase.insertEntity(entity)
                }
                
                if fetchedObjects.count < query.limit {
                    completionHandler?()
                } else {
                    query.skip += query.limit
                    self.fetchAndStoreRecursively(query, entityName: entityName, completionHandler: completionHandler)
                }
            }
            
            completionHandler?()
        })
    }
    
    override func deleteContentsToWeb(idOnWeb: Int, entityName: String) -> Bool {
        var deleted = false
        
        let query = PFQuery(className: entityName.pascalCaseFromSnakeCase())
        query.limit = 1
        query.whereKey("id", equalTo: idOnWeb)
        
        do{
            if let results = try? query.findObjects(), let result = results.first {
                try result.delete()
                deleted = true
            }
        } catch let error as NSError {
            print("error when deleting : \(error)")
        }
        
        return deleted
    }
}
