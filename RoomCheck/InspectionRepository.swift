//
//  InspectionRepository.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import CoreData
import Foundation

protocol InspectionRepository {
    func save(_ room: InspectionRoom)
    func rooms() -> [InspectionRoom]
    func uncheckedRooms() -> [InspectionRoom]
    func openInspection(address: String) -> PropertyInspection?
    func closedInspections() -> [PropertyInspection]
    func save(_ inspection: PropertyInspection)
    func currentOpenInspection() -> PropertyInspection?
}

final class CoreDataInspectionRepository: InspectionRepository {
    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(
            name: "RoomCheck",
            managedObjectModel: InspectionModel.make()
        )

        container.loadPersistentStores { _, error in
            if let error {
                print("Store failed: \(error)")
            }
        }
    }

    func save(_ inspection: PropertyInspection) {
        let context = container.viewContext

        let storedInspection =
            existingInspection(id: inspection.id, in: context)
            ?? CDPropertyInspection(context: context)

        storedInspection.id = inspection.id
        storedInspection.propertyAddress = inspection.propertyAddress
        storedInspection.openedAt = inspection.openedAt
        storedInspection.closedAt = inspection.closedAt

        for room in inspection.rooms {
            let storedRoom =
                existingRoom(id: room.id, in: context)
                ?? CDInspectionRoom(context: context)

            storedRoom.id = room.id
            storedRoom.name = room.name
            storedRoom.sortOrder = Int16(room.sortOrder)
            storedRoom.statusRaw = room.status.rawValue
            storedRoom.inspection = storedInspection

            saveDefects(room.defects, for: storedRoom, in: context)
        }

        try? context.save()
    }

    func save(_ room: InspectionRoom) {
        let context = container.viewContext

        guard let storedRoom = existingRoom(id: room.id, in: context) else {
            return
        }

        storedRoom.name = room.name
        storedRoom.sortOrder = Int16(room.sortOrder)
        storedRoom.statusRaw = room.status.rawValue

        saveDefects(room.defects, for: storedRoom, in: context)

        try? context.save()
    }

    func rooms() -> [InspectionRoom] {
        let request = NSFetchRequest<CDInspectionRoom>(
            entityName: "InspectionRoom"
        )

        request.predicate = NSPredicate(
            format: "inspection.closedAt == nil"
        )

        request.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ]

        return (try? container.viewContext.fetch(request))?.map(mapRoom) ?? []
    }

    func uncheckedRooms() -> [InspectionRoom] {
        let request = NSFetchRequest<CDInspectionRoom>(
            entityName: "InspectionRoom"
        )

        request.predicate = NSPredicate(
            format: "inspection.closedAt == nil AND statusRaw == %@",
            RoomStatus.unchecked.rawValue
        )

        request.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ]

        return (try? container.viewContext.fetch(request))?.map(mapRoom) ?? []
    }

    func openInspection(address: String) -> PropertyInspection? {
        let request = NSFetchRequest<CDPropertyInspection>(
            entityName: "PropertyInspection"
        )

        request.predicate = NSPredicate(
            format: "closedAt == nil AND propertyAddress =[c] %@",
            address
        )

        request.fetchLimit = 1

        guard let stored = (try? container.viewContext.fetch(request))?.first else {
            return nil
        }

        return mapInspection(stored)
    }
    
    func closedInspections() -> [PropertyInspection] {
        let request = NSFetchRequest<CDPropertyInspection>(
            entityName: "PropertyInspection"
        )

        request.predicate = NSPredicate(
            format: "closedAt != nil"
        )

        request.sortDescriptors = [
            NSSortDescriptor(key: "closedAt", ascending: false)
        ]

        return (try? container.viewContext.fetch(request))?.map(mapInspection) ?? []
    }

    private func saveDefects(
        _ defects: [DefectNote],
        for room: CDInspectionRoom,
        in context: NSManagedObjectContext
    ) {
        let existingNotes = (room.defects as? Set<CDDefectNote>) ?? []

        for stored in existingNotes
        where !defects.contains(where: { $0.id == stored.id }) {
            context.delete(stored)
        }

        for defect in defects {
            let stored =
                existingNotes.first(where: { $0.id == defect.id })
                ?? CDDefectNote(context: context)

            stored.id = defect.id
            stored.body = defect.body
            stored.photoPath = defect.photoPath
            stored.createdAt = defect.createdAt
            stored.room = room
        }
    }

    private func existingInspection(
        id: UUID,
        in context: NSManagedObjectContext
    ) -> CDPropertyInspection? {
        let request = NSFetchRequest<CDPropertyInspection>(
            entityName: "PropertyInspection"
        )

        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )

        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    private func existingRoom(
        id: UUID,
        in context: NSManagedObjectContext
    ) -> CDInspectionRoom? {
        let request = NSFetchRequest<CDInspectionRoom>(
            entityName: "InspectionRoom"
        )

        request.predicate = NSPredicate(
            format: "id == %@",
            id as CVarArg
        )

        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    private func mapInspection(
        _ object: CDPropertyInspection
    ) -> PropertyInspection {
        let rooms = ((object.rooms as? Set<CDInspectionRoom>) ?? [])
            .map(mapRoom)
            .sorted { $0.sortOrder < $1.sortOrder }

        return PropertyInspection(
            id: object.id ?? UUID(),
            propertyAddress: object.propertyAddress ?? "",
            openedAt: object.openedAt ?? Date(),
            closedAt: object.closedAt,
            rooms: rooms
        )
    }

    private func mapRoom(
        _ object: CDInspectionRoom
    ) -> InspectionRoom {
        let notes = ((object.defects as? Set<CDDefectNote>) ?? [])
            .map { note in
                DefectNote(
                    id: note.id ?? UUID(),
                    body: note.body ?? "",
                    photoPath: note.photoPath,
                    createdAt: note.createdAt ?? Date()
                )
            }
            .sorted { $0.createdAt < $1.createdAt }

        return InspectionRoom(
            id: object.id ?? UUID(),
            name: object.name ?? "",
            sortOrder: Int(object.sortOrder),
            status: RoomStatus(rawValue: object.statusRaw ?? "") ?? .unchecked,
            defects: notes
        )
    }
    
    func currentOpenInspection() -> PropertyInspection? {
        let request = NSFetchRequest<CDPropertyInspection>(
            entityName: "PropertyInspection"
        )

        request.predicate = NSPredicate(
            format: "closedAt == nil"
        )

        request.sortDescriptors = [
            NSSortDescriptor(key: "openedAt", ascending: false)
        ]

        request.fetchLimit = 1

        guard let stored = (try? container.viewContext.fetch(request))?.first else {
            return nil
        }

        return mapInspection(stored)
    }
}
