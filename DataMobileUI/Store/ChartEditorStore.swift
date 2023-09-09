//
//  ChartEditorStore.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

import Foundation
import ComposableArchitecture

struct ChartEditorStore: Reducer {
    
    @Dependency(\.chartItemsClient) var chartItemsClient
    
    enum Action: Equatable {
        case onSaveTapped
        case titleChanged(String)
        	
        case dimensionsChanged([String])
        case measuresChanged([String])
        case filterChanged([String])
    }
    
    struct State: Equatable {
        
        var title = "new"
        
        var dimensions: [String] = []
        var measures: [String] = []
        var filters: [String] = []
        
        var chartItemToEdit: ChartItem?
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .titleChanged(let title):
                state.title = title
                return .none
            case .dimensionsChanged(let dimensions):
                state.dimensions = dimensions
                return .none
            case .filterChanged(let filter):
                state.filters = filter
                return .none
            case .measuresChanged(let measures):
                state.measures = measures
                return .none
            case .onSaveTapped:
                return .run {
                    [
                        title = state.title,
                        dimensions = state.dimensions,
                        measures = state.measures,
                        filters = state.filters
                    ] send in
                    let chartItem = ChartItem(
                        name: title,
                        type: "BAR",
                        contents: [],
                        dimensions: dimensions,
                        measures: measures,
                        filters: filters
                    )
                    
                    do {
                        chartItem.contents = try DataSource.shared.query(dimensions: chartItem.dimensions, measures: chartItem.dimensions)
                        await chartItemsClient.updateChartItem(chartItem)
                    } catch {
                        debugPrint("kurwa")
                    }
                }
            }
        }
    }
    
    
}
