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
        room.managedObjectClassName = NSStringFromClass(CDInspectionRoom.self)

        let defect = NSEntityDescription()
        defect.name = "DefectNote"
        defect.managedObjectClassName = NSStringFromClass(CDDefectNote.self)

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

        room.properties = [defects]
        defect.properties = [roomLink]

        let model = NSManagedObjectModel()
        model.entities = [room, defect]
        return model
    }
}

@objc(CDInspectionRoom)
final class CDInspectionRoom: NSManagedObject {
    @NSManaged var defects: NSSet?
}

@objc(CDDefectNote)
final class CDDefectNote: NSManagedObject {
    @NSManaged var room: CDInspectionRoom?
}
