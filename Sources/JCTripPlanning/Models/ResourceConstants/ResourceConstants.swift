//
//  File.swift
//  
//
//  Created by Jerrycan Co on 27/2/2023.
//

import Foundation

public struct ResourceConstants {
    
    public struct URLStrings {
        
        public struct MetroAPI {
            public static let baseURL = "https://api.tripplannersydney.com/v2"
        }
        
        public struct TFNSW {
            
            public enum Website {
                public static let baseURL = "https://transportnsw.info/api/trip/v1"
                public static let departures = "https://transportnsw.info/api/trip/v1/departure-list-request"
                public static let journeys = "https://transportnsw.info/api/trip/v1/trip-request"
                public static let majorAlerts = "https://transportnsw.info/tfnsw-alerts/alert-banners"
            }
            
            public enum OpenDataAPI {
                public static let baseURL = "https://api.transport.nsw.gov.au/v1/tp"
                public static let departures = "https://api.transport.nsw.gov.au/v1/tp/departure_mon"
                public static let journeys = "https://api.transport.nsw.gov.au/v1/tp/trip"
                public static let stops = "https://api.transport.nsw.gov.au/v1/tp/stop_finder"
            }
        }
    }
    
    public struct Headers {
        /// Used for building TFNSW Website requests client-side.
        public static let dictionary: [String: String] = [
            "authority": "transportnsw.info",
            "Origin": "https://transportnsw.info",
            "Referer": "https://transportnsw.info/trip",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; rv:103.0) Gecko/20100101 Firefox/108.0",
            "Content-Type": "application/json"
        ]
        
