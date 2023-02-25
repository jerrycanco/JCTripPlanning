//
//  Date+Extension.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Date {
    static var secondsSinceMidnight: Int? {
        var cal = Calendar.init(identifier: .gregorian)
        guard let timeZone = TimeZone(identifier: "Australia/Sydney") else { return nil }
        cal.timeZone = timeZone
        let diffComponents = cal.dateComponents([.second], from: cal.startOfDay(for: Date()), to: Date())
        return diffComponents.second
    }
    
    static var yesterday: Date {
        var cal = Calendar.init(identifier: .gregorian)
        guard let timeZone = TimeZone(identifier: "Australia/Sydney") else { return Date() }
        cal.timeZone = timeZone
        return cal.date(byAdding: .day, value: -1, to: Date())!
    }
    
    static var tomorrow: Date {
        var cal = Calendar.init(identifier: .gregorian)
        guard let timeZone = TimeZone(identifier: "Australia/Sydney") else { return Date() }
        cal.timeZone = timeZone
        return cal.date(byAdding: .day, value: 1, to: Date())!
    }
    
    static var weekAway: Date {
        var cal = Calendar.init(identifier: .gregorian)
        guard let timeZone = TimeZone(identifier: "Australia/Sydney") else { return Date()}
        cal.timeZone = timeZone
        return cal.date(byAdding: .day, value: 7, to: Date())!
    }
    
    static var fortnightAway: Date {
        var cal = Calendar.init(identifier: .gregorian)
        guard let timeZone = TimeZone(identifier: "Australia/Sydney") else { return Date() }
        cal.timeZone = timeZone
        return cal.date(byAdding: .day, value: 14, to: Date())!
    }
    
    static var dateAsInt: Int? {
        let components = Calendar.current.dateComponents(in: TimeZone(identifier: "Australia/Sydney")!, from: Date())
        guard
            let year = components.year,
            let month = components.month,
            let day = components.day
        else {
            return nil
        }
        
        let string = "\(year)\(month < 10 ? "0" : "")\(month)\(day < 10 ? "0" : "")\(day)"
        return Int(string)
    }
    
    static var yesterdayAsInt: Int? {
        let components = Calendar.current.dateComponents(in: TimeZone(identifier: "Australia/Sydney")!, from: .yesterday)
        guard
            let year = components.year,
            let month = components.month,
            let day = components.day
        else {
            return nil
        }
        
        let string = "\(year)\(month < 10 ? "0" : "")\(month)\(day < 10 ? "0" : "")\(day)"
        return Int(string)
    }
    
    static var tomorrowAsInt: Int? {
        let components = Calendar.current.dateComponents(in: TimeZone(identifier: "Australia/Sydney")!, from: .tomorrow)
        guard
            let year = components.year,
            let month = components.month,
            let day = components.day
        else {
            return nil
        }
        
        let string = "\(year)\(month < 10 ? "0" : "")\(month)\(day < 10 ? "0" : "")\(day)"
        return Int(string)
    }
    
    static var weekAwayAsInt: Int? {
        let components = Calendar.current.dateComponents(in: TimeZone(identifier: "Australia/Sydney")!, from: .weekAway)
        guard
            let year = components.year,
            let month = components.month,
            let day = components.day
        else {
            return nil
        }
        
        let string = "\(year)\(month < 10 ? "0" : "")\(month)\(day < 10 ? "0" : "")\(day)"
        return Int(string)
    }
    
    static var fortnightAwayAsInt: Int? {
        let components = Calendar.current.dateComponents(in: TimeZone(identifier: "Australia/Sydney")!, from: .fortnightAway)
        guard
            let year = components.year,
            let month = components.month,
            let day = components.day
        else {
            return nil
        }
        
        let string = "\(year)\(month < 10 ? "0" : "")\(month)\(day < 10 ? "0" : "")\(day)"
        return Int(string)
    }
    
    static var timeAsInt: Int? {
        let components = Calendar.current.dateComponents(in: TimeZone(identifier: "Australia/Sydney")!, from: Date())
        guard
            let hour = components.hour,
            let minute = components.minute
        else {
            return nil
        }
        
        let string = "\(hour < 10 ? "0" : "")\(hour)\(minute < 10 ? "0" : "")\(minute)"
        return Int(string)
    }
}
