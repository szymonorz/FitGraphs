//
//  ChartItem.swift
//  DataMobileUI
//
//  Created by b on 26/04/2023.
//

import Foundation

class ChartItem: Hashable, ObservableObject, Equatable, Identifiable {
    
    struct _ChartContent: Equatable, Hashable, Identifiable {
        var id = UUID().uuidString
        var key: String
        var value: Double
    }
    
    var id: String
    @Published var name: String
    @Published var type: String
    @Published var contents: [_ChartContent]
    
    init(name: String, type: String, contents: [_ChartContent]) {
        self.id = UUID().uuidString
        print(self.id)
        self.name = name
        self.type = type
        self.contents = contents
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
