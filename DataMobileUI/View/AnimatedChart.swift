//
//  AnimatedChart.swift
//  DataMobileUI
//
//  Created by b on 26/04/2023.
//

import SwiftUI
import Charts

struct AnimatedChart: View {
    @State var chartItem: ChartItem
    var chartWidth: CGFloat
    @State var animate: Bool = false
    
    var body: some View {
        VStack {
            Text(chartItem.name)
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
                    }
                    
                }
            }
            .drawingGroup()
            .chartYScale(domain: 0...250)
            .frame(width: chartWidth, height: chartWidth)

        }
    }
    
    struct AnimatedChart_Previews: PreviewProvider {
        static var previews: some View {
            AnimatedChart(chartItem: ChartItem(name: "UWU", type: "BAR",
                                               contents: [
                                                ChartItem._ChartContent(key:"0", value: 123),
                                                ChartItem._ChartContent(key:"1", value: 125),
                                                ChartItem._ChartContent(key:"2", value: 127),
                                                ChartItem._ChartContent(key:"3", value: 12)
                                               ]),
                          chartWidth: 120)
        }
    }
}
