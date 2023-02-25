//
//  File 2.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Journey {
    
    struct Requests {
        
        struct Client: Codable {
            let origin: String?
            let fromLat: Double?
            let fromLng: Double?
            let destination: String
            let metric: DepartureMetric
            let date: Date?
            let accessible: Bool
            let includeSchoolBuses: Bool
        }
        
        struct TFNSW: Codable {
            
            struct Website {
                let from: String?
                let fromLat: Double
                let fromLng: Double
                let to: String
                let toLat: Double
                let toLng: Double
                let leaving: Bool
                let excludedModes: [Int]
                let source: String
                let filters: Filters
                let preferences: Preferences
                let dateTime: String?
                
                init(originStopID: String, destinationStopID: String, metric: DepartureMetric = .immediately, date: Date?, accessible: Bool) {
                    self.from = originStopID
                    self.to = destinationStopID
                    self.fromLat = 0
                    self.fromLng = 0
                    self.toLat = 0
                    self.toLng = 0
                    switch metric {
                    case .immediately: self.leaving = true
                    case .departingAfter: self.leaving = true
                    case .arrivingBefore: self.leaving = false
                    }
                    self.excludedModes = [11]
                    self.source = "transportnsw-info"
                    self.filters = Filters(accessible: accessible)
                    self.preferences = Preferences()
                    if let date = date, metric != .immediately {
                        self.dateTime = date.formatted(.iso8601)
                    } else {
                        self.dateTime = nil
                    }
                }
                
                init(fromLat: Double, fromLng: Double, destinationStopID: String, metric: DepartureMetric = .immediately, date: Date?, accessible: Bool) {
                    self.from = nil
                    self.to = destinationStopID
                    self.fromLat = fromLat
                    self.fromLng = fromLng
                    self.toLat = 0
                    self.toLng = 0
                    switch metric {
                    case .immediately: self.leaving = true
                    case .departingAfter: self.leaving = true
                    case .arrivingBefore: self.leaving = false
                    }
                    self.excludedModes = [11]
                    self.source = "transportnsw-info"
                    self.filters = Filters(accessible: accessible)
                    self.preferences = Preferences()
                    if let date = date, metric != .immediately {
                        self.dateTime = date.formatted(.iso8601)
                    } else {
                        self.dateTime = nil
                    }
                }
            }
            
            struct QueryItems: Codable {
                let outputFormat: String
                let coordOutputFormat: String
                let depArrMacro: String
                let itdDate: String
                let itdTime: String
                let type_origin: String
                let name_origin: String
                let type_destination: String
                let name_destination: String
                let calcNumberOfTrips: Int
                let wheelchair: String?
                let TfNSWTR: Bool
                let version: String
                let itOptionsActive: Int
                let cycleSpeed: Int
                
                init?(journeysRequest: Journey.Requests.Client) {
                    let dateValue = DateHelper.queryStringDateFormatter.string(from: Date())
                    let timeValue = DateHelper.queryStringTimeFormatter.string(from: Date())
                    
                    self.outputFormat = "rapidJSON"
                    self.coordOutputFormat = "EPSG:4326"
                    switch journeysRequest.metric {
                    case .immediately: self.depArrMacro = "dep"
                    case .departingAfter: self.depArrMacro = "dep"
                    case .arrivingBefore: self.depArrMacro = "arr"
                    }
                    
                    if let origin = journeysRequest.origin {
                        self.type_origin = "any"
                        self.name_origin = origin
                    } else if let fromLat = journeysRequest.fromLat, let fromLng = journeysRequest.fromLng {
                        self.type_origin = "coord"
                        self.name_origin = "\(fromLng):\(fromLat):EPSG:4326"
                    } else {
                        return nil
                    }
                    
                    self.itdDate = dateValue
                    self.itdTime = timeValue
                    self.type_destination = "any"
                    self.name_destination = journeysRequest.destination
                    self.calcNumberOfTrips = 30
                    self.wheelchair = journeysRequest.accessible ? "on" : nil
                    self.TfNSWTR = true
                    self.version = "10.2.1.42"
                    self.itOptionsActive = 1
                    self.cycleSpeed = 16
                }
            }
            
            struct Filters: Codable {
                let onlyAccessible, onlyOpal: Bool
                let includedJourneys: [String]
                
                init(accessible: Bool) {
                    self.onlyAccessible = accessible
                    self.onlyOpal = false
                    self.includedJourneys = ["public-transport", "walk"]
                }
            }

            struct Preferences: Codable {
                let gettingFromMode: Int
                let gettingToMode: Int
                let gettingFromValue: Int
                let gettingToValue: Int
                let tripPreference: Int
                let walkSpeed: Int
                
                init() {
                    self.gettingFromMode = 100
                    self.gettingToMode = 100
                    self.gettingFromValue = 20
                    self.gettingToValue = 20
                    self.tripPreference = 0
                    self.walkSpeed = 0
                }
            }
        }
    }
}
