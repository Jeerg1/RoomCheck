//
//  RecordDefect.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import Foundation

struct RecordDefect {
    func call(room: InspectionRoom, note: String, photoPath: String?) throws -> InspectionRoom {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw InspectionJobError.emptyDefectNote }
        let path = photoPath?.trimmingCharacters(in: .whitespacesAndNewlines)
        var updated = room
        updated.defects.append(
            DefectNote(
                id: UUID(),
                body: trimmed,
                photoPath: path?.isEmpty == false ? path : nil,
                createdAt: Date()
            )
        )
        updated.status = .hasDefect
        return updated
    }
}
