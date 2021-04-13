//
//  LandmarkInfo.swift
//  virtualTours
//
//  Created by Hunter Harloff on 3/28/21.
//

import Foundation
import CoreLocation

struct LandmarkInfo {
    let id: String
    let latitude : CLLocationDegrees
    let longitude : CLLocationDegrees
    let name: String
    let types : [String]
    let description : String
    let address : String
    let website : String
    let rating : Double
    let phone : String
    let map : String
    let open : Bool
    let hours : String
}
