//
//  CheckboxField.swift
//  FitGraphs
//
//  Created by b on 06/04/2024.
//

import SwiftUI

struct CheckboxField: View {
    var text: String
    var action: () -> ()
    var isChecked: Bool = false
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(alignment: .top, spacing: 10) {
               Rectangle()
                    .fill(isChecked ? .gray : .white)
                    .frame(width:20, height:20, alignment: .center)
                    .cornerRadius(5)
                    .border(.gray)
                Spacer()
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .foregroundColor(.black)
    }
}
