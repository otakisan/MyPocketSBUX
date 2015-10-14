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
        PFUser.logOut()
        IdentityContext.sharedInstance.currentUserID = ""
    }
    
//    override func createAccountAndChangeCurrentUser(myPocketID: String, emailAddress: String, password: String) -> (success: Bool, reason: String) {
//        let result = self.createAccount(myPocketID, emailAddress: emailAddress, password: password)
//        if result.success {
//            IdentityContext.sharedInstance.currentUserID = myPocketID
//        }
//        
//        return result
//    }
    
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
}
