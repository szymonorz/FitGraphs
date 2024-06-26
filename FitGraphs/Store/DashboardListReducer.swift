//
//  DashboardListReducer.swift
//  DataMobileUI
//
//  Created by b on 01/10/2023.
//

import Foundation
import ComposableArchitecture

class DashboardListReducer: Reducer {
    @Dependency(\.firebaseClient) var firebaseClient
    
    var demoDashboardList: [Dashboard] = [
        Dashboard(
            name: "Moje osiagniecia",
            data: [
                ChartData(
                    title: "Bieganie w roku",
                    type: "BAR",
                    query: CubeQuery(
                        dimensions: [CubeQuery.Aggregation(name: "Month", expression: "MonthLocal")],
                        measures: [CubeQuery.Aggregation(name: "Activity", expression: "SUM(Activity)")],
                        filters: [CubeQuery.Filter(name: "SportType", exclude: false,  values: ["Run", "Swim", "Ride"], chosen: ["Run"])]
                    )
                ),
                ChartData(
                    title: "Dystans jazdy w pierwszym kwartale",
                    type: "LINE",
                    query: CubeQuery(
                        dimensions: [CubeQuery.Aggregation(name: "Date", expression: "DateLocal")],
                        measures: [CubeQuery.Aggregation(name: "Distnace", expression: "SUM(Distance)")],
                        filters: [CubeQuery.Filter(name: "Date", exclude: false,  values: [], chosen: ["2023-01-01", "2023-03-30"])]
                    )
                ),
                ChartData(
                    title: "Rozkład aktywności",
                    type: "PIE",
                    query: CubeQuery(
                        dimensions: [CubeQuery.Aggregation(name: "SportType", expression: "SportType")],
                        measures: [CubeQuery.Aggregation(name: "Activity", expression: "SUM(Activity)")]
                    )
                )
            ]
        )
    ]
    
    enum Action: Equatable {
        case dashboardsChanged([Dashboard])
        case onAppear
        case save([Dashboard])
        case onDashboardTapped(Dashboard)
        case onDeleteTapped(Dashboard)
        case deleteDashboard(Dashboard)
        case addDashboardTapped
        case destination(PresentationAction<Destination.Action>)
        case demoModeEnabledChanged(Bool)
        
        case dashboard(DashboardReducer.Action)
        case path(StackAction<DashboardReducer.State,DashboardReducer.Action>)
        
        enum Alert: Equatable {
            case confirmDelete(Dashboard)
        }
    }
    
    struct State: Equatable {
        var dashboards: [Dashboard] = []
        var currentDashboard: Dashboard? = nil
        var demoModeEnabled: Bool = false
        
        var dashboard = DashboardReducer.State()
        var path = StackState<DashboardReducer.State>()
        @PresentationState var destination: Destination.State?
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.dashboard, action: /Action.dashboard) {
            DashboardReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .dashboardsChanged(let dashboards):
                state.dashboards = dashboards
                return .none
            case .onAppear:
                return .run { 
                    [
                        demoModeEnabled = state.demoModeEnabled,
                        _dashboards = self.demoDashboardList
                    ]
                    send in
                    if !demoModeEnabled && !Cube.shared.tableExists() {
                        do {
                            try Cube.shared.loadFromFilesystem()
                        } catch {
                            debugPrint("[CRITICAL] Failed to load data from fs: \(error)")
                        }
                    }
                    do {
                        let athlete = !demoModeEnabled ? try await self.firebaseClient.loadFromFirebase() : Athlete(id: 69, dashboards: _dashboards)
                        await send(.dashboardsChanged(athlete?.dashboards ?? []))
                    } catch {
                        debugPrint("onAppear: \(error.localizedDescription)")
                    }
                }
            case .deleteDashboard(let dashboard):
                var dashboards = state.dashboards
                dashboards.remove(at: dashboards.firstIndex(of: dashboard)!)
                let dashboardsCopy = dashboards
                return .run { send in
                    await send(.dashboardsChanged(dashboardsCopy))
                    await send(.save(dashboardsCopy))
                }
            case .save(let dashboards):
                return .run { 
                    [demoModeEnabled = state.demoModeEnabled]
                    send in
                    do {
                        if !demoModeEnabled {
                            var athlete: Athlete? = try await self.firebaseClient.loadFromFirebase()
                            if athlete == nil {
                                let userId: String? = UserDefaults.standard.string(forKey: "userId")
                                athlete = Athlete(id: Int64(userId!)!, activities: [], dashboards: [])
                            }
                            athlete!.dashboards = dashboards
                            try await self.firebaseClient.saveToFirebase(athlete!)
                        }
                    } catch {
                        debugPrint("saveToFirebase: \(error.localizedDescription)")
                    }
                    await send(.onAppear)
                }
            case .onDashboardTapped(let dashboard):
                state.currentDashboard = dashboard
                return .run { send in
                    await send(.dashboard(.dashboardChanged(dashboard)))
                }
            case .addDashboardTapped:
                state.destination = .addDashboard(
                    AddDashboardReducer.State(
                        dashboard: Dashboard(name: "new", data: [])
                    )
                )
                return .none
            case .destination(.presented(.addDashboard(.delegate(.save(let dashboard))))):
                state.dashboards.append(dashboard)
                return .run { [dashboards = state.dashboards] send in
                    await send(.save(dashboards))
                }
            case .destination(.presented(.alert(.confirmDelete(let dashboard)))):
                return .run { send in
                    await send(.deleteDashboard(dashboard))
                    }
            case .destination:
                return .none
            case .demoModeEnabledChanged(let demoModeEnabled):
                state.demoModeEnabled = demoModeEnabled
                if demoModeEnabled == true {
                    state.dashboards = []
                }
                return .none
            case .onDeleteTapped(let dashboard):
                state.destination = .alert(
                    AlertState {
                        TextState("Are you sure you want to delete dashboard \(dashboard.name). You can't undo this operation")
                    } actions: {
                        ButtonState(role: .destructive, action: .confirmDelete(dashboard)) {
                            TextState("Delete")
                        }
                    }
                )
            case .dashboard:
                return .none
            case let .path(.element(id: id, action: .delegate(.save(dashboard)))):
                guard let dashboardState = state.path[id: id]
                else { return .none }
                
                let contains = state.dashboards.contains { $0.id == dashboardState.dashboard!.id }
                if contains {
                    state.dashboards = state.dashboards.map({ $0.id == dashboard.id ? dashboard : $0 })
                } else {
                    debugPrint("Should never happen lol")
                    state.dashboards.append(dashboard)
                }
                return .run { [dashboards = state.dashboards] send in
                    await send(.save(dashboards))
                }
            case .path(_):
                return .none
            }
            return .none
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
        .forEach(\.path, action: /Action.path) {
            DashboardReducer()
        }
    }
}


extension DashboardListReducer {
    struct Destination: Reducer {
        enum Action: Equatable {
            case addDashboard(AddDashboardReducer.Action)
            case alert(DashboardListReducer.Action.Alert)
        }
        
        enum State: Equatable {
            case addDashboard(AddDashboardReducer.State)
            case alert(AlertState<DashboardListReducer.Action.Alert>)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.addDashboard, action: /Action.addDashboard) {
                AddDashboardReducer()
            }
        }
    }
}
