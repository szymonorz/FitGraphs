//
//  AnimatedChart.swift
//  DataMobileUI
//
//  Created by b on 26/04/2023.
//

import SwiftUI
import Charts

struct ChartView: View {
    
    var chartItem: ChartItem
    var chartWidth: CGFloat
    
    var body: some View {
        VStack {
            if let errorMsg = chartItem.errorMsg {
                Text(errorMsg)
            } else if chartItem.data.isEmpty {
                Text("No data to show")
            } else {
                var maxElement: Decimal = -1;
                let _ = chartItem.data.forEach {
                    data in
                    let newMaxElement = data.contents.max { $0.value < $1.value }?.value ?? 1
                    maxElement = newMaxElement > maxElement ? newMaxElement : maxElement
                }
                if(chartItem.type == "BAR") {
                    Chart(chartItem.data, id: \.dataType) { data in
                        ForEach(Array(data.contents.enumerated()), id: \.element) { index, content in
                            BarMark(
                                x: .value("x", content.key),
                                y: .value("y", content.value)
                            )
                        }.foregroundStyle(by: .value("type", data.dataType))
                    }.drawingGroup()
                        .chartYScale(domain: 0...maxElement)
                }else if(chartItem.type == "AREA") {
                    Chart(chartItem.data, id: \.dataType) { data in
                        ForEach(Array(data.contents.enumerated()), id: \.element) { index, content in
                            AreaMark(
                                x: .value("x", content.key),
                                y: .value("y", content.value)
                            )
                        }
                    }.drawingGroup()
                        .chartYScale(domain: 0...maxElement)
                }else if(chartItem.type == "LINE") {
                    Chart(chartItem.data, id: \.dataType) { data in
                        ForEach(Array(data.contents.enumerated()), id: \.element) { index, content in
                            LineMark(
                                x: .value("x", content.key),
                                y: .value("y", content.value)
                            )
                        }
                    }.drawingGroup()
                        .chartYScale(domain: 0...maxElement)
                }else if(chartItem.type == "PIE") {
                    Chart(chartItem.data, id: \.dataType) { data in
                        ForEach(Array(data.contents.enumerated()), id: \.element) { index, content in
                            SectorMark(
                                angle: .value("value", content.value)
                            ).foregroundStyle(by: .value("k", content.key))
                        }
                    }.drawingGroup()
                        .chartYScale(domain: 0...maxElement)
                }
            }
        }.frame(width: chartWidth, height: chartWidth)
    }
}
