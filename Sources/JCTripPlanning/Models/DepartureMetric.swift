//
//  DepartureMetric.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

public enum DepartureMetric: String, Codable, Sendable {
    case immediately
    case departingAfter
    case arrivingBefore
}
