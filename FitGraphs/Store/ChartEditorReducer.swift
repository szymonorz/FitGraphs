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
        case removeDimension(String)
        
        case addMeasure(CubeQuery.Aggregation)
        case removeMeasure(String)
        
        case addFilter(CubeQuery.Filter)
        case removeFilter(String)
        
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
        
        case openFilterSelection(String)
        case filterSelectorOpenChanged(Bool)
        
        case queryCorrectChanged(Bool)
        
        case onSaveTapped
        case onCancelTapped
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case save(ChartData)
        }
        
        case filterValueSelection(FilterValueSelectionReducer.Action)
    }
    
    struct State: Equatable {
        var isEditorOpen: Bool = false
        var isCreatorOpen: Bool = false
        var isFilterSelectorOpen: Bool = false
        var queryCorrect: Bool = false
        var title = "new"
        var type = "BAR"
        var filterValues: [String] = []
        var cubeQuery: CubeQuery = CubeQuery()
        
        var chartDataToEdit: ChartData = ChartData(
            title: "new",
            type: "BAR",
            query: CubeQuery()
        )
        var chartItemToEdit: ChartItem = ChartItem(
            name: "new",
            type: "BAR",
            numOfSplits: 1,
            data: []
        )
        
        var filterValueSelection = FilterValueSelectionReducer.State(filter: CubeQuery.Filter(name: "foo"))
    }
    
    @Dependency(\.dismiss) var dismiss
    var body: some Reducer<State, Action> {
        Scope(state: \.filterValueSelection, action: /Action.filterValueSelection) {
            FilterValueSelectionReducer()
        }
        Reduce { state, action in
            switch action {
            case .openFilterSelection(let filter):
                var filterValues: [String] = []
                do {
                    filterValues = try Cube.shared.getUniqueValues(columnName: filter)
                } catch {
                    debugPrint("\(error.localizedDescription)")
                }
                var cubeFilter: CubeQuery.Filter? = nil
                if  let _cubeFilter = state.cubeQuery.filters.first(where: { $0.name == filter }) {
                    cubeFilter = _cubeFilter
                } else {
                    cubeFilter = CubeQuery.Filter(name: filter, values: filterValues)
                }
                return .run { [_cubeFilter = cubeFilter!]
                    send in
                    await send(.filterValueSelection(.onFilterChanged(_cubeFilter)))
                    await send(.filterSelectorOpenChanged(true))
                }
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
                    numOfSplits: 1,
                    data: [])
                return .none
            case .closeCreator:
                state.isCreatorOpen = false
                return .none
            case .creatorOpenChanged(let isCreatorOpen):
                state.isCreatorOpen = isCreatorOpen
                return .none
            case .filterSelectorOpenChanged(let isFilterSelectorOpen):
                state.isFilterSelectorOpen = isFilterSelectorOpen
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
                state.cubeQuery.dimensions.removeAll(where: { $0.name == dimension })
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .addMeasure(let measure):
                state.cubeQuery.measures.append(measure)
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .removeMeasure(let measure):
                state.cubeQuery.measures.removeAll(where: { $0.name == measure })
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .addFilter(let filter):
                state.cubeQuery.filters.append(filter)
                return .run { [cubeQuery = state.cubeQuery] send in
                    await send(.cubeQueryChanged(cubeQuery))
                }
            case .removeFilter(let filter):
                state.cubeQuery.filters.removeAll(where: { $0.name == filter })
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
                        numOfSplits: chartData.query.dimensions.count,
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
                    } else if ["PIE", "LINE", "AREA"].contains(chartDataCopy.type) && chartDataCopy.query.dimensions.count > 1 {
                        chartItem.data = []
                        chartItem.errorMsg = "\(chartDataCopy.type) chart accepts only one dimension"
                    } else if ["LINE", "AREA"].contains(chartDataCopy.type) && !chartDataCopy.query.dimensions.map({ "\($0.name)" }).contains(where: { Cube.timeDimensions.contains($0) }) {
                        chartItem.data = []
                        chartItem.errorMsg = "\(chartDataCopy.type) chart requires time series"
                    } else if chartItem.type == "PIE" && chartDataCopy.query.dimensions.map({ "\($0.name)" }).contains(where:{ Cube.timeDimensions.contains($0) }) {
                        chartItem.data = []
                        chartItem.errorMsg = "\(chartDataCopy.type) chart doesnt support time series dimensions"
                    } else {
                        do {
                            chartItem.data = try Cube.shared.query(cubeQuery: chartDataCopy.query)
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
            case .filterValueSelection(.delegate(.apply(let filter))):
                if let idx = state.cubeQuery.filters.lastIndex(where: {$0.name == filter.name}) {
                    state.cubeQuery.filters[idx] = filter
                } else {
                    state.cubeQuery.filters.append(filter)
                }
                
                return .run { 
                    [query = state.cubeQuery]
                    send in
                    await send(.cubeQueryChanged(query))
                    await send(.filterSelectorOpenChanged(false))
                }
            case .filterValueSelection(.delegate(.close)):
                return .run {
                    send in
                    await send(.filterSelectorOpenChanged(false))
                }
            case .filterValueSelection(_):
                return .none
            case .delegate(_):
                return .none
            }
        }
    }
}
