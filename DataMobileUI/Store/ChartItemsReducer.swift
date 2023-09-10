//
//  ChartItemStore.swift
//  DataMobileUI
//
//  Created by b on 09/09/2023.
//

import Foundation
import ComposableArchitecture

class ChartItemsReducer: Reducer {
    
    
    @Dependency(\.chartItemsClient) var chartItemsClient
    
    enum Action: Equatable {
        case onAddButtonTapped
        case onDeleteButtonTapped
    }
    
    struct State: Equatable {
        var chartItems: [ChartItem] = []
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
