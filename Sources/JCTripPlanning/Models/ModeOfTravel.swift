//
//  ModeOfTravel.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

public enum ModeOfTravel: String, Codable, CaseIterable, Sendable {
    case train = "train"
    case bus = "bus"
    case lightRail = "lightRail"
    case ferry = "ferry"
    case metro = "metro"
    case foot = "foot"
    case multiple = "multiple"
    
    var displayName: String {
        switch self {
        case .train: return "Train"
        case .bus: return "Bus"
        case .lightRail: return "Light Rail"
        case .ferry: return "Ferry"
        case .metro: return "Metro"
        case .foot: return "Walk"
        case .multiple: return ""
        }
    }
}
