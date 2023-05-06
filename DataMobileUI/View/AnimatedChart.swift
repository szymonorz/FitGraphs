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
    @State var animate: Bool = false
    var chartWidth: CGFloat
    
    var body: some View {
        VStack {
            Text(chartItem.name)
            Chart {
                ForEach(Array(chartItem.contents.enumerated()), id: \.element) { index, content in
                    if(chartItem.type == "BAR") {
                        BarMark(
                            x: .value("x", content.key),
                            y: .value("y", animate ? content.value : 0)
                        )
                    }else if(chartItem.type == "AREA") {
                        AreaMark(
                            x: .value("x", content.key),
                            y: .value("y", animate ? content.value: 0)
                        )
                        }
                }
            }
            .drawingGroup()
            .animation(.interactiveSpring(
                response: 0.55,
                dampingFraction: 0.30,
                blendDuration: 0.0
            ), value: animate)
            .chartYScale(domain: 0...250)
            .frame(width: chartWidth, height: chartWidth)
            .onAppear {
                animate.toggle()
            }

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
