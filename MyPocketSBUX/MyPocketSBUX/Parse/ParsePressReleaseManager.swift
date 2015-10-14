//
//  ParsePressReleaseManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse

class ParsePressReleaseManager: PressReleaseManager {

    override func fetchAndStore(nextSn: Int, completion: (([PressRelease]) -> Void)?) {
        
        var results : [PressRelease] = []
        
        let query = PFQuery(className: PressReleases.entityName())
        query.whereKey("pressReleaseSn", greaterThanOrEqualTo: nextSn)
        query.orderByDescending("pressReleaseSn")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (newPressReleases, error) -> Void in
            if let newPressReleases = newPressReleases {
                newPressReleases.forEach{pfObject in
                    let pressRelease = PressReleases.createEntity()
                    let propNames = pressRelease.propertyNames()
                    for propName in propNames {
                        if ["createdAt", "updatedAt"].contains({el in el == propName}) {
                            continue
                        }
                        
                        if var propValue: AnyObject = pfObject.valueForKey(propName) {
                            if propValue is String {
                                propValue = ContentsManager.instance.typeConvert(pressRelease.propertyTypeName(propName), propValue: propValue as! String)
                            }
                            pressRelease.setValue(propValue, forKey: propName)
                        }
                    }
                    
                    pressRelease.createdAt = pfObject.createdAt ?? DateUtility.minimumDate()
                    pressRelease.updatedAt = pfObject.updatedAt ?? DateUtility.minimumDate()
                    
                    PressReleases.insertEntity(pressRelease)
                    results.append(pressRelease)
                }
            }
            
            completion?(results)

        }
    }
}
