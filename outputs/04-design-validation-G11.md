**Unresolved Questions / Assumptions:**
*   The business requirement mentions "start time" and "completion time" for maintenance records. In the logical design, these were interpreted as `ScheduledStartTime` and `CompletionTime`, with an added `ReportedTime` for when the issue was first logged. This interpretation is validated below.
*   Specific values for `MaintenanceStatus` (e.g., 'Pending', 'In Progress', 'Completed', 'Cancelled') were assumed for the logical design and will be enforced via `CHECK` constraints.
*   The `Description` attribute for `Facilities` was added to provide more detail about a facility type.
*   The `Quantity` attribute in `SpaceFacilities` was added to allow a space to have multiple instances of the same facility (e.g., two projectors).

---

### Database Design Validation Report

This report validates the logical database design (`03-logical-design-G11.md`) against the business requirements and rules identified in the analysis phase (`01-business-req-analysis-G11.md`).

#### 1. Overall Design Principles

*   **Normalization:** The design appears to be in at least 3NF.
    *   Entities are well-defined with clear primary keys.
    *   Attributes are atomic and directly dependent on their respective primary keys.
    *   Transitive dependencies have been minimized (e.g., `Facilities` is a separate entity, not just a list within `Spaces`).
*   **Referential Integrity:** Foreign keys are used consistently to link related tables, ensuring data consistency and preventing orphaned records.
*   **Traceability:** All entities and attributes identified in the business requirement analysis are represented in the logical schema.

#### 2. Entity and Attribute Coverage

All required entities and their attributes from the business requirements are covered:

*   **`Users` Table:**
    *   `UserID` (PK): Unique identifier for each user.
    *   `FullName`, `Email`, `Phone`, `Department`: Basic user information.
    *   `Role`: Stores user roles (student, lecturer, TA, facility staff, dept admin, facility manager).
    *   `AccountStatus`: Stores account status (active, inactive, suspended).
    *   **Validation:** All user-related attributes are present.
*   **`Spaces` Table:**
    *   `SpaceCode` (PK): Unique identifier for each space.
    *   `SpaceName`, `SpaceType`, `Building`, `Floor`, `RoomNumber`, `Capacity`, `UsagePolicy`: Basic space information.
    *   `CurrentStatus`: Stores space status (available, in use, under maintenance, temporarily closed, retired).
    *   **Validation:** All space-related attributes are present.
*   **`Facilities` Table:**
    *   `FacilityID` (PK): Unique identifier for each facility type.
    *   `FacilityName`, `Description`: Details about the facility.
    *   **Validation:** Represents the "several facilities" requirement as a distinct entity, allowing for standardized facility definitions.
*   **`SpaceFacilities` Table:**
    *   `SpaceCode` (FK), `FacilityID` (FK): Composite PK, linking spaces to facilities.
    *   `Quantity`: Allows tracking multiple instances of the same facility in a space.
    *   **Validation:** Correctly implements the many-to-many relationship between `Spaces` and `Facilities`.
*   **`Bookings` Table:**
    *   `BookingID` (PK): Unique identifier for each booking.
    *   `SpaceCode` (FK), `RequesterID` (FK): Links to the booked space and the user who made the request.
    *   `RequestedStartTime`, `RequestedEndTime`, `Purpose`, `ExpectedParticipants`: Core booking details.
    *   `BookingStatus`: Stores status (pending, approved, rejected, cancelled, checked in, completed, no-show).
    *   `ApprovalStaffID` (FK), `ApprovalTime`, `ApprovalNote`, `RejectionReason`: Captures approval details.
    *   `ActualStartTime`, `CheckInStaffID` (FK), `InitialCondition`, `ActualEndTime`, `FinalCondition`, `UsageNotes`: Captures usage session details.
    *   **Validation:** Consolidates booking, approval, and usage session details as required, with appropriate FKs to `Users` and `Spaces`. All specified attributes are present.
*   **`MaintenanceRecords` Table:**
    *   `MaintenanceID` (PK): Unique identifier for each record.
    *   `SpaceCode` (FK), `ReporterID` (FK), `AssignedStaffID` (FK): Links to the affected space, the reporter, and the assigned staff.
    *   `ProblemDescription`, `ReportedTime`, `ScheduledStartTime`, `ScheduledEndTime`, `CompletionTime`, `MaintenanceStatus`, `ResultNote`: Details about the maintenance.
    *   **Validation:** All maintenance-related attributes are present, including the assumed `ReportedTime`, `ScheduledStartTime`, `ScheduledEndTime`, and `MaintenanceStatus`.

#### 3. Relationship Implementation

