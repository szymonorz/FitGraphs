//
//  Dashboard.swift
//  DataMobileUI
//
//  Created by b on 01/10/2023.
//

import Foundation

struct Dashboard: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var data: [ChartData]
}
