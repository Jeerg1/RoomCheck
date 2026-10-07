# RoomCheck

RoomCheck is an iOS property-inspection application designed for residential property inspectors carrying out room-by-room condition inspections.

The app provides a structured inspection workflow so that every room must be checked, marked clear, or given a documented defect before an inspection can be closed. Inspection records are persisted using Core Data and can be reviewed later through inspection history.

## Domain Context

Residential property inspections require inspectors to move through a property and consistently record the condition of multiple rooms.

A missed room, incomplete note, or poorly recorded defect can reduce the usefulness of the final inspection record and may require the inspector to revisit the property or clarify information later.

RoomCheck addresses this by creating a standard inspection containing six rooms:

- Entry
- Kitchen
- Living
- Bedroom
- Bathroom
- Laundry

Each room begins with an `unchecked` status.

A room can then be:

- marked `clear`, or
- marked as having a defect after a defect note is recorded.

A defect must contain a written note. A photo may also be associated with the defect, but a photo does not replace the written defect description.

An inspection cannot be closed while any room remains unchecked.

If an open inspection already exists for the same property address, RoomCheck resumes that inspection rather than creating a duplicate.

## Primary Stakeholder

The primary stakeholder is a residential property inspector carrying out on-site condition inspections of rental or residential properties.

The inspector needs a fast and reliable way to record room conditions, defect notes and supporting photos while physically moving through a property.

## Main Features

RoomCheck supports:

- Creating an inspection using a property address
- Resuming an existing open inspection for the same address
- Automatically creating six standard inspection rooms
- Viewing an active inspection
- Viewing the status of each room
- Marking rooms as clear
- Recording defects with required written notes
- Optionally associating a photo path with a defect
- Preventing rooms with recorded defects from being marked clear
- Preventing an inspection from closing while rooms remain unchecked
- Persisting inspections between application launches
- Closing completed inspections
- Viewing completed inspection history
- Viewing defect information directly in inspection history
- Viewing a detailed summary of completed inspections
- Displaying the number of unchecked rooms through an iOS widget
- Importing a photo through the iOS Share Sheet

## Application Screens

RoomCheck contains five functional screens that support the inspection workflow:

1. **Inspection Start**  
   Allows the inspector to enter a property address and begin or resume an inspection.

2. **Active Inspection**  
   Displays the current property and the status of each inspection room.

3. **Room Detail**  
   Allows a room to be marked clear or a defect to be recorded.

4. **Inspection History**  
   Displays completed inspections, their completion dates and recorded defects.

5. **Inspection Summary**  
   Displays the full room-by-room result of a completed inspection.

The overall workflow is:

```text
Enter property address
        ↓
Open or resume inspection
        ↓
Active Inspection
        ↓
Room Detail
        ↓
Mark Clear / Record Defect
        ↓
Complete all rooms
        ↓
Close Inspection
        ↓
Inspection History
        ↓
Inspection Summary
```

## Architecture

RoomCheck uses a domain-centred layered architecture.

The main application flow is:

```text
SwiftUI Views
        ↓
InspectionSession
        ↓
Use Cases
        ↓
InspectionRepository Protocol
        ↓
CoreDataInspectionRepository
        ↓
Core Data
```

This separates user interface code, business rules and persistence responsibilities.

SwiftUI Views do not directly access Core Data.

## View and Session Layer

`ContentView` provides the main entry point and navigation.

The application's SwiftUI views include:

- `ContentView`
- `ActiveInspectionView`
- `RoomDetailView`
- `InspectionHistoryView`
- `InspectionSummaryView`

`InspectionSession` acts as the observable session/ViewModel layer for the application.

It coordinates:

- the current inspection
- inspection rooms
- completed inspections
- user-facing error messages
- Use Case execution
- repository persistence
- widget updates
- shared photos received from the Share Extension

## Use Case Layer

Significant inspection operations are implemented as domain-specific Use Cases.

### OpenInspection

`OpenInspection` starts an inspection for a property.

Business rules include:

