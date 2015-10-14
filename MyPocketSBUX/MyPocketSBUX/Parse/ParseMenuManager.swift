//
//  ParseMenuManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/26.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ParseMenuManager: MenuManager {

    // TODO: 要実装
    override func updateProductLocalDb(productCategory: String, completionHandler: ((NSError?) -> Void)) {
        ContentsManager.instance.fetchContentsFromWebAndStoreLocalDb(productCategory, isRefresh: true, completionHandler: {
            completionHandler(nil)
        })
    }
}
