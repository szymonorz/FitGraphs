//
//  DashboardView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @State var charts: [ChartItem]
    @State var item: Int? = 0
    @EnvironmentObject var dt: DataTransformer
    
    @State var presentModal: Bool = false
    
    
    @ViewBuilder
    var body: some View {
        let chartWidth = (UIScreen.main.bounds.width - 40) / 2 // Width of each chart, with some padding
        NavigationStack {
            VStack{
                Button("Fetch data from Strava", action: dt.fetchFromStrava)
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(Array(charts.enumerated()), id: \.element) { index, chartItem in
                        NavigationLink(destination: ChartEditorView(chartItem: chartItem),
                                        label: {
                                            ChartView(chartItem: chartItem, chartWidth: chartWidth)
                                        })
                    }
                    
                    Button("+", action: {
                        self.presentModal.toggle()
                    })
                    .sheet(isPresented: $presentModal) {
                        ChartCreatorView(
                            present: $presentModal,
                            didAddChart: {
                                chartItem in
                                
                                print(chartItem)
                                
                                charts.append(chartItem)
                            }
                        )
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
        //let dashboard = Dashboard()
        return DashboardView(charts: sample_charts)
    }
}
