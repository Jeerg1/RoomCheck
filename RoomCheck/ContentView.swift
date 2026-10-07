//
//  ContentView.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: InspectionSession
    @State private var address = ""

    var body: some View {
        NavigationStack {
            Form {
                if session.rooms.isEmpty {
                    TextField("Property address", text: $address)

                    Button("Open inspection") {
                        session.start(address: address)
                    }
                    .disabled(
                        address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                } else {
                    Section(address.isEmpty ? "Open inspection" : address) {
                        ForEach(session.rooms) { room in
                            NavigationLink(room.name) {
                                RoomDetailView(room: room)
                            }
                        }
                    }

                    Button("Close Inspection") {
                        session.close()
                    }
                    .buttonStyle(.borderedProminent)
                }

                NavigationLink("Inspection History") {
                    InspectionHistoryView()
                }

                if let message = session.message {
                    Text(message)
                        .foregroundStyle(.red)

                    Button("Clear open inspection") {
                        session.clear()
                    }
                }
            }
            .navigationTitle("Inspections")
            .environmentObject(session)
        }
    }
}

struct InspectionHistoryView: View {
    @EnvironmentObject private var session: InspectionSession

    var body: some View {
        List {
            if session.closedInspections.isEmpty {
                Text("No closed inspections yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(session.closedInspections) { inspection in
                    VStack(alignment: .leading) {
                        Text(inspection.propertyAddress)
                            .font(.headline)

                        if let closedAt = inspection.closedAt {
                            Text(
                                closedAt.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Inspection History")
        .navigationBarBackButtonHidden(false)
    }
}

struct RoomDetailView: View {
    @EnvironmentObject private var session: InspectionSession
    let room: InspectionRoom

    @State private var note = ""
    @State private var photoPath = ""

    private var live: InspectionRoom {
        session.rooms.first { $0.id == room.id } ?? room
    }

    var body: some View {
        Form {
            if live.defects.isEmpty {
                Text("No defects in this room")
                    .foregroundStyle(.secondary)
            }

            ForEach(live.defects) { defect in
                VStack(alignment: .leading) {
                    Text(defect.body)

                    if let photoPath = defect.photoPath {
                        Text(photoPath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            TextField("What is wrong in this room?", text: $note)

            TextField("Photo path", text: $photoPath)

            Button("Record defect") {
                session.addDefect(
                    roomId: live.id,
                    note: note,
                    photoPath: photoPath
                )

                note = ""
                photoPath = ""
            }

            Button("Mark room clear") {
                session.markClear(roomId: live.id)
            }

            if let message = session.message {
                Text(message)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle(live.name)
        .navigationBarBackButtonHidden(false)
    }
}
