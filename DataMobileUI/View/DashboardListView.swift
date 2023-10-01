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
                .toolbar {
                    ToolbarItem {
                        Button {
                            viewStore.send(.addDashboardTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        } destination: { store in
            DashboardView(store: store)
        }
    }
}
