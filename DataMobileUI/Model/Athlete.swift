//
//  Athlete.swift
//  DataMobileUI
//
//  Created by b on 26/09/2023.
//

import Foundation

struct Athlete: Codable {
    var id: Int64
    var activities: [Activity]
    var dashboards: [Dashboard]
}
