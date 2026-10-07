//
//  OpenInspection.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import Foundation

enum OpenInspectionError: Error, Equatable {
    case emptyAddress
    case inspectionAlreadyOpen(address: String)

    var message: String {
        switch self {
        case .emptyAddress:
            return "Enter the property address before you start the walk-through."
        case .inspectionAlreadyOpen(let address):
            return "Close the open inspection at \(address) before you start another."
        }
    }
}

struct OpenInspection {
    let repository: InspectionRepository

    func call(address: String) throws -> PropertyInspection {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw OpenInspectionError.emptyAddress }
        if let existing = repository.openInspection(address: trimmed) {
            throw OpenInspectionError.inspectionAlreadyOpen(address: existing.propertyAddress)
        }
        let inspection = PropertyInspection(
            id: UUID(),
            propertyAddress: trimmed,
            openedAt: Date(),
            closedAt: nil,
            rooms: Self.standardRooms()
        )
        repository.save(inspection)
        return inspection
    }

    static func standardRooms() -> [InspectionRoom] {
        ["Entry", "Kitchen", "Living", "Bedroom", "Bathroom", "Laundry"].enumerated().map { index, name in
            InspectionRoom(
                id: UUID(),
                name: name,
                sortOrder: index,
                status: .unchecked,
                defects: []
            )
        }
    }
}
