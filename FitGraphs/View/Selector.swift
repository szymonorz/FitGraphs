//
//  Selector.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import WrappingHStack
import ComposableArchitecture

struct Selector: View {
    var name: String
    var type: String
    
    var store: StoreOf<ChartEditorReducer>
    @State var isPickerPresented: Bool = false
    
    @State var presentationDetent = PresentationDetent.medium
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Text(name)
                    .font(.system(size: 14))
                    .frame(
                        width: 80.0,
                        alignment: .leading
                    )
                HStack {
                    switch type {
                    case "dimensions":
                        WrappingHStack(viewStore.cubeQuery.dimensions, id: \.self) { dim in
                            Field(aggr: dim.name, action: { viewStore.send(ChartEditorReducer.Action.removeDimension($0))})
                        }
                    case "measures":
                        WrappingHStack(viewStore.cubeQuery.measures, id: \.self) { measure in
                            Field(aggr: measure.name, action: { viewStore.send(ChartEditorReducer.Action.removeMeasure($0))})
                        }
                    case "filters":
                        WrappingHStack(viewStore.cubeQuery.filters, id: \.self) { filter in
                            Field(aggr: filter.name, action: { viewStore.send(ChartEditorReducer.Action.removeFilter($0))})
                        }
                    default:
                        EmptyView()
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: 33.0,
                    alignment: .leading
                )
                
                Button("+", action: {
                    self.isPickerPresented.toggle()
                })
                .fontWeight(.bold)
                .sheet(isPresented: $isPickerPresented) {
                    Button("Close") {
                        isPickerPresented = false
                    }
                    FieldPicker(isPickerPresented: $isPickerPresented,
                                type: type,
                                store: self.store
                    )
                    .presentationDetents([.medium, .fraction(0.2)], selection: $presentationDetent)
                }
            }
            .padding()
            .border(Color.gray)
        }
    }

    struct Field: View {
        var aggr: String
        var action: (String) -> ()
        
        var body: some View {
            HStack {
                Text(aggr)
                Button("X", action: {
                    action(aggr)
                })
            }
                .padding(.horizontal)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.orange, lineWidth: 4)
                )
        }
    }
    
    struct CheckboxField: View {
        var aggr: String
        var action: (String) -> ()
        var isChecked: Bool = false
        var body: some View {
            Button(action: {
                action(aggr)
            }) {
                HStack(alignment: .top, spacing: 10) {
                   Rectangle()
                        .fill(isChecked ? .gray : .white)
                        .frame(width:20, height:20, alignment: .center)
                        .cornerRadius(5)
                        .border(.gray)
                    Spacer()
                    Text(aggr)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .foregroundColor(.black)
        }
    }

    struct FieldPicker: View {
        @Binding var isPickerPresented: Bool
        @State var isFilterSelectionPresented: Bool = false
        
        var type: String
        var store: StoreOf<ChartEditorReducer>
        
        //var toChose: [String] = Activity.CodingKeys.allCases.map { $0.stringValue }.filter { $0.typ}
        var dimsToChose: [CubeQuery.Aggregation] = [
            CubeQuery.Aggregation(name: "SportType", expression: "SportType"),
            CubeQuery.Aggregation(name: "DateLocal", expression: "DateLocal"),
            CubeQuery.Aggregation(name: "Weekday", expression: "Weekday")]
        
        var measuresToChose: [CubeQuery.Aggregation] = [
            CubeQuery.Aggregation(name: "Activity", expression: "Activity")
        ]
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    HStack {
                        switch type {
                        case "dimensions":
                            WrappingHStack(viewStore.cubeQuery.dimensions, id: \.self) { dim in
                                Field(aggr: dim.name, action: { viewStore.send(ChartEditorReducer.Action.removeDimension($0))})
                            }
                        case "measures":
                            WrappingHStack(viewStore.cubeQuery.measures, id: \.self) { measure in
                                Field(aggr: measure.name, action: { viewStore.send(ChartEditorReducer.Action.removeMeasure($0))})
                            }
                        case "filters":
                            WrappingHStack(viewStore.cubeQuery.filters, id: \.self) { filter in
                                Button {
                                    viewStore.send(ChartEditorReducer.Action.openFilterSelection(filter.name))
                                } label: {
                                    Field(aggr: filter.name, action: { viewStore.send(ChartEditorReducer.Action.removeFilter($0))})

                                }.sheet(isPresented: viewStore.binding(
                                    get: \.isFilterSelectorOpen,
                                    send: {ChartEditorReducer.Action.filterSelectorOpenChanged($0)})
                                    ) {
                                        Text(viewStore.filterValues.joined(separator: ","))
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: 80
                        )
                    
                    ScrollView {
                        if type == "dimensions" {
                            ForEach(dimsToChose, id: \.self) { pick in
                                let isChecked = viewStore.cubeQuery.dimensions.contains(pick)
                                CheckboxField(aggr: pick.name, action: {
                                    let action = isChecked ? ChartEditorReducer.Action.removeDimension($0) : ChartEditorReducer.Action.addDimension(pick)
                                    viewStore.send(action)
                                }, isChecked: isChecked)
                            }.frame(minWidth: 300)
                        }
                        if type == "measures" {
                            ForEach(measuresToChose, id: \.self) { pick in
                                let isChecked = viewStore.cubeQuery.measures.contains(pick)
                                CheckboxField(aggr: pick.name, action: {
                                    let action = isChecked ? ChartEditorReducer.Action.removeMeasure($0) : ChartEditorReducer.Action.addMeasure(pick)
                                    
                                    viewStore.send(action)
                                }, isChecked: isChecked)
                            }.frame(minWidth: 300)
                        }
                        if type == "filters" {
                            ForEach(dimsToChose, id: \.self) { pick in
                                Button {
                                    viewStore.send(ChartEditorReducer.Action.openFilterSelection(pick.name))
                                } label: {
                                    CheckboxField(aggr: pick.name, action: {
                                        self.isFilterSelectionPresented.toggle()
                                        viewStore.send(ChartEditorReducer.Action.openFilterSelection($0))
                                    })

                                }.sheet(isPresented: viewStore.binding(
                                    get: \.isFilterSelectorOpen,
                                    send: {ChartEditorReducer.Action.filterSelectorOpenChanged($0)})
                                    ) {
                                        FilterValueSelectionView(store: self.store.scope(
                                            state: \.filterValueSelection,
                                            action: ChartEditorReducer.Action.filterValueSelection
                                        ))
                                }.presentationDetents([.medium])
                            }
                        }
                    }
                }
            }

        }
 
    }
}
