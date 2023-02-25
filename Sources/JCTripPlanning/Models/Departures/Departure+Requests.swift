//
//  Departure+Requests.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Departure {
    
    struct Requests {
        
        // MARK: Request Object from Client
        
        struct Client: Codable {
            let stopID: Int
            let modeOfTravel: ModeOfTravel?
        }
        
        // MARK: Query Items for TFNSW
        
        struct TFNSW {
            
            struct Website {
                
                struct QueryItems: Codable {
                    let name: String
                    let depType: String
                    let type: String
                    let accessible: String
                    let date: String
                    let time: String
                    let depArrMacro: String
                    let debug: String
                    let excludedMeans: String?
                    let exclMOT_1: String?
                    let exclMOT_4: String?
                    let exclMOT_5: String?
                    let exclMOT_7: String?
                    let exclMOT_9: String?
                    let exclMOT_11: String?
                    
                    init(stopID: Int, mode: ModeOfTravel?) {
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
            
            struct OpenDataAPI {
                
                struct QueryItems: Codable {
                    let outputFormat: String
                    let coordOutputFormat: String
                    let mode: String
                    let type_dm: String
                    let name_dm: String
                    let itdDate: String
                    let itdTime: String
                    let departureMonitorMacro: Bool
                    let TfNSWDM: Bool
                    let version: String
                    
                    init(stopID: Int) {
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
}


