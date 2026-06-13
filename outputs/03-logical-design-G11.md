```markdown
# Logical Relational Schema - Campus Space Management System (G01)

This document outlines the logical relational schema derived from the conceptual ERD, detailing relations, attributes, primary keys, foreign keys, candidate keys, and key constraints.

---

## 1. Relation: `Users`

*   **Purpose:** Stores information about all individuals with a university account who interact with the system.
*   **Attributes:**
    *   `user_id` (INTEGER)
    *   `full_name` (VARCHAR(255))
    *   `email` (VARCHAR(255))
    *   `phone_number` (VARCHAR(20))
    *   `role` (VARCHAR(50))
    *   `department` (VARCHAR(100))
    *   `account_status` (VARCHAR(20))
*   **Primary Key (PK):** `user_id`
*   **Candidate Keys (CK):** `email`
*   **Key Constraints:**
    *   `user_id` is unique and NOT NULL.
    *   `email` is unique and NOT NULL.
    *   `full_name` is NOT NULL.
    *   `role` is NOT NULL.
    *   `account_status` is NOT NULL.
*   **Check Constraints:**
    *   `role` IN ('student', 'lecturer', 'teaching assistant', 'facility staff', 'department administrator', 'facility manager')
    *   `account_status` IN ('active', 'inactive', 'suspended')

---

## 2. Relation: `Spaces`

*   **Purpose:** Manages details for all bookable physical spaces within the School of Computer Science.
*   **Attributes:**
    *   `space_code` (VARCHAR(50))
    *   `space_name` (VARCHAR(255))
    *   `space_type` (VARCHAR(50))
    *   `building` (VARCHAR(100))
    *   `floor` (VARCHAR(20))
    *   `room_number` (VARCHAR(20))
    *   `capacity` (INTEGER)
    *   `current_status` (VARCHAR(50))
    *   `usage_policy` (TEXT)
*   **Primary Key (PK):** `space_code`
*   **Candidate Keys (CK):** (`building`, `floor`, `room_number`)
*   **Key Constraints:**
    *   `space_code` is unique and NOT NULL.
    *   `space_name` is NOT NULL.
    *   `space_type` is NOT NULL.
    *   `building` is NOT NULL.
    *   `floor` is NOT NULL.
    *   `room_number` is NOT NULL.
    *   `capacity` is NOT NULL.
    *   `current_status` is NOT NULL.
*   **Check Constraints:**
    *   `space_type` IN ('auditorium', 'classroom', 'computer laboratory', 'project laboratory', 'meeting room', 'student workspace')
    *   `current_status` IN ('available', 'in use', 'under maintenance', 'temporarily closed', 'retired')
    *   `capacity` >= 0

---

## 3. Relation: `Facilities`

*   **Purpose:** Lists all types of equipment or features that can be present in a space.
*   **Attributes:**
    *   `facility_id` (INTEGER)
    *   `facility_name` (VARCHAR(100))
*   **Primary Key (PK):** `facility_id`
*   **Candidate Keys (CK):** `facility_name`
*   **Key Constraints:**
    *   `facility_id` is unique and NOT NULL.
    *   `facility_name` is unique and NOT NULL.

---

## 4. Relation: `SpaceFacilities`

*   **Purpose:** Represents the many-to-many relationship between `Spaces` and `Facilities`, detailing which facilities are available in each space.
*   **Attributes:**
    *   `space_code` (VARCHAR(50))
    *   `facility_id` (INTEGER)
    *   `quantity` (INTEGER)
    *   `notes` (TEXT)
*   **Primary Key (PK):** (`space_code`, `facility_id`)
*   **Foreign Keys (FK):**
    *   `space_code` REFERENCES `Spaces`(`space_code`)
    *   `facility_id` REFERENCES `Facilities`(`facility_id`)
*   **Key Constraints:**
    *   All attributes forming the PK are NOT NULL.
*   **Check Constraints:**
    *   `quantity` >= 0

---

## 5. Relation: `Bookings`

*   **Purpose:** Stores all booking requests, their status, and approval/rejection details.
*   **Attributes:**
    *   `booking_id` (INTEGER)
    *   `space_code` (VARCHAR(50))
    *   `requester_user_id` (INTEGER)
    *   `requested_start_time` (TIMESTAMP)
    *   `requested_end_time` (TIMESTAMP)
    *   `purpose_of_use` (VARCHAR(100))
    *   `expected_participants` (INTEGER)
    *   `booking_status` (VARCHAR(50))
    *   `submission_timestamp` (TIMESTAMP)
    *   `approver_user_id` (INTEGER) (Nullable)
    *   `decision_time` (TIMESTAMP) (Nullable)
    *   `decision_note` (TEXT) (Nullable)
    *   `rejection_reason` (TEXT) (Nullable)
*   **Primary Key (PK):** `booking_id`
*   **Foreign Keys (FK):**
    *   `space_code` REFERENCES `Spaces`(`space_code`)
    *   `requester_user_id` REFERENCES `Users`(`user_id`)
    *   `approver_user_id` REFERENCES `Users`(`user_id`)
*   **Key Constraints:**
    *   `booking_id` is unique and NOT NULL.
    *   `space_code` is NOT NULL.
    *   `requester_user_id` is NOT NULL.
    *   `requested_start_time` is NOT NULL.
    *   `requested_end_time` is NOT NULL.
    *   `purpose_of_use` is NOT NULL.
    *   `booking_status` is NOT NULL.
    *   `submission_timestamp` is NOT NULL.
*   **Check Constraints:**
    *   `requested_end_time` > `requested_start_time`
    *   `expected_participants` >= 0
    *   `booking_status` IN ('pending', 'approved', 'rejected', 'cancelled', 'checked in', 'completed', 'no-show')
    *   `purpose_of_use` IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student activity', 'administrative event')
    *   Conditional: `rejection_reason` IS NOT NULL if `booking_status` = 'rejected'.
    *   Conditional: `approver_user_id`, `decision_time`, `decision_note` are NOT NULL if `booking_status` IN ('approved', 'rejected').

---

## 6. Relation: `BookingSessions`

*   **Purpose:** Records the actual usage details of an approved booking, including check-in and completion information.
*   **Attributes:**
    *   `session_id` (INTEGER)
    *   `booking_id` (INTEGER)
    *   `check_in_time` (TIMESTAMP)
    *   `check_in_staff_user_id` (INTEGER)
    *   `initial_condition_notes` (TEXT)
    *   `actual_end_time` (TIMESTAMP) (Nullable)
    *   `completion_staff_user_id` (INTEGER) (Nullable)
    *   `final_condition_notes` (TEXT) (Nullable)
    *   `usage_notes` (TEXT) (Nullable)
*   **Primary Key (PK):** `session_id`
*   **Candidate Keys (CK):** `booking_id` (Ensures one session per booking)
*   **Foreign Keys (FK):**
    *   `booking_id` REFERENCES `Bookings`(`booking_id`)
    *   `check_in_staff_user_id` REFERENCES `Users`(`user_id`)
    *   `completion_staff_user_id` REFERENCES `Users`(`user_id`)
*   **Key Constraints:**
    *   `session_id` is unique and NOT NULL.
    *   `booking_id` is unique and NOT NULL.
    *   `check_in_time` is NOT NULL.
    *   `check_in_staff_user_id` is NOT NULL.
*   **Check Constraints:**
    *   `actual_end_time` > `check_in_time` (if `actual_end_time` is not null)

---

## 7. Relation: `MaintenanceRecords`

*   **Purpose:** Tracks all maintenance activities and incidents related to spaces.
*   **Attributes:**
    *   `maintenance_id` (INTEGER)
    *   `space_code` (VARCHAR(50))
    *   `reporter_user_id` (INTEGER)
    *   `assigned_staff_user_id` (INTEGER) (Nullable)
    *   `problem_description` (TEXT)
    *   `start_time` (TIMESTAMP)
    *   `completion_time` (TIMESTAMP) (Nullable)
    *   `maintenance_status` (VARCHAR(50))
    *   `result_note` (TEXT) (Nullable)
*   **Primary Key (PK):** `maintenance_id`
*   **Foreign Keys (FK):**
    *   `space_code` REFERENCES `Spaces`(`space_code`)
    *   `reporter_user_id` REFERENCES `Users`(`user_id`)
    *   `assigned_staff_user_id` REFERENCES `Users`(`user_id`)
*   **Key Constraints:**
    *   `maintenance_id` is unique and NOT NULL.
    *   `space_code` is NOT NULL.
    *   `reporter_user_id` is NOT NULL.
    *   `problem_description` is NOT NULL.
    *   `start_time` is NOT NULL.
    *   `maintenance_status` is NOT NULL.
*   **Check Constraints:**
    *   `completion_time` > `start_time` (if `completion_time` is not null)
    *   `maintenance_status` IN ('pending', 'in progress', 'completed', 'cancelled')

---
```