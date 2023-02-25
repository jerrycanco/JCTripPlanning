//
//  DateHelper.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

final class DateHelper {
    
    static let queryStringDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        df.timeZone = TimeZone(identifier: "Australia/Sydney")!
        df.calendar = Calendar.current
        return df
    }()
    
    static let queryStringTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HHmm"
        df.timeZone = TimeZone(identifier: "Australia/Sydney")!
        df.calendar = Calendar.current
        return df
    }()

    static let utcDF: DateFormatter = {
        let d = DateFormatter()
        d.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        d.timeZone = TimeZone(abbreviation: "UTC")
        return d
    }()

    private static var sydneyDF: DateFormatter {
        let d = DateFormatter()
        d.timeZone = TimeZone(identifier: "Australia/Sydney")
        d.dateFormat = "yyyyMMdd:HH:mm:ss"
        return d
    }

    private static let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter
    }()

    private static let utcDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()

    private static let durationFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()

    static func timetableString(_ from: Date) -> String {
        timeFormatter.string(from: from)
    }
    
    /// Needs to take into account that departures after midnight are included
    /// in previous service day.
    ///
    /// - Note: This converter is for data received direct from TFNSW. All
    /// times for GTFS data are calculated separately as they come in a local
    /// string format.
    static func secondsSinceMidnight(from tfnswDate: String) -> Int? {
        guard let date = utcDF.date(from: tfnswDate) else { return nil }
        
        // Use the year, month and day to differentiate midnight
        // Year is required in case bus trip is being planned on
        // Dec 31.
        let localString = sydneyDF.string(from: date)
        let components = localString.components(separatedBy: ":")
        guard
            components.count == 4,
            let yearMonthDay = Int(components[0]),
            let hours = Int(components[1]),
            let minutes = Int(components[2]),
            let seconds = Int(components[3])
        else {
            return nil
        }
        
        let todayString = sydneyDF.string(from: Date())
        let todayComponents = todayString.components(separatedBy: ":")
        guard
            todayComponents.count == 4,
            let todayYearMonthDay = Int(todayComponents[0])
        else {
            return nil
        }
        
        if yearMonthDay > todayYearMonthDay {
            return (((hours + 24) * 3600) + (minutes * 60) + (seconds))
        } else {
            return ((hours * 3600) + (minutes * 60) + (seconds))
        }
    }
    
    static func departureDate(from tfnswDate: String) -> Date? {
        guard let absoluteDate = utcDF.date(from: tfnswDate) else { return nil }
        let string = sydneyDF.string(from: absoluteDate)
        return sydneyDF.date(from: string)
    }
}


