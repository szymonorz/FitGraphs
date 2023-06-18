//
//  ChartEditorView.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI

struct ChartEditorView: View {
    @State var chartItem: ChartItem
    var body: some View {
        HStack {
            // Field Selector
            
            
            //Chart
            VStack {
                Text("Editor view")
                ChartView(chartItem: chartItem, chartWidth: 200)
            }
        }
    }
}

#Preview {
    ChartEditorView(chartItem: ChartItem(name: "3",type: "PIE", contents: [
                                    ChartItem._ChartContent(key:"0", value: 123),
                                    ChartItem._ChartContent(key:"1", value: 125),
                                    ChartItem._ChartContent(key:"2", value: 127),
                                    ChartItem._ChartContent(key:"3", value: 12)
                                    ])
    )
}
