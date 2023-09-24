//
//  Dashboard.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import Foundation
import ComposableArchitecture
import Charts

class DashboardReducer: Reducer {
    
    @Dependency(\.dataTransformer) var dataTransformer
    @Dependency(\.stravaApi) var stravaApi
    @Dependency(\.chartItemsClient) var chartItemsClient
    
    enum Action: Equatable {
        case loadCharts
        case fetchFromStrava
        case chartItemTapped(ChartItem)
        case updateCharts([ChartItem])
        case addChart(ChartItem)
        
        case chartEditor(ChartEditorReducer.Action)
    }
    
    struct State: Equatable {
        var charts: [ChartItem] = [
            ChartItem(
                name: "Test",
                type: "BAR",
                contents: []
            )
        ]
        
        var chartEditor = ChartEditorReducer.State()
    }
    
    var body: some ReducerOf<DashboardReducer> {
        Scope(state: \.chartEditor, action: /Action.chartEditor) {
            ChartEditorReducer()
        }
        Reduce { state, action in
            switch action {
            case .addChart(let chartItem):
                return .run { send in
                    await self.chartItemsClient.addChartItem(chartItem)
                    await send(.loadCharts)
                }
            case .loadCharts:
                return .run { send in
                    let charts = await self.chartItemsClient.fetchChartItems()
                    debugPrint(charts.count)
                    await send(.updateCharts(charts))
                }
            case .fetchFromStrava:
                return .run {
                    send in
                    let activities = try await self.stravaApi.getUserActivities()
                    try self.dataTransformer.saveToDevice(JSONEncoder().encode(activities))
                    await send(.loadCharts)
                }
            case .chartItemTapped(let chartItem):
                state.chartEditor.isEditorOpen = true
                // Copy so editing wont affect the Dashboard state
                let chartCopy = ChartItem(chartItem: chartItem)
                return .run { send in
                    await send(.chartEditor(.chartToEditChanged(chartCopy)))
                }
            case .updateCharts(let charts):
                state.charts = charts
                return .none
            case .chartEditor(let _):
                return .none
            }
        }
    }
}
