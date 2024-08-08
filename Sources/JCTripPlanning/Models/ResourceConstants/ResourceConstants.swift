//
//  ResourceConstants.swift
//
//
//  Created by Jerrycan Co on 27/2/2023.
//

import Foundation

public struct ResourceConstants {

  public static let newMetroStationStopIDs: [Int] = [
    20003,
    200046,
    2000460,
    2000461,
    2000462,
    2000463,
    2000464,
    2000465,
    2000466,
    2000467,
    200060,
    200066,
    2017077,
    2017078,
    201721,
    204420,
    204471,
    204472,
    2060114,
    2060115,
    206044,
    206516,
    2065163,
    2065164
  ]

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

  public struct PathStrings {

    public struct TFNSW {

      public enum Website {
        public static let departures = "/departure-list-request"
        public static let journeys = "/trip-request"
      }

      public enum OpenDataAPI {
        public static let departures = "/departure_mon"
        public static let journeys = "/trip"
        public static let stops = "/stop_finder"
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
          queryItems.append(("excludedModes", "1,4,5,7,11"))
        case 2:
          requestStopID = 2000441
          queryItems.append(("excludedModes", "1,4,5,7,11"))
        case 3:
          requestStopID = 10102027
          queryItems.append(("excludedModes", "1,4,5,7,11"))
        case 88888888:
          requestStopID = 2000447
          queryItems.append(("excludedModes", "1,5,7,9,11"))
        case 200020:
          if case .lightRail = mode {
            queryItems.append(("excludedModes", "1,5,7,9,11"))
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
        public let excludedModes: String?

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
            self.excludedModes = "1,4,5,7,11"
          case 2:
            requestStopID = 2000441
            self.excludedModes = "1,4,5,7,11"
          case 3:
            requestStopID = 10102027
            self.excludedModes = "1,4,5,7,11"
          case 88888888:
            requestStopID = 2000447
            self.excludedModes = "1,5,7,9,11"
          case 200020:
            switch mode {
            case .lightRail:
              self.excludedModes = "1,5,7,9,11"
            default:
              self.excludedModes = nil
            }
          default:
            self.excludedModes = nil
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

      /// Create an object representing URL query items for a trip planner request to
      /// the OpenData API.
      ///
      /// Used client-side.
      public static func tripRequestClientQueryItems(for request: Journey.Requests.Client) -> [(String, String)] {
        var output: [(String, String)] = [
          ("outputFormat", "rapidJSON"),
          ("coordOutputFormat", "EPSG:4326"),
          ("depArrMacro", request.metric == .arrivingBefore ? "arr" : "dep"),
          ("version", "10.2.1.42"),
          ("name_destination", request.destination),
          ("type_destination", "any"),
          ("calcNumberOfTrips", "30"),
          ("TfNSWTR", "true"),
          ("itOptionsActive", "0"),
          ("cycleSpeed", "16")
        ]

        if request.accessible { output.append(("wheelchair", "on")) }
        if !request.includeSchoolBuses { output.append(("excludedMeans", "11")) }

        if let origin = request.origin {
          output.append(("type_origin", "any"))
          output.append(("name_origin", origin))
        } else if let fromLat = request.fromLat, let fromLng = request.fromLng {
          output.append(("type_origin", "coord"))
          output.append(("name_origin", "\(fromLng):\(fromLat):EPSG:4326"))
        }

        if let date = request.date, request.metric != .immediately {
          let itdDate = DateHelper.queryStringDateFormatter.string(from: date)
          let itdTime = DateHelper.queryStringTimeFormatter.string(from: date)
          output.append(("itdDate", itdDate))
          output.append(("itdTime", itdTime))
        }

        return output
      }
    }
  }
}
