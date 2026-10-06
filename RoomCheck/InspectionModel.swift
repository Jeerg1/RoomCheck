//
//  InspectionModel.swift
//  RoomCheck
//
//  Created by John Re on 5/10/2026.
//

import CoreData

enum InspectionModel {
    static func make() -> NSManagedObjectModel {
        let room = NSEntityDescription()
        room.name = "InspectionRoom"
        room.managedObjectClassName = "CDInspectionRoom"

        let defect = NSEntityDescription()
        defect.name = "DefectNote"
        defect.managedObjectClassName = "CDDefectNote"

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

        room.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("name", .stringAttributeType),
            attribute("sortOrder", .integer16AttributeType),
            attribute("statusRaw", .stringAttributeType),
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
        model.entities = [room, defect]
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

@objc(CDInspectionRoom)
final class CDInspectionRoom: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var sortOrder: Int16
    @NSManaged var statusRaw: String?
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
