//
//  String+Extension.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension String {
    // TFNSW Website
    static let departuresURLString = "https://transportnsw.info/api/trip/v1/departure-list-request"
    static let journeysURLString = "https://transportnsw.info/api/trip/v1/trip-request"
    static let majorAlertsURLString = "https://transportnsw.info/tfnsw-alerts/alert-banners"
    
    // OpenData API
    static let tfnswAPIDeparturesURLString = "https://api.transport.nsw.gov.au/v1/tp/departure_mon"
    static let tfnswAPIJourneysURLString = "https://api.transport.nsw.gov.au/v1/tp/trip"
    static let tfnswAPIStopsURLString = "https://api.transport.nsw.gov.au/v1/tp/stop_finder"
}
