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
        
        case addDimension(CubeQuery.Aggregation)
        case removeDimension(CubeQuery.Aggregation)
        
        case addMeasure(CubeQuery.Aggregation)
        case removeMeasure(CubeQuery.Aggregation)
        
        case addFilter(CubeQuery.Aggregation)
        case removeFilter(CubeQuery.Aggregation)
        
        case cubeQueryChanged(CubeQuery)
        
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
        var cubeQuery: CubeQuery = CubeQuery()
        
        var chartDataToEdit: ChartData = ChartData(
            title: "new",
            type: "BAR",
            query: CubeQuery()
        )
        var chartItemToEdit: ChartItem = ChartItem(
            name: "new",
            type: "BAR",
            data: []
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
                state.queryCorrect = false
                state.isCreatorOpen = true
                state.cubeQuery = CubeQuery()
                state.title = "new"
                state.type = "BAR"
                state.chartDataToEdit = ChartData(
                    title: "new",
                    type: "BAR",
                    query: CubeQuery())
                state.chartItemToEdit = ChartItem(
                    name: "new",
                    type: "BAR",
                    data: [])
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
                state.cubeQuery.dimensions.append(dimension)
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .removeDimension(let dimension):
                state.cubeQuery.dimensions.remove(at: state.cubeQuery.dimensions.firstIndex(of: dimension)!)
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .addMeasure(let measure):
                state.cubeQuery.measures.append(measure)
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .removeMeasure(let measure):
                state.cubeQuery.measures.remove(at: state.cubeQuery.measures.firstIndex(of: measure)!)
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .addFilter(let filter):
                state.cubeQuery.filters.append(filter)
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .removeFilter(let filter):
                state.cubeQuery.filters.remove(at: state.cubeQuery.filters.firstIndex(of: filter)!)
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .cubeQueryChanged(let cubeQuery):
                state.chartDataToEdit.query = cubeQuery
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .chartToEditChanged(let chartToEdit):
                state.chartDataToEdit = chartToEdit
                state.cubeQuery = chartToEdit.query
                state.type = chartToEdit.type
                state.title = chartToEdit.title
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .recalcChartItem:
                return .run {
                    [
                        _chartItem = state.chartItemToEdit,
                        chartData = state.chartDataToEdit
                    ] send in
                    let chartItem = ChartItem(
                        id: _chartItem.id,
                        name: chartData.title,
                        type: chartData.type,
                        data: []
                    )
                    let chartDataCopy = ChartData(
                        id: chartData.id,
                        title: chartData.title,
                        type: chartData.type,
                        query: chartData.query
                    )
                    if chartDataCopy.query.dimensions.count > 2 {
                        chartItem.data = []
                        chartItem.errorMsg = "Can handle up to 2 dimensions max"
                        await send(.queryCorrectChanged(false))
                    } else if chartDataCopy.query.measures.count > 1 {
                        chartItem.data = []
                        chartItem.errorMsg = "Can handle only one measure"
                        await send(.queryCorrectChanged(false))
                    } else if chartDataCopy.query.measures.count < 1 || chartDataCopy.query.dimensions.count < 1 {
                        chartItem.data = []
                        chartItem.errorMsg = "Needs at least one measure and one dimensions"
                        await send(.queryCorrectChanged(false))
                    } else {
                        debugPrint("MATH")
                        do {
                            let chartItemData = try DataSource.shared.query(cubeQuery: chartDataCopy.query)
                            chartItem.data = chartItemData
                            await send(.queryCorrectChanged(true))
                        } catch {
                            chartItem.data = []
                            chartItem.errorMsg = error.localizedDescription
                            await send(.queryCorrectChanged(false))
                        }
                    }
                    await send(.updateChartItemView(chartItem))
                }
            case .updateChartItemView(let chartItem):
                state.chartItemToEdit = chartItem
                debugPrint("UPDATE")
                return .none
            case .onCancelTapped:
                return .run { send in
                    await send(.editorOpenChanged(false))
                    await send(.creatorOpenChanged(false))
                }
            case .onSaveTapped:
                let chartItemToSave = state.chartDataToEdit
                return .run { send in
                    await send(.delegate(.save(chartItemToSave)))
                    await send(.editorOpenChanged(false))
                    await send(.creatorOpenChanged(false))
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
