//
//  ChartItemStore.swift
//  DataMobileUI
//
//  Created by b on 09/09/2023.
//

import Foundation
import ComposableArchitecture

class ChartItemsReducer: Reducer {
    
    
    @Dependency(\.chartItemsClient) var chartItemsClient
    
    enum Action: Equatable {
        case onDeleteButtonTapped(ChartItem)
    }
    
    struct State: Equatable {
        var chartItems: [ChartItem] = []
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onDeleteButtonTapped(let chartItem):
                return .run { send in
                    await self.chartItemsClient.removeChartItem(chartItem)
                }
            }
        }
    }
}
