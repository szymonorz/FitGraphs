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
                        NavigationLink(
                            state: DashboardReducer.State(
                                charts: dashboard.data,
                                dashboard: dashboard,
                                title: dashboard.name
                            )
                        ) {
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
                WithViewStore(addDashboardStore, observe: { $0 }) { viewStore in
                    Form {
                        Text("Create new dashboard").frame(maxWidth: .infinity, alignment: .center)
                        TextField(
                            "Dashboard name",
                            text: viewStore.binding(
                                get: \.title,
                                send: { .titleChanged($0) }
                            )
                        )
                        .multilineTextAlignment(.center)
                        .disableAutocorrection(true)
                        HStack {
                            Button("Save") {
                                addDashboardStore.send(.onSaveTapped)
                            }.buttonStyle(BorderlessButtonStyle())
                            
                            Button("Cancel") {
                                addDashboardStore.send(.onCancelTapped)
                            }.buttonStyle(BorderlessButtonStyle())
                        }.frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
    }
}
