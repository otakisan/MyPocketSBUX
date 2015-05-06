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
        tastingLog.storeId = 0
        tastingLog.detail = ""
        tastingLog.createdAt = DateUtility.minimumDate()
        tastingLog.updatedAt = DateUtility.minimumDate()
        tastingLog.store = nil
    }
    
    func saveTastingLog(tastingLog: TastingLog, newTastingLog: Bool) {
        tastingLog.updatedAt = NSDate()
        
        if newTastingLog {
            tastingLog.createdAt = NSDate()
            tastingLog.id = TastingLogs.instance().maxId() + 1
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

}
