//
//  ChartMenu.swift
//  FitGraphs
//
//  Created by b on 14/04/2024.
//

import SwiftUI
import ComposableArchitecture

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
