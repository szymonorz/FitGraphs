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
    
    @Dependency(\.firebaseClient) var firebaseClient
    @Dependency(\.stravaApi) var stravaApi
    @Dependency(\.chartItemsClient) var chartItemsClient
    
    enum Action: Equatable {
        case loadCharts
        case fetchFromStrava
        case dashboardChanged(Dashboard)
        case chartItemTapped(ChartData)
        case updateCharts([ChartData])
        
        
        case chartItems(ChartItemsReducer.Action)
        case chartEditor(ChartEditorReducer.Action)
    }
    
    struct State: Equatable {
        var charts: [ChartData] = [
            ChartData(
                title: "Test",
                type: "BAR",
                dimensions: [],
                measures: [],
                filters: []
            )
        ]
        
        var dashboard: Dashboard? = nil
        
        var chartItems = ChartItemsReducer.State()
        var chartEditor = ChartEditorReducer.State()
    }
    
    
    var body: some ReducerOf<DashboardReducer> {
        Scope(state: \.chartEditor, action: /Action.chartEditor) {
            ChartEditorReducer()
        }
        Scope(state: \.chartItems, action: /Action.chartItems) {
            ChartItemsReducer()
        }
        Reduce { state, action in
            switch action {
            case .dashboardChanged(let dashboard):
                state.dashboard = dashboard
                return .none
            case .loadCharts:
                return .run { send in
                    await send(.chartItems(.onAppear))
                }
            case .fetchFromStrava:
                //                let dashboards = state.dashboards
                return .run {
                    send in
                    let activities = try await self.stravaApi.getUserActivities()
                    let userId: String? = UserDefaults.standard.string(forKey: "userId")
                    let user: Athlete = Athlete(id: Int64(userId!)!, activities: activities, dashboards: [])
                    try await self.firebaseClient.saveToFirebase(user)
                    try self.firebaseClient.saveToDevice(JSONEncoder().encode(activities))
                    await send(.loadCharts)
                }
            case .chartItemTapped(let chartItem):
                state.chartEditor.isEditorOpen = true
                // Copy so editing wont affect the Dashboard state
                //                let chartCopy = ChartData(chartItem: chartItem)
                return .run { send in
                    //                    await send(.chartEditor(.chartToEditChanged(chartCopy)))
                }
            case .updateCharts(let charts):
                state.charts = charts
                return .none
            case .chartItems:
                return .none
            case .chartEditor(.delegate(.save(let chart))):
                if state.charts.contains(chart) {
                    state.charts = state.charts.map({ $0.id == chart.id ? chart : $0 })
                } else {
                    state.charts.append(chart)
                }
                state.chartItems.chartData = state.charts
                return .none
            case .chartEditor:
                return .none
            }
        }
    }
}
