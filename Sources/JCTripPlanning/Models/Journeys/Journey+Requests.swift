//
//  Journey+Requests.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Journey {
    
    public struct Requests {
        
        public struct Client: Codable {
            public let origin: String?
            public let fromLat: Double?
            public let fromLng: Double?
            public let destination: String
            public let metric: DepartureMetric
            public let date: Date?
            public let accessible: Bool
            public let includeSchoolBuses: Bool
            
            public init(origin: String? = nil, fromLat: Double? = nil, fromLng: Double? = nil, destination: String, metric: DepartureMetric, date: Date? = nil, accessible: Bool, includeSchoolBuses: Bool) {
                self.origin = origin
                self.fromLat = fromLat
                self.fromLng = fromLng
                self.destination = destination
                self.metric = metric
                self.date = date
                self.accessible = accessible
                self.includeSchoolBuses = includeSchoolBuses
            }
        }
        
        public struct TFNSW {
            
            public struct Website: Codable {
                public let from: String?
                public let fromLat: Double
                public let fromLng: Double
                public let to: String
                public let toLat: Double
                public let toLng: Double
                public let leaving: Bool
                public let excludedModes: [Int]
                public let source: String
                public let filters: Filters
                public let preferences: Preferences
                public let dateTime: String?
                
                public init(originStopID: String, destinationStopID: String, metric: DepartureMetric = .immediately, date: Date?, accessible: Bool, includeSchoolBuses: Bool) {
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
                    self.excludedModes = includeSchoolBuses ? [] : [11]
                    self.source = "transportnsw-info"
                    self.filters = Filters(accessible: accessible)
                    self.preferences = Preferences()
                    if let date = date, metric != .immediately {
                        self.dateTime = date.formatted(.iso8601)
                    } else {
                        self.dateTime = nil
                    }
                }
                
                public init(fromLat: Double, fromLng: Double, destinationStopID: String, metric: DepartureMetric = .immediately, date: Date?, accessible: Bool, includeSchoolBuses: Bool) {
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
                    self.excludedModes = includeSchoolBuses ? [] : [11]
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
            
            public struct QueryItems: Codable {
                public let outputFormat: String
                public let coordOutputFormat: String
                public let depArrMacro: String
                public let itdDate: String
                public let itdTime: String
                public let type_origin: String
                public let name_origin: String
                public let type_destination: String
                public let name_destination: String
                public let calcNumberOfTrips: Int
                public let wheelchair: String?
                public let TfNSWTR: Bool
                public let version: String
                public let itOptionsActive: Int
                public let cycleSpeed: Int
                
                public init?(journeysRequest: Journey.Requests.Client) {
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
            
            public struct Filters: Codable {
                public let onlyAccessible, onlyOpal: Bool
                public let includedJourneys: [String]
                
                public init(accessible: Bool) {
                    self.onlyAccessible = accessible
                    self.onlyOpal = false
                    self.includedJourneys = ["public-transport", "walk"]
                }
            }

            public struct Preferences: Codable {
                public let gettingFromMode: Int
                public let gettingToMode: Int
                public let gettingFromValue: Int
                public let gettingToValue: Int
                public let tripPreference: Int
                public let walkSpeed: Int
                
                public init() {
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
