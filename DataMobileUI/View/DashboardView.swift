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
                        ForEach(Array(viewStore.state.charts.enumerated()), id: \.element) { index, chartItem in
                            ChartView(chartItem: chartItem, chartWidth: chartWidth)
                                .sheet(isPresented: viewStore.binding(
                                    get: \.chartEditor.isEditorOpen,
                                    send: { DashboardReducer.Action.chartEditor(.editorOpenChanged($0))})) {
                                        ChartEditorView(
                                            store: self.store.scope(state: \.chartEditor,
                                                                    action: DashboardReducer.Action.chartEditor),
                                            callback: {
                                                viewStore.send(DashboardReducer.Action.loadCharts)
                                            }
                                        )
                                    }.onTapGesture {
                                        Task {
                                            await viewStore.send(DashboardReducer.Action.chartItemTapped(chartItem)).finish()
                                            viewStore.send(DashboardReducer.Action.chartEditor(.openEditor))
                                        }
                                    }
                        }
                        Button("+", action: {
                            viewStore.send(DashboardReducer.Action.chartEditor(.openCreator))
                        })
                        .sheet(isPresented: viewStore.binding(
                            get: \.chartEditor.isCreatorOpen,
                            send: { DashboardReducer.Action.chartEditor(.creatorOpenChanged($0)) })){
                                ChartCreatorView(
                                    store: self.store.scope(state: \.chartEditor,
                                                            action: DashboardReducer.Action.chartEditor),
                                    callback: {
                                        viewStore.send(DashboardReducer.Action.loadCharts)
                                    }
                                )
                            }
                        }
                    }
                }.onAppear {
                    viewStore.send(DashboardReducer.Action.loadCharts)
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
