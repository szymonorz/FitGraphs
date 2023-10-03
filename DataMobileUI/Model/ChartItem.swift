//
//  ChartItem.swift
//  DataMobileUI
//
//  Created by b on 26/04/2023.
//

import Foundation
import FirebaseFirestoreSwift

class ChartItem: Hashable, Equatable, Identifiable {
    
    struct _ChartContent: Equatable, Hashable, Identifiable {
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
    var contents: [_ChartContent]
    
    init(id: String = UUID().uuidString,
         name: String,
         type: String,
         errorMsg: String? = nil,
         contents: [_ChartContent]){
        self.id = id
        self.name = name
        self.type = type
        self.errorMsg = errorMsg
        self.contents = contents
    }
    
    init(chartItem: ChartItem) {
        self.id = chartItem.id
        self.name = chartItem.name
        self.type = chartItem.type
        self.errorMsg = chartItem.errorMsg
        self.contents = chartItem.contents
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
