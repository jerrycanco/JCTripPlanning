//
//  Journey.swift
//
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation
import JCLogKit

public struct Journey: Codable {
  public let departureName: String
  public let departureDetail: String
  public let departureTime: Int
  public let departureDate: Date
  public let arrivalName: String
  public let arrivalDetail: String
  public let arrivalTime: Int
  public let duration: Int
  public let realtimeMessage: String
  public let delayed: Bool
  public var legs: [Leg]

  // MARK: TFNSW Website Initialiser

  public init?(tfnswJourney: Journey.Responses.TFNSW.TFNSWJourney) {
    let publicTransportLegs = tfnswJourney.legs
    /// Regardless of the mode, departure time is assessed against the
    /// first leg of the journey to ensure only future journeys (departing
    /// from 30 seconds time) are returned.
    guard
      !publicTransportLegs.isEmpty,
      let departure = publicTransportLegs.first,
      let departureTime = DateHelper.secondsSinceMidnight(from: departure.departingTime),
      let departureDate = DateHelper.departureDate(from: departure.departingTime),
      departureTime > ((Date.secondsSinceMidnight ?? 0) + 30)
    else {
      return nil
    }

    var realtimeMessage = "On time"
    var delayed = false
    if
      let scheduledDeparture = DateHelper.departureDate(from: departure.departingTimePlanned),
      departureDate.timeIntervalSince(scheduledDeparture) > 10,
      let scheduledDepartureTime = DateHelper.secondsSinceMidnight(from: departure.departingTimePlanned)
    {
      delayed = true
      let scheduledDepartureTimeString = DateHelper.timetableString(scheduledDepartureTime.formattedTime)
      let minutesDelay = departureDate.timeIntervalSince(scheduledDeparture)
      let delayString = Int(minutesDelay).waitTime
      realtimeMessage = "\(scheduledDepartureTimeString) service running \(delayString) late"
    }

    /// The Journey Departure details displayed client-side come from the
    /// first leg that isn't a walking leg. If for some reason the user plans
    /// a trip that only requires walking, make a common sense default.
    var departureName = ""
    var departureDetail = ""
    if let firstPTLeg = publicTransportLegs.first(where: { $0.isPublicTransport == true }) {
      let mode = firstPTLeg.transportation.mode
      departureName = Journey.name(for: firstPTLeg.origin, of: mode)
      if mode == 5 || mode == 7 || mode == 11 {
        if let routeNumber = firstPTLeg.transportation.routeNumber {
          departureDetail = "Route \(routeNumber)"
        }
      } else {
        departureDetail = Journey.detail(for: firstPTLeg.origin, of: mode)
      }
    } else {
      departureName = "Walk"
      if let distance = departure.distance {
        departureDetail = "\(distance) metres"
      } else {
        departureDetail = "See map for details"
      }
    }

    /// Journey Arrival details
    let arrival = publicTransportLegs[publicTransportLegs.count - 1]
    let arrivalName = Journey.name(for: arrival.destination, of: arrival.transportation.mode)
    let arrivalDetail = Journey.detail(for: arrival.destination, of: arrival.transportation.mode)
    guard let arrivalTime = DateHelper.secondsSinceMidnight(from: arrival.arrivalTime) else { return nil }
    let duration = tfnswJourney.duration

    /// Parse legs into separate trips in order to provide realtime
    /// updates. Walking legs are given a UUID addition as a tripID
    /// so that tripIDs can be combined as an identifier to uniquely
    /// identify a journey and cache it client-side.
    let legs = publicTransportLegs.compactMap { ptLeg -> Leg? in
      /// Remove transfers from the result
      if ptLeg.transportation.mode == 99 { return nil }
      let mode = Journey.mode(from: ptLeg.transportation.mode)
      let tripID = ptLeg.transportation.realtimeTripId ?? "Walk\(UUID().uuidString)"
      let departureStopID = Int(ptLeg.origin.id ?? "") ?? 0
      guard
        let departureTime = DateHelper.secondsSinceMidnight(from: ptLeg.departingTime),
        let arrivalTime = DateHelper.secondsSinceMidnight(from: ptLeg.arrivalTime)
      else { return nil }
      var departureName = ""
      var departureDetail = ""
      if ptLeg.isPublicTransport == true {
        let mode = ptLeg.transportation.mode
        departureName = Journey.name(for: ptLeg.origin, of: mode)
        if mode == 5 || mode == 7 || mode == 11 {
          if let routeNumber = ptLeg.transportation.routeNumber {
            departureDetail = "Route \(routeNumber)"
          }
        } else {
          departureDetail = Journey.detail(for: ptLeg.origin, of: mode)
        }
      } else {
        departureName = "Walk"
        if let distance = ptLeg.distance {
          departureDetail = "\(distance) metres"
        } else {
          departureDetail = "See map for details"
        }
      }

      let duration = arrivalTime - departureTime
      let coordinates: [[Double]] = ptLeg.coordinates ?? []

      var stopSequence: Int = 0
      let stopEvents = ptLeg.stopSequence?.compactMap { stopEvent -> StopEvent? in
        guard
          let stringID = stopEvent.id,
          let stopID = Int(stringID),
          let stopName = stopEvent.disassembledName
        else {
          return nil
        }
        var departureTime: Int? = nil
        var arrivalTime: Int? = nil
        if let stringDeparture = stopEvent.departureTimeEstimated {
          departureTime = DateHelper.secondsSinceMidnight(from: stringDeparture)
        } else if let stringDeparturePlanned = stopEvent.departureTimePlanned {
          departureTime = DateHelper.secondsSinceMidnight(from: stringDeparturePlanned)
        }
        if let stringArrival = stopEvent.arrivalTimeEstimated {
          arrivalTime = DateHelper.secondsSinceMidnight(from: stringArrival)
        } else if let stringArrivalPlanned = stopEvent.arrivalTimePlanned {
          arrivalTime = DateHelper.secondsSinceMidnight(from: stringArrivalPlanned)
        }
        let stopEvent = StopEvent(stopID: stopID,
                                  stopName: stopName,
                                  stopDetail: "",
                                  departureTime: departureTime,
                                  arrivalTime: arrivalTime,
                                  stopSequence: stopSequence,
                                  delayed: false,
                                  delay: 0)
        stopSequence += 1
        return stopEvent
      }

      return Leg(coordinates: coordinates,
                 mode: mode,
                 tripID: tripID,
                 departureStopID: departureStopID,
                 departureName: departureName,
                 departureDetail: departureDetail,
                 departureTime: departureTime,
                 arrivalTime: arrivalTime,
                 duration: duration,
                 delayed: false,
                 delay: 0,
                 stopEvents: stopEvents ?? [])
    }
    self.departureName = departureName
    self.departureDetail = departureDetail
    self.departureTime = departureTime
    self.departureDate = departureDate
    self.arrivalName = arrivalName
    self.arrivalDetail = arrivalDetail
    self.arrivalTime = arrivalTime
    self.duration = duration
    self.realtimeMessage = realtimeMessage
    self.delayed = delayed
    self.legs = legs
  }

