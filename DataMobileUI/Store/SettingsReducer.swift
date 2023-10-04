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
    }
    
    enum Action: Equatable {
        case stravaAuth(StravaAuthReducer.Action)
        case logoutTapped
        case alert(PresentationAction<Alert>)
        case fetchFromStrava
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
            case .fetchFromStrava:
                return .run {
                    send in
                    let activities = try await self.stravaApi.getUserActivities()
                    var athlete = try await self.firebaseClient.loadFromFirebase()
                    athlete.activities = activities
                    try await self.firebaseClient.saveToFirebase(athlete)
                    try self.firebaseClient.saveToDevice(JSONEncoder().encode(activities))
                }
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
