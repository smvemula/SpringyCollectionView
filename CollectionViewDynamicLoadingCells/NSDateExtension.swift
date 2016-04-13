//
//  NSDateExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 4/8/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation

extension NSDate {
    
    
    // DL Date functions
    class public func dateToDLTime(date:NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        let result = formatter.stringFromDate(date)
        
        return result
    }
    class public func convertArrayOfDaysOfWeekToIndexArray(daysOfWeek:[String]) -> [String]{
        let weekdaysArray = [NSLocalizedString("sunday", comment: "sunday"),NSLocalizedString("monday", comment: "monday"),NSLocalizedString("tuesday", comment: "tuesday"),NSLocalizedString("wednesday", comment: "wednesday"),NSLocalizedString("thursday", comment: "thursday"),NSLocalizedString("friday", comment: "friday"),NSLocalizedString("saturday", comment: "saturday")]
        var returnIndexes: [String] = []
        for day in daysOfWeek{
            if let indexExists = weekdaysArray.indexOfObject(weekdaysArray, object: day){
                returnIndexes += ["\(indexExists)"]
            }
        }
        
        return returnIndexes
    }
    
    class public func convertArrayOfIndexesToDaysOfWeekArray(indexes:[String],shortName: Bool) -> [String]{
        
        let formatter = NSDateFormatter()
        
        var weekdaysArray = [NSLocalizedString("sunday", comment: "sunday"),NSLocalizedString("monday", comment: "monday"),NSLocalizedString("tuesday", comment: "tuesday"),NSLocalizedString("wednesday", comment: "wednesday"),NSLocalizedString("thursday", comment: "thursday"),NSLocalizedString("friday", comment: "friday"),NSLocalizedString("saturday", comment: "saturday")]
        if(shortName){
            weekdaysArray = formatter.shortStandaloneWeekdaySymbols as [String]
        }
        var returnDays: [String] = []
        for index in indexes{
            if let asInt = Int(index) {
                returnDays += [weekdaysArray[asInt]]
                
            }
            
        }
        return returnDays
    }
    
    class public func makeTimeString(value: Int) -> String {
        let seconds = value
        
        let hrValue = seconds/3600
        let minValue = (seconds/60)%60
        
        let hourString = hrValue == 1 ? "hr" : "hrs"
        let minString = minValue == 1 ? "min" : "mins"
        
        var tempStr = ""
        if hrValue != 0 && minValue != 0 {
            tempStr = "\(hrValue) \(hourString) \(minValue) \(minString)"
            
        } else if hrValue == 0 && minValue != 0 {
            tempStr = "\(minValue) \(minString)"
            
        } else if hrValue != 0 && minValue == 0 {
            tempStr = "\(hrValue) \(hourString)"
            
        }
        
        return tempStr
    }
    
    class public func convertArrayOfIntIndexesToStringDaysOfWeekArray(indexes:[Int],shortName: Bool) -> [String]{
        
        let formatter = NSDateFormatter()
        
        var weekdaysArray = [NSLocalizedString("sunday", comment: "sunday"),NSLocalizedString("monday", comment: "monday"),NSLocalizedString("tuesday", comment: "tuesday"),NSLocalizedString("wednesday", comment: "wednesday"),NSLocalizedString("thursday", comment: "thursday"),NSLocalizedString("friday", comment: "friday"),NSLocalizedString("saturday", comment: "saturday")]
        if(shortName){
            weekdaysArray = formatter.shortStandaloneWeekdaySymbols as [String]
        }
        var returnDays: [String] = []
        for index in indexes{
            returnDays += [weekdaysArray[index]]
        }
        return returnDays
    }
    
    class public func dateFromStandardString(dateString:String) -> NSDate? {
        return dateFromString(dateString, format: "yyyy-MM-dd")
    }
    
    class public func standdardStringFromDate(date:NSDate) -> String {
        return stringFromDate(date, format: "yyyy-MM-dd")
    }
    
