//
//  ChartCreatorView.swift
//  FitGraphs
//
//  Created by b on 14/04/2024.
//

import SwiftUI
import ComposableArchitecture

struct ChartCreatorView: View {
    var store: StoreOf<ChartEditorReducer>
    var callback: () -> ()
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack {
                    Text("Creator view")
                    TextField(
                        "Edit name",
                        text: viewStore.binding(
                            get: \.title,
                            send: ChartEditorReducer.Action.titleChanged
                        ))
                    .multilineTextAlignment(.center)
                    .disableAutocorrection(true)
                    ChartView(chartItem: viewStore.state.chartItemToEdit)
                        .frame(
                            width: UIScreen.main.bounds.width - 100,
                            height: UIScreen.main.bounds.height/2
                        )
                    QueryBuilderView(store: self.store)
                    ChartMenu(store: self.store)
                }
                HStack {
                    Button("Save", action: {
                        Task {
                            await viewStore.send(ChartEditorReducer.Action.onSaveTapped).finish()
                            viewStore.send(ChartEditorReducer.Action.closeCreator)
                            callback()
                        }
                    }).disabled(!viewStore.queryCorrect)
                    
                    Button("Cancel", action: {
                        viewStore.send(ChartEditorReducer.Action.onCancelTapped)
                    })
                }
            }
        }
    }
}
