//
//  ChartData.swift
//  DataMobileUI
//
//  Created by b on 01/10/2023.
//

import Foundation

struct ChartData: Codable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var type: String
    var dimensions: [String]
    var measures: [String]
    var filters: [String]
}

extension ChartData {
    static func==(lhs: ChartData, rhs: ChartData) -> Bool{
        return lhs.name == rhs.name &&
                lhs.type == rhs.type &&
        lhs.measures == rhs.measures &&
        lhs.dimensions == rhs.dimensions &&
        lhs.filters == rhs.filters
    }
}
