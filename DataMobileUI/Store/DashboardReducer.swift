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
        case addChart(ChartData)

        
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
        var charts: [ChartData] = [
            ChartData(
                name: "Test",
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
                return .none
            case .addChart(let chart):
                state.charts.append(chart)
                return .run { send in
                    await send(.chartItems(.onAppear))
                }
            case .loadCharts:
                return .run { send in
                    do {
                        let charts = try await self.chartItemsClient.fetchChartItems()
                        debugPrint(charts.count)
//                        await send(.updateCharts(charts))
                    } catch {
                        debugPrint("\(error)")
                    }
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
//            case .onSaveTapped:
//                let chartData: [ChartData] = state.chartItems.chartData
//                let dashboards = state.dashboards
//                
//                return .run { send in
//                    do {
//                        var athlete: Athlete = try self.firebaseClient.loadFromFirebase()
//                        athlete.dashboards = dashboards
//                        try await self.firebaseClient.saveToFirebase(athlete)
//                    } catch {
//                        
//                    }
//                }
            case .updateCharts(let charts):
                state.charts = charts
                return .none
            case .chartItems:
                return .none
            case .chartEditor:
                return .none
            case .onSaveTapped:
                return .run { [dashboard = state.dashboard! ] send in
                    await send(.delegate(.save(dashboard)))
                    await self.dismiss()
                }
            case .onCancelTapped:
                return .run { _ in await self.dismiss() }
            case .delegate:
                return .none
            }
        }
    }
}
