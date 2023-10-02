//
//  ChartEditorView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import ComposableArchitecture

struct ChartCreatorView: View {
    var store: StoreOf<ChartEditorReducer>
    var callback: () -> ()
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text("Creator view")
                ChartView(chartItem: viewStore.state.chartItemToEdit, chartWidth: 200)
                EditHub(store: self.store)
                ChartMenu(store: self.store)
            }
            HStack {
                Button("Save", action: {
                    Task {
                        await viewStore.send(ChartEditorReducer.Action.saveChartItem).finish()
                        viewStore.send(ChartEditorReducer.Action.closeCreator)
                        callback()
                    }
                }).disabled(!viewStore.queryCorrect)
                
                Button("Cancel", action: {
                    viewStore.send(ChartEditorReducer.Action.closeCreator)
                })
            }
        }
    }
}

struct ChartEditorView: View {
    var store: StoreOf<ChartEditorReducer>
    var callback: () -> ()
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack {
                Text("Editor view")
                ChartView(chartItem: viewStore.state.chartItemToEdit, chartWidth: 200)
                EditHub(store: self.store)
                ChartMenu(store: self.store)
            }
            HStack {
                Button("Save", action: {
                    Task {
                        await viewStore.send(ChartEditorReducer.Action.updateChartItem).finish()
                        viewStore.send(ChartEditorReducer.Action.closeEditor)
                        callback()
                    }
                }).disabled(!viewStore.queryCorrect)
                Button("Cancel", action: {
                    viewStore.send(ChartEditorReducer.Action.closeEditor)
                })
            }
        }
    }
}

struct ChartMenuItem: Identifiable {
    var id = UUID().uuidString
    var label: String
    var imageName: String
}

struct ChartMenu: View {
    var store: StoreOf<ChartEditorReducer>
    
    var labels: [ChartMenuItem] = [
        ChartMenuItem(label: "PIE", imageName: "chart.pie.fill"),
        ChartMenuItem(label: "BAR", imageName: "chart.bar.fill"),
        ChartMenuItem(label: "LINE", imageName: "waveform.path.ecg"),
        ChartMenuItem(label: "AREA", imageName: "square.fill")
        
    ]
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                ForEach(labels) { item in
                    Button(action: {
                        viewStore.send(ChartEditorReducer.Action.typeChanged(item.label))
                    }) {
                        Label(item.label, systemImage: item.imageName)
                    }
                    
                }
            }
            .labelStyle(.iconOnly)
        }
    }
}
