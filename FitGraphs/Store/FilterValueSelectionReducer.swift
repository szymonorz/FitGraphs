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
        var startDate: Date = Date.distantPast
        var endDate: Date = Date.distantFuture
    }
    
    enum Action: Equatable {
        case isExclusionary(Bool)
        case delegate(Delegate)
        case startDateChanged(Date)
        case endDateChanged(Date)
        case updateDateRange([String])
        case updateDateRangeFilter
        case onFilterChanged(CubeQuery.Filter)
        enum Delegate: Equatable {
            case apply(CubeQuery.Filter)
            case close
        }
        case onApplyTapped
        case onCancelTapped
        case onValueTapped(String)
        case addValue(String)
        case removeValue(String)
    }
    
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
            case .startDateChanged(let startDate):
                state.startDate = startDate
                return .run {
                    send in
                    await send(.updateDateRangeFilter)
                }
            case .endDateChanged(let endDate):
                state.endDate = endDate
                return .run {
                    send in
                    await send(.updateDateRangeFilter)
                }
            case .updateDateRangeFilter:
                var df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                state.filter.chosen = [df.string(from:state.startDate), df.string(from:state.endDate)]
                return .none
            case .updateDateRange(let values):
                if values.isEmpty {
                    return .none
                }
                let v = values.sorted(by: Comparators.compareDates)
                let startDateString = v.first!
                let endDateString = v.last!
                var dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let d1 = dateFormatter.date(from: String(startDateString.prefix(10)))!
                let d2 = dateFormatter.date(from: String(endDateString.prefix(10)))!
                state.startDate = d1
                state.endDate = d2
                state.filter.chosen = [dateFormatter.string(from:state.startDate), dateFormatter.string(from:state.endDate)]
                return .none
                
            case .onFilterChanged(let filter):
                state.filter = filter
                if filter.name == "Date" {
                    return .run {
                        send in
                        await send(.updateDateRange(filter.values))
                    }
                }
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
                return .run {
                    send in
                    await send(.delegate(.close))
                }
            case .delegate:
                return .none
            }
        }
    }
}
