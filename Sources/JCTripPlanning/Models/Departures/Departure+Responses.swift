//
//  Departure+Responses.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Departure {
    
    public struct Responses {
        
        // MARK: Departures Response from TFNSW
        
        public struct TFNSW: Decodable {
            public let version: String?
            public let systemMessages: [DeparturesSystemMessage]?
            public let locations: [DeparturesLocationElement]?
            public let stopEvents: [DeparturesStopEvent]?
        }

        public struct DeparturesSystemMessage: Codable {
            public let code: Int?
            public let module, text, type: String?
        }

        public struct DeparturesLocationElement: Decodable {
            public let id: String?
            public let isGlobalID: Bool?
            public let name, disassembledName: String?
            public let coord: [Double]?
            public let type: String?
            public let matchQuality: Int?
            public let isBest: Bool?
            public let parent: DeparturesDestinationClass?
            public let assignedStops: [DeparturesAssignedStop]?
            public let properties: DeparturesAssignedStopProperties?
        }

        public struct DeparturesAssignedStop: Decodable {
            public let id: String?
            public let isGlobalID: Bool?
            public let name, type: String?
            public let coord: [Double]?
            public let parent: DeparturesAssignedStopParent?
            public let modes: [Int]?
            public let connectingMode: Int?
            public let properties: DeparturesAssignedStopProperties?
        }

        public struct DeparturesAssignedStopParent: Decodable {
            public let name, type: String?
        }

        public struct DeparturesAssignedStopProperties: Decodable {
            public let stopID: String?
        }

        public struct DeparturesDestinationClass: Decodable {
            public let id, name, type: String?
        }

        public struct DeparturesStopEvent: Decodable {
            public let isRealtimeControlled: Bool?
            public let location: DeparturesStopEventLocation?
            public let departureTimePlanned, departureTimeEstimated: String?
            public let transportation: DeparturesTransportation?
            public let infos: [DeparturesInfo]?
            public let properties: DeparturesStopEventProperties?
        }

        public struct DeparturesInfo: Decodable {
            public let priority, id, version, urlText: String?
            public let url: String?
            public let content, subtitle: String?
            public let properties: DeparturesInfoProperties?
        }

        public struct DeparturesInfoProperties: Decodable {
            public let publisher, infoType, appliesTo, stopIDglobalID: String?
            public let smsText, speechText: String?
        }

        public struct DeparturesStopEventLocation: Decodable {
            public let id: String?
            public let isGlobalID: Bool?
            public let name, type: String?
            public let coord: [Double]?
            public let properties: DeparturesPurpleProperties?
            public let parent: DeparturesPurpleParent?
        }

        public struct DeparturesPurpleParent: Decodable {
            public let id: String?
            public let isGlobalID: Bool?
            public let name, disassembledName, type: String?
            public let parent: DeparturesAssignedStopParent?
            public let properties: DeparturesAssignedStopProperties?
        }

        public struct DeparturesPurpleProperties: Decodable {
            public let stopID, area, platform: String?
        }

        public struct DeparturesStopEventProperties: Decodable {
            public let wheelchairAccess, realtimeTripID, avmsTripID, pbyb: String?
        }

        public struct DeparturesTransportation: Decodable {
            public let id, name, disassembledName, number: String?
            public let iconID: Int?
            public let transportationDescription: String?
            public let product: DeparturesProduct?
            public let transportationOperator: DeparturesOperator?
            public let destination: DeparturesDestinationClass?
            public let properties: DeparturesTransportationProperties?
            public let origin: DeparturesDestinationClass?
        }

        public struct DeparturesProduct: Decodable {
            public let productClass: Int?
            public let name: String?
            public let iconID: Int?
        }

        public struct DeparturesTransportationProperties: Decodable {
            public let isTTB: Bool?
            public let tripCode: Int?
            public let lineDisplay, frequencyLine: String?
        }

        public struct DeparturesOperator: Decodable {
            public let id, name: String?
        }
        
        // MARK: Departures Response to Client
        
        public struct Client: Codable {
            
            public let sorted: [Departure]
            
            public init?(res: Departure.Responses.TFNSW) {
                var departureStopID: Int?
                if let string = res.stopEvents?.first?.location?.id {
                    departureStopID = Int(string)
                }
                guard let departureStopID = departureStopID else { return nil }
                self.sorted = res.stopEvents?.compactMap { stopEvent -> Departure? in
                   
                    var departureDate: Date?
                    var departureTime: Int?
                    if let departureTimeEstimated = stopEvent.departureTimeEstimated {
                        departureTime = DateHelper.secondsSinceMidnight(from: departureTimeEstimated)
                        departureDate = DateHelper.departureDate(from: departureTimeEstimated)
                    } else if let departureTimePlanned = stopEvent.departureTimePlanned {
                        departureTime = DateHelper.secondsSinceMidnight(from: departureTimePlanned)
                        departureDate = DateHelper.departureDate(from: departureTimePlanned)
                    }
                    
                    guard let departureDate, let departureTime else { return nil }
                    
                    let departureStopName = stopEvent.location?.parent?.disassembledName ?? stopEvent.location?.parent?.name ?? ""
                    let arrivalDetail = stopEvent.transportation?.destination?.name ?? stopEvent.transportation?.destination?.name ?? "Unknown Destination"
                    let routeID = stopEvent.transportation?.disassembledName ?? stopEvent.transportation?.name ?? ""
                    
                    var realtimeMessage = "On time"
                    var realtimeStatus: RealtimeStatus = .onTime
                    
                    if let isRealtime = stopEvent.isRealtimeControlled, isRealtime {
                        if
                            let departureTimePlanned = stopEvent.departureTimePlanned,
                            let scheduledDeparture = DateHelper.departureDate(from: departureTimePlanned),
                            departureDate.timeIntervalSince(scheduledDeparture) > 10,
                            let scheduledDepartureTime = DateHelper.secondsSinceMidnight(from: departureTimePlanned)
                        {
                            realtimeStatus = .delayed
                            let scheduledDepartureTimeString = DateHelper.timetableString(scheduledDepartureTime.formattedTime)
                            let minutesDelay = departureDate.timeIntervalSince(scheduledDeparture)
                            let delayString = Int(minutesDelay).waitTime
                            realtimeMessage = "\(scheduledDepartureTimeString) service running \(delayString) late"
                        }
                    } else {
                        realtimeStatus = .noRealtimeData
                        realtimeMessage = "No realtime data available"
                    }

                    return Departure(
                        departureStopID: departureStopID,
                        departureStopName: departureStopName,
                        arrivalDetail: arrivalDetail,
                        departureTime: departureTime,
                        departureDate: departureDate,
                        routeID: routeID,
                        realtimeMessage: realtimeMessage,
                        realtimeStatus: realtimeStatus
                    )
                }
                .sorted { x, y in
                    x.departureTime < y.departureTime
                } ?? []
            }
        }
    }
}
