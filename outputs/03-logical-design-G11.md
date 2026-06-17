## Logical Database Design

This logical relational schema is derived directly from the conceptual ERD, ensuring all entities, attributes, and relationships are translated into tables, columns, and constraints.

### Relations (Tables)

#### 1. Users
*   **Description:** Stores information about all university account holders who interact with the system.
*   **Attributes:**
    *   `UserID` (Primary Key)
    *   `FullName`
    *   `Email` (Candidate Key, Unique)
    *   `PhoneNumber`
    *   `Role` (e.g., Student, Lecturer, TA, Facility Staff, Dept Admin, Facility Manager)
    *   `Department`
    *   `AccountStatus` (e.g., Active, Inactive, Suspended)
*   **Key Constraints:**
    *   `PK_Users`: `UserID`
    *   `UK_Users_Email`: `Email`

#### 2. Spaces
*   **Description:** Manages details of all bookable physical spaces on campus.
*   **Attributes:**
    *   `SpaceCode` (Primary Key)
    *   `SpaceName`
    *   `SpaceType` (e.g., Auditorium, Classroom, Computer Lab, Project Lab, Meeting Room, Student Workspace)
    *   `Building`
    *   `Floor`
    *   `RoomNumber`
    *   `Capacity`
    *   `CurrentStatus` (e.g., Available, In Use, Under Maintenance, Temporarily Closed, Retired)
    *   `UsagePolicy`
*   **Key Constraints:**
    *   `PK_Spaces`: `SpaceCode`
    *   `UK_Spaces_Location`: (`Building`, `Floor`, `RoomNumber`)

#### 3. Facilities
*   **Description:** Lists all types of equipment or features that can be present in a space.
*   **Attributes:**
    *   `FacilityID` (Primary Key)
    *   `FacilityName` (Candidate Key, Unique)
*   **Key Constraints:**
    *   `PK_Facilities`: `FacilityID`
    *   `UK_Facilities_Name`: `FacilityName`

#### 4. SpaceFacilities (Associative Entity for M:N relationship between Spaces and Facilities)
*   **Description:** Records which facilities are available in which spaces.
*   **Attributes:**
    *   `SpaceCode` (Foreign Key, part of Composite Primary Key)
    *   `FacilityID` (Foreign Key, part of Composite Primary Key)
*   **Key Constraints:**
    *   `PK_SpaceFacilities`: (`SpaceCode`, `FacilityID`)
    *   `FK_SpaceFacilities_SpaceCode`: `SpaceCode` references `Spaces(SpaceCode)`
    *   `FK_SpaceFacilities_FacilityID`: `FacilityID` references `Facilities(FacilityID)`

#### 5. Bookings
*   **Description:** Stores details of all space booking requests and their lifecycle.
*   **Attributes:**
    *   `BookingID` (Primary Key)
    *   `RequesterUserID` (Foreign Key)
    *   `SpaceCode` (Foreign Key)
    *   `RequestedStartTime`
    *   `RequestedEndTime`
    *   `Purpose` (e.g., Lecture, Examination, Seminar, Workshop, Meeting, Student Activity, Administrative Event)
    *   `ExpectedParticipants`
    *   `Status` (e.g., Pending, Approved, Rejected, Cancelled, Checked In, Completed, No-Show)
    *   `ApproverUserID` (Foreign Key, Nullable)
    *   `DecisionTime` (Nullable)
    *   `DecisionNote` (Nullable)
    *   `RejectionReason` (Nullable, if Status is Rejected)
    *   `CheckInStaffUserID` (Foreign Key, Nullable)
    *   `ActualStartTime` (Nullable, if Checked In or Completed)
    *   `InitialCondition` (Nullable, if Checked In or Completed)
    *   `CompleteStaffUserID` (Foreign Key, Nullable)
    *   `ActualEndTime` (Nullable, if Completed)
    *   `FinalCondition` (Nullable, if Completed)
    *   `UsageNotes` (Nullable, if Completed)
*   **Key Constraints:**
    *   `PK_Bookings`: `BookingID`
    *   `FK_Bookings_Requester`: `RequesterUserID` references `Users(UserID)`
    *   `FK_Bookings_Space`: `SpaceCode` references `Spaces(SpaceCode)`
    *   `FK_Bookings_Approver`: `ApproverUserID` references `Users(UserID)`
    *   `FK_Bookings_CheckInStaff`: `CheckInStaffUserID` references `Users(UserID)`
    *   `FK_Bookings_CompleteStaff`: `CompleteStaffUserID` references `Users(UserID)`

#### 6. MaintenanceRecords
*   **Description:** Tracks all maintenance activities and incidents related to spaces.
*   **Attributes:**
    *   `MaintenanceID` (Primary Key)
    *   `SpaceCode` (Foreign Key)
    *   `ReporterUserID` (Foreign Key)
    *   `AssignedStaffUserID` (Foreign Key, Nullable)
    *   `ProblemDescription`
    *   `StartTime`
    *   `CompletionTime` (Nullable)
    *   `Status` (e.g., Reported, In Progress, Completed, Cancelled)
    *   `ResultNote` (Nullable, if Completed)
*   **Key Constraints:**
    *   `PK_MaintenanceRecords`: `MaintenanceID`
    *   `FK_MaintenanceRecords_Space`: `SpaceCode` references `Spaces(SpaceCode)`
    *   `FK_MaintenanceRecords_Reporter`: `ReporterUserID` references `Users(UserID)`
    *   `FK_MaintenanceRecords_AssignedStaff`: `AssignedStaffUserID` references `Users(UserID)`