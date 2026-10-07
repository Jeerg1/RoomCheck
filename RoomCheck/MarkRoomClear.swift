//
//  MarkRoomClear.swift
//  RoomCheck
//
//  Created by John Re on 7/10/2026.
//

import Foundation

enum MarkRoomClearError: Error, Equatable {
    case roomHasDefects

    var message: String {
        switch self {
        case .roomHasDefects:
            return "This room has recorded defects and cannot be marked clear."
        }
    }
}

struct MarkRoomClear {
    func call(room: InspectionRoom) throws -> InspectionRoom {
        guard room.defects.isEmpty else {
            throw MarkRoomClearError.roomHasDefects
        }

        var updated = room
        updated.status = .clear
        return updated
    }
}
