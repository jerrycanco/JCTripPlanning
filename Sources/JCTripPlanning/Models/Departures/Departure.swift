//
//  Departure.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

public enum RealtimeStatus: String, Codable {
    case onTime
    case delayed
    case noRealtimeData
}

public struct Departure: Codable {
    public let departureStopID: Int
    public let departureStopName: String
    public let arrivalDetail: String
    public var departureTime: Int
    public let departureDate: Date
    public let routeID: String
    public let realtimeMessage: String
    public let realtimeStatus: RealtimeStatus
}