  // MARK: OpenData API Initialiser

  public init?(openDataJourney: Journey.Responses.OpenData.Journey) {
    /// Regardless of the mode, departure time is assessed against the
    /// first leg of the journey to ensure only future journeys (departing
    /// from 30 seconds time) are returned.
    guard
      let rawLegs = openDataJourney.legs,
      !rawLegs.isEmpty,
      let departureLeg = rawLegs.first,
      let origin = departureLeg.origin,
      let plannedDepartureTimeString = origin.departureTimePlanned,
      let plannedDepartureTime = DateHelper.secondsSinceMidnight(from: plannedDepartureTimeString),
      let plannedDepartureDate = DateHelper.departureDate(from: plannedDepartureTimeString),
      plannedDepartureTime > ((Date.secondsSinceMidnight ?? 0) + 30)
    else {
      JCLogKit.add("Invalid or missing departure details.\nOffending Leg:\n\(String(describing: openDataJourney.legs?.first))", type: .info, category: .businessLogic)
      return nil
    }

    var departureDate = plannedDepartureDate
    var departureTime = plannedDepartureTime
    var realtimeMessage = "On time"
    var delayed = false
    if
      let estimatedDepartureTimeString = origin.departureTimeEstimated,
      let estimatedDepartureTime = DateHelper.secondsSinceMidnight(from: estimatedDepartureTimeString),
      let estimatedDepartureDate = DateHelper.departureDate(from: estimatedDepartureTimeString),
      estimatedDepartureDate.timeIntervalSince(plannedDepartureDate) > 10
    {
      delayed = true
      departureTime = estimatedDepartureTime
      departureDate = estimatedDepartureDate
      let scheduledDepartureTimeString = DateHelper.timetableString(plannedDepartureTime.formattedTime)
      let minutesDelay = estimatedDepartureDate.timeIntervalSince(plannedDepartureDate)
      let delayString = Int(minutesDelay).waitTime
      realtimeMessage = "\(scheduledDepartureTimeString) service running \(delayString) late"
    }

    /// The Journey Departure details displayed client-side come from the
    /// first leg that isn't a walking leg. If for some reason the user plans
    /// a trip that only requires walking, make a common sense default.
    var departureName = ""
    var departureDetail = ""
    if
      let firstPTLeg = rawLegs.first(where: { [1, 2, 4, 5, 7, 9, 11].contains($0.transportation?.product?.class) }),
      let mode = firstPTLeg.transportation?.product?.class,
      let origin = firstPTLeg.origin
    {
      departureName = Journey.name(for: origin, of: mode)
      if mode == 5 || mode == 7 || mode == 11 {
        if let routeNumber = firstPTLeg.transportation?.number {
          departureDetail = "Route \(routeNumber)"
        }
      } else {
        departureDetail = Journey.detail(for: origin, of: mode)
      }
    } else {
      departureName = "Walk"
      if let distance = departureLeg.distance {
        departureDetail = "\(distance) metres"
      } else {
        departureDetail = "See map for details"
      }
    }

    /// Journey Arrival details
    let arrivalLeg = rawLegs[rawLegs.count - 1]
    guard
      let destination = arrivalLeg.destination,
      let mode = arrivalLeg.transportation?.product?.class,
      let arrivalTimeEstimated = destination.arrivalTimeEstimated
    else {
      JCLogKit.add("Invalid or missing arrival details.\nOffending Leg:\n\(arrivalLeg)", type: .info, category: .businessLogic)
      return nil
    }
    let arrivalName = Journey.name(for: destination, of: mode)
    let arrivalDetail = Journey.detail(for: destination, of: mode)
    guard let arrivalTime = DateHelper.secondsSinceMidnight(from: arrivalTimeEstimated) else { return nil }
    let duration = rawLegs.reduce(0, { $0 + ($1.duration ?? 0) })

    /// Parse legs into separate trips in order to provide realtime
    /// updates. Walking legs are given a UUID addition as a tripID
    /// so that tripIDs can be combined as an identifier to uniquely
    /// identify a journey and cache it client-side.
    let legs = rawLegs.compactMap { rawLeg -> Leg? in
      /// Remove transfers from the result
      if rawLeg.transportation?.product?.class == 99 { return nil }
      let mode = Journey.mode(from: rawLeg.transportation?.product?.class)
      let tripID = rawLeg.transportation?.properties?.realtimeTripId ?? "Walk\(UUID().uuidString)"
      let departureStopID = Int(rawLeg.origin?.id ?? "") ?? 0
      guard
        let departureTimeString = rawLeg.origin?.departureTimeEstimated ?? rawLeg.origin?.departureTimePlanned,
        let departureTime = DateHelper.secondsSinceMidnight(from: departureTimeString),
        let arrivalTimeString = rawLeg.destination?.arrivalTimeEstimated ?? rawLeg.destination?.arrivalTimePlanned,
        let arrivalTime = DateHelper.secondsSinceMidnight(from: arrivalTimeString)
      else { return nil }
      var departureName = ""
      var departureDetail = ""
      if
        let mode = rawLeg.transportation?.product?.class,
        [1, 2, 4, 5, 7, 9, 11].contains(mode),
        let origin = rawLeg.origin
      {
        departureName = Journey.name(for: origin, of: mode)
        if mode == 5 || mode == 7 || mode == 11 {
          if let routeNumber = rawLeg.transportation?.number {
            departureDetail = "Route \(routeNumber)"
          }
        } else {
          departureDetail = Journey.detail(for: origin, of: mode)
        }
      } else {
        departureName = "Walk"
        if let distance = rawLeg.distance {
          departureDetail = "\(distance) metres"
        } else {
          departureDetail = "See map for details"
        }
      }

      let duration = arrivalTime - departureTime
      let coordinates: [[Double]] = rawLeg.coords ?? []

      var stopSequence: Int = 0
      let stopEvents = rawLeg.stopSequence?.compactMap { stopEvent -> StopEvent? in
        guard let event = StopEvent(openDataStopEvent: stopEvent, stopSequence: stopSequence) else { return nil }
        stopSequence += 1
        return event
      }

      return Leg(coordinates: coordinates,
                 mode: mode,
                 tripID: tripID,
                 departureStopID: departureStopID,
                 departureName: departureName,
                 departureDetail: departureDetail,
                 departureTime: departureTime,
                 arrivalTime: arrivalTime,
                 duration: duration,
                 delayed: false,
                 delay: 0,
                 stopEvents: stopEvents ?? [])
    }
    self.departureName = departureName
    self.departureDetail = departureDetail
    self.departureTime = departureTime
    self.departureDate = departureDate
    self.arrivalName = arrivalName
    self.arrivalDetail = arrivalDetail
    self.arrivalTime = arrivalTime
    self.duration = duration
    self.realtimeMessage = realtimeMessage
    self.delayed = delayed
    self.legs = legs
  }

