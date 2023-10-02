//
//  ChartEditorStore.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

import Foundation
import ComposableArchitecture

struct ChartEditorReducer: Reducer {
    enum Action: Equatable {
        case titleChanged(String)
        case typeChanged(String)
        
        case addDimension(String)
        case removeDimension(String)
        
        case addMeasure(String)
        case removeMeasure(String)
        
        case addFilter(String)
        case removeFilter(String)
        
        case chartToEditChanged(ChartData)
        
        case recalcChartItem
        case updateChartItemView(ChartItem)
        
        
        case openEditor
        case closeEditor
        case editorOpenChanged(Bool)
        
        case openCreator
        case closeCreator
        case creatorOpenChanged(Bool)
        
        case queryCorrectChanged(Bool)
        
        case onSaveTapped
        case onCancelTapped
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case save(ChartData)
        }
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
        
        var chartDataToEdit: ChartData = ChartData(
            title: "new",
            type: "BAR",
            dimensions: [],
            measures: [],
            filters: []
        )
        var chartItemToEdit: ChartItem = ChartItem(
            name: "new",
            type: "BAR",
            contents: []
        )
    }
    
    @Dependency(\.dismiss) var dismiss
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
                state.chartDataToEdit.title = title
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .typeChanged(let type):
                state.type = type
                state.chartDataToEdit.type = type
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .addDimension(let dimension):
                state.dimensions.append(dimension)
                state.chartDataToEdit.dimensions = state.dimensions
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .removeDimension(let dimension):
                state.dimensions.remove(at: state.dimensions.firstIndex(of: dimension)!)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .addMeasure(let measure):
                state.measures.append(measure)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .removeMeasure(let measure):
                state.measures.remove(at: state.measures.firstIndex(of: measure)!)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .addFilter(let filter):
                state.filters.append(filter)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .removeFilter(let filter):
                state.filters.remove(at: state.filters.firstIndex(of: filter)!)
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .chartToEditChanged(let chartToEdit):
                state.chartDataToEdit = chartToEdit
                return .none
            case .recalcChartItem:
                return .run {
                    [
                        id = state.chartDataToEdit.id,
                        title = state.title,
                        type = state.type,
                        dimensions = state.dimensions,
                        measures = state.measures,
                        filters = state.filters
                    ] send in
                    
                    let chartDataToEdit = ChartData(
                        id: id,
                        title: title,
                        type: type,
                        dimensions: dimensions,
                        measures: measures,
                        filters: filters
                    )
                    
                    await send(.chartToEditChanged(chartDataToEdit))
                    
                    let chartItem = ChartItem(
                        id: id,
                        name: title,
                        type: type,
                        contents: []
                    )
                    debugPrint("MATH")
                    do {
                        chartItem.contents = try DataSource.shared.query(dimensions: dimensions,
                                                                         measures: measures)
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
            case .onCancelTapped:
                return .none
            case .onSaveTapped:
                let chartItemToSave = state.chartDataToEdit
                return .run { send in
                    await send(.delegate(.save(chartItemToSave)))
                }
            case .queryCorrectChanged(let correct):
                state.queryCorrect = correct
                return .none
            case .delegate(_):
                return .none
            }
        }
    }
}
