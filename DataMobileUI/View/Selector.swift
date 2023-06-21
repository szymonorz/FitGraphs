//
//  Selector.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI
import WrappingHStack

struct Selector: View {
    var name: String
    var type: String
    @StateObject var chart: ChartItem
    @State var isPickerPresented: Bool = false
    
    @State var presentationDetent = PresentationDetent.medium
    
    var callback: (ChartItem) -> ()
    
    var body: some View {
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
                    WrappingHStack(chart.dimensions, id: \.self) { dim in
                        Field(name: dim, action: {
                            dim in
                            
                            chart.dimensions.remove(at: chart.dimensions.firstIndex(of: dim)!)
                            callback(chart)
                        })
                    }
                case "measures":
                    WrappingHStack(chart.measures, id: \.self) { measure in
                        Field(name: measure, action: {
                            measure in
                            
                            chart.measures.remove(at: chart.measures.firstIndex(of: measure)!)
                            callback(chart)
                        })
                    }
                case "filters":
                    WrappingHStack(chart.filters, id: \.self) { filter in
                        Field(name: filter, action: {
                            filter in
                            
                            chart.filters.remove(at: chart.filters.firstIndex(of: filter)!)
                            callback(chart)
                        })
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
                            onSaveCallback: callback,
                            chart: chart,
                            type: type)
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

struct FieldPicker: View {
    @Binding var isPickerPresented: Bool
    var onSaveCallback: (ChartItem) -> ()
    @StateObject var chart: ChartItem
    var type: String
    
    //var toChose: [String] = Activity.CodingKeys.allCases.map { $0.stringValue }.filter { $0.typ}
    var dimsToChose: [String] = ["name", "sport_type"]
    var measuresToChose: [String] = ["COUNT(sport_type)", "AVG(distance)"]
    
    var body: some View {
        VStack {
            HStack {
                switch type {
                case "dimensions":
                    WrappingHStack(chart.dimensions, id: \.self) { dim in
                        Field(name: dim, action: {
                            dim in
                            
                            chart.dimensions.remove(at: chart.dimensions.firstIndex(of: dim)!)
                            onSaveCallback(chart)
                        })
                    }
                case "measures":
                    WrappingHStack(chart.measures, id: \.self) { measure in
                        Field(name: measure, action: {
                            measure in
                            
                            chart.measures.remove(at: chart.measures.firstIndex(of: measure)!)
                            onSaveCallback(chart)
                        })
                    }
                case "filters":
                    WrappingHStack(chart.filters, id: \.self) { filter in
                        Field(name: filter, action: {
                            filter in
                            
                            chart.filters.remove(at: chart.filters.firstIndex(of: filter)!)
                            onSaveCallback(chart)
                        })
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
                    WrappingHStack(dimsToChose, id: \.self, spacing: .constant(10)) {
                        pick in
                        Field(name: pick, action: {
                            pick in
                                chart.dimensions = [pick]
                                onSaveCallback(chart)
                            })
                    }.frame(minWidth: 300)
                }
                if type == "measures" {
                    WrappingHStack(measuresToChose, id: \.self, spacing: .constant(10)) {
                        pick in
                        Field(name: pick, action: {
                            pick in
                                chart.measures = [pick]
                                onSaveCallback(chart)
                            })
                    }.frame(minWidth: 300)
                }
            }
        }
    }
}

#Preview {
    Selector(name: "Cringe",
             type: "dimensions",
             chart: ChartItem(name: "cringe", type: "BAR", contents: []),
             callback: {
                chart in
            }
    )
}
