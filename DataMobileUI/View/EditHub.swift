//
//  EditHub.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import ComposableArchitecture

struct EditHub: View {
    
    var store: StoreOf<ChartEditorReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0.chartItemToEdit }) { viewStore in
            VStack(spacing: 0) {
                Selector(name: "Filters", type: "filters", store: self.store)
                Selector(name: "Dimensions", type: "dimensions", store: self.store)
                Selector(name: "Measures", type: "measures", store: self.store)
            }
        }
        
    }
}
