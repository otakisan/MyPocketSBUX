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
    
    func emptyIfNa() -> String {
        return self == "na" ? "" : self
    }
    
    func camelCaseFromSnakeCase() -> String {
        let pattern = "(\\w{0,1})_"
        var camel = self.capitalizedString.stringByReplacingOccurrencesOfString(pattern, withString: "$1",
            options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        
        // make the first letter lower case
        let head = self.substringToIndex(advance(self.startIndex, 1))
        camel.replaceRange(camel.startIndex...camel.startIndex, with: head.lowercaseString)
        
        return camel
    }
    
    func snakeCase() -> String {
        return self.stringByReplacingOccurrencesOfString("([A-Z])", withString:"_$1", options:NSStringCompareOptions.RegularExpressionSearch, range: nil).lowercaseString
    }
    
    func contains(compare: String) -> Bool {
        return self.rangeOfString(compare, options: NSStringCompareOptions.allZeros, range: nil, locale: nil) != nil
    }
}
