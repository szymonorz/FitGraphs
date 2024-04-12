//
//  SettingsReducer.swift
//  DataMobileUI
//
//  Created by b on 04/10/2023.
//

import Foundation
import ComposableArchitecture

class SettingsReducer: Reducer {
    
    @Dependency(\.firebaseClient) var firebaseClient
    @Dependency(\.stravaApi) var stravaApi
    
    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        var stravaAuth = StravaAuthReducer.State()
        var loadErrorVisible: Bool = false
        var demoModeEnabled: Bool = false
    }
    
    enum Action: Equatable {
        case stravaAuth(StravaAuthReducer.Action)
        case logoutTapped
        case alert(PresentationAction<Alert>)
        case fetchFromStrava
        case exitDemo
        case demoModeEnabledChanged(Bool)
        case loadErrorVisibleChanged(Bool)
        enum Alert: Equatable {
            case confirmLogout
        }
        case delegate(Delegate)
        enum Delegate: Equatable {
            case logoutFromFirebase
        }
    }
    
    var body: some ReducerOf<SettingsReducer> {
        Scope(state: \.stravaAuth, action: /Action.stravaAuth){
            StravaAuthReducer()
        }
        Reduce { state, action in
            switch action {
            case .logoutTapped:
                state.alert = AlertState {
                    TextState("Are you sure you want to logout?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmLogout) {
                        TextState("Logout")
                    }
                }
                return .none
            case .alert(.presented(.confirmLogout)):
                return .run { send in
                    await send(.stravaAuth(.logout))
                    await send(.delegate(.logoutFromFirebase))
                }
            case .loadErrorVisibleChanged(let loadErrorVisible):
                state.loadErrorVisible = loadErrorVisible
                return .none
            case .fetchFromStrava:
                return .run {
                    send in
                    do {
                        let activities = try await self.stravaApi.getUserActivities()
                        var athlete: Athlete? = try await self.firebaseClient.loadFromFirebase()
                        if athlete == nil {
                            let userId: String? = UserDefaults.standard.string(forKey: "userId")
                            athlete = Athlete(id: Int64(userId!)!, activities: [], dashboards: [])
                        }
                        athlete?.activities = activities
                        try await self.firebaseClient.saveToFirebase(athlete!)
                        try self.firebaseClient.saveToDevice(JSONEncoder().encode(activities))
                        var reloaded = false
                        try Cube.shared.reload {
                            _reloaded in
                            reloaded = _reloaded
                        }
                        await send(.loadErrorVisibleChanged(reloaded))
                    } catch {
                        debugPrint("\(error)")
                    }
                }
            case .exitDemo:
                return .run {
                    send in
                    await send(.demoModeEnabledChanged(false))
                }
            case .demoModeEnabledChanged(let demoModeEnabled):
                state.demoModeEnabled = demoModeEnabled
                return .none
            case .alert:
                return .none
            case .stravaAuth:
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
