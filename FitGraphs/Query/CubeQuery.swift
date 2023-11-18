//
//  Cube.swift
//  FitGraphs
//
//  Created by b on 18/11/2023.
//

import Foundation

class CubeQuery: Codable, Hashable {
    
    struct Aggregation: Codable, Hashable, Equatable {
        var name: String
        var expression: String
    }
    
    var dimensions: [Aggregation]
    var measures: [Aggregation]
    var filters: [Aggregation]
    
    init() {
        self.dimensions = [
        ]
        self.measures = [
        ]
        self.filters = []
    }
}

extension CubeQuery {
    static func==(lhs: CubeQuery, rhs: CubeQuery) -> Bool{
        return lhs.measures == rhs.measures &&
        lhs.dimensions == rhs.dimensions &&
        lhs.filters == rhs.filters
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dimensions)
        hasher.combine(measures)
        hasher.combine(filters)
    }
}
