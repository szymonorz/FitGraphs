//
//  ChartEditorView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI

struct ChartCreatorView: View {
    @State var changed: Bool = false
    @State var newChart: ChartItem  = ChartItem(name: "new", type: "BAR", contents: [])
    
    @Binding var present: Bool
    
    var didAddChart: (ChartItem) -> ()
    var dataChange: (ChartItem) -> ()
    
    var body: some View {
        ChartEditorView(chartItem: newChart, dataChange: dataChange)
        HStack {
            Button("Save", action: {
                self.didAddChart(newChart)
                self.present = false
            })
            Button("Cancel", action: {
                self.present = false
            })
        }
    }
}

struct ChartEditorView: View {
    @StateObject var chartItem: ChartItem
    var dataChange: (ChartItem) -> ()
    var body: some View {
            //Chart
            VStack {
                Text("Editor view")
                ChartView(chartItem: chartItem, chartWidth: 200)
                EditHub(chart: chartItem, dataChange: dataChange)
                ChartMenu(chartItem: chartItem)
            }
    }
}

struct ChartMenuItem: Identifiable {
    var id = UUID().uuidString
    var label: String
    var imageName: String
}

struct ChartMenu: View {
    @ObservedObject var chartItem: ChartItem
    var labels: [ChartMenuItem] = [
        ChartMenuItem(label: "PIE", imageName: "chart.pie.fill"),
        ChartMenuItem(label: "BAR", imageName: "chart.bar.fill"),
        ChartMenuItem(label: "LINE", imageName: "waveform.path.ecg"),
        ChartMenuItem(label: "AREA", imageName: "square.fill")
        
    ]
    var body: some View {
        HStack {
            ForEach(labels) { item in
                Button(action: {
                    chartItem.type = item.label
                }) {
                    Label(item.label, systemImage: item.imageName)
                }
                
            }
        }
        .labelStyle(.iconOnly)
    }
}
