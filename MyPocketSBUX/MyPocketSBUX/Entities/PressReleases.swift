//
//  PressReleases.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class PressReleases: NSObject {
    
    class func entityName() -> String {
        return "PressRelease"
    }
    
    /**
    ManagedObjectContext取得
    
    - returns: ManagedObjectContext
    */
    class func getManagedObjectContext() -> NSManagedObjectContext {
        
        let appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context : NSManagedObjectContext = appDel.managedObjectContext!
        
        return context
    }
    
    class func getManagedObjectModel() -> NSManagedObjectModel {
        
        let appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context : NSManagedObjectModel = appDel.managedObjectModel
        
        return context
    }
    
    /**
    PressReleaseエンティティを生成します
    
    - returns: PressReleaseエンティティ
    */
    class func createEntity() -> PressRelease {
        let context : NSManagedObjectContext = PressReleases.getManagedObjectContext()
        let ent = NSEntityDescription.entityForName(PressReleases.entityName(), inManagedObjectContext: context)
        
        return PressRelease(entity: ent!, insertIntoManagedObjectContext: nil)
    }
    
    class func copyEntityWithId(id : String) -> PressRelease? {
        
        var copiedEntity : PressRelease?
        if let srcEntity = self.getTask(id) {
            copiedEntity = self.copyEntity(srcEntity)
        }
        
        return copiedEntity
    }
    
    class func copyEntity(srcEntity : PressRelease) -> PressRelease {
        
        let entity = PressReleases.createEntity()
        entity.setValue(srcEntity.valueForKey("fiscalYear"), forKey: "fiscalYear")
        entity.setValue(srcEntity.valueForKey("pressReleaseSn"), forKey: "pressReleaseSn")
        entity.setValue(srcEntity.valueForKey("title"), forKey: "title")
        entity.setValue(srcEntity.valueForKey("url"), forKey: "url")
        entity.setValue(srcEntity.valueForKey("issueDate"), forKey: "issueDate")
        entity.setValue(srcEntity.valueForKey("createdAt"), forKey: "createdAt")
        entity.setValue(srcEntity.valueForKey("updatedAt"), forKey: "updatedAt")
        
        return entity
    }
    
    class func insertEntity(entity : PressRelease) {
        
        if PressReleases.getManagedObjectContext().objectRegisteredForID(entity.objectID) == nil {
            PressReleases.getManagedObjectContext().insertObject(entity)
        }
        
        do {
            try PressReleases.getManagedObjectContext().save()
        } catch _ {
        }
    }
    
    class func deleteEntityWithId(id : String) {
        if let entity = self.getTask(id) {
            self.deleteEntity(entity)
        }
    }
    
    class func deleteEntity(entity : PressRelease) {
        PressReleases.getManagedObjectContext().deleteObject(entity)
        do {
            try PressReleases.getManagedObjectContext().save()
        } catch _ {
        }
    }
    
    class func getAllOrderBy(orderKeys : [(columnName : String, ascending : Bool)]) -> [PressRelease] {
        
        var sortKeys : [NSSortDescriptor] = []
        for orderkey in orderKeys {
            sortKeys.append(NSSortDescriptor(key: orderkey.columnName, ascending: orderkey.ascending))
        }
        
        return self.findByFetchRequestTemplate(
            "allPressReleasesFetchRequest",
            variables: [:],
            sortDescriptors: sortKeys,
            limit: 0)
    }
    
    class func getTasks() -> [PressRelease] {
        return self.findTodayOrBeforeTasks(100)
    }
    
    class func getTasks(date : NSDate) -> [PressRelease] {
        return self.findByDueDate(date, limit: 100)
    }
    
    class func getTasks(fromDate : NSDate, toDate : NSDate) -> [PressRelease] {
        return self.findByDueDate(fromDate, toDueDate: toDate, limit: 100)
    }
    
    class func getTasksUnfinished(fromDate : NSDate, toDate : NSDate) -> [PressRelease] {
        return self.findUnfinishedByDueDate(fromDate, toDueDate: toDate, limit: 100)
    }
    
    class func getTask(id : String) -> PressRelease? {
        return self.findById(id)
    }
    
    class func getTaskCount(dueDate : NSDate) -> Int {
        return self.countByDueDate(dueDate)
    }
    
    class func clearAllEntities() {
        if let results = try? PressReleases.getManagedObjectContext().executeFetchRequest(NSFetchRequest(entityName: PressReleases.entityName())) {
            for result in results as! [PressRelease] {
                PressReleases.getManagedObjectContext().deleteObject(result)
            }
            
            do {
                try PressReleases.getManagedObjectContext().save()
            } catch _ {
            }
        }
    }
    
    class func rollback() {
        PressReleases.getManagedObjectContext().rollback()
    }
    