  // MARK: Helper Methods

  private static func mode(from tfnswMode: Int?) -> String {
    switch tfnswMode {
    case 1: return "train"
    case 2: return "metro"
    case 4: return "lightRail"
    case 5: return "bus"
    case 7: return "bus" // coach
    case 9: return "ferry"
    case 11: return "bus" // school
    case 10, 100: return "foot"
    default: return ""
    }
  }

  private static func name(for stopEvent: Journey.Responses.TFNSW.TFNSWJourneyStopEvent, of tfnswMode: Int? = nil) -> String {
    guard let input = stopEvent.disassembledName ?? stopEvent.name else { return "" }
    switch tfnswMode {
      // Train and Metro
      // "Flemington Station, Platform 4"
    case 1, 2:
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
      // Light Rail
    case 4:
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
      // Bus and Coach and School Bus
      // "Herring Rd before Bridge Rd"
    case 5, 7, 11:
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
      // Ferry
      // "Meadowbank Wharf, Bowden St"
    case 9:
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
    case 100: return "Walk"
    default: return input
    }
  }

  private static func name(for stopEvent: Journey.Responses.OpenData.StopEvent, of tfnswMode: Int? = nil) -> String {
    guard let input = stopEvent.disassembledName ?? stopEvent.name else { return "" }
    switch tfnswMode {
      // Train and Metro
      // "Flemington Station, Platform 4"
    case 1, 2:
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
      // Light Rail
    case 4:
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
      // Bus and Coach and School Bus
      // "Herring Rd before Bridge Rd"
    case 5, 7, 11:
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
      // Ferry
      // "Meadowbank Wharf, Bowden St"
    case 9:
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
    case 100: return "Walk"
    default: return input
    }
  }

