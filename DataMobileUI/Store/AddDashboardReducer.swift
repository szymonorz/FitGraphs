//
//  AddDashboardReducer.swift
//  DataMobileUI
//
//  Created by b on 02/10/2023.
//

import ComposableArchitecture

struct AddDashboardReducer: Reducer {
    struct State: Equatable {
        var dashboard: Dashboard? = nil
    }
    
    enum Action: Equatable {
        case onSaveTapped
        case onCancelTapped
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case save(Dashboard)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onSaveTapped:
                return .run { [dashboard = state.dashboard! ] send in
                    await send(.delegate(.save(dashboard)))
                    await self.dismiss()
                }
            case .onCancelTapped:
                return .run { _ in await self.dismiss() }
            case .delegate:
                return .none
            }
        }
    }
}
