//
//  DateUtility.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class DateUtility {
    
    class func isEqualDateComponent(date1 : NSDate, date2 : NSDate) -> Bool{
        
        // 日付部分が同一かどうか
        var unitFlags = NSCalendarUnit.CalendarUnitYear
            | NSCalendarUnit.CalendarUnitMonth
            | NSCalendarUnit.CalendarUnitDay
            | NSCalendarUnit.CalendarUnitTimeZone
        
        var compo1 = NSCalendar.currentCalendar().components(unitFlags, fromDate: date1)
        var compo2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: date2)
        
        compo1.timeZone = NSTimeZone.systemTimeZone()
        compo2.timeZone = NSTimeZone.systemTimeZone()
        
        return compo1.year == compo2.year && compo1.month == compo2.month && compo1.day == compo2.day
    }
    
    private class func edgeOfDay(date : NSDate, edgeString : String) -> NSDate {
        var formatterSrc = NSDateFormatter()
        formatterSrc.dateFormat = "yyyyMMdd"
        var dateStringSrc = formatterSrc.stringFromDate(date)
        
        var formatterDst = NSDateFormatter()
        formatterDst.dateFormat = "yyyyMMddHHmmssSSS"
        
        return formatterDst.dateFromString("\(dateStringSrc)\(edgeString)")!
    }
    
    class func firstEdgeOfDay(date : NSDate) -> NSDate {
        return edgeOfDay(date, edgeString: "000000000")
    }
    
    class func lastEdgeOfDay(date : NSDate) -> NSDate {
        return edgeOfDay(date, edgeString: "235959999")
    }
    
    class func dateFromSqliteDateTimeString(dateString : String) -> NSDate? {
        // TとZが不要なので消す
        var dateStringInner = (dateString as NSString).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "Z"))
        var index = dateString.rangeOfString("T", options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil)
        dateStringInner.replaceRange(index!, with: " ")
        
        var formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        var date = formatter.dateFromString(dateStringInner)
        
        return date
    }
    
    class func dateFromSqliteDateTimeString(jsonObject: NSDictionary, key: String) -> NSDate {
        return DateUtility.dateFromSqliteDateTimeString((jsonObject[key] as? NSString ?? "") as String) ?? NSDate(timeIntervalSince1970: 0)
    }
    
    class func dateFromSqliteDateString(dateString : String) -> NSDate? {
        var formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        var date = formatter.dateFromString(dateString)
        
        return date
    }

    class func localDateString(date : NSDate) -> String {
        var formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle;
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        formatter.locale = NSLocale.currentLocale()
        var dateStringSrc = formatter.stringFromDate(date)
        
        return dateStringSrc
    }
    
    class func localTimeString(date : NSDate) -> String {
        var formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.NoStyle;
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        formatter.locale = NSLocale.currentLocale()
        var dateStringSrc = formatter.stringFromDate(date)
        
        return dateStringSrc
    }
    
    class func minimumDate() -> NSDate {
        return NSDate(timeIntervalSince1970: 0)
    }
    
    class func railsLocalDateString(date : NSDate) -> String {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        formatter.locale = NSLocale.currentLocale()
        var dateStringSrc = formatter.stringFromDate(date)
        
        return dateStringSrc
    }
}
