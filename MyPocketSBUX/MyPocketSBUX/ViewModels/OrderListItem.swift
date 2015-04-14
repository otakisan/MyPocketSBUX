//
//  OrderListItem.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/04/13.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

// 同一構成のオーダーでも別インスタンスにする
// インスタンスが実際の商品と対応する形
class OrderListItem: NSObject {
    var on : Bool = false
    var productEntity : AnyObject?
    var customizationItems : [AnyObject] = []
    var nutritionEntities : [AnyObject] = []

    var size : String = ""
    var hotOrIce : String = ""
}
