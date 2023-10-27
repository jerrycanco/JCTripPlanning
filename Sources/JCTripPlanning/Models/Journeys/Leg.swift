//
//  Leg.swift
//
//
//  Created by Jerrycan Co Pty Ltd on 26/10/2023.
//

import Foundation

/// An object representing a single leg of a `Journey`.
///
/// If a user was travelling from Paddington Public School
/// to Strathfield, the bus from Paddington to Museum Station
/// would be considered a `Leg`.
///
/// - Parameters:
///   - id: Used for Identifiable conformance
///   - coordinates: Array of lat longs for this leg
///   - mode: The type of vehicle (train, bus etc) or walk
///   - tripID: The TFNSW realtime TripID
///   - departureStopID: The stopID for the first `StopEvent` in this leg
///   - departureName: The name of the stop for the first `StopEvent` in this leg
///   - departureDetail: The platform etc for the first `StopEvent` in this leg
///   - departureTime: The time of departure from the first `StopEvent` in this leg
///   - arrivalTime: The time of arrival at the last `StopEvent` in this leg
///   - duration: The length of this leg measured in seconds
///   - delayed: Boolean indicator of whether this leg is delayed
///   - delay: The amount of any delay, measured in seconds
///   - stopEvents: The individual stop events that make up this leg
public struct Leg: Codable, Identifiable {
  public var id: Int { departureStopID }
  public let coordinates: [[Double]]
  public let mode: String
  public let tripID: String
  public let departureStopID: Int
  public let departureName: String
  public let departureDetail: String
  public let departureTime: Int
  public let arrivalTime: Int
  public let duration: Int
  public var delayed: Bool
  public var delay: Int
  public let stopEvents: [StopEvent]

  public var actualDepartureTime: Int { departureTime + delay }
  public var actualArrivalTime: Int { arrivalTime + delay }
}
