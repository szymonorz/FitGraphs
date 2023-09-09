//
//  Dashboard.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import Foundation
import ComposableArchitecture
import Charts

class Dashboard: Reducer {
    
    var body: some ReducerOf<Dashboard> {
        Reduce { state, action in
//            switch action {
//                
//            }
            
            return .none
        }
    }
    
    enum Action: Equatable {
        
    }
    
    struct State: Equatable {
        
    }
    
    @Published var charts: [ChartItem] //dont care
    
    init(){
        self.charts = []
    }
}


var sample_charts: [ChartItem] = [
    ChartItem(name: "1", type: "BAR", contents: [
        ChartItem._ChartContent(key:"0", value: 123),
        ChartItem._ChartContent(key:"1", value: 125),
        ChartItem._ChartContent(key:"2", value: 127),
        ChartItem._ChartContent(key:"3", value: 12)
        ]
    ),
    ChartItem(name: "2", type: "LINE", contents: [
        ChartItem._ChartContent(key:"0", value: 123),
        ChartItem._ChartContent(key:"1", value: 125),
        ChartItem._ChartContent(key:"2", value: 127),
        ChartItem._ChartContent(key:"3", value: 12)
        ]
    ),
    ChartItem(name: "3",type: "AREA", contents: [
        ChartItem._ChartContent(key:"0", value: 123),
        ChartItem._ChartContent(key:"1", value: 125),
        ChartItem._ChartContent(key:"2", value: 127),
        ChartItem._ChartContent(key:"3", value: 12)
        ]
    ),
    ChartItem(name: "3",type: "PIE", contents: [
        ChartItem._ChartContent(key:"0", value: 123),
        ChartItem._ChartContent(key:"1", value: 125),
        ChartItem._ChartContent(key:"2", value: 127),
        ChartItem._ChartContent(key:"3", value: 12)
        ]
    )
]



