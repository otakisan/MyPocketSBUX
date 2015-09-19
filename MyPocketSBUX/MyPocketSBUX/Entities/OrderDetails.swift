//
//  OrderDetails.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/29.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class OrderDetails: DbContextBase {
    static var contextInstance : OrderDetails = OrderDetails()
    
    class func instance() -> OrderDetails{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "OrderDetail"
    }
    
    class func sequenceNumber() -> Int {
        return OrderDetails.instance().maxId() + 1
        //return Int(Double(NSDate().timeIntervalSince1970) * 1.0e6)
    }
    
    class func getOrderDetailsWithOrderId(orderId : Int, orderKeys : [(columnName : String, ascending : Bool)]) -> [OrderDetail] {
        
        var sortKeys : [NSSortDescriptor] = []
        for orderkey in orderKeys {
            sortKeys.append(NSSortDescriptor(key: orderkey.columnName, ascending: orderkey.ascending))
        }
        
        return findByFetchRequestTemplate(
            "orderDetailsWithOrderIdFetchRequest",
            variables: ["orderId":orderId],
            sortDescriptors: sortKeys,
            limit: 0) as! [OrderDetail]
    }
    
    func orderDetailsWithBean() -> [OrderDetail] {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: DbContextBase.getManagedObjectContext())
        
        fetchRequest.entity = entity
        // Specify criteria for filtering which objects to fetch
        let beans : [Bean] = Beans.instance().getAllOrderBy([])
        let args : [String] = beans.map {$0.janCode}
        let predicate = NSPredicate(format:"productJanCode IN %@", args)
        fetchRequest.predicate = predicate
        // Specify how the fetched objects should be sorted
        let sortDescriptor = NSSortDescriptor(key: "orderId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var details : [OrderDetail] = []
        if let results = (try? DbContextBase.getManagedObjectContext().executeFetchRequest(fetchRequest)) as? [OrderDetail] {
            details = results
        }

        return details
    }

}
