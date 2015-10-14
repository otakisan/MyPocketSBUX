//
//  ParseFactory.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ParseFactory: BaseFactory {
    override func createAppDelegeteBackend() -> UIApplicationDelegate? {
        return ParseAppDelegete()
    }

    override func createAccountManager() -> AccountManager {
        return ParseAccountManager()
    }
    
    override func createPressReleaseManager() -> PressReleaseManager {
        return ParsePressReleaseManager()
    }
    
    override func createStoreManager() -> StoreManager {
        return ParseStoreManager()
    }
    
    override func createContentsManager() -> ContentsManager {
        return ParseContentsManager()
    }
    
    override func createMenuManager() -> MenuManager {
        return ParseMenuManager()
    }
    
    override func createOrderManager() -> OrderManager {
        return ParseOrderManager()
    }
}
