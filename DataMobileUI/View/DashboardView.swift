//
//  DashboardView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Charts

struct DashboardView: View {
    var charts: [ChartItem]
    @State private var bools: [Bool] = Array(sample_charts.map({ $0.contents })).flatMap({ $0 }).map({ $0.animate })
    
    @State private var whocares: Bool = false
    
    @ViewBuilder
    var body: some View {
        let chartWidth = (UIScreen.main.bounds.width - 40) / 2 // Width of each chart, with some padding
        
        Grid {
            ForEach(sample_charts.chunked(into: 2), id: \.self) { chartRow in
                GridRow {
                    ForEach(Array(chartRow.enumerated()), id: \.element) { jndex, chartItem in
                        AnimatedChart(chartItem: chartItem, chartWidth: chartWidth)
                        
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

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let dashboard = Dashboard()
        return DashboardView(charts: sample_charts)
    }
}
