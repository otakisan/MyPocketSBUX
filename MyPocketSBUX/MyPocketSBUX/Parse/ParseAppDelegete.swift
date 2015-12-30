//
//  ParseAppDelegete.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseCrashReporting

class ParseAppDelegete: NSObject, UIApplicationDelegate {
    
    private func getParseAppId() -> String {
        // Application IDやClient Keyは公開しても問題ないらしい
        // そもそも逆コンパイルされたり、トラフィックを覗かれたら見破られるので、とある。
        // https://parse.com/docs/ios/guide#security
        return "d8f4ppwZJ7vyp1HnS6uc6V9MlDjClB5UUjoDKmIs"
    }
    
    private func getParseClientKey() -> String {
        return "Vs1Pa5WgkZlB36W0LqOh4f7RWPNmqTwDkoK3yIiK"
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        ParseCrashReporting.enable()
        Parse.setApplicationId(self.getParseAppId(), clientKey: self.getParseClientKey())
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        self.clearBadge(application)

        // TODO: ACLの設定って必要？
//        let defaultACL = PFACL()
//        // Enable public read access by default, with any newly created PFObjects belonging to the current user
//        defaultACL.setPublicReadAccess(true)
//        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

        // ここでのログアウトって不要？？
        PFUser.logOut()
        
        // TODO: anypicのサンプルだと、handlepushというメソッドを作って、その中でプッシュ通知を受けての起動がらみの処理をしているが一旦保留
        self.prepareForPushNotification(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // クリアしないと、バッジの表示が残り続ける
        // Clear badge and update installation, required for auto-incrementing badges.
        self.clearBadge(application)
        
        // 下記により、didRegisterForRemoteNotificationsWithDeviceTokenに制御が回るようになる？？
        // Clears out all notifications from Notification Center.
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0

    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        self.clearBadge(application)
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
//        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("local notification : \(notification.alertBody)")
    }

    private func prepareForPushNotification(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        
        // Push通知
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
    }
    
    private func clearBadge(application: UIApplication) {
        // PFInstallationのbadgeを0にクリアしないと、次回通知を受けた時に残った値にインクリメントした値が表示されてしまう
        if (application.applicationIconBadgeNumber != 0) {
            application.applicationIconBadgeNumber = 0
            PFInstallation.currentInstallation().badge = 0
            PFInstallation.currentInstallation().saveInBackground();
        }
    }
}
