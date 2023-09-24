//
//  ChartEditorStore.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

import Foundation
import ComposableArchitecture

struct ChartEditorReducer: Reducer {
    
    @Dependency(\.chartItemsClient) var chartItemsClient
    
    enum Action: Equatable {
        case titleChanged(String)
        case typeChanged(String)
        
        case addDimension(String)
        case removeDimension(String)
        
        case addMeasure(String)
        case removeMeasure(String)
        
        case addFilter(String)
        case removeFilter(String)
        
        case chartToEditChanged(ChartItem)
        
        case recalcChartItem
        case updateChartItemView(ChartItem)
        
        case updateChartItem
        case saveChartItem
        
        case openEditor
        case closeEditor
        case editorOpenChanged(Bool)
        
        case openCreator
        case closeCreator
        case creatorOpenChanged(Bool)
        
        case queryCorrectChanged(Bool)
    }
    
    struct State: Equatable {
        var isEditorOpen: Bool = false
        var isCreatorOpen: Bool = false
        var queryCorrect: Bool = false
        var title = "new"
        var type = "BAR"
        var dimensions: [String] = []
        var measures: [String] = []
        var filters: [String] = []
        
        var chartItemToEdit: ChartItem = ChartItem(
            name: "new",
            type: "BAR",
            contents: [],
            dimensions: [],
            measures: [],
            filters: []
        )
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .openEditor:
                state.isEditorOpen = true
                return .none
            case .closeEditor:
                state.isEditorOpen = false
                return .none
            case .editorOpenChanged(let isEditorOpen):
                state.isEditorOpen = isEditorOpen
                return .none
            case .openCreator:
                state.isCreatorOpen = true
                state.measures = []
                state.dimensions = []
                state.filters = []
                state.title = "new"
                state.type = "BAR"
                state.chartItemToEdit = ChartItem(
                    name: "new",
                    type: "BAR",
                    contents: [])
                return .none
            case .closeCreator:
                state.isCreatorOpen = false
                return .none
            case .creatorOpenChanged(let isCreatorOpen):
                state.isCreatorOpen = isCreatorOpen
                return .none
            case .titleChanged(let title):
                state.title = title
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .typeChanged(let type):
                state.type = type
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .addDimension(let dimension):
                state.dimensions.append(dimension)
                state.chartItemToEdit.dimensions.append(dimension)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .removeDimension(let dimension):
                state.dimensions.remove(at: state.dimensions.firstIndex(of: dimension)!)
                state.chartItemToEdit.dimensions.remove(at: state.chartItemToEdit.dimensions.firstIndex(of: dimension)!)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .addMeasure(let measure):
                state.measures.append(measure)
                state.chartItemToEdit.measures.append(measure)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .removeMeasure(let measure):
                state.measures.remove(at: state.measures.firstIndex(of: measure)!)
                state.chartItemToEdit.measures.remove(at: state.chartItemToEdit.measures.firstIndex(of: measure)!)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .addFilter(let filter):
                state.filters.append(filter)
                state.chartItemToEdit.filters.append(filter)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .removeFilter(let filter):
                state.filters.remove(at: state.filters.firstIndex(of: filter)!)
                state.chartItemToEdit.filters.remove(at: state.chartItemToEdit.filters.firstIndex(of: filter)!)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .chartToEditChanged(let chartToEdit):
                state.chartItemToEdit = chartToEdit
                state.measures = chartToEdit.measures
                state.dimensions = chartToEdit.dimensions
                state.filters = chartToEdit.filters
                state.type = chartToEdit.type
                state.title = chartToEdit.name
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .recalcChartItem:
                return .run {
                    [
                        id = state.chartItemToEdit.id,
                        title = state.title,
                        type = state.type,
                        dimensions = state.dimensions,
                        measures = state.measures,
                        filters = state.filters
                    ] send in
                    let chartItem = ChartItem(
                        id: id,
                        name: title,
                        type: type,
                        contents: [],
                        dimensions: dimensions,
                        measures: measures,
                        filters: filters
                    )
                    debugPrint("MATH")
                    do {
                        chartItem.contents = try DataSource.shared.query(dimensions: chartItem.dimensions,
                                                                         measures: chartItem.measures)
                        await send(.updateChartItemView(chartItem))
                        await send(.queryCorrectChanged(true))
                    } catch {
                        debugPrint("kurwa")
                        await send(.queryCorrectChanged(false))
                    }
                }
            case .updateChartItemView(let chartItem):
                state.chartItemToEdit = chartItem
                return .none
            case .updateChartItem:
                let chartItemToSave = state.chartItemToEdit
                return .run { send in
                    await chartItemsClient.updateChartItem(chartItemToSave)
                }
            case .saveChartItem:
                let chartItemToSave = state.chartItemToEdit
                return .run { send in
                    await chartItemsClient.addChartItem(chartItemToSave)
                }
            case .queryCorrectChanged(let correct):
                state.queryCorrect = correct
                return .none
            }
        }
    }
}
