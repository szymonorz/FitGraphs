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
        let chartWidth = (UIScreen.main.bounds.width - 80) / 2 // Width of each chart, with some padding
        
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
                                VStack {
                                    Text(chartItem.name)
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
                                            }
                                }
                                .padding() // Padding inside the background
                                .background(
                                   RoundedRectangle(cornerRadius: 10) // Background shape with rounded corners
                                       .foregroundColor(.white) // Setting the background color
                                    .shadow(color: Color.black.opacity(0.5), radius: 5, x: 5, y: 5) // Shadow applied to bottom-right
                               )
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
                }.onAppear {
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
