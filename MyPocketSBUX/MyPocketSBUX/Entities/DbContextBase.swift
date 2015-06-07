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
    
    :returns: ManagedObjectContext
    */
    class func getManagedObjectContext() -> NSManagedObjectContext {
        
        var appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context : NSManagedObjectContext = appDel.managedObjectContext!
        
        return context
    }
    
    class func getManagedObjectModel() -> NSManagedObjectModel {
        
        var appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context : NSManagedObjectModel = appDel.managedObjectModel
        
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
    
    func createEntity<T : NSManagedObject>() -> T {
        var context : NSManagedObjectContext = DbContextBase.getManagedObjectContext()
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
        DbContextBase.getManagedObjectContext().save(nil)
    }
    
    class func deleteEntities(entities : [NSManagedObject]) {
        for entity in entities {
            DbContextBase.getManagedObjectContext().deleteObject(entity)
        }
        
        DbContextBase.getManagedObjectContext().save(nil)
    }

    class func insertEntity(entity : NSManagedObject) {
        
        getManagedObjectContext().performBlockAndWait({
            DbContextBase.registerEntity(entity)
            //let ret = DbContextBase.getManagedObjectContext().obtainPermanentIDsForObjects([entity], error: nil)
            DbContextBase.getManagedObjectContext().save(nil)
        })
    }
    
    func insertEntity<TEntity: NSManagedObject>(attributeValues : [String:AnyObject?]) {
        
        var entity = self.createEntity()
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
        
        var sortKeys : [AnyObject] = []
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
        if var results = DbContextBase.getManagedObjectContext().executeFetchRequest(NSFetchRequest(entityName: self.entityName()), error: nil) {
            for result in results as! [NSManagedObject] {
                DbContextBase.getManagedObjectContext().deleteObject(result)
            }
            
            DbContextBase.getManagedObjectContext().save(nil)
        }
    }
    
    func clearAllEntitiesExceptForUnsyncData() {
        if var results = DbContextBase.getManagedObjectContext().executeFetchRequest(NSFetchRequest(entityName: self.entityName()), error: nil) {
            contains([], "")
            for result in results as! [NSManagedObject] {
                if !contains(result.propertyNames(), "myPocketId") || result.valueForKey("myPocketId") as? String != IdentityContext.sharedInstance.anonymousUserID() {
                    DbContextBase.getManagedObjectContext().deleteObject(result)
                }
            }
            
            DbContextBase.getManagedObjectContext().save(nil)
        }
    }
    
    class func rollback() {
        getManagedObjectContext().rollback()
    }
    
    class func getFetchRequestTemplate(templateName : String, variables : [NSObject:AnyObject], sortDescriptors : [AnyObject]?, limit : Int) -> NSFetchRequest? {
        
        var request : NSFetchRequest?
        
        if var fetchRequest = getManagedObjectModel().fetchRequestFromTemplateWithName(templateName, substitutionVariables: variables){
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
    
    class func countByFetchRequestTemplate(templateName : String, variables : [NSObject:AnyObject]) -> Int {
        
        var count = 0
        
        if var fetchRequest = getFetchRequestTemplate(templateName, variables: variables, sortDescriptors: nil, limit: 0){
            
            count = getManagedObjectContext().countForFetchRequest(fetchRequest, error: nil)
        }
        
        return count
    }
    
    func countByFetchRequestTemplate(variables : [NSObject:AnyObject]) -> Int {
        
        return DbContextBase.countByFetchRequestTemplate(self.templateNameFetchAll(), variables: variables)
    }
    
    
    class func findByFetchRequestTemplate(templateName : String, variables : [NSObject:AnyObject], sortDescriptors : [AnyObject]?, limit : Int) -> [NSManagedObject] {
        
        var results : [NSManagedObject] = []
        
        //getManagedObjectContext().performBlockAndWait({
            
            if var fetchRequest = DbContextBase.getFetchRequestTemplate(templateName, variables: variables, sortDescriptors: sortDescriptors, limit: limit){
                
                if let fetchResults = DbContextBase.getManagedObjectContext().executeFetchRequest(fetchRequest, error: nil) {
                    results = fetchResults as! [NSManagedObject]
                }
            }
            
        //})
        
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
        
        var req = NSFetchRequest()
        var entity = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: DbContextBase.getManagedObjectContext())
        req.entity = entity
        req.resultType = NSFetchRequestResultType.DictionaryResultType
        
        var keyPathExpression = NSExpression(forKeyPath:"id")
        var maxExpression = NSExpression(forFunction:"max:", arguments:[keyPathExpression])
        var expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxId"
        expressionDescription.expression = maxExpression
        expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
        req.propertiesToFetch = [expressionDescription]
        
        var maxId = NSNotFound
        var error : NSError? = nil
        if let fetchResult = DbContextBase.getManagedObjectContext().executeFetchRequest(req, error: nil){
            if fetchResult.count > 0 {
                maxId = fetchResult.first!["maxId"] as! NSInteger
            }
        }
        
        return maxId == NSNotFound ? 0 : Int(maxId)
    }
    
    func searchSyncRequestsByEntityTypeName() -> [SyncRequest] {
        
        var sortKeys : [AnyObject] = []
        return DbContextBase.findByFetchRequestTemplate(
            "searchSyncRequestsByEntityTypeNameFetchRequest",
            variables: ["entityTypeName":self.entityName()],
            sortDescriptors: sortKeys,
            limit: 0) as! [SyncRequest]
    
    }

    func searchSyncRequestsByEntityTypeNameOnCurrentUser() -> [SyncRequest] {
        var results : [NSManagedObject] = []
        
        //getManagedObjectContext().performBlockAndWait({
        
        if var fetchRequest = DbContextBase.getFetchRequestTemplate("searchSyncRequestsByEntityTypeNameFetchRequest", variables: ["entityTypeName":self.entityName()], sortDescriptors: [], limit: 0){

            // 追加の条件を足しこむ
            var additionalPredicate1: NSPredicate = NSPredicate(format: "myPocketId = %@", argumentArray: [IdentityContext.sharedInstance.currentUserIDCorrespondingToSignIn()])
            var additionalPredicate2: NSPredicate = NSPredicate(format: "myPocketId = %@", argumentArray: [IdentityContext.sharedInstance.anonymousUserID()])
            var identityPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [additionalPredicate1, additionalPredicate2])
            
            fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [fetchRequest.predicate!, identityPredicate])
            
            if let fetchResults = DbContextBase.getManagedObjectContext().executeFetchRequest(fetchRequest, error: nil) {
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
        if var objectIDString = entity.objectID.URIRepresentation().lastPathComponent {
            zPK = objectIDString.substringFromIndex(objectIDString.startIndex.successor()).toInt() ?? 0
        }
        
        return zPK
    }
}
