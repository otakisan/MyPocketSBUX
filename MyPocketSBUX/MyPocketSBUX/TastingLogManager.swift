//
//  TastingLogManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogManager: NSObject {
    static let instance = TastingLogManager()
    
    func entityResourceName() -> String {
        return "tasting_log"
    }
    
    func newTastingLog() -> TastingLog {
        var tastingLog : TastingLog = TastingLogs.instance().createEntity()
        self.initializeTastingLog(tastingLog)
        
        return tastingLog
    }
    
    func initializeTastingLog(tastingLog: TastingLog) {
        tastingLog.id = 0
        tastingLog.title = ""
        tastingLog.tag = ""
        tastingLog.tastingAt = DateUtility.minimumDate()
        tastingLog.detail = ""
        tastingLog.createdAt = DateUtility.minimumDate()
        tastingLog.updatedAt = DateUtility.minimumDate()
        tastingLog.store = nil
    }
    
    func saveTastingLog(tastingLog: TastingLog, newTastingLog: Bool) {
        tastingLog.updatedAt = NSDate()
        
        if newTastingLog {
            tastingLog.createdAt = NSDate()
            // IDはサーバーで採番する
            //tastingLog.id = TastingLogs.instance().maxId() + 1
            TastingLogs.insertEntity(tastingLog)
        }
        else{
            TastingLogs.getManagedObjectContext().save(nil)
        }
    }
    
    func cancelTastingLog(tastingLog: TastingLog, newTastingLog: Bool) {
        if newTastingLog {
            TastingLogs.getManagedObjectContext().deleteObject(tastingLog)
        }
        else{
            TastingLogs.getManagedObjectContext().refreshObject(tastingLog, mergeChanges: false)
        }
    }
    
    func registerSyncRequest(tastingLog: TastingLog) {
        var entity: SyncRequest = SyncRequests.instance().createEntity()
        entity.entityTypeName = TastingLogs.instance().entityName()
        entity.entityPk = DbContextBase.zpk(tastingLog)
        
        TastingLogs.insertEntity(entity)
    }

    func postJsonContentsToWeb(tastingLog: TastingLog) -> Bool {
        return ContentsManager.instance.postJsonContentsToWeb(tastingLog, entityName: self.entityResourceName())
    }
    
    func postJsonContentsToWebWithRegiserSyncRequestIfFailed(tastingLog: TastingLog) {
        if !self.postJsonContentsToWeb(tastingLog) {
            // TODO: 同期が失敗した場合は、同期要求に格納する
            self.registerSyncRequest(tastingLog)
        }
    }
    
    func postJsonContentsToWebWithSyncRequest() {
        
        var syncedList: [SyncRequest] = []
        let syncRequests = TastingLogs.instance().searchSyncRequestsByEntityTypeName()
        for syncRequest in syncRequests {
            if let targetEntity : TastingLog = TastingLogs.instance().findByPk(syncRequest.entityPk as Int) {
                if self.postJsonContentsToWeb(targetEntity) {
                    syncedList += [syncRequest]
                }
            }
        }
        
        SyncRequests.deleteEntities(syncedList)
    }
}
