//
//  DateUtility.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/03/28.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class DateUtility: NSObject {
    
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
   
}
