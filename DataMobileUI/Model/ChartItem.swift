//
//  ChartItem.swift
//  DataMobileUI
//
//  Created by b on 26/04/2023.
//

import Foundation

class ChartItem: Hashable, ObservableObject, Equatable, Identifiable {
    
    struct _ChartContent: Equatable, Hashable, Identifiable {
        var id: UUID
        var key: String
        var value: Decimal
        
        init(id: UUID = UUID(), key: String, value: Decimal) {
            self.id = id
            self.key = key
            self.value = value
        }
    }
    
    var id: UUID
    @Published var name: String
    @Published var type: String
    @Published var contents: [_ChartContent]
    
    @Published var dimensions: [String]
    @Published var measures: [String]
    @Published var filters: [String]
    
    init(id: UUID = UUID(),
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

extension ChartItem._ChartContent {
    init(record: ChartContentEntity) {
        self.id = record.id!
        self.key = record.key!
        self.value = record.val! as Decimal
    }
}
