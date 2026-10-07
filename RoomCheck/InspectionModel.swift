//
//  InspectionModel.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import CoreData

enum InspectionModel {
    static func make() -> NSManagedObjectModel {
        let inspection = NSEntityDescription()
        inspection.name = "PropertyInspection"
        inspection.managedObjectClassName = "CDPropertyInspection"

        let room = NSEntityDescription()
        room.name = "InspectionRoom"
        room.managedObjectClassName = "CDInspectionRoom"

        let defect = NSEntityDescription()
        defect.name = "DefectNote"
        defect.managedObjectClassName = "CDDefectNote"

        let rooms = NSRelationshipDescription()
        rooms.name = "rooms"
        rooms.destinationEntity = room
        rooms.deleteRule = .cascadeDeleteRule
        rooms.minCount = 0
        rooms.maxCount = 0

        let inspectionLink = NSRelationshipDescription()
        inspectionLink.name = "inspection"
        inspectionLink.destinationEntity = inspection
        inspectionLink.deleteRule = .nullifyDeleteRule
        inspectionLink.minCount = 1
        inspectionLink.maxCount = 1

        rooms.inverseRelationship = inspectionLink
        inspectionLink.inverseRelationship = rooms

        let defects = NSRelationshipDescription()
        defects.name = "defects"
        defects.destinationEntity = defect
        defects.deleteRule = .cascadeDeleteRule
        defects.minCount = 0
        defects.maxCount = 0

        let roomLink = NSRelationshipDescription()
        roomLink.name = "room"
        roomLink.destinationEntity = room
        roomLink.deleteRule = .nullifyDeleteRule
        roomLink.minCount = 1
        roomLink.maxCount = 1

        defects.inverseRelationship = roomLink
        roomLink.inverseRelationship = defects

        inspection.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("propertyAddress", .stringAttributeType),
            attribute("openedAt", .dateAttributeType),
            attribute("closedAt", .dateAttributeType, optional: true),
            rooms
        ]

        room.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("name", .stringAttributeType),
            attribute("sortOrder", .integer16AttributeType),
            attribute("statusRaw", .stringAttributeType),
            inspectionLink,
            defects
        ]

        defect.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("body", .stringAttributeType),
            attribute("photoPath", .stringAttributeType, optional: true),
            attribute("createdAt", .dateAttributeType),
            roomLink
        ]

        let model = NSManagedObjectModel()
        model.entities = [inspection, room, defect]
        return model
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }
}

@objc(CDPropertyInspection)
final class CDPropertyInspection: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var propertyAddress: String?
    @NSManaged var openedAt: Date?
    @NSManaged var closedAt: Date?
    @NSManaged var rooms: NSSet?
}

@objc(CDInspectionRoom)
final class CDInspectionRoom: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var sortOrder: Int16
    @NSManaged var statusRaw: String?
    @NSManaged var inspection: CDPropertyInspection?
    @NSManaged var defects: NSSet?
}

@objc(CDDefectNote)
final class CDDefectNote: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var body: String?
    @NSManaged var photoPath: String?
    @NSManaged var createdAt: Date?
    @NSManaged var room: CDInspectionRoom?
}
