//
//  LoginReducer.swift
//  FitGraphs
//
//  Created by b on 12/04/2024.
//

import Foundation
import ComposableArchitecture

struct LoginReducer: Reducer {
    
    enum Action: Equatable {
        case googleAuth(GoogleAuthReducer.Action)
        case demo
        case delegate(Delegate)
        enum Delegate: Equatable {
            case demoMode
        }
    }
    
    struct State: Equatable {
        var googleAuth: GoogleAuthReducer.State = GoogleAuthReducer.State()
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.googleAuth, action: /Action.googleAuth){
            GoogleAuthReducer()
        }
        Reduce { state, action in
            switch action {
            case .googleAuth:
                return .none
            case .demo:
                return .run {
                    send in
                    await send(.delegate(.demoMode))
                }
            case .delegate:
                return .none
            }
        }
    }
}

