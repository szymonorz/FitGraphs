//
//  RootStore.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

import Foundation
import ComposableArchitecture

struct RootReducer: Reducer {
    
    enum Action: Equatable {
        case dashboardList(DashboardListReducer.Action)
        case chartEditor(ChartEditorReducer.Action)
        case settings(SettingsReducer.Action)
        case login(LoginReducer.Action)
        case demoModeEnabledChanged(Bool)
    }
    
    struct State: Equatable {
        
        var dashboardList = DashboardListReducer.State()
        
        var chartEditor = ChartEditorReducer.State()
        
        var settings = SettingsReducer.State()
        
        var login = LoginReducer.State()
        
        var demoModeEnabled: Bool = false
        
    }
    
    var body: some Reducer<State,Action> {
        Scope(state: \.dashboardList, action: /Action.dashboardList){
            DashboardListReducer()
        }
        
        Scope(state: \.chartEditor, action: /Action.chartEditor) {
            ChartEditorReducer()
        }
        
        Scope(state: \.settings, action: /Action.settings) {
            SettingsReducer()
        }
        
        Scope(state: \.login, action: /Action.login){
            LoginReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .dashboardList:
                return .none
            case .chartEditor:
                return .none
            case .settings(.delegate(.logoutFromFirebase)):
                return .run { send in
                    await send(.login(.googleAuth(.signOut)))
                }
            case .settings(.delegate(.exitDemo)):
                return .run {
                    send in
                    await send(.demoModeEnabledChanged(false))
                }
            case .settings:
                return .none
            case .login(.delegate(.demoMode)):
                return .run {
                    send in
                    await send(.demoModeEnabledChanged(true))
                }
            case .login:
                return .none
            case .demoModeEnabledChanged(let demoModeEnabled):
                state.demoModeEnabled = demoModeEnabled
                if demoModeEnabled {
                    do {
                        try Cube.shared.loadDemoData()
                    } catch {
                        debugPrint("[CRITICAL] Failed to load demo data.")
                        return .none
                    }
                } else {
                    do {
                        try Cube.shared.loadFromFilesystem()
                    } catch {
                        debugPrint("[CRITICAL] Failed to load data from fs \(error)")
                        return .none
                    }
                }
                return .run {
                    send in
                    await send(.settings(.demoModeEnabledChanged(demoModeEnabled)))
                    await send(.dashboardList(.demoModeEnabledChanged(demoModeEnabled)))
                }
            }
        }
    }
}
