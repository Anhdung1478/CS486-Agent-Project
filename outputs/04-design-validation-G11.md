```markdown
# 04-design-validation-GXX.md

## Database Design Validation Report

This report validates the proposed logical relational schema against the initial business requirements and conceptual ERD, ensuring correctness, adherence to business rules, and appropriate use of keys and constraints.

### 1. Overview of Logical Schema

The logical schema consists of the following relations:

*   **Users**: Manages all system users and their roles.
*   **Spaces**: Stores details about all bookable physical spaces.
*   **Facilities**: Lists available equipment/features.
*   **SpaceFacilities**: A junction table linking spaces to their facilities.
*   **Bookings**: Records all booking requests made by users.
*   **BookingApprovals**: Stores approval/rejection details for bookings.
*   **UsageSessions**: Captures check-in and completion details for approved bookings.
*   **MaintenanceRecords**: Manages maintenance activities for spaces.

### 2. Validation Against Business Requirements

#### 2.1. Entities and Attributes Coverage

All identified entities and their critical attributes from the business requirements are represented in the logical schema:

*   **Users**: `UserID`, `FullName`, `Email`, `PhoneNumber`, `Role`, `Department`, `AccountStatus`. (Matches requirement)
*   **Spaces**: `SpaceCode`, `SpaceName`, `SpaceType`, `Building`, `Floor`, `RoomNumber`, `Capacity`, `CurrentStatus`, `UsagePolicy`. (Matches requirement)
*   **Facilities**: `FacilityID`, `FacilityName`. (Matches requirement for "list of facilities")
*   **Bookings**: `BookingID`, `SpaceCode`, `RequesterID`, `RequestedStartTime`, `RequestedEndTime`, `Purpose`, `ExpectedParticipants`, `BookingStatus`, `SubmissionTime` (added for completeness and audit). (Matches requirement)
*   **BookingApprovals**: `BookingID`, `ApproverID`, `DecisionTime`, `DecisionNote`, `RejectionReason`. (Matches requirement)
*   **UsageSessions**: `BookingID`, `CheckInStaffID`, `ActualStartTime`, `InitialCondition`, `CompletionStaffID`, `ActualEndTime`, `FinalCondition`, `UsageNotes`. (Matches requirement for check-in/completion)
*   **MaintenanceRecords**: `MaintenanceID`, `SpaceCode`, `ReporterID`, `AssignedStaffID`, `ProblemDescription`, `StartTime`, `CompletionTime`, `Status`, `ResultNote`. (Matches requirement)

#### 2.2. Primary Keys (PKs) and Candidate Keys (CKs)

*   **Users**: `UserID` (PK). `Email` is a strong candidate key, assuming unique university emails.
*   **Spaces**: `SpaceCode` (PK). `(Building, RoomNumber)` is a candidate key, assuming room numbers are unique within a building.
*   **Facilities**: `FacilityID` (PK). `FacilityName` is a candidate key.
*   **SpaceFacilities**: `(SpaceCode, FacilityID)` (Composite PK).
*   **Bookings**: `BookingID` (PK).
*   **BookingApprovals**: `BookingID` (PK, also FK to Bookings). This ensures one approval record per booking.
*   **UsageSessions**: `BookingID` (PK, also FK to Bookings). This ensures one usage session record per booking.
*   **MaintenanceRecords**: `MaintenanceID` (PK).

All tables have appropriate primary keys, ensuring entity integrity.

#### 2.3. Foreign Keys (FKs) and Relationships

All relationships identified in the conceptual design are correctly translated into the logical schema using foreign keys:

*   **Users** (Requester, Approver, Check-in Staff, Completion Staff, Reporter, Assigned Staff)
    *   `Bookings.RequesterID` references `Users.UserID` (Many-to-One: Many bookings by one user).
    *   `BookingApprovals.ApproverID` references `Users.UserID` (Many-to-One: Many approvals by one staff/manager).
    *   `UsageSessions.CheckInStaffID` references `Users.UserID` (Many-to-One: Many check-ins by one staff).
    *   `UsageSessions.CompletionStaffID` references `Users.UserID` (Many-to-One: Many completions by one staff).
    *   `MaintenanceRecords.ReporterID` references `Users.UserID` (Many-to-One: Many reports by one user).
    *   `MaintenanceRecords.AssignedStaffID` references `Users.UserID` (Many-to-One: Many assignments to one staff).
*   **Spaces** (Booked, Has Facilities, Maintained)
    *   `Bookings.SpaceCode` references `Spaces.SpaceCode` (Many-to-One: Many bookings for one space).
    *   `SpaceFacilities.SpaceCode` references `Spaces.SpaceCode` (Many-to-Many via junction table).
    *   `MaintenanceRecords.SpaceCode` references `Spaces.SpaceCode` (Many-to-One: Many maintenance records for one space).
*   **Facilities** (Available in Spaces)
    *   `SpaceFacilities.FacilityID` references `Facilities.FacilityID` (Many-to-Many via junction table).
*   **Bookings** (Approved, Used)
    *   `BookingApprovals.BookingID` references `Bookings.BookingID` (One-to-One/Optional: A booking *may* have an approval).
    *   `UsageSessions.BookingID` references `Bookings.BookingID` (One-to-One/Optional: A booking *may* have a usage session).

All foreign keys are defined, ensuring referential integrity.

#### 2.4. Cardinalities and Participation Constraints

*   **Mandatory Participation:**
    *   A booking *must* have a requester (`Bookings.RequesterID` is `NOT NULL`).
    *   A booking *must* be for a space (`Bookings.SpaceCode` is `NOT NULL`).
    *   A space *must* have a space code (`Spaces.SpaceCode` is PK, `NOT NULL`).
    *   A maintenance record *must* be for a space (`MaintenanceRecords.SpaceCode` is `NOT NULL`).
*   **Optional Participation:**
    *   A booking *may* have an approval (`BookingApprovals.BookingID` is PK, but insertion into `BookingApprovals` is optional).
    *   A booking *may* have a usage session (`UsageSessions.BookingID` is PK, but insertion into `UsageSessions` is optional).
    *   A maintenance record's `CompletionTime` and `ResultNote` can be `NULL` if not yet completed.
    *   `BookingApprovals.RejectionReason` can be `NULL` if the booking is approved.

These are generally handled by `NOT NULL` constraints on FKs where participation is mandatory, and by allowing `NULL` where optional.

### 3. Validation Against Specific Business Rules

1.  **User Roles and Space Status/Types:**
    *   `Users.Role`, `Spaces.SpaceType`, `Spaces.CurrentStatus`, `Bookings.Purpose`, `Bookings.BookingStatus`, `MaintenanceRecords.Status` will be enforced using `CHECK` constraints or `ENUM` types in the DDL, ensuring data integrity for predefined values.
2.  **Space Capacity:**
    *   `Spaces.Capacity` will have a `CHECK` constraint (`Capacity > 0`).
    *   `Bookings.ExpectedParticipants` will have a `CHECK` constraint (`ExpectedParticipants > 0`).
    *   Application logic will be needed to ensure `ExpectedParticipants` does not exceed `Spaces.Capacity`.
3.  **Booking Conflict Prevention (Overlapping Times):**
    *   The schema provides `SpaceCode`, `RequestedStartTime`, `RequestedEndTime` in the `Bookings` table.
    *   **Direct DDL enforcement for overlapping times is complex (e.g., using exclusion constraints in PostgreSQL). For a standard relational schema, this rule will primarily be enforced by application logic at the time of booking submission and approval.** The database design *supports* the data needed for this check.
    *   A unique constraint on `(SpaceCode, RequestedStartTime, RequestedEndTime)` is not sufficient as it only prevents exact duplicates, not overlaps.
4.  **Booking Prevention for Unavailable Spaces:**
    *   "A space that is under maintenance, closed, or retired cannot be booked."
    *   This rule requires a dynamic check against `Spaces.CurrentStatus` when a booking is attempted.
    *   **This is best enforced by application logic or potentially a database trigger (more advanced DDL).** The schema provides the necessary `Spaces.CurrentStatus` attribute.
5.  **Booking Approval Details:**
    *   `BookingApprovals` table correctly stores `ApproverID`, `DecisionTime`, `DecisionNote`, and `RejectionReason` (nullable).
    *   `DecisionTime` should be `CHECK`ed to be after `Bookings.SubmissionTime`.
6.  **Booking Check-in/Completion Details:**
    *   `UsageSessions` table correctly stores `CheckInStaffID`, `ActualStartTime`, `InitialCondition`, `CompletionStaffID`, `ActualEndTime`, `FinalCondition`, `UsageNotes`.
    *   `ActualStartTime` should be `CHECK`ed to be before `ActualEndTime`.
    *   `ActualStartTime` should ideally be close to `RequestedStartTime`, and `ActualEndTime` close to `RequestedEndTime`, which is an application-level validation.
7.  **Maintenance Records:**
    *   `MaintenanceRecords` table captures all required attributes.
    *   `StartTime` should be `CHECK`ed to be before `CompletionTime` (if `CompletionTime` is not `NULL`).
8.  **Historical Records:**
    *   The design inherently supports historical records for bookings, approvals, usage sessions, and maintenance activities as all past records are retained in their respective tables.

### 4. Normalization Review

The schema appears to be in at least 3rd Normal Form (3NF):

*   **1NF (First Normal Form):** All attributes are atomic, and there are no repeating groups.
*   **2NF (Second Normal Form):** All non-key attributes are fully dependent on the primary key. For composite keys (e.g., `SpaceFacilities`), non-key attributes (none in this case) would depend on the *entire* key.
*   **3NF (Third Normal Form):** There are no transitive dependencies. Non-key attributes do not depend on other non-key attributes. For example, `Department` in `Users` depends on `UserID`, not `Role`.

### 5. Conclusion

The logical relational schema is conceptually sound and accurately represents the entities, attributes, and relationships derived from the business requirements. It adheres to normalization principles and provides the necessary structure to store all required information.

While most business rules can be enforced through DDL (PKs, FKs, `NOT NULL`, `CHECK` constraints), complex rules like preventing overlapping bookings or booking unavailable spaces will require additional enforcement mechanisms, such as:
*   **Application-level logic:** For real-time checks during booking submission.
*   **Database triggers:** For more robust, server-side enforcement of complex inter-table rules.
*   **Exclusion constraints (if supported by the RDBMS):** For direct database enforcement of non-overlapping time periods.

The current design provides a solid foundation for implementing the Campus Space Management System.
```