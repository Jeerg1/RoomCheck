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
    func save(_ inspection: PropertyInspection)
}

final class CoreDataInspectionRepository: InspectionRepository {
    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "RoomCheck", managedObjectModel: InspectionModel.make())
        container.loadPersistentStores { _, error in
            if let error {
                print("Store failed: \(error)")
            }
        }
    }

    func save(_ room: InspectionRoom) {
        let context = container.viewContext
        let object = existing(id: room.id, in: context) ?? CDInspectionRoom(context: context)
        object.id = room.id
        object.name = room.name
        object.sortOrder = Int16(room.sortOrder)
        object.statusRaw = room.status.rawValue

        let existingNotes = (object.defects as? Set<CDDefectNote>) ?? []
        for note in existingNotes where !room.defects.contains(where: { $0.id == note.id }) {
            context.delete(note)
        }
        for note in room.defects {
            let stored = existingNotes.first { $0.id == note.id } ?? CDDefectNote(context: context)
            stored.id = note.id
            stored.body = note.body
            stored.createdAt = note.createdAt
            stored.room = object
        }
        try? context.save()
    }

    func rooms() -> [InspectionRoom] {
        let request = NSFetchRequest<CDInspectionRoom>(entityName: "InspectionRoom")
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return (try? container.viewContext.fetch(request))?.map(map) ?? []
    }

    func uncheckedRooms() -> [InspectionRoom] {
        let request = NSFetchRequest<CDInspectionRoom>(entityName: "InspectionRoom")
        request.predicate = NSPredicate(format: "statusRaw == %@", RoomStatus.unchecked.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return (try? container.viewContext.fetch(request))?.map(map) ?? []
    }

    func openInspection(address: String) -> PropertyInspection? {
        let saved = rooms()
        guard !saved.isEmpty else { return nil }
        return PropertyInspection(
            id: UUID(),
            propertyAddress: address,
            openedAt: Date(),
            closedAt: nil,
            rooms: saved
        )
    }

    func save(_ inspection: PropertyInspection) {
        let context = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InspectionRoom")
        let wipe = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? context.execute(wipe)
        context.reset()
        inspection.rooms.forEach(save)
    }

    private func existing(id: UUID, in context: NSManagedObjectContext) -> CDInspectionRoom? {
        let request = NSFetchRequest<CDInspectionRoom>(entityName: "InspectionRoom")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func map(_ object: CDInspectionRoom) -> InspectionRoom {
        let notes = ((object.defects as? Set<CDDefectNote>) ?? []).map { note in
            DefectNote(id: note.id ?? UUID(), body: note.body ?? "", createdAt: note.createdAt ?? Date())
        }
        return InspectionRoom(
            id: object.id ?? UUID(),
            name: object.name ?? "",
            sortOrder: Int(object.sortOrder),
            status: RoomStatus(rawValue: object.statusRaw ?? "") ?? .unchecked,
            defects: notes
        )
    }
}