    // General Date functions
    class public func stringToLocalizedDate(dateString:String, dateFormat:String, tzName:String) -> NSDate {
        let aDate = NSDate.dateFromString(dateString, format: dateFormat)
        
        
        return aDate == nil ? dateToLocalizedDate(NSDate(), tzName: tzName) : dateToLocalizedDate(aDate!, tzName: tzName)
    }
    
    
    class public func dateFromMapKey(keyDate:String) -> NSDate? {
        return dateFromString(keyDate, format: "EEEE, MMMM dd, yyyy")
    }
    
    class public func stringForMapKey(date:NSDate) -> String {
        return stringFromDate(date, format: "EEEE, MMMM d, yyyy")
    }
    
    class public func convertStringDate(fromString:String,withFormat:String,toFormat:String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = withFormat
        
        let date = dateFormatter.dateFromString(fromString)
        dateFormatter.dateFormat = toFormat
        
        return date == nil ? "" : dateFormatter.stringFromDate(date!)
    }
    
    
    class public func stringFromDate(date:NSDate, format:String) -> String {
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.locale = NSLocale.currentLocale()
        newDateFormatter.dateFormat = format
        
        return newDateFormatter.stringFromDate(date)
    }
    
    class public func dateFromString(date:String?, format:String) -> NSDate? {
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = format
        
        var result:NSDate? = nil
        
        if let theDate = date {
            //var formattedDate = newDateFormatter.dateFromString(theDate)
            result = newDateFormatter.dateFromString(theDate)
        }
        
        return result
    }
    
    public class func dateToLocalizedDate(aDate:NSDate, tzName:String) -> NSDate {
        var result:NSDate?
        
        let timeZone:NSTimeZone? = NSTimeZone(name: tzName)
        if let tz = timeZone as NSTimeZone! {
            let seconds:NSTimeInterval = NSTimeInterval(tz.secondsFromGMT)
            result = NSDate(timeInterval: seconds, sinceDate: aDate)
        }
        
        return result == nil ? aDate : result!
    }
    
    public class func currentDLCTimeWithFormat(format:String) -> String{
        let today = NSDate()
        let dateFormatter = NSDateFormatter()
        let timezone = NSTimeZone.localTimeZone()
        
        dateFormatter.timeZone = timezone
        dateFormatter.dateFormat = format
        
        return dateFormatter.stringFromDate(today)
    }
    public class func dateToLocalizedDate(date:NSDate) -> NSDate {
        return NSDate.dateToLocalizedDate(date, tzName: "PST")
    }
    
    public class func doubleToLocalizedDate(gmtUnixEpoc:Double) -> NSDate {
        return dateToLocalizedDate(NSDate(timeIntervalSince1970: gmtUnixEpoc / 1000))
    }
    
    public class func getDefaultTimeUsingDate(date : NSDate, dateFormat:String) -> String {
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        //dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.stringFromDate(date)
    }
    
    public class func getDefaultTimeUsingGMTDoubleValue(GMTTime : Double, dateFormat:String) -> String {
        let timestamp : Double = GMTTime
        //timestamp = timestamp/1000
        let date : NSDate = NSDate(timeIntervalSince1970: timestamp/1000)
        
        return self.getDefaultTimeUsingDate(date, dateFormat: dateFormat)
    }
    
    public class func getStartOfDayOnDate(date:NSDate) -> NSDate {
        //default end date - TODAY
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var tempDate = dateFormatter.stringFromDate(date)
        tempDate = tempDate + " 00.01 AM"
        dateFormatter.dateFormat = "yyyy-MM-dd HH.mm aa"
        return dateFormatter.dateFromString(tempDate)!
    }
    
