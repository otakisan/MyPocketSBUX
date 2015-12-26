//
//  BaseFactory.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class BaseFactory: NSObject {
    static var instance: BaseFactory = BaseFactory.createFactory()
    
    static func backendType() -> Backend {
        // TODO: 設定画面か、もしくはウェブ経由で値を取得するか
        return .Parse
    }
    
    static func createFactory() -> BaseFactory {
        switch(BaseFactory.backendType()) {
        case .Defalut:
            return BaseFactory()
        case .Parse:
            return ParseFactory()
        }
    }
    
    func createAppDelegeteBackend() -> UIApplicationDelegate? {
        return nil
    }
    
    func createAccountManager() -> AccountManager {
        return AccountManager()
    }
    
    func createPressReleaseManager() -> PressReleaseManager {
        return PressReleaseManager()
    }
    
    func createStoreManager() -> StoreManager {
        return StoreManager()
    }
    
    func createContentsManager() -> ContentsManager {
        return ContentsManager()
    }
    
    func createMenuManager() -> MenuManager {
        return MenuManager()
    }
    
    func createOrderManager() -> OrderManager {
        return OrderManager()
    }

    func createTastingLogManager() -> TastingLogManager {
        return TastingLogManager()
    }
    
}

enum Backend {
    case Defalut
    case Parse
}