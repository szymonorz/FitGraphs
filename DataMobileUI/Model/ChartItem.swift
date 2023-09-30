//
//  ChartItem.swift
//  DataMobileUI
//
//  Created by b on 26/04/2023.
//

import Foundation
import FirebaseFirestoreSwift

class ChartItem: Hashable, Equatable, Identifiable, Codable {
    
    struct _ChartContent: Equatable, Hashable, Identifiable, Codable {
        var id: String
        var key: String
        var value: Decimal
        
        init(id: String = UUID().uuidString, key: String, value: Decimal) {
            self.id = id
            self.key = key
            self.value = value
        }
    }
    
    var id: String
    var name: String
    var type: String
    var contents: [_ChartContent]
    
    var dimensions: [String]
    var measures: [String]
    var filters: [String]
    
    init(id: String = UUID().uuidString,
         name: String,
         type: String,
         contents: [_ChartContent],
         dimensions: [String] = [],
         measures: [String] = [],
         filters: [String] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.contents = contents
        self.dimensions = dimensions
        self.measures = measures
        self.filters = filters
    }
    
    init(chartItem: ChartItem) {
        self.id = chartItem.id
        self.name = chartItem.name
        self.type = chartItem.type
        self.contents = chartItem.contents
        self.dimensions = chartItem.dimensions
        self.measures = chartItem.measures
        self.filters = chartItem.filters
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ChartItem {
    static func==(lhs: ChartItem, rhs: ChartItem) -> Bool{
        return lhs.name == rhs.name &&
                lhs.type == rhs.type &&
                lhs.contents == rhs.contents
    }
}
