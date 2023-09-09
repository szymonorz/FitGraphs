//
//  ContentView.swift
//  DataMobileUI
//
//  Created by b on 23/04/2023.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct ContentView: View {
    @State private var showAlert: Bool = false
    @State private var alertText: String = ""
    
    let authStore: StoreOf<StravaAuth>
    let store: Store
    
    var body: some View {
        WithViewStore(authStore, observe: { $0 }) { store in
            NavigationView {
                ZStack {
                    if store.loggedIn {
                        HomeView(authStore: authStore)
                            .environmentObject(DataTransformer(api: StravaApi(stravaAuth: authStore.)))
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
}

struct HomeView: View {
    @EnvironmentObject var dt: DataTransformer
    let authStore: StoreOf<StravaAuth>
    
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
        
        WithViewStore(authStore, observe: { $0 }) { authStore in
            VStack(spacing: 0) {
                Button("Deauth", action: {
                    authStore.send(.logout)
                })
                DashboardView(charts: charts,
                              store: .init(
                                initialState: Dashboard.State(),
                                reducer: Dashboard()))
                .environmentObject(ds)
            }
        }
    }
}
