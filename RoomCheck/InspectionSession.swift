//
//  InspectionSession.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import Foundation
import WidgetKit

final class InspectionSession: ObservableObject {
    @Published private(set) var rooms: [InspectionRoom] = []
    @Published private(set) var inspection: PropertyInspection?
    @Published var message: String?

    private let repository: InspectionRepository
    private let openInspection: OpenInspection
    private let recordDefect = RecordDefect()
    private let closeInspection = CloseInspection()

    init(repository: InspectionRepository) {
        self.repository = repository
        openInspection = OpenInspection(repository: repository)
        rooms = repository.rooms()
        publishWidget()
    }
    
    func attachSharedPhoto() {
        let store = UserDefaults(suiteName: "group.JohnReUTS.RoomCheck")
        guard let path = store?.string(forKey: "sharedPhotoPath"),
              let index = rooms.firstIndex(where: { $0.status != .clear }) else { return }
        store?.removeObject(forKey: "sharedPhotoPath")
        do {
            let updated = try recordDefect.call(room: rooms[index], note: "Shared photo", photoPath: path)
            repository.save(updated)
            rooms[index] = updated
            publishWidget()
        } catch {
            message = "The shared photo could not be saved."
        }
    }

    func start(address: String) {
        guard rooms.isEmpty else { return }

        do {
            let opened = try openInspection.call(address: address)
            inspection = opened
            rooms = opened.rooms
            message = nil
            publishWidget()
        } catch let error as OpenInspectionError {
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
            publishWidget()
        } catch let error as RecordDefectError {
            message = error.message
        } catch {
            message = "The defect could not be saved. Try again."
        }
    }
    
    func close() {
        do {
            try closeInspection.call(rooms: rooms)

            guard var inspection else { return }

            inspection.rooms = rooms
            inspection.closedAt = Date()

            repository.save(inspection)

            self.inspection = nil
            rooms = []
            message = nil
            publishWidget()
        } catch let error as CloseInspectionError {
            message = error.message
        } catch {
            message = "The inspection could not be closed. Try again."
        }
    }

    func clear() {
        inspection = nil
        rooms = []
        message = nil
        publishWidget()
    }

    private func publishWidget() {
        let summary = rooms.isEmpty ? "No rooms" : "\(rooms.filter { $0.status == .unchecked }.count) unchecked"
        UserDefaults(suiteName: "group.JohnReUTS.RoomCheck")?.set(summary, forKey: "widgetSummary")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
