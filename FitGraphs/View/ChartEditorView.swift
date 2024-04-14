//
//  ChartEditorView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import ComposableArchitecture

struct ChartEditorView: View {
    var store: StoreOf<ChartEditorReducer>
    var callback: () -> ()
    
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            VStack {
                Text("Editor view")
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
                        viewStore.send(ChartEditorReducer.Action.closeEditor)
                        callback()
                    }
                }).disabled(!viewStore.queryCorrect)
                Button("Cancel", action: {
                    viewStore.send(ChartEditorReducer.Action.closeEditor)
                })
            }
        }
    }
}
