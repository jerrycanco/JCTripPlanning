//
//  Departure+Responses.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Departure {
    
    struct Responses {
        
        // MARK: Departures Response from TFNSW
        
        struct TFNSW: Decodable {
            let version: String?
            let systemMessages: [DeparturesSystemMessage]?
            let locations: [DeparturesLocationElement]?
            let stopEvents: [DeparturesStopEvent]?
        }

        struct DeparturesSystemMessage: Codable {
            let code: Int?
            let module, text, type: String?
        }

        struct DeparturesLocationElement: Decodable {
            let id: String?
            let isGlobalID: Bool?
            let name, disassembledName: String?
            let coord: [Double]?
            let type: String?
            let matchQuality: Int?
            let isBest: Bool?
            let parent: DeparturesDestinationClass?
            let assignedStops: [DeparturesAssignedStop]?
            let properties: DeparturesAssignedStopProperties?
        }

        struct DeparturesAssignedStop: Decodable {
            let id: String?
            let isGlobalID: Bool?
            let name, type: String?
            let coord: [Double]?
            let parent: DeparturesAssignedStopParent?
            let modes: [Int]?
            let connectingMode: Int?
            let properties: DeparturesAssignedStopProperties?
        }

        struct DeparturesAssignedStopParent: Decodable {
            let name, type: String?
        }

        struct DeparturesAssignedStopProperties: Decodable {
            let stopID: String?
        }

        struct DeparturesDestinationClass: Decodable {
            let id, name, type: String?
        }

        struct DeparturesStopEvent: Decodable {
            let isRealtimeControlled: Bool?
            let location: DeparturesStopEventLocation?
            let departureTimePlanned, departureTimeEstimated: String?
            let transportation: DeparturesTransportation?
            let infos: [DeparturesInfo]?
            let properties: DeparturesStopEventProperties?
        }

        struct DeparturesInfo: Decodable {
            let priority, id, version, urlText: String?
            let url: String?
            let content, subtitle: String?
            let properties: DeparturesInfoProperties?
        }

        struct DeparturesInfoProperties: Decodable {
            let publisher, infoType, appliesTo, stopIDglobalID: String?
            let smsText, speechText: String?
        }

        struct DeparturesStopEventLocation: Decodable {
            let id: String?
            let isGlobalID: Bool?
            let name, type: String?
            let coord: [Double]?
            let properties: DeparturesPurpleProperties?
            let parent: DeparturesPurpleParent?
        }

        struct DeparturesPurpleParent: Decodable {
            let id: String?
            let isGlobalID: Bool?
            let name, disassembledName, type: String?
            let parent: DeparturesAssignedStopParent?
            let properties: DeparturesAssignedStopProperties?
        }

        struct DeparturesPurpleProperties: Decodable {
            let stopID, area, platform: String?
        }

        struct DeparturesStopEventProperties: Decodable {
            let wheelchairAccess, realtimeTripID, avmsTripID, pbyb: String?
        }

        struct DeparturesTransportation: Decodable {
            let id, name, disassembledName, number: String?
            let iconID: Int?
            let transportationDescription: String?
            let product: DeparturesProduct?
            let transportationOperator: DeparturesOperator?
            let destination: DeparturesDestinationClass?
            let properties: DeparturesTransportationProperties?
            let origin: DeparturesDestinationClass?
        }

        struct DeparturesProduct: Decodable {
            let productClass: Int?
            let name: String?
            let iconID: Int?
        }

        struct DeparturesTransportationProperties: Decodable {
            let isTTB: Bool?
            let tripCode: Int?
            let lineDisplay, frequencyLine: String?
        }

        struct DeparturesOperator: Decodable {
            let id, name: String?
        }
        
        // MARK: Departures Response to Client
        
        struct Client: Codable {
            
            let sorted: [Departure]
            
            init?(res: Departure.Responses.TFNSW) {
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
