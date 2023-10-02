//
//  ChartEditorStore.swift
//  DataMobileUI
//
//  Created by b on 10/09/2023.
//

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
        
        case recalcChartItem
        case updateChartItemView(ChartItem)
        
        case openEditor
        case closeEditor
        case editorOpenChanged(Bool)
        
        case openCreator
        case closeCreator
        case creatorOpenChanged(Bool)
        case queryCorrectChanged(Bool)
        
        case onCancelTapped
        case onSaveTapped
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case save(ChartData)
        }
    }
    
    struct State: Equatable {
        var isEditorOpen: Bool = false
        var isCreatorOpen: Bool = false
        var title = "new"
        var type = "BAR"
        var queryCorrect: Bool = false
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
        var chartItem: ChartItem = ChartItem(
            name: "new",
            type: "BAR",
            contents: []
        )
    }
    
    @Dependency(\.dismiss) var dismiss
    var body: some ReducerOf<Self> {
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
                state.chartDataToEdit = ChartData(
                    title: state.title,
                    type: state.type,
                    dimensions: state.dimensions,
                    measures: state.measures,
                    filters: state.filters
                )
                return .none
            case .closeCreator:
                state.isCreatorOpen = false
                return .none
            case .creatorOpenChanged(let isCreatorOpen):
                state.isCreatorOpen = isCreatorOpen
                return .none
            case .titleChanged(let title):
                state.title = title
                state.chartDataToEdit.title = state.title
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .typeChanged(let type):
                state.type = type
                state.chartDataToEdit.type = state.type
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
                state.chartDataToEdit.dimensions = state.dimensions
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .addMeasure(let measure):
                state.measures.append(measure)
                state.chartDataToEdit.measures = state.measures
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .removeMeasure(let measure):
                state.measures.remove(at: state.measures.firstIndex(of: measure)!)
                state.chartDataToEdit.measures = state.measures
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .addFilter(let filter):
                state.filters.append(filter)
                state.chartDataToEdit.filters = state.filters
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .removeFilter(let filter):
                state.filters.remove(at: state.filters.firstIndex(of: filter)!)
                state.chartDataToEdit.filters = state.filters
                return .run { send in
                    await send(.recalcChartItem)
                }
            case .recalcChartItem:
                return .run {
                    [
                        chartData = state.chartDataToEdit
                    ] send in
                    let chartItem = ChartItem(
                        name: chartData.title,
                        type: chartData.type,
                        contents: []
                    )
                    debugPrint("MATH")
                    do {
                        chartItem.contents = try DataSource.shared.query(dimensions: chartData.dimensions,
                                                                         measures: chartData.measures)
                        await send(.queryCorrectChanged(false))
                    } catch {
                        debugPrint("kurwa")
                        chartItem.errorMsg = error.localizedDescription
                        await send(.queryCorrectChanged(false))
                    }
                    await send(.updateChartItemView(chartItem))
                }
            case .queryCorrectChanged(let correct):
                state.queryCorrect = correct
                return .none
            case .updateChartItemView(let chartItem):
                state.chartItem = chartItem
                return .none
            case .onCancelTapped:
                return .run { _ in await self.dismiss() }
            case .onSaveTapped:
                return .run { [chartData = state.chartDataToEdit ] send in
                    await send(.delegate(.save(chartData)))
                    await self.dismiss()
                }
            case .delegate:
                return .none
            }
        }
    }
}
