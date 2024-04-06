//
//  FilterValueSelectionReducer.swift
//  FitGraphs
//
//  Created by b on 17/02/2024.
//

import Foundation
import ComposableArchitecture

class FilterValueSelectionReducer: Reducer {
    
    struct State: Equatable {
        var filter: CubeQuery.Filter
    }
    
    enum Action: Equatable {
        case isExclusionary(Bool)
        case delegate(Delegate)
        case onFilterChanged(CubeQuery.Filter)
        enum Delegate: Equatable {
            case apply(CubeQuery.Filter)
        }
        case onApplyTapped
        case onCancelTapped
        case onValueTapped(String)
        case addValue(String)
        case removeValue(String)
    }
    
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<FilterValueSelectionReducer> {
        Reduce { state, action in
            switch action {
            case .isExclusionary(let exclusionary):
                state.filter.exclude = exclusionary
                return .none
            case .onApplyTapped:
                return .run { [filter = state.filter]
                    send in
                    await send(.delegate(.apply(filter)))
                }
            case .onFilterChanged(let filter):
                state.filter = filter
                return .none
            case .addValue(let c):
                state.filter.chosen.append(c)
                return .none
            case .removeValue(let c):
                state.filter.chosen.removeAll(where: { $0 == c })
                return .none
            case .onValueTapped(let choice):
                guard let _ = state.filter.chosen.last(where: {$0 == choice}) else {
                    return .run { send in
                        await send(.addValue(choice))
                    }
                }
                return .run { send in
                    await send(.removeValue(choice))
                }
            case .onCancelTapped:
                return .run { _ in await self.dismiss() }
            case .delegate:
                return .none
            }
        }
    }
}
