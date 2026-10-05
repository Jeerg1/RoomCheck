//
//  ContentView.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var address = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Property address", text: $address)
                Button("Open inspection") {}
                    .disabled(address.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationTitle("Inspections")
        }
    }
}

#Preview {
    ContentView()
}