//    class func createId() -> String {
//        var formatter = NSDateFormatter()
//        formatter.dateFormat = "yyyyMMddHHmmssSSS"
//        var dateTimePart = formatter.stringFromDate(NSDate())
//        return "Task_\(dateTimePart)"
//    }
    
    class func getFetchRequestTemplate(templateName : String, variables : [String:AnyObject], sortDescriptors : [NSSortDescriptor]?, limit : Int) -> NSFetchRequest? {
        
        var request : NSFetchRequest?
        
        if let fetchRequest = PressReleases.getManagedObjectModel().fetchRequestFromTemplateWithName(templateName, substitutionVariables: variables){
            fetchRequest.returnsObjectsAsFaults = false
            
            if(limit > 0){
                fetchRequest.fetchLimit = limit
            }
            
            fetchRequest.sortDescriptors = sortDescriptors
            
            request = fetchRequest
        }
        
        return request
    }
    
    class func countByFetchRequestTemplate(templateName : String, variables : [String:AnyObject]) -> Int {
        
        var count = 0
        
        if let fetchRequest = self.getFetchRequestTemplate(templateName, variables: variables, sortDescriptors: nil, limit: 0){
            
            count = PressReleases.getManagedObjectContext().countForFetchRequest(fetchRequest, error: nil)
        }
        
        return count
    }
    
    class func findByFetchRequestTemplate(templateName : String, variables : [String:AnyObject], sortDescriptors : [NSSortDescriptor]?, limit : Int) -> [PressRelease] {
        
        var results : [PressRelease] = []
        
        if let fetchRequest = self.getFetchRequestTemplate(templateName, variables: variables, sortDescriptors: sortDescriptors, limit: limit){
            
            if let fetchResults = try? PressReleases.getManagedObjectContext().executeFetchRequest(fetchRequest) {
                results = fetchResults as! [PressRelease]
            }
        }
        
        return results
    }
    
    class func findById(id : String) -> PressRelease? {
        
        var entity : PressRelease? = nil
        var results = self.findByFetchRequestTemplate("IdFetchRequest", variables: ["id" : id], sortDescriptors: nil, limit: 0)
        if results.count > 0{
            entity = results[0]
        }
        
        return entity
    }
    
    class func findByDueDate(dueDate : NSDate, limit : Int) -> [PressRelease] {
        
        let results = self.findByFetchRequestTemplate("DueDateFetchRequest", variables: ["fromDueDate" : DateUtility.firstEdgeOfDay(dueDate), "toDueDate":DateUtility.lastEdgeOfDay(dueDate)], sortDescriptors: nil, limit: limit)
        
        return results
    }
    
    class func findByDueDate(fromDueDate : NSDate, toDueDate : NSDate, limit : Int) -> [PressRelease] {
        let results = self.findByFetchRequestTemplate("DueDateFetchRequest", variables: ["fromDueDate" : DateUtility.firstEdgeOfDay(fromDueDate), "toDueDate":DateUtility.lastEdgeOfDay(toDueDate)], sortDescriptors: nil, limit: limit)
        
        return results
    }
    
    class func findUnfinishedByDueDate(fromDueDate : NSDate, toDueDate : NSDate, limit : Int) -> [PressRelease] {
        let results = self.findByFetchRequestTemplate("UnfinishedFetchRequest", variables: ["fromDueDate" : DateUtility.firstEdgeOfDay(fromDueDate), "toDueDate":DateUtility.lastEdgeOfDay(toDueDate)], sortDescriptors: nil, limit: limit)
        
        return results
    }
    
    class func findTodayOrBeforeTasks(limit : Int) -> [PressRelease] {
        
        return self.findByFetchRequestTemplate(
            "TodayOrBeforeFetchRequest",
            variables: ["today" : NSDate()],
            sortDescriptors: [
                NSSortDescriptor(key: "dueDate", ascending: true),
                NSSortDescriptor(key: "priority", ascending: false)
            ],
            limit: limit)
    }
    
    class func findTheDayOrBeforeTasks(date : NSDate, limit : Int) -> [PressRelease] {
        
        return self.findByFetchRequestTemplate(
            "TodayOrBeforeFetchRequest",
            variables: ["today" : date],
            sortDescriptors: [
                NSSortDescriptor(key: "dueDate", ascending: true),
                NSSortDescriptor(key: "priority", ascending: false)
            ],
            limit: limit)
    }
    
    class func countByDueDate(dueDate : NSDate) -> Int {
        
        let count = self.countByFetchRequestTemplate("DueDateFetchRequest", variables: ["fromDueDate" : DateUtility.firstEdgeOfDay(dueDate), "toDueDate":DateUtility.lastEdgeOfDay(dueDate)])
        
        return count
    }
    
    class func countUnfinishedByDueDate(fromDueDate : NSDate, toDueDate : NSDate) -> Int {
        let count = self.countByFetchRequestTemplate("UnfinishedFetchRequest", variables: ["fromDueDate" : DateUtility.firstEdgeOfDay(fromDueDate), "toDueDate":DateUtility.lastEdgeOfDay(toDueDate)])
        
        return count
    }
    
    class func groupByWithCount(propName : String) -> [(propValue : String, count : Int)] {
        
        var returnList : [(propValue : String, count : Int)] = []
        
        // SELECT `propName`, COUNT(propName) FROM `PressRelease` GROUP BY `propName`
        
        let fetch = NSFetchRequest(entityName: "PressRelease")
        
        if let entity = NSEntityDescription.entityForName("PressRelease", inManagedObjectContext: PressReleases.getManagedObjectContext()) {
            
            if let groupDesc: AnyObject = entity.attributesByName[propName] {
                let keyPathExpression = NSExpression(forKeyPath: propName)
                let countExpression = NSExpression(forFunction: "count:", arguments: [keyPathExpression])
                
                let expressionDescription = NSExpressionDescription()
                expressionDescription.name = "count"
                expressionDescription.expression = countExpression
                expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
                
                fetch.propertiesToFetch = [groupDesc, expressionDescription]
                fetch.propertiesToGroupBy = [groupDesc]
                fetch.resultType = NSFetchRequestResultType.DictionaryResultType
                
                if let results = try? PressReleases.getManagedObjectContext().executeFetchRequest(fetch) {
                    
                    for result in results {
                        if result[propName] != nil && result["count"] != nil {
                            let propValueData = result[propName]! as! String
                            let countData = result["count"]! as! Int
                            
                            returnList.append((propValue:propValueData, count : countData))
                        }
                    }
                }
            }
        }
        
        return returnList
        
    }
}
