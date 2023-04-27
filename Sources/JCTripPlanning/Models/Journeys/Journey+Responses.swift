//
//  Journey+Responses.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Journey {
    
    public struct Responses {
        
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
