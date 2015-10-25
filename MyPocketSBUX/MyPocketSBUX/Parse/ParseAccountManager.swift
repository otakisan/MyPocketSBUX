//
//  ParseAccountManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import Foundation
import Parse

class ParseAccountManager: AccountManager {
    override func signIn(myPocketID: String, password: String) -> User? {
        
        // 後々は非同期対応にする
        var user : User? = nil
        if let pfUser = try? PFUser.logInWithUsername(myPocketID, password: password) {
            user = self.createUser(pfUser)
            IdentityContext.sharedInstance.currentUserID = user!.myPocketId
            
            PFInstallation.currentInstallation().saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                if let query = PFInstallation.query(), let currentUser = PFUser.currentUser() {
                    let push = PFPush()
                    // TODO: カレントユーザーと関係のあるユーザーにのみ通知するようにする
                    query.whereKey("user", notEqualTo: currentUser)
                    push.setQuery(query)
                    push.setMessage("\(IdentityContext.sharedInstance.currentUserID) signed in!")
                    push.sendPushInBackground()
                }
            })
        }
        
        return user
    }
    
    private func createUser(pfUser: PFUser) -> User {
        let user = User()
        user.myPocketId = pfUser.username ?? ""
        user.emailAddress = pfUser.email ?? ""
        return user
    }
    
    override func signOut() {
        
        // Unsubscribe from push notifications by removing the user association from the current installation.
        PFInstallation.currentInstallation().removeObjectForKey("user")
        PFInstallation.currentInstallation().saveInBackground();
        
        // Clear all caches
        PFQuery.clearAllCachedResults()

        PFUser.logOut()
        
        // TODO: これは共通の処理のほうか（本アプリの取り決めによるか）
        IdentityContext.sharedInstance.currentUserID = ""
    }
    
    override func createAccount(myPocketID: String, emailAddress: String, password: String) -> (success: Bool, reason: String) {
        // TODO: パスワードを暗号化
        // 公開鍵で暗号化する
        let user = PFUser()
        user.username = myPocketID
        user.password = password
        user.email = emailAddress
        
        // other fields can be set if you want to save more information
        //user["phone"] = phone
        
        // TODO: 非同期化
        var result = (success: false, reason: "")
        do{
            try user.signUp()
            result.success = true
        }
        catch let error as NSError {
            // TODO: エラー情報の受け取り方はOK
            result.reason = error.description
        }
        
        return result
    }
    
    // これはParse固有でないような気がする
    override func registerForRemoteNotifications() {
        
        let userNotificationTypes = UIUserNotificationType(rawValue: UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Badge.rawValue | UIUserNotificationType.Sound.rawValue)
        
        // カテゴリの指定なしだと、カテゴリの指定されていない通知のみを受け取る？
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
}
