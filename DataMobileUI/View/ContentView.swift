//
//  ContentView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Combine


struct ContentView: View {
    @EnvironmentObject var stravaAuth: StravaAuth
    @State private var showAlert: Bool = false
    @State private var alertText: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                if stravaAuth.oauth.hasUnexpiredAccessToken() {
                    HomeView()
                        .environmentObject(DataTransformer(api: StravaApi(stravaAuth: stravaAuth)))
                } else {
                    LoginView()
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(alertText))
                        }
                }
            }
        }.foregroundStyle(.black)
    }
}

struct HomeView: View {
    @EnvironmentObject var dashboard: Dashboard
    @EnvironmentObject var dt: DataTransformer
    @EnvironmentObject var stravaAuth: StravaAuth
    
    var body: some View {
        let ds = try! DataSource.create()
        
        var charts: [ChartItem] {
            var charts = [ChartItem]()
            
            for c in sample_charts {
                var chartContents = [ChartItem._ChartContent]()
                let chart = ChartItem(name: c.name,
                                      type: c.type,
                                      contents: [])
                do {
                    let df = try ds.query(measure: c.measures.joined(separator: ","),
                                          dimensions: c.dimensions.joined(separator: ","))
                    
                    let activityTypeColumn = df.columns[0].assumingType(String.self).filled(with: "b.d")
                    let countColumn = df.columns[1].assumingType(Int.self).filled(with: 0)
                    
                    for (activity, count) in zip(activityTypeColumn, countColumn) {
                        chartContents.append(ChartItem._ChartContent(key: String(activity), value: Double(count)))
                    }
                    chart.contents = chartContents
                    charts.append(chart)
                } catch {
                    debugPrint(error.localizedDescription)
                    break
                }
            }
            
            
            return charts
        }
        
        
        VStack(spacing: 0){
            Button("Deauth", action: stravaAuth.logout)
            DashboardView(charts: charts)
                .environmentObject(ds)
        }
    }
}
