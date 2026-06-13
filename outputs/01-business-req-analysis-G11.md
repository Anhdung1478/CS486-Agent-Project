```markdown
# 01-business-req-analysis-G01.md

## 1. Business Purpose

The primary goal is to develop a database system for the School of Computer Science to efficiently manage shared physical campus spaces. This system aims to:
*   Automate space booking, approval, and usage tracking.
*   Streamline maintenance management and incident reporting.
*   Prevent booking conflicts and ensure fair space allocation.
*   Track equipment and facility utilization.
*   Maintain historical records of bookings and maintenance activities.
*   Improve overall efficiency and reduce manual administrative overhead.

## 2. Actors

The system interacts with various user roles within the university:
*   **Requester:** Any user (Student, Lecturer, Teaching Assistant, Staff) who submits a booking request.
*   **Approver:** Facility Staff or Facility Manager who reviews and approves/rejects booking requests.
*   **Checker-in/Completer:** Facility Staff who manages the check-in and completion processes for bookings.
*   **Reporter:** Any user who reports a maintenance issue.
*   **Assigned Staff:** Facility Staff or other designated personnel assigned to resolve maintenance issues.

## 3. Entities and Attributes

### 3.1. User
Represents individuals interacting with the system.
*   **UserID** (Primary Key, unique identifier for the user)
*   FullName
*   Email (unique)
*   PhoneNumber
*   Role (e.g., 'Student', 'Lecturer', 'Teaching Assistant', 'Facility Staff', 'Department Administrator', 'Facility Manager')
*   Department
*   AccountStatus (e.g., 'Active', 'Inactive', 'Suspended')

### 3.2. Space
Represents the physical bookable spaces.
*   **SpaceCode** (Primary Key, unique identifier for the space, e.g., 'A101', 'LAB001')
*   SpaceName
*   SpaceType (e.g., 'Auditorium', 'Classroom', 'Computer Laboratory', 'Project Laboratory', 'Meeting Room', 'Student Workspace')
*   Building
*   Floor
*   RoomNumber
*   Capacity
*   CurrentStatus (e.g., 'Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', 'Retired')
*   UsagePolicy

### 3.3. FacilityType
Represents types of equipment or amenities available in spaces.
*   **FacilityTypeID** (Primary Key, unique identifier for the facility type)
*   FacilityName (e.g., 'Projector', 'Whiteboard', 'Microphone', 'Computer', 'Livestreaming Equipment', 'Air Conditioner')

### 3.4. Booking
Represents a request and subsequent management of a space reservation.
*   **BookingID** (Primary Key, unique identifier for the booking)
*   RequestedStartTime
*   RequestedEndTime
*   Purpose (e.g., 'Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'Student Activity', 'Administrative Event')
*   ExpectedParticipants
*   Status (e.g., 'Pending', 'Approved', 'Rejected', 'Cancelled', 'Checked In', 'Completed', 'No-Show')
*   SubmissionTimestamp (timestamp when the booking was submitted)
*   ActualStartTime (nullable, recorded at check-in)
*   ActualEndTime (nullable, recorded at completion)
*   InitialSpaceCondition (nullable, recorded at check-in)
*   FinalSpaceCondition (nullable, recorded at completion)
*   UsageNotes (nullable, recorded at completion)
*   RejectionReason (nullable, if status is 'Rejected')

### 3.5. BookingApproval
Records the decision details for a booking.
*   **BookingApprovalID** (Primary Key, unique identifier for the approval record)
*   DecisionTime
*   DecisionNote (nullable)

### 3.6. MaintenanceRecord
Records details about maintenance activities for a space.
*   **MaintenanceID** (Primary Key, unique identifier for the maintenance record)
*   ProblemDescription
*   ReportTime (timestamp when the problem was reported)
*   MaintenanceStartTime (when work began)
*   CompletionTime (nullable, when work finished)
*   Status (e.g., 'Reported', 'In Progress', 'Completed', 'Cancelled')
*   ResultNote (nullable, details about the resolution)

## 4. Relationships and Cardinalities

### 4.1. User - submits - Booking
*   **Relationship:** A `User` submits `Booking` requests.
*   **Cardinality:** One `User` can submit many `Booking` requests (1:N). Each `Booking` is submitted by exactly one `User`.
*   **Foreign Key:** `RequesterUserID` in `Booking` references `UserID` in `User`.

### 4.2. Booking - is for - Space
*   **Relationship:** A `Booking` is made for a specific `Space`.
*   **Cardinality:** One `Space` can have many `Booking` requests (1:N). Each `Booking` is for exactly one `Space`.
*   **Foreign Key:** `SpaceCode` in `Booking` references `SpaceCode` in `Space`.

### 4.3. Space - has - FacilityType (Many-to-Many)
*   **Relationship:** A `Space` can have multiple `FacilityType`s, and a `FacilityType` can be present in multiple `Space`s.
*   **Cardinality:** Many `Space`s to Many `FacilityType`s (N:M).
*   **Linking Entity:** `SpaceFacility`
    *   **SpaceCode** (Foreign Key to Space, part of Composite Primary Key)
    *   **FacilityTypeID** (Foreign Key to FacilityType, part of Composite Primary Key)

### 4.4. User - approves/rejects - Booking (via BookingApproval)
*   **Relationship:** A `User` (with role 'Facility Staff' or 'Facility Manager') makes an approval/rejection decision for a `Booking`.
*   **Cardinality:** One `User` can approve/reject many `Booking`s (1:N). Each `BookingApproval` is made by exactly one `User`. Each `Booking` may have one `BookingApproval` record (0:1).
*   **Foreign Key:** `ApproverUserID` in `BookingApproval` references `UserID` in `User`.
*   **Foreign Key:** `BookingID` in `BookingApproval` references `BookingID` in `Booking`.

### 4.5. User - checks in - Booking
*   **Relationship:** A `User` (with role 'Facility Staff') checks in a `Booking`.
*   **Cardinality:** One `User` can check in many `Booking`s (1:N). A `Booking` (if checked in) is checked in by one `User`.
*   **Foreign Key:** `CheckerInUserID` in `Booking` references `UserID` in `User`.

### 4.6. User - completes - Booking
*   **Relationship:** A `User` (with role 'Facility Staff') completes a `Booking`.
*   **Cardinality:** One `User` can complete many `Booking`s (1:N). A `Booking` (if completed) is completed by one `User`.
*   **Foreign Key:** `CompleterUserID` in `Booking` references `UserID` in `User`.

### 4.7. Space - has - MaintenanceRecord
*   **Relationship:** A `Space` can have many `MaintenanceRecord`s.
*   **Cardinality:** One `Space` can have many `MaintenanceRecord`s (1:N). Each `MaintenanceRecord` is for exactly one `Space`.
*   **Foreign Key:** `SpaceCode` in `MaintenanceRecord` references `SpaceCode` in `Space`.

### 4.8. User - reports - MaintenanceRecord
*   **Relationship:** A `User` reports a `MaintenanceRecord`.
*   **Cardinality:** One `User` can report many `MaintenanceRecord`s (1:N). Each `MaintenanceRecord` is reported by exactly one `User`.
*   **Foreign Key:** `ReporterUserID` in `MaintenanceRecord` references `UserID` in `User`.

### 4.9. User - assigned to - MaintenanceRecord
*   **Relationship:** A `User` (with role 'Facility Staff' or similar) can be assigned to a `MaintenanceRecord`.
*   **Cardinality:** One `User` can be assigned to many `MaintenanceRecord`s (1:N). A `MaintenanceRecord` may be assigned to one `User` (0:1).
*   **Foreign Key:** `AssignedStaffUserID` in `MaintenanceRecord` references `UserID` in `User`.

## 5. Business Rules

1.  **User Authentication:** Each user must have a university account.
2.  **User Roles:** Users can have one of several predefined roles: Student, Lecturer, Teaching Assistant, Facility Staff, Department Administrator, Facility Manager.
3.  **Space Statuses:** Spaces can be in one of the following states: Available, In Use, Under Maintenance, Temporarily Closed, Retired.
4.  **Booking Purposes:** Bookings can be for various purposes: Lecture, Examination, Seminar, Workshop, Meeting, Student Activity, Administrative Event.
5.  **Booking Statuses:** Booking requests progress through statuses: Pending, Approved, Rejected, Cancelled, Checked In, Completed, No-Show.
6.  **Booking Conflict Prevention:**
    *   The system must prevent conflicting bookings: The same space cannot have two **approved** bookings with overlapping time periods.
    *   A space that is 'Under Maintenance', 'Temporarily Closed', or 'Retired' cannot be booked.
7.  **Booking Approval Process:**
    *   Booking requests may require approval from a Facility Staff member or Facility Manager.
    *   When a booking is approved or rejected, the system records: the `ApproverUserID`, `DecisionTime`, and an optional `DecisionNote`.
    *   If rejected, a `RejectionReason` must be stored.
8.  **Booking Check-in Process:**
    *   When a requester arrives, Facility Staff can check in the booking.
    *   The system records: `ActualStartTime`, `CheckerInUserID`, and `InitialSpaceCondition`.
9.  **Booking Completion Process:**
    *   When a session ends, Facility Staff can complete the booking.
    *   The system records: `ActualEndTime`, `CompleterUserID`, `FinalSpaceCondition`, and any `UsageNotes`.
10. **Maintenance Management:**
    *   Spaces can have maintenance records.
    *   Each maintenance record stores: `SpaceCode`, `ReporterUserID`, `AssignedStaffUserID` (nullable), `ProblemDescription`, `MaintenanceStartTime`, `CompletionTime` (nullable), `Status`, and `ResultNote` (nullable).
    *   A space with `CurrentStatus` 'Under Maintenance' cannot be booked (reiteration of rule 6.2).
11. **Historical Records:** The system must keep historical records of all bookings and maintenance activities.
12. **Data Integrity:** Email addresses for users must be unique. Space codes must be unique. Facility type names must be unique.
```