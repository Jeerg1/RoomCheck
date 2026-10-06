//
//  RoomCheckTests.swift
//  RoomCheckTests
//
//  Created by John Re on 5/10/2026.
//

import Foundation
import Testing
@testable import RoomCheck

final class MockInspectionRepository: InspectionRepository {
    var inspections: [PropertyInspection] = []

    func save(_ room: InspectionRoom) {}

    func rooms() -> [InspectionRoom] { [] }

    func uncheckedRooms() -> [InspectionRoom] { [] }

    func openInspection(address: String) -> PropertyInspection? {
        inspections.first {
            $0.isOpen && $0.propertyAddress.compare(address, options: .caseInsensitive) == .orderedSame
        }
    }

    func save(_ inspection: PropertyInspection) {
        if let index = inspections.firstIndex(where: { $0.id == inspection.id }) {
            inspections[index] = inspection
        } else {
            inspections.append(inspection)
        }
    }
}

struct OpenInspectionTests {
    @Test func rejectsSecondOpenInspectionOnSameProperty() throws {
        let repository = MockInspectionRepository()
        let useCase = OpenInspection(repository: repository)
        _ = try useCase.call(address: "12 Darling Street")

        #expect(throws: InspectionJobError.inspectionAlreadyOpen(address: "12 Darling Street")) {
            try useCase.call(address: "12 darling street")
        }
    }
}

struct RecordDefectTests {
    @Test func rejectsDefectWithEmptyNote() {
        let room = InspectionRoom(
            id: UUID(),
            name: "Kitchen",
            sortOrder: 1,
            status: .unchecked,
            defects: []
        )

        #expect(throws: InspectionJobError.emptyDefectNote) {
            try RecordDefect().call(room: room, note: "   ", photoPath: "kitchen.jpg")
        }
    }
}
