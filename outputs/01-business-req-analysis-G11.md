```markdown
# 01-business-req-analysis-G11.md

## Unresolved Questions / Assumptions

1.  **User Roles and Permissions:** The system stores user roles, but the specific permissions associated with each role (e.g., who can approve, who can check-in) are assumed to be handled by the application layer, not strictly enforced by database constraints beyond foreign key relationships to specific user roles where applicable (e.g., `ApproverUserID` would typically be a Facility Staff or Manager).
2.  **Facility Granularity:** "Facilities" are interpreted as types of equipment (e.g., "projector", "whiteboard"), not individual, trackable assets with unique IDs. A many-to-many relationship between `Space` and `FacilityType` is assumed.
3.  **Department and Account Status:** `Department` and `AccountStatus` for users are treated as simple text attributes, not separate entities.
4.  **Space Attributes:** `SpaceType`, `Building`, `Floor`, `RoomNumber` are treated as simple text/numeric attributes of the `Space` entity, not separate entities.
5.  **Booking and Maintenance Statuses:** The various statuses (e.g., `Booking.Status`, `Space.CurrentStatus`, `MaintenanceRecord.Status`) are assumed to be string enumerations, managed by the application, with `CHECK` constraints in the database for validity.
6.  **Derived Space Status:** The `Space.CurrentStatus` (e.g., 'in use', 'under maintenance') is assumed to be primarily derived from active bookings or maintenance records, but also allows for manual setting (e.g., 'temporarily closed', 'retired'). The database will store the explicit status, and application logic will manage its updates based on events.
7.  **Time Zones:** All timestamps are assumed to be stored in a consistent time zone (e.g., UTC) and converted for display by the application.

---

## Business Requirement Analysis

### 1. Actors

The individuals or groups interacting with the system.

*   **Requester:** Lecturers, Teaching Assistants, Students, Staff (general) - submit booking requests.
*   **Approver:** Facility Staff, Facility Manager - approve or reject booking requests.
*   **Check-in/Completion Staff:** Facility Staff - check in and complete bookings.
*   **Reporter:** Any User - reports maintenance issues.
*   **Assigned Staff:** Facility Staff - assigned to resolve maintenance issues.
*   **System Administrator:** (Implied) Manages user accounts and space definitions.

### 2. Entities and Attributes

Core objects in the system and their characteristics.

*   **User**
    *   `UserID` (Primary Key, unique identifier for a user)
    *   `FullName`
    *   `Email`
    *   `PhoneNumber`
    *   `Role` (e.g., Student, Lecturer, TA, Facility Staff, Dept Admin, Facility Manager)
    *   `Department`
    *   `AccountStatus` (e.g., Active, Inactive, Suspended)
*   **Space**
    *   `SpaceCode` (Primary Key, unique identifier for a space)
    *   `SpaceName`
    *   `SpaceType` (e.g., Auditorium, Classroom, Computer Lab, Project Lab, Meeting Room, Student Workspace)
    *   `Building`
    *   `Floor`
    *   `RoomNumber`
    *   `Capacity` (maximum number of participants)
    *   `CurrentStatus` (e.g., Available, In Use, Under Maintenance, Temporarily Closed, Retired)
    *   `UsagePolicy` (text description)
*   **FacilityType**
    *   `FacilityTypeID` (Primary Key, unique identifier for a type of facility)
    *   `FacilityName` (e.g., Projector, Whiteboard, Microphone, Computer, Livestreaming Equipment, Air Conditioner)
*   **Booking**
    *   `BookingID` (Primary Key, unique identifier for a booking request)
    *   `RequestedStartTime`
    *   `RequestedEndTime`
    *   `Purpose` (e.g., Lecture, Examination, Seminar, Workshop, Meeting, Student Activity, Administrative Event)
    *   `ExpectedParticipants`
    *   `Status` (e.g., Pending, Approved, Rejected, Cancelled, Checked In, Completed, No-Show)
    *   `DecisionTime` (nullable)
    *   `DecisionNote` (nullable)
    *   `RejectionReason` (nullable, if status is Rejected)
    *   `ActualStartTime` (nullable, if checked in)
    *   `ActualEndTime` (nullable, if completed)
    *   `InitialCondition` (nullable, recorded at check-in)
    *   `FinalCondition` (nullable, recorded at completion)
    *   `UsageNotes` (nullable, recorded at completion)
*   **MaintenanceRecord**
    *   `MaintenanceID` (Primary Key, unique identifier for a maintenance record)
    *   `ProblemDescription`
    *   `StartTime` (when maintenance started or was reported)
    *   `CompletionTime` (nullable, when maintenance was completed)
    *   `Status` (e.g., Reported, In Progress, Completed, Cancelled)
    *   `ResultNote` (nullable, outcome of maintenance)

### 3. Relationships and Cardinalities

How entities relate to each other.

*   **User --1:M-- Booking (Requester)**
    *   A `User` submits many `Booking` requests.
    *   A `Booking` is submitted by one `User`.
*   **User --1:M-- Booking (Approver)** (Optional)
    *   A `User` (Facility Staff/Manager) can approve/reject many `Booking` requests.
    *   A `Booking` is approved/rejected by one `User` (or none if pending/cancelled by requester).
*   **User --1:M-- Booking (Check-in Staff)** (Optional)
    *   A `User` (Facility Staff) can check in many `Booking` sessions.
    *   A `Booking` session is checked in by one `User` (or none if not checked in).
*   **User --1:M-- Booking (Completion Staff)** (Optional)
    *   A `User` (Facility Staff) can complete many `Booking` sessions.
    *   A `Booking` session is completed by one `User` (or none if not completed).
*   **Space --1:M-- Booking**
    *   A `Space` can be requested for many `Booking` requests.
    *   A `Booking` request is for one `Space`.
*   **Space --M:M-- FacilityType (via SpaceFacility junction table)**
    *   A `Space` can have many `FacilityType`s.
    *   A `FacilityType` can be present in many `Space`s.
    *   **SpaceFacility** (Junction Table)
        *   `SpaceCode` (Composite PK, Foreign Key to Space)
        *   `FacilityTypeID` (Composite PK, Foreign Key to FacilityType)
        *   `Quantity` (Optional, number of this facility type in the space)
*   **Space --1:M-- MaintenanceRecord**
    *   A `Space` can have many `MaintenanceRecord`s.
    *   A `MaintenanceRecord` is for one `Space`.
*   **User --1:M-- MaintenanceRecord (Reporter)**
    *   A `User` can report many `MaintenanceRecord`s.
    *   A `MaintenanceRecord` is reported by one `User`.
*   **User --1:M-- MaintenanceRecord (Assigned Staff)** (Optional)
    *   A `User` (Facility Staff) can be assigned to many `MaintenanceRecord`s.
    *   A `MaintenanceRecord` is assigned to one `User` (or none if not assigned).

### 4. Business Rules

Constraints and policies governing the system's behavior.

1.  **User Account Requirement:** Each user must have a university account.
2.  **Unique Space Identification:** Each space must have a unique `SpaceCode`.
3.  **Space Statuses:** A space's `CurrentStatus` can be 'Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', or 'Retired'.
4.  **Booking Conflict Prevention:** The system must prevent conflicting bookings. The same `Space` cannot have two `Approved` bookings with overlapping time periods.
5.  **Unavailable Space Booking Restriction:** A `Space` that is 'Under Maintenance', 'Temporarily Closed', or 'Retired' cannot be booked.
6.  **Booking Approval/Rejection Details:** When a booking is approved or rejected, the system must record the `ApproverUserID`, `DecisionTime`, and `DecisionNote`.
7.  **Rejection Reason:** If a booking is rejected, the `RejectionReason` must be stored.
8.  **Booking Check-in Details:** When a booking is checked in, the system must record the `ActualStartTime`, `CheckInStaffUserID`, and `InitialCondition` of the space.
9.  **Booking Completion Details:** When a booking session ends, the system must record the `ActualEndTime`, `CompleteStaffUserID`, `FinalCondition` of the space, and any `UsageNotes`.
10. **Maintenance Impact on Booking:** A space 'Under Maintenance' cannot be booked. (Reinforces rule 5).
11. **Historical Records:** The system must keep historical records of bookings and maintenance activities.
12. **Reporting Capabilities:** Staff should be able to view booking history, upcoming bookings, spaces under maintenance, and no-show bookings.
13. **Core System Goals:** Manage shared campus spaces fairly, avoid overlapping bookings, prevent the use of unavailable spaces, and preserve usage history.
```