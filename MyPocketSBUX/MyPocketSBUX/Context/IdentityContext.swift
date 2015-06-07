//
//  IdentityContext.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/06/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class IdentityContext: NSObject {
    static var sharedInstance = IdentityContext()
    
    var currentUserID: String = ""
    
    func signedIn() -> Bool {
        return self.currentUserID != ""
    }
    
    func anonymousUserID() -> String {
        return "anonymous"
    }
    
    func currentUserIDCorrespondingToSignIn() -> String {
        return self.signedIn() ? self.currentUserID : self.anonymousUserID()
    }
}
