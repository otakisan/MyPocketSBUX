//
//  StringExtension.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//
import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(args : [CVarArgType]) -> String {
        return String(format: self.localized(), arguments: args)
    }
    
    func toFloat() -> Float {
        return (self as NSString).floatValue
    }
    
    func toFloatToInt() -> Int? {
        return String(format: "%.0f", self.toFloat()).toInt()
    }
}
