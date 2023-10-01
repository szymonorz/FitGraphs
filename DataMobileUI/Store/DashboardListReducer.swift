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
        
        case dashboard(DashboardReducer.Action)
    }
    
    struct State: Equatable {
        var dashboards: [Dashboard] = []
        var currentDashboard: Dashboard? = nil
        
        var dashboard = DashboardReducer.State()
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
                        let athlete = try self.firebaseClient.loadFromFirebase()
                        await send(.dashboardsChanged(athlete.dashboards))
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
                        var athlete = try self.firebaseClient.loadFromFirebase()
                        athlete.dashboards = dashboards
                        try await self.firebaseClient.saveToFirebase(athlete)
                    } catch {
                        debugPrint("saveToFirebase: \(error.localizedDescription)")
                    }
                }
            case .onDashboardTapped(let dashboard):
                state.currentDashboard = dashboard
                return .run { send in
                    await send(.dashboard(.dashboardChanged(dashboard)))
                }
            case .dashboard(let _):
                return .none
            }
        }
    }
}
