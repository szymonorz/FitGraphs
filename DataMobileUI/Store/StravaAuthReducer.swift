//
//  StravaAuthStore.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

import Foundation
import ComposableArchitecture

struct StravaAuthReducer: Reducer {
    
    @Dependency(\.stravaApi) var stravaApi
    
    enum Action: Equatable {
        case authorize
        case logout
        case authorizedChanged(Bool)
        case storeAthleteData
    }
    
    struct State: Equatable {
        var isAuthorized: Bool = StravaAuth.shared.oauth.hasUnexpiredAccessToken()
    }
    
    var body: some Reducer<State,Action> {
        Reduce { state, action in
            switch action{
            case .authorize:
                return .run { send in
                    await StravaAuth.shared.authorize()
                    await send(.authorizedChanged(true))
                }
            case .logout:
                return .run { send in
                    await StravaAuth.shared.logout()
                    await send(.authorizedChanged(false))
                }
            case .authorizedChanged(let authorized):
                state.isAuthorized = authorized
                return .none
            case .storeAthleteData:
                return .run { send in
                    guard let userId = try? await stravaApi.getUserId() else {
                        debugPrint("Failed to fetch athlete")
                        await send(.authorizedChanged(false))
                        return
                    }
                    UserDefaults.standard.set(userId, forKey: "userId")
                    
                }
            }
        }
    }
}