- the property address cannot be blank
- leading and trailing whitespace is ignored
- an existing open inspection for the same address is resumed rather than duplicated

### RecordDefect

`RecordDefect` records a defect against a room.

Business rules include:

- a defect must contain a written note
- whitespace-only notes are rejected
- a photo alone is not considered a valid defect record
- recording a defect changes the room status to `hasDefect`

### MarkRoomClear

`MarkRoomClear` marks an inspected room as clear.

Business rule:

- a room containing recorded defects cannot be marked clear

### CloseInspection

`CloseInspection` determines whether an inspection can be closed.

Business rule:

- every room must be checked before the inspection can close

Each Use Case defines domain-specific errors so failures can be shown to the inspector in understandable language.

## Domain Models

RoomCheck uses semantic domain models that represent the property-inspection workflow.

### PropertyInspection

Represents an inspection of one property.

Contains:

- ID
- property address
- opening date
- closing date
- inspection rooms

### InspectionRoom

Represents a room included in an inspection.

Contains:

- ID
- room name
- display order
- room status
- defect notes

Room status can be:

- `unchecked`
- `clear`
- `hasDefect`

### DefectNote

Represents a defect recorded during an inspection.

Contains:

- ID
- written defect description
- optional photo path
- creation date

## Database Choice

RoomCheck uses **Core Data** to persist its primary domain data.

Core Data was chosen because RoomCheck requires inspection information to be stored locally, accessed quickly and remain available after the application is terminated.

The current workflow does not require multiple inspectors to simultaneously edit the same inspection or automatically share records between different users. Local persistence is therefore appropriate for the current application.

Core Data also allows an unfinished inspection to survive application termination so that the inspector can resume the inspection later.

The Core Data model contains three related entities:

```text
PropertyInspection
        |
        | one-to-many
        ↓
InspectionRoom
        |
        | one-to-many
        ↓
DefectNote
```

All Core Data access is isolated behind the `InspectionRepository` protocol.

The production implementation is:

```text
CoreDataInspectionRepository
```

Unit tests use:

```text
MockInspectionRepository
```

This allows business logic to be tested without using the real Core Data stack.

## Repository Queries

RoomCheck uses domain-relevant Core Data predicates rather than loading all data and filtering it in the user interface.

Repository queries include:

- retrieving the current open inspection
- retrieving an open inspection for a particular property address
- retrieving closed inspections
- retrieving unchecked rooms belonging to an open inspection

## System Extensions

RoomCheck implements two iOS system extensions:

1. WidgetKit Widget Extension
2. Share Extension

Both extensions use the same App Group as the main RoomCheck application.

## WidgetKit Widget

The RoomCheck widget displays information about the current inspection.

Its primary purpose is to let the inspector quickly see how many rooms remain unchecked without navigating back through the main application.

The widget supports two widget families:

- Lock Screen `accessoryRectangular`
- Home Screen `systemMedium`

When inspection data changes, RoomCheck writes the updated inspection summary to the shared App Group and calls:

```swift
WidgetCenter.shared.reloadAllTimelines()
```

This allows the widget to refresh after relevant inspection changes.

The widget is added to the Home Screen or Lock Screen manually by the user, as required by iOS.

## Share Extension

The RoomCheck Share Extension allows a property inspector to send a photo from another application, such as Photos, into RoomCheck.

The workflow is:

```text
Photos
    ↓
iOS Share Sheet
    ↓
RoomCheck Share Extension
    ↓
App Group shared container
    ↓
RoomCheck
```

The Share Extension:

1. receives an image
2. stores the image in the shared App Group container
3. records the shared photo path
4. completes and dismisses the Share Extension
5. allows the main RoomCheck app to process the shared photo when it becomes active

The shared image is attached to the open inspection with the note:

```text
Shared photo
```

This allows supporting inspection evidence already stored in Photos to be brought into the inspection workflow.

## App Group

The main application, Widget Extension and Share Extension use:

```text
group.JohnReUTS.RoomCheck
```

The App Group is enabled for:

- RoomCheck
- RoomCheckWidget
- RoomCheckShare

