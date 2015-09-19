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
        let tastingLog : TastingLog = TastingLogs.instance().createEntity()
        self.initializeTastingLog(tastingLog)
        
        return tastingLog
    }
    
    func initializeTastingLog(tastingLog: TastingLog) {
        tastingLog.id = 0
        tastingLog.title = ""
        tastingLog.tag = ""
        tastingLog.tastingAt = DateUtility.minimumDate()
        tastingLog.detail = ""
        tastingLog.myPocketId = ""
        tastingLog.createdAt = DateUtility.minimumDate()
        tastingLog.updatedAt = DateUtility.minimumDate()
        tastingLog.store = nil
    }
    
    func saveTastingLog(tastingLog: TastingLog, newTastingLog: Bool) {
        tastingLog.updatedAt = NSDate()
        tastingLog.myPocketId = IdentityContext.sharedInstance.currentUserIDCorrespondingToSignIn()
        
        if newTastingLog {
            tastingLog.createdAt = NSDate()
            // IDはサーバーで採番する
            //tastingLog.id = TastingLogs.instance().maxId() + 1
            TastingLogs.insertEntity(tastingLog)
        }
        else{
            do {
                try TastingLogs.getManagedObjectContext().save()
            } catch _ {
            }
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
    
    func deleteTastingLog(tastingLog: TastingLog) {
        let idOnWeb = tastingLog.id as Int
        if !ContentsManager.instance.deleteContentsToWeb(idOnWeb, entityName: "tasting_log") {
            self.registerSyncRequest(tastingLog)
        }
        
        TastingLogs.deleteEntity(tastingLog)
    }
    
    func registerSyncRequest(tastingLog: TastingLog) {
        // TODO: ここも共通化の必要性あり。SyncRequestのスキーマ変更時に漏れが出るリスクがあるため。
        let entity: SyncRequest = SyncRequests.instance().createEntity()
        entity.entityTypeName = TastingLogs.instance().entityName()
        entity.entityPk = DbContextBase.zpk(tastingLog)
        entity.entityGlobalID = tastingLog.id ?? 0
        entity.myPocketId = IdentityContext.sharedInstance.currentUserIDCorrespondingToSignIn()
        
        SyncRequests.insertEntity(entity)
    }

    func postJsonContentsToWeb(tastingLog: TastingLog) -> Bool {
        return IdentityContext.sharedInstance.signedIn() && ContentsManager.instance.postJsonContentsToWeb(tastingLog, entityName: self.entityResourceName())
    }
    
    func postJsonContentsToWebWithRegiserSyncRequestIfFailed(tastingLog: TastingLog) {
        if !self.postJsonContentsToWeb(tastingLog) {
            // TODO: 同期が失敗した場合は、同期要求に格納する
            self.registerSyncRequest(tastingLog)
        }
    }
    
    func postJsonContentsToWebWithSyncRequest() {
        
        var syncedList: [SyncRequest] = []
        let syncRequests = TastingLogs.instance().searchSyncRequestsByEntityTypeNameOnCurrentUser()
        for syncRequest in syncRequests {
            if let targetEntity : TastingLog = TastingLogs.instance().findByPk(syncRequest.entityPk as Int) {
                // TODO: 現在の仕様としては未ログイン時に登録したものを同期する場合、カレントIDのデータとみなして登録する
                targetEntity.myPocketId = IdentityContext.sharedInstance.currentUserIDCorrespondingToSignIn()
                if self.postJsonContentsToWeb(targetEntity) {
                    syncedList += [syncRequest]
                }
            }
            else if syncRequest.entityGlobalID as Int > 0 {
                if ContentsManager.instance.deleteContentsToWeb(syncRequest.entityGlobalID as Int, entityName: "tasting_log") {
                    syncedList += [syncRequest]
                }
            }
        }
        
        SyncRequests.deleteEntities(syncedList)
    }
}
