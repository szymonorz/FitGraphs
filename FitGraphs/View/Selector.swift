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
                        WrappingHStack(viewStore.dimensions, id: \.self) { dim in
                            Field(name: dim, action: { viewStore.send(ChartEditorReducer.Action.removeDimension($0))})
                        }
                    case "measures":
                        WrappingHStack(viewStore.measures, id: \.self) { measure in
                            Field(name: measure, action: { viewStore.send(ChartEditorReducer.Action.removeMeasure($0))})
                        }
                    case "filters":
                        WrappingHStack(viewStore.filters, id: \.self) { filter in
                            Field(name: filter, action: { viewStore.send(ChartEditorReducer.Action.removeFilter($0))})
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
        var name: String
        var action: (String) -> ()
        
        var body: some View {
                Button(name, action: {
                    action(name)
                })
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
        var name: String
        var action: (String) -> ()
        var isChecked: Bool = false
        var body: some View {
            Button(action: {
                action(name)
            }) {
                HStack(alignment: .top, spacing: 10) {
                   Rectangle()
                        .fill(isChecked ? .gray : .white)
                        .frame(width:20, height:20, alignment: .center)
                        .cornerRadius(5)
                        .border(.gray)
                    Spacer()
                    Text(name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .foregroundColor(.black)
        }
    }

    struct FieldPicker: View {
        @Binding var isPickerPresented: Bool
        
        var type: String
        var store: StoreOf<ChartEditorReducer>
        
        //var toChose: [String] = Activity.CodingKeys.allCases.map { $0.stringValue }.filter { $0.typ}
        var dimsToChose: [String] = ["name", "sport_type"]
        var measuresToChose: [String] = ["count(sport_type)"]
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    HStack {
                        switch type {
                        case "dimensions":
                            WrappingHStack(viewStore.dimensions, id: \.self) { dim in
                                Field(name: dim, action: { viewStore.send(ChartEditorReducer.Action.removeDimension($0))})
                            }
                        case "measures":
                            WrappingHStack(viewStore.measures, id: \.self) { measure in
                                Field(name: measure, action: { viewStore.send(ChartEditorReducer.Action.removeMeasure($0))})
                            }
                        case "filters":
                            WrappingHStack(viewStore.filters, id: \.self) { filter in
                                Field(name: filter, action: { viewStore.send(ChartEditorReducer.Action.removeFilter($0))})
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
                                let isChecked = viewStore.dimensions.contains(pick)
                                CheckboxField(name: pick, action: {
                                    let action = isChecked ? ChartEditorReducer.Action.removeDimension($0) : ChartEditorReducer.Action.addDimension($0)
                                    viewStore.send(action)
                                }, isChecked: isChecked)
                            }.frame(minWidth: 300)
                        }
                        if type == "measures" {
                            ForEach(measuresToChose, id: \.self) { pick in
                                let isChecked = viewStore.measures.contains(pick)
                                CheckboxField(name: pick, action: {
                                    let action = isChecked ? ChartEditorReducer.Action.removeMeasure($0) : ChartEditorReducer.Action.addMeasure($0)
                                    
                                    viewStore.send(action)
                                }, isChecked: isChecked)
                            }.frame(minWidth: 300)
                        }
                    }
                }
            }

        }
 
    }
}
