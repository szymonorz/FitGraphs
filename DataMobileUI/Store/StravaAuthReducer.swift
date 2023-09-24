//
//  StravaAuthStore.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

import Foundation
import ComposableArchitecture

struct StravaAuthReducer: Reducer {
    
    enum Action: Equatable {
        case authorize
        case logout
        case authorizedChanged
    }
    
    struct State: Equatable {
        var isAuthorized: Bool = false
    }
    
    var body: some Reducer<State,Action> {
        Reduce { state, action in
            switch action{
            case .authorize:
                return .run { send in
                    await StravaAuth.shared.authorize()
                    await send(.authorizedChanged)
                }
            case .logout:
                return .run { send in
                    await StravaAuth.shared.logout()
                    await send(.authorizedChanged)
                }
            case .authorizedChanged:
                state.isAuthorized.toggle()
                return .none
            }
        }
    }
}
