//
//  Journey+Responses.swift
//
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Journey {

  public struct Responses {

    public struct OpenData {

      public struct JourneysResponse: Decodable {
        public let error: Error?
        public let journeys: [Journey]?
        public let systemMessages: [SystemMessages]?
        public let version: String?
      }

      // MARK: - Error
      public struct Error: Decodable {
        public let message: String?
        public let versions: Versions?
      }

      // MARK: - Versions
      public struct Versions: Decodable {
        public let controller, interfaceMax, interfaceMin: String?
      }

      // MARK: - Journey
      public struct Journey: Decodable {
        public let isAdditional: Bool?
        public let legs: [Leg]?
        public let rating: Int?
      }

      // MARK: - Leg
      public struct Leg: Decodable {
        public let coords: [[Double]]?
        public let destination: StopEvent?
        public let distance, duration: Int?
        public let footPathInfo: [FootPathInfo]?
        public let hints: [Hint]?
        public let infos: [Info]?
        public let interchange: Interchange?
        public let isRealtimeControlled: Bool?
        public let origin: StopEvent?
        public let pathDescriptions: [PathDescription]?
        public let properties: LegProperties?
        public let stopSequence: [StopEvent]?
        public let transportation: Transportation?
      }

      // MARK: - StopSequenceClass
      public struct StopEvent: Decodable {
        public let arrivalTimeEstimated, arrivalTimePlanned: String?
        public let coord: [Double]?
        public let departureTimeEstimated, departureTimePlanned, disassembledName, id: String?
        public let name: String?
        public let parent: Parent?
        public let properties: DestinationProperties?
        public let type: String?
      }

      // MARK: - Parent
      public struct Parent: Decodable {
        public let disassembledName, id, name: String?
        public let parent: ParentParent?
        public let type: String?
      }

      public struct ParentParent: Decodable {}

      // MARK: - DestinationProperties
      public struct DestinationProperties: Decodable {
        public let wheelchairAccess: String?
        public let downloads: [Download]?
      }

      // MARK: - Download
      public struct Download: Decodable {
        public let type, url: String?
      }

      // MARK: - FootPathInfo
      public struct FootPathInfo: Decodable {
        public let duration: Int?
        public let footPathElem: [FootPathElem]?
        public let position: String?
      }

      // MARK: - FootPathElem
      public struct FootPathElem: Decodable {
        public let description: String?
        public let destination: FootPathElemDestination?
        public let level: String?
        public let levelFrom, levelTo: Int?
        public let origin: FootPathElemDestination?
        public let type: String?
      }

      // MARK: - FootPathElemDestination
      public struct FootPathElemDestination: Decodable {
        public let area: Int?
        public let georef: String?
        public let location: Location?
        public let platform: Int?
      }

      // MARK: - Location
      public struct Location: Decodable {
        public let coord: [Double]?
        public let id, type: String?
      }

      // MARK: - Hint
      public struct Hint: Decodable {
        public let infoText: String?
      }

      // MARK: - Info
      public struct Info: Decodable {
        public let content, id, priority, subtitle: String?
        public let timestamps: Timestamps?
        public let url, urlText: String?
        public let version: String?
      }

      // MARK: - Timestamps
      public struct Timestamps: Decodable {
        public let availability: Ity?
        public let creation, lastModification: String?
        public let validity: [Ity]?
      }

      // MARK: - Ity
      public struct Ity: Decodable {
        public let from, to: String?
      }

      // MARK: - Interchange
      public struct Interchange: Decodable {
        public let coords: [[Double]]?
        public let desc: String?
        public let type: Int?
      }

      // MARK: - PathDescription
      public struct PathDescription: Decodable {
        public let coord: [Double]?
        public let cumDistance, cumDuration, distance, distanceDown: Int?
        public let distanceUp, duration, fromCoordsIndex: Int?
        public let manoeuvre, name: String?
        public let skyDirection, toCoordsIndex: Int?
        public let turnDirection: String?
      }

      // MARK: - LegProperties
      public struct LegProperties: Decodable {
        public let differentFares, planLowFloorVehicle, planWheelChairAccess, lineType: String?
        public let vehicleAccess: [VehicleAccess]?
      }

      // MARK: Vehicle Access
      public struct VehicleAccess: Decodable {}

      // MARK: - Transportation
      public struct Transportation: Decodable {
        public let description: String?
        public let destination: OperatorClass?
        public let disassembledName: String?
        public let iconID: Int?
        public let id, name, number: String?
        public let transportationOperator: OperatorClass?
        public let product: Product?
        public let properties: TransportationProperties?
      }

      // MARK: - OperatorClass
      public struct OperatorClass: Decodable {
        public let id, name: String?
      }

      // MARK: - Product
      public struct Product: Decodable {
        public let `class`, iconID: Int?
        public let name: String?
      }

      // MARK: - TransportationProperties
      public struct TransportationProperties: Decodable {
        public let isTTB: Bool?
        public let tripCode: Int?
        public let timetablePeriod: String?
        public let lineDisplay: String?
        public let globalId: String?
        public let realtimeTripId: String?

        public enum CodingKeys: String, CodingKey {
          case isTTB, tripCode, timetablePeriod, lineDisplay, globalId
          case realtimeTripId = "RealtimeTripId"
        }
      }

      // MARK: - SystemMessages
      public struct SystemMessages: Decodable {
        public let code: Int?
        public let error, module, type, text, subType: String?
      }
    }

    public struct TFNSW {

      public struct Website: Codable {
        public let journeys: [TFNSWJourney]?
        public let systemMessages: [TFNSWJourneySystemMessage]?
        public let serverTime: String?
      }

      public struct TFNSWJourneySystemMessage: Codable {
        public let category: String?
        public let type: String?
        public let text: String?
      }

      public struct TFNSWJourney: Codable  {
        public let type: String?
        public let fares: [TFNSWJourneyFare]?
        public let legs: [TFNSWJourneyLeg]
        public let isBookingRequired, isFree, isOpalEnabled, isOpalPayEnabled: Bool?
        public let hasAlertMessages, isAccessible: Bool?
        public let isRealTime: Bool
        public let duration: Int

        public init?(type: String?, fares: [TFNSWJourneyFare]?, legs: [TFNSWJourneyLeg], isRealTime: Bool?, duration: Int) {
          guard
            type == "publicTransport",
            let isRealTime = isRealTime,
            isRealTime == true
          else { return nil }

          self.type = type
          self.fares = fares
          self.isBookingRequired = false
          self.isFree = false
          self.isOpalEnabled = false
          self.isOpalPayEnabled = false
          self.hasAlertMessages = false
          self.isAccessible = false
          self.isRealTime = isRealTime
          self.duration = duration
          self.legs = legs.compactMap { leg -> TFNSWJourneyLeg? in
            guard
              [1,2,4,5,7,9,11,100].contains(leg.transportation.mode)
            else { return nil }
            return leg
          }
        }
      }

      public struct TFNSWJourneyFare: Codable  {
        public let type: Int?
        public let amount: Double?
        public let stationAccessFee: Double?
        public let fareAvailable, farePartiallyEnabled, opalAvailable: Bool?
      }

      public struct TFNSWJourneyLeg: Codable  {
        public let coordinates: [[Double]]?
        public let isPublicTransport, isBookingRequired: Bool?
        public let origin, destination: TFNSWJourneyStopEvent
        public let departingTime: String
        public let departingTimeUnadjusted: String?
        public let departingTimePlanned: String
        public let departingTimePlannedUnadjusted: String?
        public let arrivalTime: String
        public let arrivalTimeUnadjusted: String?
        public let arrivalTimePlanned: String?
        public let arrivalTimePlannedUnadjusted: String?
        public let alerts: [TFNSWJourneyAlert]?
        public let hasAlertMessages, isHighFrequency: Bool?
        public let isRealTime: Bool?
        public let duration: Int?
        public let transportation: TFNSWJourneyTransportation
        public let arrivalStatus: String?
        public let isFootpath, isBikeRide, isTaxiDrive: Bool?
        public let fares: [TFNSWJourneyFare]?
        public let isFreeService, isOpalAvailable, isOpalPay, isFareAvailable: Bool?
        public let stopSequence: [TFNSWJourneyStopEvent]?
        public let isAccessible: Bool?
        public let distance: Int?
        public let pathDescriptions: [PathDescription]?
        public let standby: Int?
      }

      public struct TFNSWJourneyAlert: Codable {
        public let subtitle: String?
        public let isVeryLowPriority: Bool?
        public let isHighPriority: Bool?
        public let url: String?
        public let urlText: String?
        public let creationDate: String?
        public let lastUpdated: String?
      }

      public struct TFNSWJourneyStopEvent: Codable  {
        public let coordinates: [Double]?
        public let id, name, disassembledName: String?
        public let type: String?
        public let arrivalTimeEstimated, arrivalTimePlanned: String?
        public let isAccessible: Bool?
        public let suburb, parentID: String?
        public let departureTimeEstimated, departureTimePlanned: String?
      }

      public struct PathDescription: Codable  {
        public let manoeuvre: String?
        public let turnDirection: String?
        public let name: String?
        public let duration: Double?
        public let distance: Int?
        public let cumDistance, cumDuration: Double?
        public let properties: TFNSWJourneyProperties?
        public let skyDirection: String?
      }

      public struct TFNSWJourneyProperties: Codable  {}

      public struct TFNSWJourneyTransportation: Codable  {
        public let id: String?
        public let mode: Int
        public let name: String
        public let productID: Int?
        public let routeNumber, serviceDirection: String?
        public let type: String?
        public let colour: TFNSWJourneyColour?
        public let networkID: Int?
        public let destination: TransportationDestination?
        public let occupancy: String?
        public let transportationOperator: TFNSWJourneyOperator?
        public let isOperatorVisible: Bool?
        public let realtimeTripId, category: String?
        public let isBus, isHistoricalOccupancy: Bool?
        public let _occupancy: TFNSWJourneyOccupancy?
      }

      public struct TFNSWJourneyColour: Codable {
        public let background, foreground, text: String?
      }

      public struct TransportationDestination: Codable {
        public let name, type: String?
      }

      public struct TFNSWJourneyOccupancy: Codable  {
        public let queryID, percent: String?
        public let settings: TFNSWJourneySettings?
        public let calculatedLevel: String?
      }

      public struct TFNSWJourneySettings: Codable  {
        public let low, medium, full: Int?
        public let settingsDescription: String?
      }

      public struct TFNSWJourneyOperator: Codable  {
        public let id, name: String?
      }
    }
  }
}
