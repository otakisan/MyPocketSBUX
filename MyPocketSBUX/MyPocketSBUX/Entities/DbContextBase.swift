//
//  DbContextBase.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class DbContextBase: NSObject {
    
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
    
    func entityName() -> String {
        return ""
    }
    
    func templateNameFetchAll() -> String {
        return "all\(self.entityName())sFetchRequest"
    }
    
    func templateNameFindById() -> String {
        return "find\(self.entityName())ByIdFetchRequest"
    }
    
    func templateNameFindByPk() -> String {
        return "find\(self.entityName())ByPkFetchRequest"
    }
    
    func childRelations() -> [(foreignKeyName:String, propertyName:String, destinationEntityName:String, destinationKeyName:String)] {
        return []
    }
    
    func createEntity<T : NSManagedObject>() -> T {
        let context : NSManagedObjectContext = DbContextBase.getManagedObjectContext()
        let ent = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)
        
        return T(entity: ent!, insertIntoManagedObjectContext: nil)
    }
    
    class func registerEntity(entity : NSManagedObject) -> Bool {
        var inserted = false
        if DbContextBase.getManagedObjectContext().objectRegisteredForID(entity.objectID) == nil {
            DbContextBase.getManagedObjectContext().insertObject(entity)
            inserted = true
        }
        
        return inserted
    }
    
    class func deleteEntity(entity : NSManagedObject) {
        DbContextBase.getManagedObjectContext().deleteObject(entity)
        do {
            try DbContextBase.getManagedObjectContext().save()
        } catch _ {
        }
    }
    
    class func deleteEntities(entities : [NSManagedObject]) {
        for entity in entities {
            DbContextBase.getManagedObjectContext().deleteObject(entity)
        }
        
        do {
            try DbContextBase.getManagedObjectContext().save()
        } catch _ {
        }
    }

    class func insertEntity(entity : NSManagedObject) {
        
        getManagedObjectContext().performBlockAndWait({
            DbContextBase.registerEntity(entity)
            do {
                //let ret = DbContextBase.getManagedObjectContext().obtainPermanentIDsForObjects([entity], error: nil)
                try DbContextBase.getManagedObjectContext().save()
            } catch _ {
            }
        })
    }
    
    func insertEntity(attributeValues : [String:AnyObject?]) {
        
        let entity = self.createEntity()
        DbContextBase.registerEntity(entity)
        
        for (key, value) in attributeValues {
            entity.setValue(value, forKey: key)
        }
        
        DbContextBase.insertEntity(entity)
    }
    
    func insertEntityFromJsonObject(jsonObject : NSArray){
        fatalError("should implement subclass")
    }
    
    class func getAllOrderBy<TResultEntity : NSManagedObject>(templateName: String, orderKeys : [(columnName : String, ascending : Bool)]) -> [TResultEntity] {
        
        var sortKeys : [NSSortDescriptor] = []
        for orderkey in orderKeys {
            sortKeys.append(NSSortDescriptor(key: orderkey.columnName, ascending: orderkey.ascending))
        }
        
        return self.findByFetchRequestTemplate(
            templateName,
            variables: [:],
            sortDescriptors: sortKeys,
            limit: 0) as! [TResultEntity]
    }
    
    func getAllOrderBy<TResultEntity : NSManagedObject>(orderKeys : [(columnName : String, ascending : Bool)]) -> [TResultEntity] {
        
        return DbContextBase.getAllOrderBy(self.templateNameFetchAll(), orderKeys: orderKeys)
    }
    
    func clearAllEntities() {
        if let results = try? DbContextBase.getManagedObjectContext().executeFetchRequest(NSFetchRequest(entityName: self.entityName())) {
            for result in results as! [NSManagedObject] {
                DbContextBase.getManagedObjectContext().deleteObject(result)
            }
            
            do {
                try DbContextBase.getManagedObjectContext().save()
            } catch _ {
            }
        }
    }
    
    func clearAllEntitiesExceptForUnsyncData() {
        if let results = try? DbContextBase.getManagedObjectContext().executeFetchRequest(NSFetchRequest(entityName: self.entityName())) {
            for result in results as! [NSManagedObject] {
                if !result.propertyNames().contains("myPocketId") || result.valueForKey("myPocketId") as? String != IdentityContext.sharedInstance.anonymousUserID() {
                    DbContextBase.getManagedObjectContext().deleteObject(result)
                }
            }
            
            do {
                try DbContextBase.getManagedObjectContext().save()
            } catch _ {
            }
        }
    }
    
    class func rollback() {
        getManagedObjectContext().rollback()
    }
    
    class func getFetchRequestTemplate(templateName : String, variables : [String:AnyObject], sortDescriptors : [NSSortDescriptor]?, limit : Int) -> NSFetchRequest? {
        
        var request : NSFetchRequest?
        
        if let fetchRequest = getManagedObjectModel().fetchRequestFromTemplateWithName(templateName, substitutionVariables: variables){
            fetchRequest.returnsObjectsAsFaults = false
            
            if(limit > 0){
                fetchRequest.fetchLimit = limit
            }
            
            fetchRequest.sortDescriptors = sortDescriptors
            
            request = fetchRequest
        }
        else{
            fatalError("FetchRequestTemplate not found. name:\(templateName)")
        }
        
        return request
    }
    
    class func countByFetchRequestTemplate(templateName : String, variables : [String:AnyObject]) -> Int {
        
        var count = 0
        
        if let fetchRequest = getFetchRequestTemplate(templateName, variables: variables, sortDescriptors: nil, limit: 0){
            
            count = getManagedObjectContext().countForFetchRequest(fetchRequest, error: nil)
        }
        
        return count
    }
    
    func countByFetchRequestTemplate(variables : [String:AnyObject]) -> Int {
        
        return DbContextBase.countByFetchRequestTemplate(self.templateNameFetchAll(), variables: variables)
    }
    
    
    class func findByFetchRequestTemplate(templateName : String, variables : [String:AnyObject], sortDescriptors : [NSSortDescriptor]?, limit : Int) -> [NSManagedObject] {
        
        var results : [NSManagedObject] = []
        
        //getManagedObjectContext().performBlockAndWait({
            
            if let fetchRequest = DbContextBase.getFetchRequestTemplate(templateName, variables: variables, sortDescriptors: sortDescriptors, limit: limit){
                
                if let fetchResults = try? DbContextBase.getManagedObjectContext().executeFetchRequest(fetchRequest) {
                    results = fetchResults as! [NSManagedObject]
                }
            }
            
        //})
        
        return results
    }
    
    func findEntities<TResultEntity : NSManagedObject>(variables : [String:AnyObject], orderKeys : [(columnName : String, ascending : Bool)]) -> [TResultEntity] {
        
        var results : [TResultEntity] = []
        var sortKeys : [NSSortDescriptor] = []
        for orderkey in orderKeys {
            sortKeys.append(NSSortDescriptor(key: orderkey.columnName, ascending: orderkey.ascending))
        }
        
        if let allfetchRequest = DbContextBase.getFetchRequestTemplate(self.templateNameFetchAll(), variables: [:], sortDescriptors: sortKeys, limit: 0) {
            variables.forEach({variable in
                let additionalPredicate: NSPredicate = NSPredicate(format: "\(variable.0) = %@", argumentArray: [variable.1])
                if let currentPredicate = allfetchRequest.predicate {
                    allfetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [currentPredicate, additionalPredicate])
                }else{
                    allfetchRequest.predicate = additionalPredicate
                }
            })  
            
            if let fetchResults = try? DbContextBase.getManagedObjectContext().executeFetchRequest(allfetchRequest) {
                results = fetchResults as! [TResultEntity]
            }

        }
        
        return results
    }
    
    func findById<TResultEntity : NSManagedObject>(id : Int) -> TResultEntity? {
        
        var entity : TResultEntity? = nil
        if var results = DbContextBase.findByFetchRequestTemplate(self.templateNameFindById(), variables: ["id" : id], sortDescriptors: nil, limit: 0) as? [TResultEntity] {
            if results.count > 0{
                entity = results[0]
            }
        }
        
        return entity
    }

    func findByPk<TResultEntity : NSManagedObject>(pk : Int) -> TResultEntity? {
        
        var entity : TResultEntity? = nil
        if var results = DbContextBase.findByFetchRequestTemplate(self.templateNameFindByPk(), variables: ["pk" : pk], sortDescriptors: nil, limit: 0) as? [TResultEntity] {
            if results.count > 0{
                entity = results[0]
            }
        }
        
        return entity
    }

    func maxId() -> Int {
        
        let req = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: DbContextBase.getManagedObjectContext())
        req.entity = entity
        req.resultType = NSFetchRequestResultType.DictionaryResultType
        
        let keyPathExpression = NSExpression(forKeyPath:"id")
        let maxExpression = NSExpression(forFunction:"max:", arguments:[keyPathExpression])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxId"
        expressionDescription.expression = maxExpression
        expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
        req.propertiesToFetch = [expressionDescription]
        
        var maxId = NSNotFound
        if let fetchResult = try? DbContextBase.getManagedObjectContext().executeFetchRequest(req){
            if fetchResult.count > 0 {
                maxId = fetchResult.first!["maxId"] as! NSInteger
            }
        }
        
        return maxId == NSNotFound ? 0 : Int(maxId)
    }
    
    func maxCreatedAt() -> NSDate {
        
        let req = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: DbContextBase.getManagedObjectContext())
        req.entity = entity
        req.resultType = NSFetchRequestResultType.DictionaryResultType
        
        let keyPathExpression = NSExpression(forKeyPath:"createdAt")
        let maxExpression = NSExpression(forFunction:"max:", arguments:[keyPathExpression])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxCreatedAt"
        expressionDescription.expression = maxExpression
        expressionDescription.expressionResultType = NSAttributeType.DateAttributeType
        req.propertiesToFetch = [expressionDescription]
        
        var maxCreatedAt = DateUtility.minimumDate()
        if let fetchResult = try? DbContextBase.getManagedObjectContext().executeFetchRequest(req){
            if let resultValue = fetchResult.first?["maxCreatedAt"] as? NSDate {
                maxCreatedAt = resultValue
            }
        }
        
        return maxCreatedAt
    }
    
    func searchSyncRequestsByEntityTypeName() -> [SyncRequest] {
        
        let sortKeys : [NSSortDescriptor] = []
        return DbContextBase.findByFetchRequestTemplate(
            "searchSyncRequestsByEntityTypeNameFetchRequest",
            variables: ["entityTypeName":self.entityName()],
            sortDescriptors: sortKeys,
            limit: 0) as! [SyncRequest]
    
    }

    func searchSyncRequestsByEntityTypeNameOnCurrentUser() -> [SyncRequest] {
        var results : [NSManagedObject] = []
        
        //getManagedObjectContext().performBlockAndWait({
        
        if let fetchRequest = DbContextBase.getFetchRequestTemplate("searchSyncRequestsByEntityTypeNameFetchRequest", variables: ["entityTypeName":self.entityName()], sortDescriptors: [], limit: 0){

            // 追加の条件を足しこむ
            let additionalPredicate1: NSPredicate = NSPredicate(format: "myPocketId = %@", argumentArray: [IdentityContext.sharedInstance.currentUserIDCorrespondingToSignIn()])
            let additionalPredicate2: NSPredicate = NSPredicate(format: "myPocketId = %@", argumentArray: [IdentityContext.sharedInstance.anonymousUserID()])
            let identityPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [additionalPredicate1, additionalPredicate2])
            
            fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [fetchRequest.predicate!, identityPredicate])
            
            if let fetchResults = try? DbContextBase.getManagedObjectContext().executeFetchRequest(fetchRequest) {
                results = fetchResults as! [NSManagedObject]
            }
        }
        
        //})
        
        return results as! [SyncRequest]
        
//        var sortKeys : [AnyObject] = []
//        return DbContextBase.findByFetchRequestTemplate(
//            "searchSyncRequestsByEntityTypeNameFetchRequest",
//            variables: ["entityTypeName":self.entityName()],
//            sortDescriptors: sortKeys,
//            limit: 0) as! [SyncRequest]
        
    }

    class func zpk(entity: NSManagedObject) -> Int {
        if entity.objectID.temporaryID {
            fatalError("objectID is Temporary !!")
        }
        
        var zPK = 0
        if let objectIDString = entity.objectID.URIRepresentation().lastPathComponent {
            zPK = Int(objectIDString.substringFromIndex(objectIDString.startIndex.successor())) ?? 0
        }
        
        return zPK
    }
}
