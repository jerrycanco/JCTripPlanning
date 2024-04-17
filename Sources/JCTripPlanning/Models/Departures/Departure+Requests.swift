//
//  Departure+Requests.swift
//  
//
//  Created by Jerrycan Co on 25/2/2023.
//

import Foundation

extension Departure {
    
    public struct Requests {
        
        // MARK: Request Object from Client
        
        public struct Client: Codable, Sendable {
            public let stopID: Int
            public let modeOfTravel: ModeOfTravel?
            
            public init(stopID: Int, modeOfTravel: ModeOfTravel? = nil) {
                self.stopID = stopID
                self.modeOfTravel = modeOfTravel
            }
        }
    }
}
