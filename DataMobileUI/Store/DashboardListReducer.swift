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
        case saveToFirebase([Dashboard])
        case onDashboardTapped(Dashboard)
        case deleteDashboard(Dashboard)
        case addDashboardTapped
        case addDashboard(PresentationAction<AddDashboardReducer.Action>)
        
        case dashboard(DashboardReducer.Action)
        case path(StackAction<DashboardReducer.State,DashboardReducer.Action>)
    }
    
    struct State: Equatable {
        var dashboards: [Dashboard] = []
        var currentDashboard: Dashboard? = nil
        
        var dashboard = DashboardReducer.State()
        var path = StackState<DashboardReducer.State>()
        @PresentationState var addDashboard: AddDashboardReducer.State?
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
                return .run { send in
                    do {
                        let athlete = try await self.firebaseClient.loadFromFirebase()
                        await send(.dashboardsChanged(athlete.dashboards ?? []))
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
                    await send(.saveToFirebase(dashboardsCopy))
                }
            case .saveToFirebase(let dashboards):
                return .run { send in
                    do {
                        var athlete = try await self.firebaseClient.loadFromFirebase()
                        athlete.dashboards = dashboards
                        try await self.firebaseClient.saveToFirebase(athlete)
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
                state.addDashboard = AddDashboardReducer.State(
                    dashboard: Dashboard(name: "new", data: [])
                )
                return .none
            case .addDashboard(.presented(.delegate(.save(let dashboard)))):
                state.dashboards.append(dashboard)
                return .run { [dashboards = state.dashboards] send in
                    await send(.saveToFirebase(dashboards))
                }
            case .dashboard:
                return .none
            case let .path(.element(id: id, action: .delegate(.save(dashboard)))):
                guard let dashboardState = state.path[id: id]
                else { return .none }
                
                let contains = state.dashboards.contains { $0.id == dashboardState.dashboard!.id }
                if contains {
                    debugPrint("KURWAAAA")
                    state.dashboards = state.dashboards.map({ $0.id == dashboard.id ? dashboard : $0 })
                } else {
                    debugPrint("Should never happen lol")
                    state.dashboards.append(dashboard)
                }
                return .run { [dashboards = state.dashboards] send in
                    await send(.saveToFirebase(dashboards))
                }
            case .path:
                return .none
            case .addDashboard(.dismiss):
                return .none
            case .addDashboard(.presented(_)):
                return .none
            }
        }
        .ifLet(\.$addDashboard, action: /Action.addDashboard) {
            AddDashboardReducer()
        }
        .forEach(\.path, action: /Action.path) {
            DashboardReducer()
        }
    }
}
