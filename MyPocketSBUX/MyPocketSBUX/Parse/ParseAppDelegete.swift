//
//  ParseAppDelegete.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse

class ParseAppDelegete: NSObject, UIApplicationDelegate {
    
    private func getParseAppId() -> String {
        // キーってどう管理すべきなんだろう？？
        // このアプリそのものから発信された通信出ることを証明して、
        // それが確認できたら、キーを返却する、といった仕組み？？
        return "d8f4ppwZJ7vyp1HnS6uc6V9MlDjClB5UUjoDKmIs"
    }
    
    private func getParseClientKey() -> String {
        // キーってどう管理すべきなんだろう？？
        return "Vs1Pa5WgkZlB36W0LqOh4f7RWPNmqTwDkoK3yIiK"
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.setApplicationId(self.getParseAppId(), clientKey: self.getParseClientKey())
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        PFUser.logOut()
        return true
    }
}
