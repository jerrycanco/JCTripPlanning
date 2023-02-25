//
//  NumbersHelper.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Int {
    static func make(_ string: String?) -> Int? {
        if let string = string {
            return Int(string)
        } else {
            return nil
        }
    }
    
    var formattedTime: Date {
        return Calendar.current.date(
            byAdding: .second,
            value: self,
            to: Calendar.current.startOfDay(for: Date())) ?? Date()
    }
    
    var waitTime: String {
        let minutes = Int(self / 60)
        switch minutes {
        case ..<0: return "Dep"
        case 0: return "< 1m"
        case 1...99: return "\(minutes) min"
        case 100...119:
            let min = minutes - 60
            return "1h \(min)m"
        case 120: return "2h"
        case 121...179:
            let min = minutes - 120
            return "2h \(min)m"
        case 180: return "3h"
        case 181...239:
            let min = minutes - 180
            return "3h \(min)m"
        case 240: return "4h"
        case 241...299:
            let min = minutes - 240
            return "4h \(min)m"
        default: return "> 5h"
        }
    }
}

extension Double {
    static func make(_ string: String?) -> Double? {
        if let string = string {
            return Double(string)
        } else {
            return nil
        }
    }
}
