//
//  RootStore.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

import Foundation
import ComposableArchitecture

struct RootReducer: Reducer {
    
    @Dependency(\.stravaApi) var stravaApi
    @Dependency(\.firebaseClient) var firebaseClient
    
    enum Action: Equatable {
        case chartItems(ChartItemsReducer.Action)
        case dashboard(DashboardReducer.Action)
        case dashboardList(DashboardListReducer.Action)
        case chartEditor(ChartEditorReducer.Action)
        case settings(SettingsReducer.Action)
        case googleAuth(GoogleAuthReducer.Action)
    }
    
    struct State: Equatable {
        var chartItems = ChartItemsReducer.State()
        
        var dashboard = DashboardReducer.State()
        
        var dashboardList = DashboardListReducer.State()
        
        var chartEditor = ChartEditorReducer.State()
        
        var settings = SettingsReducer.State()
        
        var googleAuth = GoogleAuthReducer.State()
        
    }
    
    var body: some Reducer<State,Action> {
        Scope(state: \.chartItems, action: /Action.chartItems) {
            ChartItemsReducer()
        }
        Scope(state: \.dashboardList, action: /Action.dashboardList){
            DashboardListReducer()
        }
        
        Scope(state: \.dashboard, action: /Action.dashboard) {
            DashboardReducer()
        }
        
        Scope(state: \.chartEditor, action: /Action.chartEditor) {
            ChartEditorReducer()
        }
        
        Scope(state: \.settings, action: /Action.settings) {
            SettingsReducer()
        }
        
        Scope(state: \.googleAuth, action: /Action.googleAuth){
            GoogleAuthReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .chartItems(let _):
                return .none
            case .dashboardList(let _):
                return .none
            case .dashboard(let _):
                return .none
            case .chartEditor(let _):
                return .none
            case .settings(.delegate(.logoutFromFirebase)):
                return .run { send in
                    await send(.googleAuth(.signOut))
                }
            case .settings(let _):
                return .none
            case .googleAuth(let _):
                return .none
            }
        }
    }
}
