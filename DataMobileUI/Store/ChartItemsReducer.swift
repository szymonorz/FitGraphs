//
//  ChartItemStore.swift
//  DataMobileUI
//
//  Created by b on 09/09/2023.
//

import ComposableArchitecture

class ChartItemsReducer: Reducer {
    @Dependency(\.chartItemsClient) var chartItemsClient
    
    enum Action: Equatable {
        case onAppear
        case onDeleteButtonTapped(ChartItem)
        
//        case chartEditor(ChartEditorReducer.Action)
    }
    
    struct State: Equatable {
        var data : [ChartData] = []
        var items: [ChartItem] = []
        
//        var chartEditor = ChartEditorReducer.State()
    }
    
    var body: some Reducer<State, Action> {
//        Scope(state: \.chartEditor, action: /Action.chartEditor) {
//            ChartEditorReducer()
//        }
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
            case .onAppear:
                state.items = []
                for data in state.data {
                    var chartItem = ChartItem(
                            name: data.title,
                            type: data.type,
                            contents: []
                        )
                    
                    do {
                        let contents = try DataSource.shared.query(dimensions: data.dimensions, measures: data.measures)
                        chartItem.contents = contents
                    } catch {
                        chartItem.errorMsg = error.localizedDescription
                    }
                    state.items.append(chartItem)
                }
                return .none
//            case .chartEditor(let _):
//                return .none
            }
        }
    }
}
