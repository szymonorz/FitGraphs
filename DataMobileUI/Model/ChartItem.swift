//
//  ChartItem.swift
//  DataMobileUI
//
//  Created by b on 26/04/2023.
//

import Foundation

struct ChartItem: Hashable {
    
    struct _ChartContent: Equatable, Hashable, Identifiable {
        var id = UUID().uuidString
        var key: String
        var value: Double
        var animate: Bool = false
    }
    
    var name: String
    var type: String
    var contents: [_ChartContent]
    
//    init(name: String, type: String, contents: [_ChartContent]) {
//        self.name = name
//        self.type = type
//        self.contents = contents
//    }
//
}

extension ChartItem {
    static func==(lhs: ChartItem, rhs: ChartItem) -> Bool{
        return lhs.name == rhs.name &&
                lhs.type == rhs.type &&
                lhs.contents == rhs.contents
    }
}
