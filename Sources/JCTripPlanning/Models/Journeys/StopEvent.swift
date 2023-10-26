//
//  StopEvent.swift
//
//
//  Created by Jerrycan Co Pty Ltd on 26/10/2023.
//

import Foundation

/// Represents an individual part of a `Leg`
///
/// If a user was travelling from Meadowbank to Town Hall, this object
/// might represent the train's stop at North Strathfield as part of the
/// Meadowbank -> Strathfield `Leg` of the `Journey`.
public struct StopEvent: Codable {
  public let stopID: Int
  public let stopName: String
  public let stopDetail: String
  public let departureTime: Int?
  public let arrivalTime: Int?
  public let stopSequence: Int
  public var delayed: Bool
  public var delay: Int

  public init(
    stopID: Int,
    stopName: String,
    stopDetail: String,
    departureTime: Int?,
    arrivalTime: Int?,
    stopSequence: Int,
    delayed: Bool,
    delay: Int
  ) {
    self.stopID = stopID
    self.stopName = stopName
    self.stopDetail = stopDetail
    self.departureTime = departureTime
    self.arrivalTime = arrivalTime
    self.stopSequence = stopSequence
    self.delayed = delayed
    self.delay = delay
  }

  public init?(openDataStopEvent: Journey.Responses.OpenData.StopEvent, stopSequence: Int) {
    guard
      let stringID = openDataStopEvent.id,
      let stopID = Int(stringID),
      let stopName = openDataStopEvent.disassembledName
    else {
      return nil
    }
    var departureTime: Int? = nil
    var arrivalTime: Int? = nil
    if let stringDeparture = openDataStopEvent.departureTimeEstimated {
      departureTime = DateHelper.secondsSinceMidnight(from: stringDeparture)
    } else if let stringDeparturePlanned = openDataStopEvent.departureTimePlanned {
      departureTime = DateHelper.secondsSinceMidnight(from: stringDeparturePlanned)
    }
    if let stringArrival = openDataStopEvent.arrivalTimeEstimated {
      arrivalTime = DateHelper.secondsSinceMidnight(from: stringArrival)
    } else if let stringArrivalPlanned = openDataStopEvent.arrivalTimePlanned {
      arrivalTime = DateHelper.secondsSinceMidnight(from: stringArrivalPlanned)
    }
    self.stopID = stopID
    self.stopName = stopName
    self.stopDetail = ""
    self.departureTime = departureTime
    self.arrivalTime = arrivalTime
    self.stopSequence = stopSequence
    self.delayed = false
    self.delay = 0
  }
}