    public class func getEndOfDayOnDate(date:NSDate) -> NSDate {
        //default end date - TODAY
        let components = NSDateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endOfDay = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))
        return endOfDay!
    }
    
    public class func getAllDatesBetween(beginDate: NSDate, endDate: NSDate, incrementUnit:NSCalendarUnit, withWeekdayIndexFilter:[Int]?) -> [NSDate]{
        
        if(beginDate.compare(endDate) == NSComparisonResult.OrderedDescending){
            return []
        }
        
        let calendar = NSCalendar.currentCalendar()
        
        let returnDatesSet: NSMutableSet = NSMutableSet()
        if(incrementUnit == NSCalendarUnit.WeekOfYear){
            let dayComponent = calendar.components([.Weekday, .Year,.WeekOfYear], fromDate: beginDate)
            dayComponent.weekday = 1
            if let setToSundaydateExists = calendar.dateFromComponents(dayComponent){
                returnDatesSet.addObject(setToSundaydateExists)
            }
        }
        else{
            returnDatesSet.addObject(beginDate)
        }
        if let weekFilterExists = withWeekdayIndexFilter{
            let weekdayIndexBegin = calendar.component(NSCalendarUnit.Weekday, fromDate: beginDate)
            if weekFilterExists.contains((weekdayIndexBegin - 1)) {
                returnDatesSet.addObject(beginDate)
            }
        }
        
        let dayComponents = NSDateComponents()
        var numOfIncrement = 0
        while(true){
            
            switch(incrementUnit){
            case NSCalendarUnit.Year:
                dayComponents.year = ++numOfIncrement
            case NSCalendarUnit.Month:
                dayComponents.month = ++numOfIncrement
            case NSCalendarUnit.WeekOfYear:
                dayComponents.weekOfYear = ++numOfIncrement
            default:
                dayComponents.day = ++numOfIncrement
            }
            
            if var dateExists = calendar.dateByAddingComponents(dayComponents, toDate: beginDate, options: NSCalendarOptions(rawValue: 0)) {
                if(incrementUnit == NSCalendarUnit.WeekOfYear){
                    let dayComponent = calendar.components([.Weekday,.Year,.WeekOfYear], fromDate: dateExists)
                    dayComponent.weekday = 1
                    if let setToSundaydateExists = calendar.dateFromComponents(dayComponent){
                        dateExists = setToSundaydateExists
                    }
                }
                
                if(dateExists.compare(endDate) == NSComparisonResult.OrderedDescending){
                    break
                }
                
                if let weekFilterExists = withWeekdayIndexFilter{
                    let weekdayIndexBegin = calendar.component(.Weekday, fromDate: dateExists)
                    if weekFilterExists.contains((weekdayIndexBegin - 1)) {
                        //returnDates += [dateExists]
                        returnDatesSet.addObject(dateExists)
                    }
                }
                else{
                    returnDatesSet.addObject(dateExists)
                }
                
            }
        }
        let datesArray = returnDatesSet.allObjects as! [NSDate]
        return datesArray.sort{(date1, date2) -> Bool in
            return date1.compare(date2) == NSComparisonResult.OrderedAscending || date1.compare(date2) == NSComparisonResult.OrderedSame
        }
    }
}

//MARK: begin and end for date
public extension NSDate{
    
    public func isThisDateYesterday() -> Bool
    {
        //print("Yesterday Date : \(NSDate.getStartOfDayOnDate(NSDate(timeIntervalSinceNow: -1*24*60*60))) compare Date : \(date)")
        return NSDate.getStartOfDayOnDate(NSDate(timeIntervalSinceNow: -1*24*60*60)).compare(NSDate.getStartOfDayOnDate(self)) == NSComparisonResult.OrderedSame //&& NSDate.getStartOfDayOnDate(NSDate()).compare(date) == NSComparisonResult.OrderedAscending
    }
    
    public func isThisDateToday() -> Bool
    {
        //print("Today Date : \(NSDate()) compare Date : \(date)")
        _ = NSDate.getStartOfDayOnDate(NSDate()).compare(self) == NSComparisonResult.OrderedAscending
        _ = NSDate.getEndOfDayOnDate(NSDate()).compare(self) == NSComparisonResult.OrderedDescending
        return NSDate.getStartOfDayOnDate(NSDate()).compare(NSDate.getStartOfDayOnDate(self)) == NSComparisonResult.OrderedSame //|| (greaterThanStart && lesserThanEnd)
    }
    
