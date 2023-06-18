//
//  EditHub.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI

struct EditHub: View {
    var body: some View {
        VStack(spacing: 0) {
            Selector(name: "Filters")
            Selector(name: "Dimensions")
            Selector(name: "Measures")
        }
    }
}

#Preview {
    EditHub()
}
