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
                    [demoModeEnabled = state.demoModeEnabled]
                    send in
                    do {
                        let athlete = !demoModeEnabled ? try await self.firebaseClient.loadFromFirebase() : Athlete(id: 69)
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