        /// Used for building TFNSW Website requests server-side.
        public static let array: [(String, String)] = [
            ("authority", "transportnsw.info"),
            ("Origin", "https://transportnsw.info"),
            ("Referer", "https://transportnsw.info/trip"),
            ("User-Agent", "Mozilla/5.0 (Windows NT 10.0; rv:103.0) Gecko/20100101 Firefox/108.0"),
            ("Content-Type", "application/json")
        ]
    }
    
    public struct QueryItems {
        
        public struct Website {
            
            /// Used for client-side requests.
            public static func array(for stopID: Int, mode: ModeOfTravel? = nil) -> [(String, String)] {
                
                let dateValue = DateHelper.queryStringDateFormatter.string(from: Date())
                let timeValue = DateHelper.queryStringTimeFormatter.string(from: Date())
                
                var queryItems: [(String, String)] = [
                    ("depType", "stopEvents"),
                    ("type", "stop"),
                    ("accessible", "false"),
                    ("date", dateValue),
                    ("time", timeValue),
                    ("depArrMacro", "dep"),
                    ("debug", "false"),
                    ("depType", "stopEvents")
                ]
                
                /// Circular Quay, Barangaroo and Manly are treated differently
                /// as they have multiple 'parent' stations and offer departures
                /// from multiple modes.
                ///
                /// Central Chalmers St Light Rail is given stopID
                /// 88888888 by the API as it has two child stops that
                /// depart for Randwick/Kingsford.
                var requestStopID = stopID
                switch stopID {
                case 1:
                    requestStopID = 200020
                    let extraQueryItems: [(String, String)] = [
                        ("excludedMeans", "checkbox"),
                        ("exclMOT_1", "1"), // Exclude trains
                        ("exclMOT_4", "1"), // Exclude light rail
                        ("exclMOT_5", "1"), // Exclude buses
                        ("exclMOT_7", "1"), // Exclude coaches
                        ("exclMOT_11", "1") // Exclude school buses
                    ]
                    queryItems.append(contentsOf: extraQueryItems)
                case 2:
                    requestStopID = 2000441
                    let extraQueryItems: [(String, String)] = [
                        ("excludedMeans", "checkbox"),
                        ("exclMOT_1", "1"), // Exclude trains
                        ("exclMOT_4", "1"), // Exclude light rail
                        ("exclMOT_5", "1"), // Exclude buses
                        ("exclMOT_7", "1"), // Exclude coaches
                        ("exclMOT_11", "1") // Exclude school buses
                    ]
                    queryItems.append(contentsOf: extraQueryItems)
                case 3:
                    requestStopID = 10102027
                    let extraQueryItems: [(String, String)] = [
                        ("excludedMeans", "checkbox"),
                        ("exclMOT_1", "1"), // Exclude trains
                        ("exclMOT_4", "1"), // Exclude light rail
                        ("exclMOT_5", "1"), // Exclude buses
                        ("exclMOT_7", "1"), // Exclude coaches
                        ("exclMOT_11", "1") // Exclude school buses
                    ]
                    queryItems.append(contentsOf: extraQueryItems)
                case 88888888:
                    requestStopID = 2000447
                    let extraQueryItems: [(String, String)] = [
                        ("excludedMeans", "checkbox"),
                        ("exclMOT_1", "1"), // Exclude trains
                        ("exclMOT_5", "1"), // Exclude buses
                        ("exclMOT_7", "1"), // Exclude coaches
                        ("exclMOT_9", "1"), // Exclude ferries
                        ("exclMOT_11", "1") // Exclude school buses
                    ]
                    queryItems.append(contentsOf: extraQueryItems)
                case 200020:
                    if case .lightRail = mode {
                        let extraQueryItems: [(String, String)] = [
                            ("excludedMeans", "checkbox"),
                            ("exclMOT_1", "1"), // Exclude trains
                            ("exclMOT_5", "1"), // Exclude buses
                            ("exclMOT_7", "1"), // Exclude coaches
                            ("exclMOT_9", "1"), // Exclude ferries
                            ("exclMOT_11", "1") // Exclude school buses
                        ]
                        queryItems.append(contentsOf: extraQueryItems)
                    }
                default: break
                }
                
                queryItems.append(("name", "\(requestStopID)"))
                return queryItems
            }
            
            /// Used for server-side requests.
            public struct ContentObject: Codable {
                public let name: String
                public let depType: String
                public let type: String
                public let accessible: String
                public let date: String
                public let time: String
                public let depArrMacro: String
                public let debug: String
                public let excludedMeans: String?
                public let exclMOT_1: String?
                public let exclMOT_4: String?
                public let exclMOT_5: String?
                public let exclMOT_7: String?
                public let exclMOT_9: String?
                public let exclMOT_11: String?
                
                public init(stopID: Int, mode: ModeOfTravel?) {
                    let dateValue = DateHelper.queryStringDateFormatter.string(from: Date())
                    let timeValue = DateHelper.queryStringTimeFormatter.string(from: Date())
                    
                    /// Circular Quay, Barangaroo and Manly are treated differently
                    /// as they have multiple 'parent' stations and offer departures
                    /// from multiple modes.
                    ///
                    /// Central Chalmers St Light Rail is given stopID
                    /// 88888888 by the API as it has two child stops that
                    /// depart for Randwick/Kingsford.
                    var requestStopID = stopID
                    switch stopID {
                    case 1:
                        requestStopID = 200020
                        self.excludedMeans = "checkbox"
                        self.exclMOT_1 = "1" // Exclude trains
                        self.exclMOT_4 = "1" // Exclude light rail
                        self.exclMOT_5 = "1" // Exclude buses
                        self.exclMOT_7 = "1" // Exclude coaches
                        self.exclMOT_9 = nil
                        self.exclMOT_11 = "1" // Exclude school buses
                    case 2:
                        requestStopID = 2000441
                        self.excludedMeans = "checkbox"
                        self.exclMOT_1 = "1" // Exclude trains
                        self.exclMOT_4 = "1" // Exclude light rail
                        self.exclMOT_5 = "1" // Exclude buses
                        self.exclMOT_7 = "1" // Exclude coaches
                        self.exclMOT_9 = nil
                        self.exclMOT_11 = "1" // Exclude school buses
                    case 3:
                        requestStopID = 10102027
                        self.excludedMeans = "checkbox"
                        self.exclMOT_1 = "1" // Exclude trains
                        self.exclMOT_4 = "1" // Exclude light rail
                        self.exclMOT_5 = "1" // Exclude buses
                        self.exclMOT_7 = "1" // Exclude coaches
                        self.exclMOT_9 = nil
                        self.exclMOT_11 = "1" // Exclude school buses
                    case 88888888:
                        requestStopID = 2000447
                        self.excludedMeans = "checkbox"
                        self.exclMOT_1 = "1" // Exclude trains
                        self.exclMOT_4 = nil
                        self.exclMOT_5 = "1" // Exclude buses
                        self.exclMOT_7 = "1" // Exclude coaches
                        self.exclMOT_9 = "1" // Exclude ferries
                        self.exclMOT_11 = "1" // Exclude school buses
                    case 200020:
                        switch mode {
                        case .lightRail:
                            self.excludedMeans = "checkbox"
                            self.exclMOT_1 = "1" // Exclude trains
                            self.exclMOT_4 = nil
                            self.exclMOT_5 = "1" // Exclude buses
                            self.exclMOT_7 = "1" // Exclude coaches
                            self.exclMOT_9 = "1" // Exclude ferries
                            self.exclMOT_11 = "1" // Exclude school buses
                        default:
                            self.excludedMeans = nil
                            self.exclMOT_1 = nil
                            self.exclMOT_4 = nil
                            self.exclMOT_5 = nil
                            self.exclMOT_7 = nil
                            self.exclMOT_9 = nil
                            self.exclMOT_11 = nil
                        }
                    default:
                        self.excludedMeans = nil
                        self.exclMOT_1 = nil
                        self.exclMOT_4 = nil
                        self.exclMOT_5 = nil
                        self.exclMOT_7 = nil
                        self.exclMOT_9 = nil
                        self.exclMOT_11 = nil
                    }
                    
                    self.depType = "stopEvents"
                    self.type = "stop"
                    self.accessible = "false"
                    self.date = dateValue
                    self.time = timeValue
                    self.depArrMacro = "dep"
                    self.debug = "false"
                    self.name = "\(requestStopID)"
                }
            }
        }
        
        public struct OpenDataAPI {
            /// Used for server-side requests.
            public struct ContentObject: Codable {
                public let outputFormat: String
                public let coordOutputFormat: String
                public let mode: String
                public let type_dm: String
                public let name_dm: String
                public let itdDate: String
                public let itdTime: String
                public let departureMonitorMacro: Bool
                public let TfNSWDM: Bool
                public let version: String
                
                public init(stopID: Int) {
                    let dateValue = DateHelper.queryStringDateFormatter.string(from: Date())
                    let timeValue = DateHelper.queryStringTimeFormatter.string(from: Date())
                    
                    self.outputFormat = "rapidJSON"
                    self.coordOutputFormat = "EPSG:4326"
                    self.mode = "direct"
                    self.type_dm = "stop"
                    self.name_dm = "\(stopID)"
                    self.itdDate = dateValue
                    self.itdTime = timeValue
                    self.departureMonitorMacro = true
                    self.TfNSWDM = true
                    self.version = "10.2.1.42"
                }
            }
        }
    }
}
