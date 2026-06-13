```sql
-- 05-db-definition-G01.sql

-- Drop tables in reverse dependency order to avoid foreign key constraint issues
DROP TABLE IF EXISTS UsageSessions CASCADE;
DROP TABLE IF EXISTS BookingApprovals CASCADE;
DROP TABLE IF EXISTS MaintenanceRecords CASCADE;
DROP TABLE IF EXISTS Bookings CASCADE;
DROP TABLE IF EXISTS SpaceFacilities CASCADE;
DROP TABLE IF EXISTS Spaces CASCADE;
DROP TABLE IF EXISTS Facilities CASCADE;
DROP TABLE IF EXISTS Users CASCADE;

-- Create Users Table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    role VARCHAR(50) NOT NULL,
    department VARCHAR(100),
    account_status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT chk_user_role CHECK (role IN ('student', 'lecturer', 'teaching assistant', 'facility staff', 'department administrator', 'facility manager')),
    CONSTRAINT chk_account_status CHECK (account_status IN ('active', 'inactive', 'suspended'))
);

-- Create Facilities Table
CREATE TABLE Facilities (
    facility_id SERIAL PRIMARY KEY,
    facility_name VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT chk_facility_name CHECK (facility_name IN ('projector', 'whiteboard', 'microphone', 'computer', 'livestreaming equipment', 'air conditioner', 'smart board', 'sound system', 'desks', 'chairs', 'interactive display'))
);

-- Create Spaces Table
CREATE TABLE Spaces (
    space_id SERIAL PRIMARY KEY,
    space_code VARCHAR(50) NOT NULL UNIQUE,
    space_name VARCHAR(255) NOT NULL,
    space_type VARCHAR(50) NOT NULL,
    building VARCHAR(100) NOT NULL,
    floor VARCHAR(10) NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    capacity INT NOT NULL,
    current_status VARCHAR(50) NOT NULL DEFAULT 'available',
    usage_policy TEXT,
    CONSTRAINT chk_space_type CHECK (space_type IN ('auditorium', 'classroom', 'computer laboratory', 'project laboratory', 'meeting room', 'student workspace')),
    CONSTRAINT chk_space_capacity CHECK (capacity > 0),
    CONSTRAINT chk_space_status CHECK (current_status IN ('available', 'in use', 'under maintenance', 'temporarily closed', 'retired'))
);

-- Create SpaceFacilities Junction Table
CREATE TABLE SpaceFacilities (
    space_id INT NOT NULL,
    facility_id INT NOT NULL,
    PRIMARY KEY (space_id, facility_id),
    FOREIGN KEY (space_id) REFERENCES Spaces(space_id) ON DELETE CASCADE,
    FOREIGN KEY (facility_id) REFERENCES Facilities(facility_id) ON DELETE CASCADE
);

-- Create Bookings Table
CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,
    requester_id INT NOT NULL,
    space_id INT NOT NULL,
    requested_start_time TIMESTAMP NOT NULL,
    requested_end_time TIMESTAMP NOT NULL,
    purpose_of_use VARCHAR(100) NOT NULL,
    expected_participants INT NOT NULL,
    booking_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    submission_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (requester_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (space_id) REFERENCES Spaces(space_id) ON DELETE RESTRICT,
    CONSTRAINT chk_booking_time_order CHECK (requested_start_time < requested_end_time),
    CONSTRAINT chk_purpose_of_use CHECK (purpose_of_use IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student activity', 'administrative event', 'research')),
    CONSTRAINT chk_expected_participants CHECK (expected_participants > 0),
    CONSTRAINT chk_booking_status CHECK (booking_status IN ('pending', 'approved', 'rejected', 'cancelled', 'checked in', 'completed', 'no-show'))
    -- Note: Complex business rules like preventing overlapping approved bookings or booking unavailable spaces
    -- require triggers or application-level logic, and are not directly enforceable with simple DDL constraints.
);

-- Create BookingApprovals Table
CREATE TABLE BookingApprovals (
    approval_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE, -- Ensures one approval record per booking
    approver_id INT NOT NULL,
    decision_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    decision_type VARCHAR(20) NOT NULL,
    decision_note TEXT,
    rejection_reason TEXT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (approver_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    CONSTRAINT chk_decision_type CHECK (decision_type IN ('approved', 'rejected'))
);

-- Create UsageSessions Table
CREATE TABLE UsageSessions (
    session_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE, -- Ensures one usage session per booking
    check_in_staff_id INT,
    actual_start_time TIMESTAMP,
    initial_condition TEXT,
    check_out_staff_id INT,
    actual_end_time TIMESTAMP,
    final_condition TEXT,
    usage_notes TEXT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (check_in_staff_id) REFERENCES Users(user_id) ON DELETE SET NULL, -- If staff leaves, their check-in record can be nullified
    FOREIGN KEY (check_out_staff_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    CONSTRAINT chk_actual_time_order CHECK (actual_start_time IS NULL OR actual_end_time IS NULL OR actual_start_time < actual_end_time)
);

-- Create MaintenanceRecords Table
CREATE TABLE MaintenanceRecords (
    maintenance_id SERIAL PRIMARY KEY,
    space_id INT NOT NULL,
    reporter_id INT NOT NULL,
    assigned_staff_id INT,
    problem_description TEXT NOT NULL,
    reported_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_time TIMESTAMP,
    completion_time TIMESTAMP,
    maintenance_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    result_note TEXT,
    FOREIGN KEY (space_id) REFERENCES Spaces(space_id) ON DELETE RESTRICT,
    FOREIGN KEY (reporter_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (assigned_staff_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    CONSTRAINT chk_maintenance_time_order CHECK (start_time IS NULL OR completion_time IS NULL OR start_time < completion_time),
    CONSTRAINT chk_maintenance_status CHECK (maintenance_status IN ('pending', 'in progress', 'completed', 'cancelled'))
);
```