    public class func isThisDateTomorrow(date : NSDate) -> Bool
    {
        return NSDate.getStartOfDayOnDate(NSDate(timeIntervalSinceNow: +1*24*60*60)).compare(NSDate.getStartOfDayOnDate(date)) == NSComparisonResult.OrderedSame //|| NSDate.getStartOfDayOnDate(NSDate()).compare(date) == NSComparisonResult.OrderedDescending
    }
    
    public func isThisDateFuture() -> Bool
    {
        return NSDate.getStartOfDayOnDate(NSDate(timeIntervalSinceNow: +1*24*60*60)).compare(NSDate.getStartOfDayOnDate(self)) == NSComparisonResult.OrderedSame || NSDate.getStartOfDayOnDate(NSDate(timeIntervalSinceNow: +1*24*60*60)).compare(self) == NSComparisonResult.OrderedAscending
    }
    
    public func isFuture() -> Bool
    {
        return NSDate().compare(self) == NSComparisonResult.OrderedAscending
    }
    
    
    public class func getBeginAndEndWeek(fromDate:NSDate) -> (begin:NSDate,end:NSDate)?{
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Weekday,.Year,.Month, .Day], fromDate: fromDate)
        dateComponents.day -= dateComponents.weekday - 1
        let begginningWeek = calendar.dateFromComponents(dateComponents)
        dateComponents.day += 7
        let endingWeek = calendar.dateFromComponents(dateComponents)
        if let begin = begginningWeek{
            if let end = endingWeek{
                return (begin, end)
            }
        }
        return nil
    }
    
    public class func getBeginAndEndMonth(fromDate:NSDate) -> (begin:NSDate,end:NSDate)?{
        let calendar = NSCalendar.currentCalendar()
        let monthDateComponents = calendar.components([.Weekday,.Year,.Month, .Day], fromDate: fromDate)
        monthDateComponents.day = 1
        let begMonth = calendar.dateFromComponents(monthDateComponents)
        monthDateComponents.month += 1
        let endMonth = calendar.dateFromComponents(monthDateComponents)
        if let begin = begMonth{
            if let end = endMonth{
                return (begin, end)
            }
        }
        return nil
    }
    
    public class func getBeginAndEndYear(fromDate:NSDate) -> (begin:NSDate,end:NSDate)?{
        let calendar = NSCalendar.currentCalendar()
        let yearDateComponents = calendar.components([.Weekday,.Year,.Month, .Day], fromDate: fromDate)
        yearDateComponents.month = 1
        yearDateComponents.day = 1
        let begYear = calendar.dateFromComponents(yearDateComponents)
        yearDateComponents.month += 12
        let endYear = calendar.dateFromComponents(yearDateComponents)
        if let begin = begYear{
            if let end = endYear{
                return (begin, end)
            }
        }
        return nil
    }

    class func getTodayAndYesterdayOfWeek()-> (String, String) {
    
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var date = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        var myComponents = myCalendar?.components(.Weekday, fromDate: date)
        let todayValue = myComponents?.weekday
        date = date.dateByAddingTimeInterval(-86400.0)
        myComponents = myCalendar?.components(.Weekday, fromDate: date)
        let yesterdayValue = myComponents?.weekday
        return (NSDate.getDayStringForIntValue(todayValue!), NSDate.getDayStringForIntValue(yesterdayValue!))
    }
    
    class func getDayStringForIntValue(dayInt : Int) -> String {
        switch (dayInt) {
        case 1:
            return "sunday"
        case 2:
            return "monday"
        case 3:
            return "tuesday"
        case 4:
            return "wednesday"
        case 5:
            return "thursday"
        case 6:
            return "friday"
        default:
            return "saturday"
        }
    }
}