  private static func detail(for stopEvent: Journey.Responses.TFNSW.TFNSWJourneyStopEvent, of tfnswMode: Int? = nil) -> String {
    switch tfnswMode {
      // Train and Metro
      // "Flemington Station, Platform 4"
    case 1, 2:
      guard let input = stopEvent.disassembledName else { return "" }
      let parts = input.components(separatedBy: ", ")
      guard parts.count == 2 else { return input }
      return parts[1]
      // Light Rail
    case 4:
      guard let input = stopEvent.name else { return "" }
      let parts = input.components(separatedBy: ", ")
      guard parts.count > 1 else { return input }
      return parts[1]
      // Bus and Coach and School Bus
      // "Herring Rd before Bridge Rd"
    case 5, 7, 11:
      guard let input = stopEvent.name else { return "" }
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
      // Ferry
      // "Sydney Olympic Park Wharf, Side A"
      // "Circular Quay, Wharf 5, Side B"
    case 9:
      guard let input = stopEvent.disassembledName else { return "" }
      let parts = input.components(separatedBy: ", ")
      guard parts.count > 1 else { return input }
      return parts[1]
    default: return stopEvent.disassembledName ?? stopEvent.name ?? ""
    }
  }

  private static func detail(for stopEvent: Journey.Responses.OpenData.StopEvent, of tfnswMode: Int? = nil) -> String {
    switch tfnswMode {
      // Train and Metro
      // "Flemington Station, Platform 4"
    case 1, 2:
      guard let input = stopEvent.disassembledName else { return "" }
      let parts = input.components(separatedBy: ", ")
      guard parts.count == 2 else { return input }
      return parts[1]
      // Light Rail
    case 4:
      guard let input = stopEvent.name else { return "" }
      let parts = input.components(separatedBy: ", ")
      guard parts.count > 1 else { return input }
      return parts[1]
      // Bus and Coach and School Bus
      // "Herring Rd before Bridge Rd"
    case 5, 7, 11:
      guard let input = stopEvent.name else { return "" }
      let parts = input.components(separatedBy: ", ")
      guard !parts.isEmpty else { return input }
      return parts[0]
      // Ferry
      // "Sydney Olympic Park Wharf, Side A"
      // "Circular Quay, Wharf 5, Side B"
    case 9:
      guard let input = stopEvent.disassembledName else { return "" }
      let parts = input.components(separatedBy: ", ")
      guard parts.count > 1 else { return input }
      return parts[1]
    default: return stopEvent.disassembledName ?? stopEvent.name ?? ""
    }
  }
}
