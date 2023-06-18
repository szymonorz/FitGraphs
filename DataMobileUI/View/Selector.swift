//
//  Selector.swift
//  DataMobileUI
//
//  Created by b on 18/06/2023.
//

import SwiftUI

struct Selector: View {
    var name: String
    
    func scream() {
        print("AAAAA")
    }
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 14))
                .frame(
                    width: 80.0,
                    alignment: .leading
                )
            HStack {
                Text("hi")
                Text("hi")
                Text("hi")
                Text("hi")
                Text("hi")
                Text("hi")
                Text("hi")
                Text("hi")
                Text("hi")
                Text("hi")
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: 33.0,
                alignment: .leading
            )
            
            
            
            Button("+", action: scream)
                .fontWeight(.bold)
        }
        .padding()
        .border(Color.gray)
    }
}

#Preview {
    Selector(name: "Cringe")
}
