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
    
    enum Action: Equatable {
        case loadCharts
        case fetchFromStrava
        case dashboardChanged(Dashboard)
        case chartItemTapped(ChartData)
        case updateCharts([ChartData])
        
        
        case chartItems(ChartItemsReducer.Action)
        case chartEditor(ChartEditorReducer.Action)
        
        case onSaveTapped
        case onCancelTapped
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case save(Dashboard)
        }
    }
    
    struct State: Equatable {
        var charts: [ChartData] = []
        
        var dashboard: Dashboard? = nil
        
        var chartItems = ChartItemsReducer.State()
        var chartEditor = ChartEditorReducer.State()
    }
    
    @Dependency(\.dismiss) var dismiss
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
                state.charts = dashboard.data
                state.chartItems.chartData = dashboard.data
                return .none
            case .loadCharts:
                guard let dashboard = state.dashboard 
                else { return .none }
                
                state.charts = dashboard.data
                state.chartItems.chartData = dashboard.data
                return .run { send in
                    await send(.chartItems(.loadItems))
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
                return .run { send in
                    await send(.chartEditor(.chartToEditChanged(chartItem)))
                }
            case .updateCharts(let charts):
                state.charts = charts
                return .none
            case .chartItems:
                return .none
            case .chartEditor(.delegate(.save(let chart))):
                debugPrint("DEBUGID: \(chart.id)")
                let contains = state.charts.contains { $0.id == chart.id }
                if contains {
                    debugPrint("CONTAINS")
                    state.charts = state.charts.map({ $0.id == chart.id ? chart : $0 })
                } else {
                    debugPrint("KILLME")
                    state.charts.append(chart)
                }
                state.chartItems.chartData = state.charts
                return .none
            case .chartEditor:
                return .none
            case .onCancelTapped:
                return .run { _ in await self.dismiss() }
            case .onSaveTapped:
                state.dashboard?.data = state.charts
                return .run { [dashboard = state.dashboard ] send in
                    await send(.delegate(.save(dashboard!)))
                    await self.dismiss()
                }
            case .delegate(_):
                return .none
            }
        }
    }
}
