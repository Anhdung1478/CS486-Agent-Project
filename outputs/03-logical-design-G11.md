```markdown
## Unresolved Questions / Assumptions

*   **User ID Generation:** Assumed `UserID` is an auto-incrementing integer.
*   **Space Code Format:** Assumed `SpaceCode` is a unique string identifier (e.g., "CSB-101").
*   **ID Generation:** Assumed `BookingID`, `MaintenanceID`, and `FacilityTypeID` are auto-incrementing integers.
*   **Maintenance Start Time:** Interpreted "start time" for maintenance records as `ReportTime`.
*   **Conditional Constraints:** Constraints like "RejectionReason must be stored if rejected" or "cannot book a space under maintenance" are noted as business rules to be enforced by the application layer or through more complex database triggers/procedures, as standard DDL `CHECK` constraints might not fully cover them.
*   **Time Overlap Constraint:** The business rule "The same space cannot have two approved bookings with overlapping time periods" is a complex temporal constraint. While the schema supports the necessary attributes, enforcing this strictly with standard DDL `UNIQUE` or `CHECK` constraints is challenging and typically handled at the application level or with advanced database features (e.g., exclusion constraints in PostgreSQL, which are not standard SQL). For this logical design, it's noted as a critical business rule.

## Logical Relational Schema

### 1. Relation: `Users`

*   **Purpose:** Stores information about all university account holders who interact with the system.
*   **Attributes:**
    *   `UserID` (PK, INT)
    *   `FullName` (VARCHAR(255), NOT NULL)
    *   `Email` (VARCHAR(255), NOT NULL, UNIQUE)
    *   `PhoneNumber` (VARCHAR(20), NULLABLE)
    *   `Role` (VARCHAR(50), NOT NULL) - Candidate Key: (Email)
    *   `Department` (VARCHAR(100), NULLABLE)
    *   `AccountStatus` (VARCHAR(20), NOT NULL)
*   **Constraints:**
    *   `PK_Users`: Primary Key on `UserID`.
    *   `UQ_Users_Email`: Unique constraint on `Email`.
    *   `CK_Users_Role`: `Role` IN ('student', 'lecturer', 'teaching assistant', 'facility staff', 'department administrator', 'facility manager').
    *   `CK_Users_AccountStatus`: `AccountStatus` IN ('active', 'inactive', 'suspended').

### 2. Relation: `Spaces`

*   **Purpose:** Manages details of all bookable physical spaces on campus.
*   **Attributes:**
    *   `SpaceCode` (PK, VARCHAR(50))
    *   `SpaceName` (VARCHAR(255), NOT NULL)
    *   `SpaceType` (VARCHAR(50), NOT NULL)
    *   `Building` (VARCHAR(100), NOT NULL)
    *   `Floor` (INT, NOT NULL)
    *   `RoomNumber` (VARCHAR(50), NOT NULL)
    *   `Capacity` (INT, NOT NULL)
    *   `CurrentStatus` (VARCHAR(50), NOT NULL)
    *   `UsagePolicy` (TEXT, NULLABLE)
*   **Constraints:**
    *   `PK_Spaces`: Primary Key on `SpaceCode`.
    *   `CK_Spaces_Capacity`: `Capacity` > 0.
    *   `CK_Spaces_SpaceType`: `SpaceType` IN ('auditorium', 'classroom', 'computer laboratory', 'project laboratory', 'meeting room', 'student workspace').
    *   `CK_Spaces_CurrentStatus`: `CurrentStatus` IN ('available', 'in use', 'under maintenance', 'temporarily closed', 'retired').

### 3. Relation: `FacilityTypes`

*   **Purpose:** Defines different types of facilities that can be present in a space.
*   **Attributes:**
    *   `FacilityTypeID` (PK, INT)
    *   `TypeName` (VARCHAR(100), NOT NULL, UNIQUE)
*   **Constraints:**
    *   `PK_FacilityTypes`: Primary Key on `FacilityTypeID`.
    *   `UQ_FacilityTypes_TypeName`: Unique constraint on `TypeName`.

### 4. Relation: `SpaceFacilities`

*   **Purpose:** Links spaces to the facilities they contain (Many-to-Many relationship).
*   **Attributes:**
    *   `SpaceCode` (PK, FK to `Spaces.SpaceCode`)
    *   `FacilityTypeID` (PK, FK to `FacilityTypes.FacilityTypeID`)
*   **Constraints:**
    *   `PK_SpaceFacilities`: Composite Primary Key on (`SpaceCode`, `FacilityTypeID`).
    *   `FK_SpaceFacilities_SpaceCode`: Foreign Key referencing `Spaces(SpaceCode)`.
    *   `FK_SpaceFacilities_FacilityTypeID`: Foreign Key referencing `FacilityTypes(FacilityTypeID)`.

### 5. Relation: `Bookings`

*   **Purpose:** Stores all booking requests, their status, and usage details.
*   **Attributes:**
    *   `BookingID` (PK, INT)
    *   `RequesterUserID` (FK to `Users.UserID`, NOT NULL)
    *   `SpaceCode` (FK to `Spaces.SpaceCode`, NOT NULL)
    *   `RequestedStartTime` (DATETIME, NOT NULL)
    *   `RequestedEndTime` (DATETIME, NOT NULL)
    *   `Purpose` (VARCHAR(100), NOT NULL)
    *   `ExpectedParticipants` (INT, NOT NULL)
    *   `BookingStatus` (VARCHAR(50), NOT NULL)
    *   `ApproverUserID` (FK to `Users.UserID`, NULLABLE)
    *   `DecisionTime` (DATETIME, NULLABLE)
    *   `DecisionNote` (TEXT, NULLABLE)
    *   `RejectionReason` (TEXT, NULLABLE)
    *   `CheckInUserID` (FK to `Users.UserID`, NULLABLE)
    *   `ActualStartTime` (DATETIME, NULLABLE)
    *   `InitialCondition` (TEXT, NULLABLE)
    *   `ActualEndTime` (DATETIME, NULLABLE)
    *   `FinalCondition` (TEXT, NULLABLE)
    *   `UsageNotes` (TEXT, NULLABLE)
*   **Constraints:**
    *   `PK_Bookings`: Primary Key on `BookingID`.
    *   `FK_Bookings_RequesterUserID`: Foreign Key referencing `Users(UserID)`.
    *   `FK_Bookings_SpaceCode`: Foreign Key referencing `Spaces(SpaceCode)`.
    *   `FK_Bookings_ApproverUserID`: Foreign Key referencing `Users(UserID)` (for staff/manager who approved/rejected).
    *   `FK_Bookings_CheckInUserID`: Foreign Key referencing `Users(UserID)` (for facility staff who checked in).
    *   `CK_Bookings_TimeOrderRequested`: `RequestedEndTime` > `RequestedStartTime`.
    *   `CK_Bookings_TimeOrderActual`: `ActualEndTime` > `ActualStartTime` (if both are not NULL).
    *   `CK_Bookings_Purpose`: `Purpose` IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student activity', 'administrative event').
    *   `CK_Bookings_ExpectedParticipants`: `ExpectedParticipants` >= 0.
    *   `CK_Bookings_BookingStatus`: `BookingStatus` IN ('pending', 'approved', 'rejected', 'cancelled', 'checked in', 'completed', 'no-show').

### 6. Relation: `MaintenanceRecords`

*   **Purpose:** Tracks maintenance activities for spaces.
*   **Attributes:**
    *   `MaintenanceID` (PK, INT)
    *   `SpaceCode` (FK to `Spaces.SpaceCode`, NOT NULL)
    *   `ReporterUserID` (FK to `Users.UserID`, NOT NULL)
    *   `AssignedStaffUserID` (FK to `Users.UserID`, NULLABLE)
    *   `ProblemDescription` (TEXT, NOT NULL)
    *   `ReportTime` (DATETIME, NOT NULL)
    *   `CompletionTime` (DATETIME, NULLABLE)
    *   `MaintenanceStatus` (VARCHAR(50), NOT NULL)
    *   `ResultNote` (TEXT, NULLABLE)
*   **Constraints:**
    *   `PK_MaintenanceRecords`: Primary Key on `MaintenanceID`.
    *   `FK_MaintenanceRecords_SpaceCode`: Foreign Key referencing `Spaces(SpaceCode)`.
    *   `FK_MaintenanceRecords_ReporterUserID`: Foreign Key referencing `Users(UserID)`.
    *   `FK_MaintenanceRecords_AssignedStaffUserID`: Foreign Key referencing `Users(UserID)` (for staff assigned to maintenance).
    *   `CK_MaintenanceRecords_TimeOrder`: `CompletionTime` > `ReportTime` (if `CompletionTime` is not NULL).
    *   `CK_MaintenanceRecords_Status`: `MaintenanceStatus` IN ('reported', 'in progress', 'completed', 'cancelled').
```