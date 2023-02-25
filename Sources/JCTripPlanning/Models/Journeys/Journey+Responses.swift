//
//  File.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Journey {
    
    struct Responses {
        
        struct TFNSW {
            
            struct Website: Codable {
                let journeys: [TFNSWJourney]?
                let systemMessages: [TFNSWJourneySystemMessage]?
                let serverTime: String?
            }
            
            struct TFNSWJourneySystemMessage: Codable {
                let category: String?
                let type: String?
                let text: String?
            }

            struct TFNSWJourney: Codable  {
                let type: String?
                let fares: [TFNSWJourneyFare]?
                let legs: [TFNSWJourneyLeg]
                let isBookingRequired, isFree, isOpalEnabled, isOpalPayEnabled: Bool?
                let hasAlertMessages, isAccessible: Bool?
                let isRealTime: Bool
                let duration: Int
                
                init?(type: String?, fares: [TFNSWJourneyFare]?, legs: [TFNSWJourneyLeg], isRealTime: Bool?, duration: Int) {
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

            struct TFNSWJourneyFare: Codable  {
                let type: Int?
                let amount: Double?
                let stationAccessFee: Double?
                let fareAvailable, farePartiallyEnabled, opalAvailable: Bool?
            }

            struct TFNSWJourneyLeg: Codable  {
                let coordinates: [[Double]]?
                let isPublicTransport, isBookingRequired: Bool?
                let origin, destination: TFNSWJourneyStopEvent
                let departingTime: String
                let departingTimeUnadjusted: String?
                let departingTimePlanned: String
                let departingTimePlannedUnadjusted: String?
                let arrivalTime: String
                let arrivalTimeUnadjusted: String?
                let arrivalTimePlanned: String?
                let arrivalTimePlannedUnadjusted: String?
                let alerts: [TFNSWJourneyAlert]?
                let hasAlertMessages, isHighFrequency: Bool?
                let isRealTime: Bool?
                let duration: Int?
                let transportation: TFNSWJourneyTransportation
                let arrivalStatus: String?
                let isFootpath, isBikeRide, isTaxiDrive: Bool?
                let fares: [TFNSWJourneyFare]?
                let isFreeService, isOpalAvailable, isOpalPay, isFareAvailable: Bool?
                let stopSequence: [TFNSWJourneyStopEvent]?
                let isAccessible: Bool?
                let distance: Int?
                let pathDescriptions: [PathDescription]?
                let standby: Bool?
            }

            struct TFNSWJourneyAlert: Codable {
                let subtitle: String?
                let isVeryLowPriority: Bool?
                let isHighPriority: Bool?
                let url: String?
                let urlText: String?
                let creationDate: String?
                let lastUpdated: String?
            }

            struct TFNSWJourneyStopEvent: Codable  {
                let coordinates: [Double]?
                let id, name, disassembledName: String?
                let type: String?
                let arrivalTimeEstimated, arrivalTimePlanned: String?
                let isAccessible: Bool?
                let suburb, parentID: String?
                let departureTimeEstimated, departureTimePlanned: String?
            }

            struct PathDescription: Codable  {
                let manoeuvre: String?
                let turnDirection: String?
                let name: String?
                let duration: Double?
                let distance: Int?
                let cumDistance, cumDuration: Double?
                let properties: TFNSWJourneyProperties?
                let skyDirection: String?
            }

            struct TFNSWJourneyProperties: Codable  {}

            struct TFNSWJourneyTransportation: Codable  {
                let id: String?
                let mode: Int
                let name: String
                let productID: Int?
                let routeNumber, serviceDirection: String?
                let type: String?
                let colour: TFNSWJourneyColour?
                let networkID: Int?
                let destination: TransportationDestination?
                let occupancy: String?
                let transportationOperator: TFNSWJourneyOperator?
                let isOperatorVisible: Bool?
                let realtimeTripId, category: String?
                let isBus, isHistoricalOccupancy: Bool?
                let _occupancy: TFNSWJourneyOccupancy?
            }

            struct TFNSWJourneyColour: Codable {
                let background, foreground, text: String?
            }

            struct TransportationDestination: Codable {
                let name, type: String?
            }

            struct TFNSWJourneyOccupancy: Codable  {
                let queryID, percent: String?
                let settings: TFNSWJourneySettings?
                let calculatedLevel: String?
            }

            struct TFNSWJourneySettings: Codable  {
                let low, medium, full: Int?
                let settingsDescription: String?
            }

            struct TFNSWJourneyOperator: Codable  {
                let id, name: String?
            }
        }
    }
}
