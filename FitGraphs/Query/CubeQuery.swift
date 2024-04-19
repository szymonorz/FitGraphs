//
//  Cube.swift
//  FitGraphs
//
//  Created by b on 18/11/2023.
//

import Foundation

struct CubeQuery: Codable, Hashable {
    
    enum QueryErrors: Error {
        case emptyDimensions
        case emptyMeasures
    }
    
    struct Aggregation: Codable, Hashable, Equatable {
        var name: String
        var expression: String
        
        init(name: String) {
            self.name = name
            self.expression = name
        }
        
        init(name: String, expression: String) {
            self.name = name
            self.expression = expression
        }
    }
    
    struct Filter: Codable, Hashable, Equatable {
        var name: String
        var exclude: Bool = false
        var values: [String] = []
        var chosen: [String] = []
    }
    
    var dimensions: [Aggregation]
    var measures: [Aggregation]
    var filters: [Filter]
    
    init(
        dimensions: [CubeQuery.Aggregation] = [],
        measures: [CubeQuery.Aggregation] = [],
        filters: [CubeQuery.Filter] = []
    ) {
        self.dimensions = dimensions
        self.measures = measures
        self.filters = filters
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

extension CubeQuery.QueryErrors: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emptyDimensions:
            return "No dimensions provided"
        case .emptyMeasures:
            return "No measures provided"
        }
    }
}
