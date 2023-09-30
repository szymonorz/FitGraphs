//
//  GoogleAuthReducer.swift
//  DataMobileUI
//
//  Created by b on 27/09/2023.
//

import Foundation
import ComposableArchitecture

struct GoogleAuthReducer: Reducer {
    
    enum Action: Equatable {
        case signIn
        case signOut
        
        case authorized(Bool)
    }
    
    struct State: Equatable {
        var isAuthorized: Bool = false
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .signIn:
                return .run { send in
                    let authorized = await FirebaseGoogleAuth.shared.signInWithGoogle()
                    await send(.authorized(authorized))
                }
            case .signOut:
                return .run { send in
                    do {
                        try FirebaseGoogleAuth.shared.signOut()
                        await send(.authorized(false))
                    } catch {
                        debugPrint("\(error.localizedDescription)")
                    }
                }
            case .authorized(let isAuthorized):
                state.isAuthorized = isAuthorized
                return .none
            }
        }
    }
}
