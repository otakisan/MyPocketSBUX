//
//  PressReleaseManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class PressReleaseManager: NSObject {
    static var instance: PressReleaseManager = BaseFactory.instance.createPressReleaseManager()
    
    func fetchAndStore(nextSn:Int, completion: (([PressRelease]) -> Void)?) {
        if let url  = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):3000/press_releases.json/?type=range&key=press_release_sn&from=\(nextSn)") {
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task    = session.dataTaskWithURL(url, completionHandler: {
                (data, resp, err) in
                var newPressReleaseData : [PressRelease] = []
                if let data = data, let newsData = self.initializeNewsArrayFromJson(data) {
                    newPressReleaseData = self.insertNewPressReleaseToLocal(newsData)
                }
                
                completion?(newPressReleaseData)
            })
            
            task.resume()
        }
    }
    
    private func initializeNewsArrayFromJson(newsJson: NSData) -> NSArray?{
        return (try? NSJSONSerialization.JSONObjectWithData(newsJson, options: NSJSONReadingOptions.MutableContainers)) as? NSArray
    }

    private func insertNewPressReleaseToLocal(newPressReleaseData : NSArray) -> [PressRelease] {
        
        var results : [PressRelease] = []
        
        for newPressRelease in newPressReleaseData {
            let entity = PressReleases.createEntity()
            entity.fiscalYear = (newPressRelease["fiscal_year"] as? NSNumber) ?? 0
            entity.pressReleaseSn = (newPressRelease["press_release_sn"] as? NSNumber) ?? 0
            entity.title = ((newPressRelease["title"] as? NSString) ?? "") as String
            entity.url = ((newPressRelease["url"] as? NSString) ?? "") as String
            entity.issueDate = DateUtility.dateFromSqliteDateString(newPressRelease["issue_date"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.createdAt = DateUtility.dateFromSqliteDateTimeString(newPressRelease["created_at"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = DateUtility.dateFromSqliteDateTimeString(newPressRelease["updated_at"] as? String ?? "") ?? NSDate(timeIntervalSince1970: 0)
            
            PressReleases.insertEntity(entity)
            results.append(entity)
        }
        
        return results
    }

}
