//
//  DashboardListView.swift
//  DataMobileUI
//
//  Created by b on 01/10/2023.
//

import SwiftUI
import ComposableArchitecture

struct DashboardListView: View {
    
    var store: StoreOf<DashboardListReducer>
    
    var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    ForEach(viewStore.dashboards) { dashboard in
                        NavigationLink(state: DashboardReducer.State(dashboard: dashboard)) {
                            Text(dashboard.name)
                        }
                    }
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .toolbar {
                    ToolbarItem {
                        NavigationLink(state: DashboardReducer.State()) {
                            Button {
                                viewStore.send(.addDashboardTapped)
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
        } destination: { store in
            DashboardView(store: store)
        }
        .sheet(store: self.store.scope(state: \.$addDashboard, action: { .addDashboard($0)})) { addDashboardStore in
            NavigationStack {
                VStack {
                    Text("Create new dashboard")
                    
                    HStack {
                        Button("Save") {
                            addDashboardStore.send(.onSaveTapped)
                        }
                        Button("Cancel") {
                            addDashboardStore.send(.onCancelTapped)
                        }
                    }
                }
            }
        }
    }
}
