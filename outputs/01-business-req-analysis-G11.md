Unresolved Questions / Assumptions:

1.  **Facility Entity Granularity**: Assumed `FacilityType` as an entity to list types of facilities (e.g., 'Projector', 'Whiteboard') rather than tracking individual instances of equipment. If individual equipment tracking (e.g., 'Projector A', 'Projector B') were needed, a separate `Equipment` entity with serial numbers would be required.
2.  **Maintenance Record Start Time**: Interpreted "start time" in maintenance records as `MaintenanceStartTime` (when work begins) and added `ReportedDateTime` to capture when the issue was initially logged.
3.  **User Roles and Permissions**: Assumed that `User.Role` is sufficient to determine who can perform actions (e.g., approve bookings, check-in). Specific permission logic (e.g., "Facility Staff or Manager" for approval) will be handled at the application layer, but the database design supports identifying these roles.
4.  **Enumerated Types**: Assumed that `Space.SpaceType`, `Space.CurrentStatus`, `Booking.Purpose`, `Booking.BookingStatus`, `User.Role`, `User.AccountStatus`, and `MaintenanceRecord.MaintenanceStatus` will be constrained using `CHECK` constraints or lookup tables in the physical design. For the logical design, they are treated as attributes with defined value sets.
5.  **Condition Fields**: `InitialCondition` and `FinalCondition` for bookings are assumed to be free-text fields.
6.  **Nullable Fields**: Fields like `ApproverUserID`, `DecisionTime`, `RejectionReason`, `CheckInUserID`, `ActualStartTime`, `CompletionUserID`, `ActualEndTime`, `FinalCondition`, `UsageNotes`, `AssignedUserID`, `MaintenanceStartTime`, `CompletionTime`, `ResultNote` are explicitly marked as nullable as they are not present at the initial creation of a record or are conditional.

---

### 1. Actors

The system interacts with various types of users, all of whom are represented by a generic `User` entity with different roles.

*   **Requester**: Any user (Lecturer, TA, Student, Staff) who submits a booking request.
*   **Approver**: Facility Staff or Facility Manager who approves or rejects booking requests.
*   **Check-in/Completion Staff**: Facility Staff who check in and complete bookings.
*   **Reporter**: Any user who reports a maintenance issue.
*   **Assigned Staff**: Facility Staff or Facility Manager assigned to resolve a maintenance issue.
*   **System Administrator**: (Implicit) Manages user accounts and system configurations.

### 2. Entities and Attributes

1.  **User**
    *   **Attributes**:
        *   `UserID` (Primary Key, Unique Identifier)
        *   `FullName`
        *   `Email` (Unique)
        *   `PhoneNumber`
        *   `Role` (e.g., 'Student', 'Lecturer', 'Teaching Assistant', 'Facility Staff', 'Department Administrator', 'Facility Manager')
        *   `Department`
        *   `AccountStatus` (e.g., 'Active', 'Inactive', 'Suspended')

2.  **Space**
    *   **Attributes**:
        *   `SpaceCode` (Primary Key, Unique Identifier)
        *   `SpaceName`
        *   `SpaceType` (e.g., 'Auditorium', 'Classroom', 'Computer Laboratory', 'Meeting Room')
        *   `Building`
        *   `Floor`
        *   `RoomNumber`
        *   `Capacity`
        *   `CurrentStatus` (e.g., 'Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', 'Retired')
        *   `UsagePolicy` (Text description)

3.  **FacilityType**
    *   **Attributes**:
        *   `FacilityTypeID` (Primary Key, Unique Identifier)
        *   `FacilityTypeName` (e.g., 'Projector', 'Whiteboard', 'Microphone', 'Computer', 'Livestreaming Equipment', 'Air Conditioner')

