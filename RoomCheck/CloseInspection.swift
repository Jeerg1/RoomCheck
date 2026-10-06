//
//  CloseInspection.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import Foundation

enum CloseInspectionError: Error, Equatable {
    case roomUnchecked(name: String)

    var message: String {
        switch self {
        case .roomUnchecked(let name):
            return "\(name) is still unchecked. Mark it clear or record a defect before closing."
        }
    }
}

struct CloseInspection {
    func call(rooms: [InspectionRoom]) throws {
        if let unchecked = rooms.first(where: { $0.status == .unchecked }) {
            throw CloseInspectionError.roomUnchecked(name: unchecked.name)
        }
    }
}
