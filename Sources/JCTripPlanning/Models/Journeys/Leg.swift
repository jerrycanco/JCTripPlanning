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

  public init(
    coordinates: [[Double]],
    mode: String,
    tripID: String,
    departureStopID: Int,
    departureName: String,
    departureDetail: String,
    departureTime: Int,
    arrivalTime: Int,
    duration: Int,
    delayed: Bool,
    delay: Int,
    stopEvents: [StopEvent]
  ) {
    self.coordinates = coordinates
    self.mode = mode
    self.tripID = tripID
    self.departureStopID = departureStopID
    self.departureName = departureName
    self.departureDetail = departureDetail
    self.departureTime = departureTime
    self.arrivalTime = arrivalTime
    self.duration = duration
    self.delayed = delayed
    self.delay = delay
    self.stopEvents = stopEvents
  }

  public init?(openDataLeg: Journey.Responses.OpenData.Leg) {
    /// Remove transfers from the result
    if openDataLeg.transportation?.product?.class == 99 { return nil }
    let mode = Journey.mode(from: openDataLeg.transportation?.product?.class)
    let tripID = openDataLeg.transportation?.properties?.realtimeTripId ?? "Walk\(UUID().uuidString)"
    let departureStopID = Int(openDataLeg.origin?.id ?? "") ?? 0
    guard
      let departureTimeString = openDataLeg.origin?.departureTimeEstimated ?? openDataLeg.origin?.departureTimePlanned,
      let departureTime = DateHelper.secondsSinceMidnight(from: departureTimeString),
      let arrivalTimeString = openDataLeg.destination?.arrivalTimeEstimated ?? openDataLeg.destination?.arrivalTimePlanned,
      let arrivalTime = DateHelper.secondsSinceMidnight(from: arrivalTimeString)
    else { return nil }
    var departureName = ""
    var departureDetail = ""
    if
      let mode = openDataLeg.transportation?.product?.class,
      [1, 2, 4, 5, 7, 9, 11].contains(mode),
      let origin = openDataLeg.origin
    {
      departureName = Journey.name(for: origin, of: mode)
      if mode == 5 || mode == 7 || mode == 11 {
        if let routeNumber = openDataLeg.transportation?.number {
          departureDetail = "Route \(routeNumber)"
        }
      } else {
        departureDetail = Journey.detail(for: origin, of: mode)
      }
    } else {
      departureName = "Walk"
      if let distance = openDataLeg.distance {
        departureDetail = "\(distance) metres"
      } else {
        departureDetail = "See map for details"
      }
    }

    let duration = arrivalTime - departureTime
    let coordinates: [[Double]] = openDataLeg.coords ?? []

    var stopSequence: Int = 0
    let stopEvents = openDataLeg.stopSequence?.compactMap { stopEvent -> StopEvent? in
      guard let event = StopEvent(openDataStopEvent: stopEvent, stopSequence: stopSequence) else { return nil }
      stopSequence += 1
      return event
    }

    self.coordinates = coordinates
    self.mode = mode
    self.tripID = tripID
    self.departureStopID = departureStopID
    self.departureName = departureName
    self.departureDetail = departureDetail
    self.departureTime = departureTime
    self.arrivalTime = arrivalTime
    self.duration = duration
    self.delayed = false
    self.delay = 0
    self.stopEvents = stopEvents ?? []
  }
}