4.  **Booking**
    *   **Attributes**:
        *   `BookingID` (Primary Key, Unique Identifier)
        *   `RequestedStartTime`
        *   `RequestedEndTime`
        *   `Purpose` (e.g., 'Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'Student Activity', 'Administrative Event')
        *   `ExpectedParticipants`
        *   `BookingStatus` (e.g., 'Pending', 'Approved', 'Rejected', 'Cancelled', 'Checked In', 'Completed', 'No-Show')
        *   `DecisionTime` (Nullable)
        *   `DecisionNote` (Nullable)
        *   `RejectionReason` (Nullable)
        *   `ActualStartTime` (Nullable)
        *   `InitialCondition` (Nullable, Text)
        *   `ActualEndTime` (Nullable)
        *   `FinalCondition` (Nullable, Text)
        *   `UsageNotes` (Nullable, Text)

5.  **MaintenanceRecord**
    *   **Attributes**:
        *   `MaintenanceID` (Primary Key, Unique Identifier)
        *   `ProblemDescription`
        *   `ReportedDateTime`
        *   `MaintenanceStartTime` (Nullable, when work began)
        *   `CompletionTime` (Nullable)
        *   `MaintenanceStatus` (e.g., 'Reported', 'In Progress', 'Completed', 'Cancelled')
        *   `ResultNote` (Nullable, Text)

### 3. Relationships and Cardinalities

1.  **User -- submits --> Booking**
    *   **Relationship**: A `User` submits `Booking` requests.
    *   **Cardinality**: One `User` can submit many `Booking`s (1:M). Each `Booking` is submitted by exactly one `User`.
    *   **Foreign Key**: `RequesterUserID` in `Booking` references `UserID` in `User`.

2.  **User -- approves/rejects --> Booking**
    *   **Relationship**: A `User` (Facility Staff/Manager) approves or rejects `Booking` requests.
    *   **Cardinality**: One `User` can approve/reject many `Booking`s (1:M). A `Booking` may be approved/rejected by one `User` or none (if pending/cancelled).
    *   **Foreign Key**: `ApproverUserID` in `Booking` references `UserID` in `User` (Nullable).

3.  **User -- checks in --> Booking**
    *   **Relationship**: A `User` (Facility Staff) checks in a `Booking`.
    *   **Cardinality**: One `User` can check in many `Booking`s (1:M). A `Booking` may be checked in by one `User` or none.
    *   **Foreign Key**: `CheckInUserID` in `Booking` references `UserID` in `User` (Nullable).

4.  **User -- completes --> Booking**
    *   **Relationship**: A `User` (Facility Staff) completes a `Booking`.
    *   **Cardinality**: One `User` can complete many `Booking`s (1:M). A `Booking` may be completed by one `User` or none.
    *   **Foreign Key**: `CompletionUserID` in `Booking` references `UserID` in `User` (Nullable).

5.  **Space -- has --> Booking**
    *   **Relationship**: A `Space` is booked for a `Booking`.
    *   **Cardinality**: One `Space` can have many `Booking`s (1:M). Each `Booking` is for exactly one `Space`.
    *   **Foreign Key**: `SpaceCode` in `Booking` references `SpaceCode` in `Space`.

6.  **Space -- has --> FacilityType (M:N via SpaceFacility)**
    *   **Relationship**: A `Space` can have multiple `FacilityType`s, and a `FacilityType` can be present in multiple `Space`s.
    *   **Associative Entity**: `SpaceFacility`
        *   **Attributes**:
            *   `SpaceCode` (Part of Composite PK, Foreign Key to `Space`)
            *   `FacilityTypeID` (Part of Composite PK, Foreign Key to `FacilityType`)
    *   **Cardinality**: Many `Space`s to Many `FacilityType`s.

7.  **Space -- has --> MaintenanceRecord**
    *   **Relationship**: A `Space` can have `MaintenanceRecord`s.
    *   **Cardinality**: One `Space` can have many `MaintenanceRecord`s (1:M). Each `MaintenanceRecord` is for exactly one `Space`.
    *   **Foreign Key**: `SpaceCode` in `MaintenanceRecord` references `SpaceCode` in `Space`.

8.  **User -- reports --> MaintenanceRecord**
    *   **Relationship**: A `User` reports a `MaintenanceRecord`.
    *   **Cardinality**: One `User` can report many `MaintenanceRecord`s (1:M). Each `MaintenanceRecord` is reported by exactly one `User`.
    *   **Foreign Key**: `ReporterUserID` in `MaintenanceRecord` references `UserID` in `User`.

9.  **User -- assigned to --> MaintenanceRecord**
    *   **Relationship**: A `User` (Facility Staff/Manager) is assigned to a `MaintenanceRecord`.
    *   **Cardinality**: One `User` can be assigned to many `MaintenanceRecord`s (1:M). A `MaintenanceRecord` may be assigned to one `User` or none.
    *   **Foreign Key**: `AssignedUserID` in `MaintenanceRecord` references `UserID` in `User` (Nullable).

### 4. Business Rules

1.  **User Account Uniqueness**: Each user must have a unique `UserID` and `Email`.
2.  **User Roles**: `User.Role` must be one of: 'Student', 'Lecturer', 'Teaching Assistant', 'Facility Staff', 'Department Administrator', 'Facility Manager'.
3.  **Space Uniqueness**: Each space must have a unique `SpaceCode`.
4.  **Space Status**: `Space.CurrentStatus` must be one of: 'Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', 'Retired'.
5.  **Booking Purpose**: `Booking.Purpose` must be one of: 'Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'Student Activity', 'Administrative Event'.
6.  **Booking Status Workflow**: `Booking.BookingStatus` must be one of: 'Pending', 'Approved', 'Rejected', 'Cancelled', 'Checked In', 'Completed', 'No-Show'. The status transitions should follow a logical flow (e.g., 'Pending' -> 'Approved'/'Rejected'/'Cancelled'; 'Approved' -> 'Checked In'/'No-Show'/'Cancelled'; 'Checked In' -> 'Completed').
7.  **Booking Conflict Prevention**: A `Space` cannot have two `Approved` `Booking`s with overlapping time periods (`RequestedStartTime`, `RequestedEndTime`).
8.  **Space Availability for Booking**: A `Space` with `CurrentStatus` of 'Under Maintenance', 'Temporarily Closed', or 'Retired' cannot be booked.
9.  **Approval Recording**: When a `Booking` is `Approved` or `Rejected`, `ApproverUserID`, `DecisionTime`, and `DecisionNote` must be recorded. If `Rejected`, `RejectionReason` must also be stored.
10. **Check-in Recording**: When a `Booking` is `Checked In`, `CheckInUserID`, `ActualStartTime`, and `InitialCondition` must be recorded.
11. **Completion Recording**: When a `Booking` is `Completed`, `CompletionUserID`, `ActualEndTime`, `FinalCondition`, and `UsageNotes` must be recorded.
12. **Maintenance Status**: `MaintenanceRecord.MaintenanceStatus` must be one of: 'Reported', 'In Progress', 'Completed', 'Cancelled'.
13. **Historical Records**: The system must retain all `Booking` and `MaintenanceRecord` history.
14. **Referential Integrity**: All foreign key relationships must be maintained.