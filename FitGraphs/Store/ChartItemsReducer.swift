//
//  ChartItemStore.swift
//  DataMobileUI
//
//  Created by b on 09/09/2023.
//

import Foundation
import ComposableArchitecture

class ChartItemsReducer: Reducer {
    enum Action: Equatable {
        case loadItems

    }
    
    struct State: Equatable {
        var chartData : [ChartData] = []
        var chartItems: [ChartItem] = []
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadItems:
                state.chartItems = []
                for data in state.chartData {
                    var chartItem = ChartItem(
                            name: data.title,
                            type: data.type,
                            numOfSplits: data.query.dimensions.count,
                            data: []
                        )
                    
                    do {
                        let data = try Cube.shared.query(cubeQuery: data.query)
                        chartItem.data = data
                    } catch {
                        chartItem.errorMsg = error.localizedDescription
                    }
                    state.chartItems.append(chartItem)
                }
                return .none
            }
        }
    }
}
