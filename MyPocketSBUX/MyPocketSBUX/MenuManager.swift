//
//  MenuManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/26.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class MenuManager: NSObject {
    static var instance: MenuManager = BaseFactory.instance.createMenuManager()
    
    func updateProductLocalDb(productCategory : String, completionHandler: ((NSError?) -> Void)){
        
        // 全件を取得
        if let url  = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):3000/\(productCategory)s.json") {
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task    = session.dataTaskWithURL(url, completionHandler: { data, res, error in
                
                if data != nil {
                    if let productsJson = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray {
                        ContentsManager.instance.getDbContext(productCategory).insertEntityFromJsonObject(productsJson)
                    }
                }
                
                completionHandler(error)
            })
            
            task.resume()
        }
    }

}