*   **User-Booking (1:N):** `RequesterID` in `Bookings` correctly links to `UserID` in `Users`.
*   **Space-Booking (1:N):** `SpaceCode` in `Bookings` correctly links to `SpaceCode` in `Spaces`.
*   **Space-Facility (M:N):** Implemented via the `SpaceFacilities` junction table, with `SpaceCode` and `FacilityID` as foreign keys forming a composite primary key. This correctly handles that a space can have many facilities, and a facility can be in many spaces.
*   **Booking-Approval (1:1, integrated):** Approval details (`ApprovalStaffID`, `ApprovalTime`, `ApprovalNote`, `RejectionReason`) are integrated directly into the `Bookings` table, with `ApprovalStaffID` referencing `Users`. This is appropriate as approval is directly tied to a specific booking.
*   **Booking-UsageSession (1:1, integrated):** Usage session details (`ActualStartTime`, `CheckInStaffID`, `InitialCondition`, `ActualEndTime`, `FinalCondition`, `UsageNotes`) are integrated directly into the `Bookings` table, with `CheckInStaffID` referencing `Users`. This is appropriate as usage is directly tied to a specific booking.
*   **Space-MaintenanceRecord (1:N):** `SpaceCode` in `MaintenanceRecords` correctly links to `SpaceCode` in `Spaces`.
*   **User-MaintenanceRecord (1:N for Reporter, 1:N for Assigned Staff):** `ReporterID` and `AssignedStaffID` in `MaintenanceRecords` correctly link to `UserID` in `Users`.

#### 4. Business Rule Enforcement

1.  **Unique User ID & Space Code:** Enforced by `UserID` as PK in `Users` and `SpaceCode` as PK in `Spaces`.
2.  **User Roles & Account Status:** `Role` and `AccountStatus` attributes in `Users` table. Will be enforced by `CHECK` constraints in DDL.
3.  **Space Types & Status:** `SpaceType` and `CurrentStatus` attributes in `Spaces` table. Will be enforced by `CHECK` constraints in DDL.
4.  **Booking Purpose & Status:** `Purpose` and `BookingStatus` attributes in `Bookings` table. Will be enforced by `CHECK` constraints in DDL.
5.  **Conflict Prevention 1 (Overlapping Approved Bookings):** This is a complex temporal constraint that cannot be fully enforced by standard DDL `CHECK` constraints alone. It will require:
    *   A unique index on `(SpaceCode, RequestedStartTime, RequestedEndTime)` for *approved* bookings, if the DBMS supports conditional indexing.
    *   More likely, an application-level check or a database trigger to ensure that for a given `SpaceCode`, no two `Bookings` with `BookingStatus = 'Approved'` have `RequestedStartTime` and `RequestedEndTime` ranges that overlap.
    *   **Validation:** The schema provides the necessary attributes (`SpaceCode`, `RequestedStartTime`, `RequestedEndTime`, `BookingStatus`) to implement this rule, but the enforcement mechanism will primarily be at the application layer or via advanced DB features (triggers/stored procedures).
6.  **Conflict Prevention 2 (Booking Unavailable Spaces):** A space that is `under maintenance`, `temporarily closed`, or `retired` cannot be booked.
    *   **Validation:** The `Spaces.CurrentStatus` attribute allows tracking the status. This rule will primarily be enforced at the application layer during booking submission, checking `Spaces.CurrentStatus` before allowing a booking to proceed. A `CHECK` constraint on `Bookings` could potentially reference `Spaces.CurrentStatus` if the DBMS supports such complex cross-table constraints, but it's typically handled by application logic.
7.  **Booking Approval Details:** `ApprovalStaffID`, `ApprovalTime`, `ApprovalNote`, `RejectionReason` in `Bookings` table. `ApprovalStaffID` is an FK to `Users`.
    *   **Validation:** Correctly captured.
8.  **Booking Check-in/Completion Details:** `ActualStartTime`, `CheckInStaffID`, `InitialCondition`, `ActualEndTime`, `FinalCondition`, `UsageNotes` in `Bookings` table. `CheckInStaffID` is an FK to `Users`.
    *   **Validation:** Correctly captured.
9.  **Maintenance Record Attributes:** `SpaceCode`, `ReporterID`, `AssignedStaffID`, `ProblemDescription`, `ReportedTime`, `ScheduledStartTime`, `ScheduledEndTime`, `CompletionTime`, `MaintenanceStatus`, `ResultNote` in `MaintenanceRecords` table. All FKs are correctly established.
    *   **Validation:** Correctly captured.
10. **Historical Records:** The design retains all `Bookings` and `MaintenanceRecords` indefinitely, fulfilling the requirement to keep historical data.
    *   **Validation:** Achieved by the persistence of records in `Bookings` and `MaintenanceRecords` tables.

#### 5. Potential Data Anomalies and Mitigation

*   **Redundancy:** Minimal redundancy due to normalization. `SpaceFacilities` correctly handles the M:N relationship without repeating facility data in `Spaces` or space data in `Facilities`.
*   **Update Anomalies:** Not expected, as attributes are dependent on their respective primary keys. For example, updating a user's email only affects the `Users` table.
*   **Deletion Anomalies:** Handled by `ON DELETE` referential actions (e.g., `SET NULL` for optional FKs, `CASCADE` for strong dependencies like `SpaceFacilities` if a space or facility is deleted, though `RESTRICT` is generally safer for core entities like `Users` and `Spaces`). These will be specified in DDL.
*   **Insertion Anomalies:** Not expected, as entities can be created independently before being referenced (e.g., a `User` must exist before making a `Booking`).

#### Conclusion

The logical database design is robust, well-normalized, and effectively translates the conceptual ERD. It covers all specified entities, attributes, and relationships from the business requirements. While some complex business rules (like preventing overlapping bookings or booking unavailable spaces) require application-level logic or advanced database features (triggers), the schema provides all necessary data points for their enforcement. The design is ready for physical implementation.