//
//  RoomCheckApp.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import SwiftUI

@main
struct RoomCheckApp: App {
    @StateObject private var session = InspectionSession(
        repository: CoreDataInspectionRepository()
    )
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                session.attachSharedPhoto()
            }
        }
    }
}
