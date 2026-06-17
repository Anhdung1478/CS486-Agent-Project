```mermaid
erDiagram
    User {
        VARCHAR userID PK "User's unique identifier (e.g., university ID)"
        VARCHAR fullName "Full name of the user"
        VARCHAR email "User's email address"
        VARCHAR phoneNumber "User's phone number"
        VARCHAR role "User's role (e.g., student, lecturer, facility staff, facility manager)"
        VARCHAR department "User's academic or administrative department"
        VARCHAR accountStatus "Current status of the user's account (e.g., active, inactive, suspended)"
    }

    Space {
        VARCHAR spaceCode PK "Unique code for the space (e.g., COM1-0201)"
        VARCHAR spaceName "Descriptive name of the space (e.g., Auditorium 1, Computer Lab 2)"
        VARCHAR spaceType "Type of space (e.g., auditorium, classroom, computer laboratory, meeting room)"
        VARCHAR building "Building where the space is located"
        INT floor "Floor number of the space"
        VARCHAR roomNumber "Room number within the building/floor"
        INT capacity "Maximum capacity of the space"
        VARCHAR currentStatus "Current operational status of the space (e.g., available, in use, under maintenance, temporarily closed, retired)"
        TEXT usagePolicy "Policy governing the use of the space"
    }

    Facility {
        VARCHAR facilityName PK "Name of the facility type (e.g., Projector, Whiteboard, Microphone, Computer)"
        TEXT description "Description of the facility type"
    }

    Booking {
        INT bookingID PK "Unique identifier for the booking request"
        VARCHAR spaceCode FK "Foreign key to Space (the space being booked)"
        VARCHAR requesterUserID FK "Foreign key to User (the user who submitted the booking request)"
        VARCHAR approverUserID FK NULL "Foreign key to User (the staff/manager who approved/rejected the booking)"
        VARCHAR checkInStaffUserID FK NULL "Foreign key to User (the facility staff who checked in the booking)"
        VARCHAR completeStaffUserID FK NULL "Foreign key to User (the facility staff who completed the booking)"
        DATETIME requestedStartTime "Requested start time for the booking"
        DATETIME requestedEndTime "Requested end time for the booking"
        VARCHAR purposeOfUse "Purpose of the booking (e.g., lecture, examination, seminar, workshop, meeting)"
        INT expectedParticipants "Expected number of participants for the booking"
        VARCHAR status "Current status of the booking (e.g., pending, approved, rejected, checked in, completed, no-show)"
        DATETIME decisionTime NULL "Timestamp when the approval/rejection decision was made"
        TEXT decisionNote NULL "Notes related to the approval/rejection decision"
        TEXT rejectionReason NULL "Reason if the booking was rejected"
        DATETIME actualStartTime NULL "Actual start time of the session (recorded at check-in)"
        TEXT initialCondition NULL "Initial condition of the space (recorded at check-in)"
        DATETIME actualEndTime NULL "Actual end time of the session (recorded at completion)"
        TEXT finalCondition NULL "Final condition of the space (recorded at completion)"
        TEXT usageNotes NULL "Notes about the space usage during the session"
    }

    MaintenanceRecord {
        INT maintenanceID PK "Unique identifier for the maintenance record"
        VARCHAR spaceCode FK "Foreign key to Space (the space requiring maintenance)"
        VARCHAR reporterUserID FK "Foreign key to User (the user who reported the problem)"
        VARCHAR assignedStaffUserID FK NULL "Foreign key to User (the staff member assigned to resolve the maintenance issue)"
        TEXT problemDescription "Detailed description of the problem"
        DATETIME startTime "Time when the maintenance activity started"
        DATETIME completionTime NULL "Time when the maintenance activity was completed"
        VARCHAR status "Status of the maintenance (e.g., pending, in progress, completed, cancelled)"
        TEXT resultNote NULL "Notes about the maintenance outcome or resolution"
    }

    SpaceFacility {
        VARCHAR spaceCode PK,FK "Foreign key to Space"
        VARCHAR facilityName PK,FK "Foreign key to Facility"
    }

    User ||--o{ Booking : requests
    User ||--o{ Booking : approves
    User ||--o{ Booking : checks_in
    User ||--o{ Booking : completes
    User ||--o{ MaintenanceRecord : reports
    User ||--o{ MaintenanceRecord : is_assigned_to

    Space ||--o{ Booking : has
    Space ||--o{ MaintenanceRecord : has
    Space ||--o{ SpaceFacility : has

    Facility ||--o{ SpaceFacility : is_part_of
```