//
//  RecordDefect.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import Foundation

enum RecordDefectError: Error, Equatable {
    case emptyDefectNote

    var message: String {
        switch self {
        case .emptyDefectNote:
            return "Write what is wrong in this room. A photo alone is not a condition note."
        }
    }
}

struct RecordDefect {
    func call(room: InspectionRoom, note: String, photoPath: String?) throws -> InspectionRoom {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RecordDefectError.emptyDefectNote }
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
