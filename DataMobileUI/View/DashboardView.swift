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
    @EnvironmentObject var ds: DataSource
    
    @State var presentModal: Bool = false
    
    
    func processChartData(chart: ChartItem) {
        var chartContents = [ChartItem._ChartContent]()
        do {
            let df = try ds.query(measure: chart.measures.joined(separator: ","),
                                  dimensions: chart.dimensions.joined(separator: ","))
            
            let activityTypeColumn = df.columns[0].assumingType(String.self).filled(with: "b.d")
            let countColumn = df.columns[1].assumingType(Int.self).filled(with: 0)
            
            for (activity, count) in zip(activityTypeColumn, countColumn) {
                chartContents.append(ChartItem._ChartContent(key: String(activity), value: Double(count)))
            }
            chart.contents = chartContents
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    
    @ViewBuilder
    var body: some View {
        let chartWidth = (UIScreen.main.bounds.width - 40) / 2 // Width of each chart, with some padding
       
        NavigationStack {
            ScrollView {
                VStack{
                    Button("Fetch data from Strava", action: dt.fetchFromStrava)
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(Array(charts.enumerated()), id: \.element) { index, chartItem in
                            NavigationLink(destination: ChartEditorView(chartItem: chartItem, dataChange: {
                                chart in
                                processChartData(chart: chart)
                            }),
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
                                
                                    processChartData(chart: chartItem)
                                    charts.append(chartItem)
                                },
                                dataChange: {
                                    chart in
                                    processChartData(chart: chart)
                                }
                            )
                        }
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
