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
                                        .chartLegend(.hidden)
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
                                    width:  UIScreen.main.bounds.width/2 - 40,
                                    height: UIScreen.main.bounds.width/2 - 40 )
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
                            VStack {
                                TextField(
                                    "Dashboard name",
                                    text: viewStore.binding(
                                        get: \.title,
                                        send: DashboardReducer.Action.titleChanged
                                    )
                                )
                                .multilineTextAlignment(.center)
                                .disableAutocorrection(true)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black)
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                            }

                            Button  {
                                viewStore.send(.onSaveTapped)
                            } label : {
                                Text("Save")
                                    .foregroundStyle(.blue)
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
