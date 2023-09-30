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
        case chartEditor(ChartEditorReducer.Action)
        case stravaAuth(StravaAuthReducer.Action)
        case googleAuth(GoogleAuthReducer.Action)
    }
    
    struct State: Equatable {
        var chartItems = ChartItemsReducer.State()
        
        var dashboard = DashboardReducer.State()
        
        var chartEditor = ChartEditorReducer.State()
        
        var stravaAuth = StravaAuthReducer.State()
        
        var googleAuth = GoogleAuthReducer.State()
        
    }
    
    var body: some Reducer<State,Action> {
        Scope(state: \.chartItems, action: /Action.chartItems) {
            ChartItemsReducer()
        }
        
        Scope(state: \.dashboard, action: /Action.dashboard) {
            DashboardReducer()
        }
        
        Scope(state: \.chartEditor, action: /Action.chartEditor) {
            ChartEditorReducer()
        }
        
        Scope(state: \.stravaAuth, action: /Action.stravaAuth) {
            StravaAuthReducer()
        }
        
        Scope(state: \.googleAuth, action: /Action.googleAuth){
            GoogleAuthReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .chartItems(let _):
                return .none
            case .dashboard(let _):
                return .none
            case .chartEditor(let _):
                return .none
            case .stravaAuth(let _):
                return .none
            case .googleAuth(let _):
                return .none
            }
        }
    }
}
