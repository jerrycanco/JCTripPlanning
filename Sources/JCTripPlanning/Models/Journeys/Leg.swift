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
public struct Leg: Codable {
  public let coordinates: [[Double]]
  public let mode: String
  public let tripID: String
  public let departureName: String
  public let departureDetail: String
  public let departureTime: Int
  public let departureStopID: Int
  public let duration: Int
  public var delayed: Bool
  public var delay: Int
  public let stopEvents: [StopEvent]
}

