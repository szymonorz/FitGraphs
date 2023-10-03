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
            } else if chartItem.contents.isEmpty {
                Text("No data to show")
            } else {
                let maxElement = chartItem.contents.max { $0.value < $1.value}
                Chart {
                    ForEach(Array(chartItem.contents.enumerated()), id: \.element) { index, content in
                        if(chartItem.type == "BAR") {
                            BarMark(
                                x: .value("x", content.key),
                                y: .value("y", content.value)
                            )
                        }else if(chartItem.type == "AREA") {
                            AreaMark(
                                x: .value("x", content.key),
                                y: .value("y", content.value)
                            )
                        }else if(chartItem.type == "LINE") {
                            LineMark(
                                x: .value("x", content.key),
                                y: .value("y", content.value)
                            )
                        }else if(chartItem.type == "PIE") {
                            SectorMark(
                                angle: .value("value", content.value)
                            ).foregroundStyle(by: .value("k", content.key))
                        }
                    }
                }
                .drawingGroup()
                .chartYScale(domain: 0...maxElement!.value)
            }
        }.frame(width: chartWidth, height: chartWidth)
    }
}
