//
//  AccountManager.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/06/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Foundation

class AccountManager: NSObject {
    static var instance: AccountManager = BaseFactory.instance.createAccountManager()
    
    func signIn(myPocketID: String, password: String) -> User? {
        // TODO: パスワードを暗号化
        // 公開鍵で暗号化する
        
        let encryptedPW = self.encrypt(password)
        let user = self.getUser(myPocketID, password: encryptedPW)
        if user != nil {
            IdentityContext.sharedInstance.currentUserID = user!.myPocketId
        }
        
        return user
    }
    
    func signOut() {
        IdentityContext.sharedInstance.currentUserID = ""
    }
    
    func createAccountAndChangeCurrentUser(myPocketID: String, emailAddress: String, password: String) -> (success: Bool, reason: String) {
        let result = self.createAccount(myPocketID, emailAddress: emailAddress, password: password)
        if result.success {
            IdentityContext.sharedInstance.currentUserID = myPocketID
        }
        
        return result
    }
    
    func createAccount(myPocketID: String, emailAddress: String, password: String) -> (success: Bool, reason: String) {
        // TODO: パスワードを暗号化
        // 公開鍵で暗号化する
        
        let encryptedPW = self.encrypt(password)
        return self.postAccountToWeb(myPocketID, emailAddress: emailAddress, password: encryptedPW)
    }
    
    private func encrypt(plainText: String) -> String {
        return plainText
    }
    
    /**
    アカウント情報をPOSTで送信し、登録を依頼する
    */
    private func postAccountToWeb(myPocketID: String, emailAddress: String, password: String) -> (success: Bool, reason: String) {
        
        // NSObjectに直接serValueできない。プロパティを持つクラスを定義しておく必要がある。
        let user = User()
        user.myPocketId = myPocketID
        user.emailAddress = emailAddress
        user.password = password
        let jsonData = JSONUtility.jsonData(user)
        JSONUtility.printJsonData(jsonData!)
        
        // ポート番号までは同じだから共通化したい
        let url = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):\(ResourceContext.instance.servicePort())/users.json")
        let request = NSMutableURLRequest(URL: url!)
        
        // JSONでのリクエスト時、下記のcontent-typeの指定忘れでBad Requestになり、ハマることが多いので対策を練る
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        
        var success = false
        var errorReason = ""
        if let data = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
            if let dic = (try? NSJSONSerialization.JSONObjectWithData(data, options:[])) as? NSDictionary {
                // 登録が成功した、イコール、登録データのmy_pocket_idと等しい、とする
                // エラーの場合、配列でメッセージを返却する仕様らしい
                if let returnId = dic.valueForKey("my_pocket_id") as? String where returnId == user.myPocketId {
                    success = true
                }
                else if let errorArray = dic.valueForKey("my_pocket_id") as? NSArray where (errorArray.count > 0) {
                    errorReason = errorArray[0] as? String ?? "don't get an error message."
                }
                else{
                    errorReason = "error. but, there is no error message."
                }
                print(dic.description)
            }
        }
        
        return (success: success, reason: errorReason)
    }

    private func getUser(myPocketID: String, password: String) -> User? {
        // ポート番号までは同じだから共通化したい
        let url = NSURL(string: "http://\(ResourceContext.instance.serviceHost()):\(ResourceContext.instance.servicePort())/users/\(myPocketID)/\(password).json")
        let request = NSMutableURLRequest(URL: url!)
        
        // JSONでのリクエスト時、下記のcontent-typeの指定忘れでBad Requestになり、ハマることが多いので対策を練る
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        
        var result: User? = nil
        if let data = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil) {
            if let dic = (try? NSJSONSerialization.JSONObjectWithData(data, options:[])) as? NSDictionary {
                let user: User = JSONUtility.objectFromJsonObject(dic)
                result = user
                print(dic.description)
            }
        }
        
        return result
    }
    
    func registerForRemoteNotifications() {
    }
}

class User: NSObject {
    var myPocketId: String = ""
    var emailAddress: String = ""
    var password: String = ""
}