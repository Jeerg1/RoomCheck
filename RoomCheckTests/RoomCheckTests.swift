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
    
    func closedInspections() -> [PropertyInspection] {
        inspections.filter { !$0.isOpen }
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

        #expect(throws: OpenInspectionError.inspectionAlreadyOpen(address: "12 Darling Street")) {
            try useCase.call(address: "12 darling street")
        }
    }
    
    @Test func createsNewInspectionForNewAddress() throws {
        let repository = MockInspectionRepository()
        let useCase = OpenInspection(repository: repository)

        let inspection = try useCase.call(address: "12 Darling Street")

        #expect(inspection.propertyAddress == "12 Darling Street")
        #expect(inspection.rooms.count == 6)
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

        #expect(throws: RecordDefectError.emptyDefectNote) {
            try RecordDefect().call(room: room, note: "   ", photoPath: "kitchen.jpg")
        }
    }
}

struct CloseInspectionTests {
    @Test func rejectsCloseWhileARoomIsUnchecked() {
        let rooms = [
            InspectionRoom(id: UUID(), name: "Kitchen", sortOrder: 1, status: .clear, defects: []),
            InspectionRoom(id: UUID(), name: "Laundry", sortOrder: 5, status: .unchecked, defects: [])
        ]

        #expect(throws: CloseInspectionError.roomUnchecked(name: "Laundry")) {
            try CloseInspection().call(rooms: rooms)
        }
    }
    
    @Test func allowsCloseWhenAllRoomsAreChecked() throws {
        let rooms = [
            InspectionRoom(
                id: UUID(),
                name: "Kitchen",
                sortOrder: 1,
                status: .clear,
                defects: []
            ),
            InspectionRoom(
                id: UUID(),
                name: "Laundry",
                sortOrder: 5,
                status: .hasDefect,
                defects: []
            )
        ]

        try CloseInspection().call(rooms: rooms)
    }
}

struct InspectionRepositoryTests {
    @Test func savesAndRetrievesOpenInspection() {
        let repository = MockInspectionRepository()

        let inspection = PropertyInspection(
            id: UUID(),
            propertyAddress: "12 Darling Street",
            openedAt: Date(),
            closedAt: nil,
            rooms: []
        )

        repository.save(inspection)

        let saved = repository.openInspection(address: "12 Darling Street")

        #expect(saved?.id == inspection.id)
        #expect(saved?.propertyAddress == "12 Darling Street")
    }
}
