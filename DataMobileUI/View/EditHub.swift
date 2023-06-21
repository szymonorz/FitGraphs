//
//  EditHub.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI

struct EditHub: View {
    @StateObject var chart: ChartItem
    var dataChange: (ChartItem) -> ()
    
    
    var body: some View {
        VStack(spacing: 0) {
            Selector(name: "Filters", type: "filters", chart: chart, callback: { chart in dataChange(chart) })
            Selector(name: "Dimensions", type: "dimensions", chart: chart, callback: { chart in dataChange(chart) })
            Selector(name: "Measures", type: "measures", chart: chart, callback: { chart in dataChange(chart) })
        }
    }
}

#Preview {
    EditHub(chart: ChartItem(name: "name", type: "BAR", contents: []), dataChange: {
        chart in
    })
}
