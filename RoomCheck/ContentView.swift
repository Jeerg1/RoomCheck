//
//  ContentView.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var session = InspectionSession(
        repository: CoreDataInspectionRepository()
    )
    @State private var address = ""

    var body: some View {
        NavigationStack {
            Form {
                if session.rooms.isEmpty {
                    TextField("Property address", text: $address)
                    Button("Open inspection") {
                        session.start(address: address)
                    }
                    .disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else {
                    Section(address.isEmpty ? "Open inspection" : address) {
                        ForEach(session.rooms) { room in
                            Text(room.name)
                        }
                    }
                }
                if let message = session.message {
                    Text(message)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Inspections")
        }
    }
}
