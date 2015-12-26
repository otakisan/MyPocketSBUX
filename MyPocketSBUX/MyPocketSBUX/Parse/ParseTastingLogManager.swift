//
//  ParseTastingLogManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse

class ParseTastingLogManager: TastingLogManager {
    override func fetchFullSizeImage(id: Int, completion: ((Bool, NSData?) -> Void)?) {
        ParseUtility.instance.fetchTastingLogInBackgroundWithBlock(id) { (pfObject, error) -> Void in
            if let tastingLog = pfObject, let fullSizeImageFile = tastingLog[tastingLogPhotoKey] as? PFFile {
                fullSizeImageFile.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                    completion?(error == nil, imageData)
                })
            }else{
                completion?(false, nil)
            }
        }
    }
}
