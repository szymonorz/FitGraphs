//
//  DashboardView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Charts
import ComposableArchitecture

struct DashboardView: View {
    @State var charts: [ChartItem]
    @State var item: Int? = 0
    
    @State var presentModal: Bool = false
    
    @Dependency(\.dataTransformer) var dataTransformer
    @Dependency(\.stravaApi) var stravaApi
    
    let store: StoreOf<Dashboard>
    
    func processChartData(chart: ChartItem) {
        var chartContents = [ChartItem._ChartContent]()
        do {
            let df = try DataSource.shared.query(
                dimensions: chart.dimensions,
                measures: chart.measures
            )
                                  
            chart.contents = df
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func updateCharts() {
        var _charts = [ChartItem]()
        
        for c in sample_charts {
            var chartContents = [ChartItem._ChartContent]()
            let chart = ChartItem(name: c.name,
                                  type: c.type,
                                  contents: [])
            do {
                let df = try DataSource.shared.query(
                    dimensions: chart.dimensions,
                    measures: chart.measures
                )
                
                chart.contents = df
                _charts.append(chart)
            } catch {
                debugPrint(error.localizedDescription)
                break
            }
        }
        
        charts.removeAll()
        charts.append(contentsOf: _charts)
    }
    
    @ViewBuilder
    var body: some View {
        let chartWidth = (UIScreen.main.bounds.width - 40) / 2 // Width of each chart, with some padding
    
        WithViewStore(store, observe: { $0 }) { dashboardViewStore in
            NavigationStack {
                ScrollView {
                    VStack{
                        Button("Fetch data from Strava", action: {
                            debugPrint("chuj")
                        })
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
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
