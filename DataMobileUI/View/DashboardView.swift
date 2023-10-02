//
//  DashboardView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Charts
import ComposableArchitecture

struct DashboardView: View {
    
    @State var presentModal: Bool = false
    
    @Dependency(\.stravaApi) var stravaApi
    
    let store: StoreOf<DashboardReducer>
    
    @ViewBuilder
    var body: some View {
        let chartWidth = (UIScreen.main.bounds.width - 40) / 2 // Width of each chart, with some padding
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack{
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(Array(viewStore.state.chartItems.items.enumerated()), id: \.element) { index, chartItem in
                            ChartView(chartItem: chartItem, chartWidth: chartWidth)
//                                .onTapGesture {
//                                    viewStore.send(.chartItemTapped(<#T##ChartData#>))
//                                }
                        }
                        Button {
                            viewStore.send(.addChartTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }.onAppear {
                    viewStore.send(DashboardReducer.Action.chartItems(.onAppear))
                }.sheet(store: self.store.scope(state: \.$chartEditor, action: { .chartEditor($0)})) { chartEditorStore in
                    NavigationStack {
                        ChartEditorView(store: chartEditorStore, callback: {
                            viewStore.send(.loadCharts)
                        })
                    }
                }
            }
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
