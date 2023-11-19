//
//  ChartItem.swift
//  DataMobileUI
//
//  Created by b on 26/04/2023.
//

import Foundation
import FirebaseFirestoreSwift

class ChartItem: Hashable, Equatable, Identifiable {
    
    struct _ChartContent: Equatable, Hashable, Identifiable, Comparable {
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
    var errorMsg: String?
    var data: [(dataType: String, contents: [_ChartContent])]
    
    init(id: String = UUID().uuidString,
         name: String,
         type: String,
         errorMsg: String? = nil,
         data: [(dataType: String, contents: [_ChartContent])]){
        self.id = id
        self.name = name
        self.type = type
        self.errorMsg = errorMsg
        self.data = data
    }
    
    init(chartItem: ChartItem) {
        self.id = chartItem.id
        self.name = chartItem.name
        self.type = chartItem.type
        self.errorMsg = chartItem.errorMsg
        self.data = chartItem.data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(errorMsg)
    }
}

extension ChartItem {
    static func==(lhs: ChartItem, rhs: ChartItem) -> Bool{
        return lhs.name == rhs.name &&
                lhs.type == rhs.type &&
        lhs.hashValue == rhs.hashValue &&
        areArraysOfTuplesEqual(lhs.data, rhs.data)
    }
}

extension ChartItem._ChartContent {
    static func <(lhs: ChartItem._ChartContent, rhs: ChartItem._ChartContent) -> Bool {
        return lhs.value < rhs.value
    }
}

func areTuplesEqual(
    _ tuple1: (dataType: String, contents: [ChartItem._ChartContent]),
    _ tuple2: (dataType: String, contents: [ChartItem._ChartContent])
) -> Bool {
    return tuple1.dataType == tuple2.dataType && tuple1.contents == tuple2.contents
}

func areArraysOfTuplesEqual(
    _ array1: [(dataType: String, contents: [ChartItem._ChartContent])],
    _ array2: [(dataType: String, contents: [ChartItem._ChartContent])]
) -> Bool {
    guard array1.count == array2.count else { return false }
    
    for (index, tuple1) in array1.enumerated() {
        let tuple2 = array2[index]
        if !areTuplesEqual(tuple1, tuple2) {
            return false
        }
    }
    
    return true
}
