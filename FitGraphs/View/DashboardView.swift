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
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    @Dependency(\.stravaApi) var stravaApi
    
    let store: StoreOf<DashboardReducer>
    
    @ViewBuilder
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack{
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(Array(viewStore.state.chartItems.chartItems.enumerated()), id: \.element) { index, chartItem in
                            Menu {
                                Button("Edit") {
                                    let chartData = viewStore.state.charts[index]
                                    viewStore.send(.chartItemTapped(chartData))
                                }
                                
                                Button("Delete", role: .destructive) {
                                    let chartData = viewStore.state.charts[index]
                                    viewStore.send(.deleteChart(chartData))
                                }
                            } label: {
                                GroupBox(chartItem.name) {
                                    ChartView(chartItem: chartItem)
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
                                            }
                                }.frame(
                                    width: verticalSizeClass == .compact ? UIScreen.main.bounds.width/2 - 80 : UIScreen.main.bounds.width/2 - 40,
                                    height: verticalSizeClass == .compact ? UIScreen.main.bounds.height/3 : UIScreen.main.bounds.width/2 - 40 )
                            } primaryAction: {
                                let chartData = viewStore.state.charts[index]
                                viewStore.send(.chartItemTapped(chartData))
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
                }
            .contentMargins(.horizontal, 5.0)
            .onAppear {
                    viewStore.send(DashboardReducer.Action.loadCharts)
                }.toolbar {
                    ToolbarItem {
                        HStack {
                            TextField(
                                "Dashboard name",
                                text: viewStore.binding(
                                    get: \.title,
                                    send: DashboardReducer.Action.titleChanged
                                )
                            )
                            .multilineTextAlignment(.center)
                            .disableAutocorrection(true)

                            Button("Save") {
                                viewStore.send(.onSaveTapped)
                            }
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
