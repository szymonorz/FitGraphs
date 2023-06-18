//
//  ChartEditorView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI

struct ChartEditorView: View {
    @StateObject var chartItem: ChartItem
//    var labels: [ChartMenuItem] = [
//        ChartMenuItem(label: "PIE", imageName: "chart.pie.fill"),
//        ChartMenuItem(label: "BAR", imageName: "chart.bar.fill"),
//        ChartMenuItem(label: "LINE", imageName: "waveform.path.ecg"),
//        ChartMenuItem(label: "AREA", imageName: "square.fill")
//        
//    ]
    var body: some View {
        HStack {
            // Field Selector
            
            
            //Chart
            VStack {
                Text("Editor view")
                EditHub()
                ChartView(chartItem: chartItem, chartWidth: 200)
                ChartMenu(chartItem: chartItem)
//                HStack {
//                    ForEach(labels) { item in
//                        Button(action: {
//                            chartItem.type = item.label
//                        }) {
//                            Label(item.label, systemImage: item.imageName)
//                        }
//                        
//                    }
//                }
//                .labelStyle(.iconOnly)
            }.padding()
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

#Preview {
    ChartEditorView(chartItem: ChartItem(name: "3",type: "PIE", contents: [
                                    ChartItem._ChartContent(key:"0", value: 123),
                                    ChartItem._ChartContent(key:"1", value: 125),
                                    ChartItem._ChartContent(key:"2", value: 127),
                                    ChartItem._ChartContent(key:"3", value: 12)
                                    ])
    )
}
