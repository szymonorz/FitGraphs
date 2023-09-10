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
    
    let store: StoreOf<RootReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            if StravaAuth.shared.oauth.hasUnexpiredAccessToken() {
                HomeView(store: self.store)
            } else {
                LoginView(store: self.store.scope(
                    state: \.stravaAuth,
                    action: RootReducer.Action.stravaAuth
                    )
                )
            }
        }
    }
}

struct HomeView: View {
    let store: StoreOf<RootReducer>
    
    var body: some View {
        
        var charts: [ChartItem] {
            var charts = [ChartItem]()
            
            for c in sample_charts {
                var chartContents = [ChartItem._ChartContent]()
                let chart = ChartItem(name: c.name,
                                      type: c.type,
                                      contents: [])
                do {
                    let contents = try DataSource.shared.query(
                                    dimensions: c.dimensions,
                                    measures: c.measures)
                    
                    chart.contents = contents
                    charts.append(chart)
                } catch {
                    debugPrint(error.localizedDescription)
                    break
                }
            }
            
            
            return charts
        }
        
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                Button("Deauth", action: {
                    viewStore.send(RootReducer.Action.stravaAuth(.logout))
                })
//                DashboardView(charts: charts,
//                              store: .init(
//                                initialState: Dashboard.State(),
//                                reducer: Dashboard()))
            }
        }
    }
}
