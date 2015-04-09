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
    
    func prefecture() -> String {
        
        var address = self
        var resultPrefecture = ""
        
        //パターンから正規表現オブジェクト作成
        if let regex = NSRegularExpression(pattern: "[^\\d\\s-]+?[都道府県](?=\\s+)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil){
            //matchesにはマッチした文字列の位置情報が格納されている
            if var matches = regex.matchesInString(address, options: nil, range:NSMakeRange(0,  count(address))) as? Array<NSTextCheckingResult> {
                //のでそれをforで順番にとってきて利用
                if matches.count > 0 {
                    resultPrefecture = (address as NSString).substringWithRange(matches.first!.range)
                }
            }
        }
        
        return resultPrefecture
    }
}
