//
//  Departure.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

enum RealtimeStatus: String, Codable {
    case onTime
    case delayed
    case noRealtimeData
}

struct Departure: Codable {
    let departureStopID: Int
    let departureStopName: String
    let arrivalDetail: String
    var departureTime: Int
    let departureDate: Date
    let routeID: String
    let realtimeMessage: String
    let realtimeStatus: RealtimeStatus
}

