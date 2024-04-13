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
            CheckboxField(text: "Exclude", action: {
                viewStore.send(.isExclusionary(!viewStore.state.filter.exclude))
            }, isChecked: viewStore.state.filter.exclude)
            Divider()
            if viewStore.state.filter.name != "Date" {
                ScrollView {
                    ForEach(viewStore.state.filter.values, id: \.self) { val in
                        CheckboxField(text: val, action: {
                            viewStore.send(.onValueTapped(val))
                        }, isChecked: viewStore.state.filter.chosen.contains(val))
                    }
                }
            } else {
                VStack {
                    DatePicker(
                        "Start date",
                        selection: viewStore.binding(
                            get: \.startDate,
                            send: {FilterValueSelectionReducer.Action.startDateChanged($0)}
                        ),
                        displayedComponents: [.date]
                    )
                    
                    DatePicker(
                        "End date",
                        selection: viewStore.binding(
                            get: \.endDate,
                            send: {FilterValueSelectionReducer.Action.endDateChanged($0)}
                        ),
                        displayedComponents: [.date]
                    )
                }
            }
            HStack{
                Button("Apply") {
                    viewStore.send(.onApplyTapped)
                }
                Button("Close") {
                    viewStore.send(.onCancelTapped)
                }
            }
        }
    }
}
