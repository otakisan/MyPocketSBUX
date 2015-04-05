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
        
        var appDel : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        var context : NSManagedObjectContext = appDel.managedObjectContext!
        
        return context
    }
    
    class func getManagedObjectModel() -> NSManagedObjectModel {
        
        var appDel : AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        var context : NSManagedObjectModel = appDel.managedObjectModel
        
        return context
    }
    
    func entityName() -> String {
        return ""
    }
    
    func createEntity<T : NSManagedObject>() -> T {
        var context : NSManagedObjectContext = DbContextBase.getManagedObjectContext()
        let ent = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)
        
        return T(entity: ent!, insertIntoManagedObjectContext: nil)
    }

    class func insertEntity(entity : NSManagedObject) {
        
        if getManagedObjectContext().objectRegisteredForID(entity.objectID) == nil {
            getManagedObjectContext().insertObject(entity)
        }
        
        getManagedObjectContext().save(nil)
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
            limit: 0) as [TResultEntity]
    }
    
    func clearAllEntities() {
        if var results = DbContextBase.getManagedObjectContext().executeFetchRequest(NSFetchRequest(entityName: self.entityName()), error: nil) {
            for result in results as [NSManagedObject] {
                DbContextBase.getManagedObjectContext().deleteObject(result)
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
        
        return request
    }
    
    class func countByFetchRequestTemplate(templateName : String, variables : [NSObject:AnyObject]) -> Int {
        
        var count = 0
        
        if var fetchRequest = getFetchRequestTemplate(templateName, variables: variables, sortDescriptors: nil, limit: 0){
            
            count = getManagedObjectContext().countForFetchRequest(fetchRequest, error: nil)
        }
        
        return count
    }
    
    
    class func findByFetchRequestTemplate(templateName : String, variables : [NSObject:AnyObject], sortDescriptors : [AnyObject]?, limit : Int) -> [NSManagedObject] {
        
        var results : [NSManagedObject] = []
        
        if var fetchRequest = getFetchRequestTemplate(templateName, variables: variables, sortDescriptors: sortDescriptors, limit: limit){
            
            if let fetchResults = getManagedObjectContext().executeFetchRequest(fetchRequest, error: nil) {
                results = fetchResults as [NSManagedObject]
            }
        }
        
        return results
    }
    
    class func findById<TResultEntity : NSManagedObject>(id : String) -> TResultEntity? {
        
        var entity : TResultEntity? = nil
        if var results = DbContextBase.findByFetchRequestTemplate("IdFetchRequest", variables: ["id" : id], sortDescriptors: nil, limit: 0) as? [TResultEntity] {
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
                maxId = fetchResult.first!["maxId"] as NSInteger
            }
        }
        
        return maxId == NSNotFound ? 0 : Int(maxId)
    }
}
