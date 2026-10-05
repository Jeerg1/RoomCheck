//
//  InspectionSession.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import Foundation

final class InspectionSession: ObservableObject {
    @Published private(set) var rooms: [InspectionRoom] = []
    @Published var message: String?

    private let openInspection: OpenInspection

    init(repository: InspectionRepository) {
        openInspection = OpenInspection(repository: repository)
    }

    func start(address: String) {
        do {
            let inspection = try openInspection.call(address: address)
            rooms = inspection.rooms
            message = nil
        } catch let error as InspectionJobError {
            message = error.message
        } catch {
            message = "The inspection could not be saved. Try again."
        }
    }
}
