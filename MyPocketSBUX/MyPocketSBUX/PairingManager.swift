//
//  PairingManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class PairingManager: NSObject {
    static let instance = PairingManager()
    
    // TODO: Pairing.beanでソート済みのある必要あり
    func arrayOfBeanToFoods(pairings: [Pairing]) -> [(bean: Bean, foods: [Food])] {
        var categorized : [(bean: Bean, foods: [Food])] = []
        
        var previousBeanId = -1
        for pairing in pairings {
            if let bean = pairing.bean {
                var beanAndFoods : (bean: Bean, foods: [Food])
                if bean.id != previousBeanId {
                    previousBeanId = Int(bean.id)
                    beanAndFoods = (bean, [Food]())
                    categorized += [beanAndFoods]
                }
                
                if let food = pairing.food {
                    categorized[categorized.endIndex - 1].foods += [food]
                }
            }
        }
        
        return categorized
    }
}
