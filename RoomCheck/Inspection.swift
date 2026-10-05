//
//  Inspection.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import Foundation

struct PropertyInspection: Identifiable, Equatable {
    let id: UUID
    var propertyAddress: String
    var openedAt: Date
    var closedAt: Date?
    var rooms: [InspectionRoom]

    var isOpen: Bool { closedAt == nil }
}

struct InspectionRoom: Identifiable, Equatable {
    let id: UUID
    var name: String
    var sortOrder: Int
    var status: RoomStatus
    var defects: [DefectNote]
}

enum RoomStatus: String, Equatable {
    case unchecked
    case clear
    case hasDefect
}

struct DefectNote: Identifiable, Equatable {
    let id: UUID
    var body: String
    var createdAt: Date
}
