//
//  FilterValueSelectionView.swift
//  FitGraphs
//
//  Created by b on 17/02/2024.
//

import SwiftUI
import ComposableArchitecture

struct FilterValueSelectionView: View {
    
    var store: StoreOf<FilterValueSelectionReducer>
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            ScrollView {
                ForEach(viewStore.state.filter.values, id: \.self) { val in
                    Button {
                        viewStore.send(.onValueTapped(val))
                    } label: {
                        HStack{
                            Text(val)
                            if viewStore.state.filter.chosen.contains(val) {
                                Text("X")
                            }
                        }
                    }
                }
            }
            
            Button("Apply") {
                viewStore.send(.onApplyTapped)
            }
        }
    }
}
