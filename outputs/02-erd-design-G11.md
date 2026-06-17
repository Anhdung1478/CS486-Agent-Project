erDiagram
    User {
        VARCHAR UserID PK
        VARCHAR FullName
        VARCHAR Email
        VARCHAR PhoneNumber
        VARCHAR Role
        VARCHAR Department
        VARCHAR AccountStatus
    }

    Space {
        VARCHAR SpaceCode PK
        VARCHAR SpaceName
        VARCHAR SpaceType
        VARCHAR Building
        VARCHAR Floor
        VARCHAR RoomNumber
        INT Capacity
        VARCHAR CurrentStatus
        TEXT UsagePolicy
    }

    FacilityType {
        INT FacilityTypeID PK
        VARCHAR FacilityTypeName
    }

    SpaceFacility {
        VARCHAR SpaceCode PK,FK
        INT FacilityTypeID PK,FK
    }

    BookingRequest {
        INT BookingID PK
        VARCHAR RequesterUserID FK "User"
        VARCHAR SpaceCode FK "Space"
        DATETIME RequestedStartTime
        DATETIME RequestedEndTime
        VARCHAR PurposeOfUse
        INT ExpectedParticipants
        VARCHAR BookingStatus
        VARCHAR ApproverUserID FK "User"
        DATETIME DecisionTime
        TEXT DecisionNote
        TEXT RejectionReason
    }

    BookingSession {
        INT SessionID PK
        INT BookingID FK "BookingRequest"
        DATETIME ActualStartTime
        VARCHAR CheckedInByUserID FK "User"
        TEXT InitialCondition
        DATETIME ActualEndTime
        VARCHAR CompletedByUserID FK "User"
        TEXT FinalCondition
        TEXT UsageNotes
    }

    MaintenanceRecord {
        INT MaintenanceID PK
        VARCHAR SpaceCode FK "Space"
        VARCHAR ReporterUserID FK "User"
        VARCHAR AssignedStaffUserID FK "User"
        TEXT ProblemDescription
        DATETIME ReportTime
        DATETIME CompletionTime
        VARCHAR MaintenanceStatus
        TEXT ResultNote
    }

    User ||--o{ BookingRequest : "submits"
    User ||--o{ BookingRequest : "approves/rejects"
    User ||--o{ BookingSession : "checks in"
    User ||--o{ BookingSession : "completes"
    User ||--o{ MaintenanceRecord : "reports"
    User ||--o{ MaintenanceRecord : "is assigned to"

    Space ||--o{ BookingRequest : "is booked for"
    Space ||--o{ MaintenanceRecord : "has"
    Space }|--|{ SpaceFacility : "has"

    FacilityType }|--|{ SpaceFacility : "is part of"

    BookingRequest ||--o| BookingSession : "has"