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

    private let repository: InspectionRepository
    private let openInspection: OpenInspection
    private let recordDefect = RecordDefect()

    init(repository: InspectionRepository) {
        self.repository = repository
        openInspection = OpenInspection(repository: repository)
        rooms = repository.rooms()
    }

    func start(address: String) {
        guard rooms.isEmpty else { return }
        do {
            _ = try openInspection.call(address: address)
            rooms = repository.rooms()
            message = nil
        } catch let error as InspectionJobError {
            message = error.message
        } catch {
            message = "The inspection could not be saved. Try again."
        }
    }

    func addDefect(roomId: UUID, note: String, photoPath: String?) {
        guard let index = rooms.firstIndex(where: { $0.id == roomId }) else { return }
        do {
            let updated = try recordDefect.call(room: rooms[index], note: note, photoPath: photoPath)
            repository.save(updated)
            rooms[index] = updated
            message = nil
        } catch let error as InspectionJobError {
            message = error.message
        } catch {
            message = "The defect could not be saved. Try again."
        }
    }

    func clear() {
        rooms = []
        message = nil
    }
}
