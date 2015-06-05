//
//  AccountManager.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/06/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class AccountManager: NSObject {
    static var instance: AccountManager = AccountManager()
    
    func CreateAccount(myPocketID: String, emailAddress: String, password: String) {
        // TODO: パスワードを暗号化
        // 公開鍵で暗号化する
        
        let encryptedPW = self.encrypt(password)
        self.postAccountToWeb(myPocketID, emailAddress: emailAddress, password: encryptedPW)
    }
    
    func encrypt(plainText: String) -> String {
        return plainText
    }
    
    func postAccountToWeb(myPocketID: String, emailAddress: String, password: String){
        
        let str = "{ \"my_pocket_id\": \"\(myPocketID)\", \"email_address\": \"\(emailAddress)\", \"password\": \"\(password)\" }"
        let strData = str.dataUsingEncoding(NSUTF8StringEncoding)
        
        var url = NSURL(string: "http://localhost:3000/accounts.json")
        var request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = strData
        
        if var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil) {
            if var dic = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: nil) as? NSDictionary {
                print(dic.count)
            }
        }
    }

}