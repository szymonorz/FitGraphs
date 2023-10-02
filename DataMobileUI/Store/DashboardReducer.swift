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
        case addChartTapped
        case updateCharts([ChartData])
        case addChart(ChartData)
        
        
        case chartItems(ChartItemsReducer.Action)
        case chartEditor(PresentationAction<ChartEditorReducer.Action>)
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
        @PresentationState var chartEditor: ChartEditorReducer.State?
    }
    
    
    var body: some ReducerOf<DashboardReducer> {
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
                let currentDashboard = state.dashboard
                return .run { send in
                    do {
                        let athlete = try await self.firebaseClient.loadFromFirebase()
                        let dashboard = athlete.dashboards?.first(where: { $0.id == currentDashboard!.id } )
                        await send(.updateCharts(dashboard!.data))
                    } catch {
                        debugPrint("\(error)")
                    }
                }
            case .fetchFromStrava:
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
                state.chartEditor = ChartEditorReducer.State(
                        chartDataToEdit: chartItem
                )
                return .none
            case .addChartTapped:
                state.chartEditor = ChartEditorReducer.State(
                        chartDataToEdit: ChartData(
                            title: "new",
                            type: "BAR",
                            dimensions: [],
                            measures: [],
                            filters: [])
                )
                return .none
            case .chartEditor(.presented(.delegate(.save(let chartData)))):
                if state.charts.contains(chartData) {
                    state.charts = state.charts.map({ return $0.id == chartData.id ? chartData : $0 })
                } else {
                    state.charts.append(chartData)
                }
                return .none
            case .updateCharts(let charts):
                state.charts = charts
                return .none
            case .chartItems:
                return .none
            case .chartEditor(.dismiss):
                return .none
            case .chartEditor(.presented(.titleChanged(_))):
                return .none
            case .chartEditor(.presented(.typeChanged(_))):
                return .none
            case .chartEditor(.presented(.addDimension(_))):
                return .none
            case .chartEditor(.presented(.removeDimension(_))):
                return .none
            case .chartEditor(.presented(.addMeasure(_))):
                return .none
            case .chartEditor(.presented(.removeMeasure(_))):
                return .none
            case .chartEditor(.presented(.addFilter(_))):
                return .none
            case .chartEditor(.presented(.removeFilter(_))):
                return .none
            case .chartEditor(.presented(.recalcChartItem)):
                return .none
            case .chartEditor(.presented(.updateChartItemView(_))):
                return .none
            case .chartEditor(.presented(.openEditor)):
                return .none
            case .chartEditor(.presented(.closeEditor)):
                return .none
            case .chartEditor(.presented(.editorOpenChanged(_))):
                return .none
            case .chartEditor(.presented(.openCreator)):
                return .none
            case .chartEditor(.presented(.closeCreator)):
                return .none
            case .chartEditor(.presented(.creatorOpenChanged(_))):
                return .none
            case .chartEditor(.presented(.queryCorrectChanged(_))):
                return .none
            case .chartEditor(.presented(.onCancelTapped)):
                return .none
            case .chartEditor(.presented(.onSaveTapped)):
                return .none
            }
        }
    }
}
