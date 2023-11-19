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
        case loadItems
        case onDeleteButtonTapped(ChartItem)
        
        case chartEditor(ChartEditorReducer.Action)

    }
    
    struct State: Equatable {
        var chartData : [ChartData] = []
        var chartItems: [ChartItem] = []
        
        var chartEditor = ChartEditorReducer.State()
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.chartEditor, action: /Action.chartEditor) {
            ChartEditorReducer()
        }
        Reduce { state, action in
            switch action {
            case .onDeleteButtonTapped(let chartItem):
                return .run { send in
                    do {
                        try await self.chartItemsClient.removeChartItem(chartItem)
                    } catch {
                        debugPrint("\(error.localizedDescription)")
                    }
                }
            case .loadItems:
                state.chartItems = []
                debugPrint(state.chartData)
                for data in state.chartData {
                    var chartItem = ChartItem(
                            name: data.title,
                            type: data.type,
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
            case .chartEditor(let _):
                return .none
            }
        }
    }
}