The App Group allows the application's separate processes to exchange the small amount of shared information required by the widget and Share Extension.

## Unit Testing

RoomCheck includes automated unit tests using Swift Testing.

Tests use `MockInspectionRepository` instead of the real Core Data stack.

The test suite covers scenarios including:

- creating a new inspection
- resuming an existing open inspection at the same property address
- rejecting a blank property address
- rejecting an empty defect note
- rejecting a whitespace-only defect note
- preventing a room with existing defects from being marked clear
- preventing an inspection from closing while a room remains unchecked
- allowing an inspection to close when all rooms have been checked
- saving and retrieving inspections through the repository abstraction

The test suite covers:

- happy paths
- boundary conditions
- domain error cases
- repository behaviour

UI launch tests generated by the Xcode project template are not used as part of the assessed unit-test suite.

## Setup Instructions

1. Clone or download the RoomCheck repository.
2. Open `RoomCheck.xcodeproj`.
3. Select the RoomCheck project in Xcode.
4. Configure an Apple Development Team under **Signing & Capabilities** if required.
5. Confirm that the following App Group is enabled:

```text
group.JohnReUTS.RoomCheck
```

6. Confirm the App Group is enabled for:
   - RoomCheck
   - RoomCheckWidget
   - RoomCheckShare
7. Select an iPhone Simulator.
8. Build the project using `Command + B`.
9. Run the application using `Command + R`.
10. Run the unit tests using `Command + U`.

## Testing the Main Inspection Workflow

1. Launch RoomCheck.
2. Enter a property address.
3. Open the inspection.
4. Select each room.
5. Mark the room clear or record a defect.
6. Attempting to close the inspection while a room remains unchecked should display an error.
7. Complete all rooms.
8. Close the inspection.
9. Open Inspection History.
10. Select the completed inspection to view its Inspection Summary.

## Testing Persistence

1. Start an inspection.
2. Record room information.
3. Close RoomCheck.
4. Relaunch the application.
5. Confirm that the open inspection and previously saved room information are restored.

## Testing the Widget

1. Run RoomCheck.
2. Start an inspection.
3. Return to the Simulator Home Screen.
4. Add the RoomCheck widget.
5. Select either the medium Home Screen widget or Lock Screen widget.
6. Confirm the widget displays the unchecked-room count.
7. Return to RoomCheck.
8. Mark a room clear or record a defect.
9. Return to the widget.
10. Confirm the unchecked-room count has updated.

## Testing the Share Extension

1. Start an inspection in RoomCheck.
2. Open Photos.
3. Select an image.
4. Open the iOS Share Sheet.
5. Select RoomCheck.
6. Complete the Share Extension action.
7. Return to RoomCheck.
8. Confirm that the shared photo has been processed into the open inspection.

## Version Control

RoomCheck is maintained using Git.

Development was completed using small commits rather than uploading the complete application in a single commit.

Commit messages follow Conventional Commit prefixes including:

```text
feat:
fix:
test:
docs:
```

The `main` branch contains the stable working application.

Major application functionality was developed incrementally and committed throughout development.

## Technologies

RoomCheck uses Apple platform technologies including:

- Swift
- SwiftUI
- Core Data
- WidgetKit
- UIKit
- UniformTypeIdentifiers
- App Groups
- Swift Testing

No third-party Swift packages are currently required.

## AI Assistance

AI coding assistance was used during development.

AI assistance was used for activities including:

- discussing architecture
- reviewing code
- debugging compiler errors
- identifying assessment requirement gaps
- developing unit-test cases
- suggesting implementation approaches
- structure and formatting for the README.md file

AI-generated suggestions were reviewed, implemented incrementally and tested using Xcode before being retained in the project.

AI use will also be declared in the accompanying Assessment 3 documentation.

## Attribution

RoomCheck was developed as an individual university assessment.

The project uses Apple frameworks and APIs supplied with the iOS SDK.

No third-party libraries or external code were used in the project.

## Author

John Re

University of Technology Sydney
