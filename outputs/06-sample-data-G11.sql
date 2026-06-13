```sql
-- 06-sample-data-G01.sql

-- Insert data into Departments
INSERT INTO Departments (department_id, department_name) VALUES
(1, 'Computer Science'),
(2, 'Electrical Engineering'),
(3, 'Mathematics'),
(4, 'Physics'),
(5, 'University Administration');

-- Insert data into Users
INSERT INTO Users (user_id, full_name, email, phone_number, role, department_id, account_status) VALUES
(101, 'Alice Smith', 'alice.s@example.com', '111-222-3333', 'Lecturer', 1, 'active'),
(102, 'Bob Johnson', 'bob.j@example.com', '111-222-4444', 'Student', 1, 'active'),
(103, 'Charlie Brown', 'charlie.b@example.com', '111-222-5555', 'Facility Staff', 5, 'active'),
(104, 'Diana Prince', 'diana.p@example.com', '111-222-6666', 'Facility Manager', 5, 'active'),
(105, 'Eve Adams', 'eve.a@example.com', '111-222-7777', 'Teaching Assistant', 1, 'active'),
(106, 'Frank White', 'frank.w@example.com', '111-222-8888', 'Student', 2, 'active'),
(107, 'Grace Lee', 'grace.l@example.com', '111-222-9999', 'Lecturer', 3, 'active'),
(108, 'Henry King', 'henry.k@example.com', '111-222-0000', 'Department Administrator', 1, 'active'),
(109, 'Ivy Green', 'ivy.g@example.com', '111-333-1111', 'Facility Staff', 5, 'active'),
(110, 'Jack Black', 'jack.b@example.com', '111-333-2222', 'Student', 1, 'inactive'); -- Inactive user

-- Insert data into SpaceTypes
INSERT INTO SpaceTypes (space_type_id, type_name) VALUES
(1, 'Auditorium'),
(2, 'Classroom'),
(3, 'Computer Laboratory'),
(4, 'Project Laboratory'),
(5, 'Meeting Room'),
(6, 'Student Workspace');

-- Insert data into Spaces
INSERT INTO Spaces (space_id, space_code, space_name, space_type_id, building, floor, room_number, capacity, current_status, usage_policy) VALUES
(1, 'AUDI-001', 'Main Auditorium', 1, 'Building A', 1, 'A101', 300, 'available', 'For large events and lectures only.'),
(2, 'CR-101', 'Classroom 101', 2, 'Building B', 1, 'B101', 50, 'available', 'General purpose classroom.'),
(3, 'CL-201', 'Computer Lab 201', 3, 'Building C', 2, 'C201', 30, 'available', 'For computer science practicals.'),
(4, 'MR-301', 'Meeting Room 301', 5, 'Building A', 3, 'A301', 10, 'available', 'For staff meetings and small group discussions.'),
(5, 'PL-401', 'Project Lab 401', 4, 'Building D', 4, 'D401', 20, 'under maintenance', 'For student projects, specialized equipment.'), -- Under maintenance
(6, 'CR-102', 'Classroom 102', 2, 'Building B', 1, 'B102', 40, 'available', 'General purpose classroom.'),
(7, 'SW-501', 'Student Workspace 501', 6, 'Building E', 5, 'E501', 15, 'temporarily closed', 'Collaborative student workspace.'), -- Temporarily closed
(8, 'AUDI-002', 'Mini Auditorium', 1, 'Building A', 1, 'A102', 100, 'available', 'For medium-sized events and presentations.');

-- Insert data into Facilities
INSERT INTO Facilities (facility_id, facility_name) VALUES
(1, 'Projector'),
(2, 'Whiteboard'),
(3, 'Microphone'),
(4, 'Computer'),
(5, 'Livestreaming Equipment'),
(6, 'Air Conditioner'),
(7, 'Smart Board'),
(8, 'Sound System');

-- Insert data into SpaceFacilities
INSERT INTO SpaceFacilities (space_id, facility_id) VALUES
(1, 1), (1, 3), (1, 5), (1, 6), (1, 8), -- Main Auditorium
(2, 1), (2, 2), (2, 6), -- Classroom 101
(3, 1), (3, 2), (3, 4), (3, 6), -- Computer Lab 201
(4, 1), (4, 2), (4, 6), -- Meeting Room 301
(5, 1), (5, 2), (5, 4), (5, 6), -- Project Lab 401 (currently under maintenance)
(6, 1), (6, 2), (6, 6), -- Classroom 102
(7, 2), (7, 4), (7, 6), -- Student Workspace 501 (temporarily closed)
(8, 1), (8, 3), (8, 6), (8, 8); -- Mini Auditorium

-- Insert data into Bookings
-- Booking 1: Approved lecture
INSERT INTO Bookings (booking_id, user_id, space_id, requested_start_time, requested_end_time, purpose, expected_participants, booking_status, request_time) VALUES
(1001, 101, 2, '2024-03-10 09:00:00', '2024-03-10 11:00:00', 'lecture', 45, 'approved', '2024-03-01 10:00:00');

-- Booking 2: Pending student activity
INSERT INTO Bookings (booking_id, user_id, space_id, requested_start_time, requested_end_time, purpose, expected_participants, booking_status, request_time) VALUES
(1002, 102, 4, '2024-03-15 14:00:00', '2024-03-15 16:00:00', 'student activity', 8, 'pending', '2024-03-05 11:30:00');

-- Booking 3: Rejected due to conflict
INSERT INTO Bookings (booking_id, user_id, space_id, requested_start_time, requested_end_time, purpose, expected_participants, booking_status, request_time) VALUES
(1003, 105, 2, '2024-03-10 09:30:00', '2024-03-10 11:30:00', 'workshop', 30, 'rejected', '2024-03-02 09:00:00'); -- Conflicts with Booking 1

-- Booking 4: Completed seminar
INSERT INTO Bookings (booking_id, user_id, space_id, requested_start_time, requested_end_time, purpose, expected_participants, booking_status, request_time) VALUES
(1004, 107, 1, '2024-03-08 13:00:00', '2024-03-08 17:00:00', 'seminar', 200, 'completed', '2024-02-20 14:00:00');

-- Booking 5: No-show
INSERT INTO Bookings (booking_id, user_id, space_id, requested_start_time, requested_end_time, purpose, expected_participants, booking_status, request_time) VALUES
(1005, 106, 6, '2024-03-09 10:00:00', '2024-03-09 12:00:00', 'student activity', 15, 'no-show', '2024-03-01 16:00:00');

-- Booking 6: Approved, but for a space under maintenance (for testing constraints)
INSERT INTO Bookings (booking_id, user_id, space_id, requested_start_time, requested_end_time, purpose, expected_participants, booking_status, request_time) VALUES
(1006, 101, 5, '2024-03-20 09:00:00', '2024-03-20 12:00:00', 'workshop', 18, 'approved', '2024-03-01 10:00:00');

-- Booking 7: Approved, checked in, but not yet completed
INSERT INTO Bookings (booking_id, user_id, space_id, requested_start_time, requested_end_time, purpose, expected_participants, booking_status, request_time) VALUES
(1007, 102, 3, '2024-03-12 10:00:00', '2024-03-12 12:00:00', 'student project', 25, 'checked in', '2024-03-07 08:00:00');

-- Booking 8: Cancelled booking
INSERT INTO Bookings (booking_id, user_id, space_id, requested_start_time, requested_end_time, purpose, expected_participants, booking_status, request_time) VALUES
(1008, 106, 6, '2024-03-25 13:00:00', '2024-03-25 15:00:00', 'meeting', 10, 'cancelled', '2024-03-10 10:00:00');

-- Insert data into BookingApprovals
-- Approval for Booking 1
INSERT INTO BookingApprovals (approval_id, booking_id, approver_id, decision_time, decision_status, decision_note, rejection_reason) VALUES
(2001, 1001, 103, '2024-03-01 11:00:00', 'approved', 'Space available, requester authorized.', NULL);

-- Rejection for Booking 3
INSERT INTO BookingApprovals (approval_id, booking_id, approver_id, decision_time, decision_status, decision_note, rejection_reason) VALUES
(2002, 1003, 103, '2024-03-02 09:30:00', 'rejected', 'Time conflict with existing approved booking.', 'Overlapping time with Booking 1.');

-- Approval for Booking 4
INSERT INTO BookingApprovals (approval_id, booking_id, approver_id, decision_time, decision_status, decision_note, rejection_reason) VALUES
(2003, 104, 104, '2024-02-21 09:00:00', 'approved', 'Large event, space is suitable.', NULL);

-- Approval for Booking 6 (for space under maintenance, for testing purposes)
INSERT INTO BookingApprovals (approval_id, booking_id, approver_id, decision_time, decision_status, decision_note, rejection_reason) VALUES
(2004, 1006, 103, '2024-03-01 11:15:00', 'approved', 'Approved before maintenance status was updated.', NULL);

-- Approval for Booking 7
INSERT INTO BookingApprovals (approval_id, booking_id, approver_id, decision_time, decision_status, decision_note, rejection_reason) VALUES
(2005, 1007, 109, '2024-03-07 09:00:00', 'approved', 'Space available.', NULL);


-- Insert data into CheckIns
-- Check-in for Booking 4 (completed)
INSERT INTO CheckIns (check_in_id, booking_id, check_in_staff_id, actual_start_time, initial_condition) VALUES
(3001, 1004, 103, '2024-03-08 12:55:00', 'Clean and tidy, all equipment functional.');

-- Check-in for Booking 7 (checked in)
INSERT INTO CheckIns (check_in_id, booking_id, check_in_staff_id, actual_start_time, initial_condition) VALUES
(3002, 1007, 109, '2024-03-12 09:58:00', 'Good condition.');

-- Insert data into CheckOuts
-- Check-out for Booking 4 (completed)
INSERT INTO CheckOuts (check_out_id, booking_id, check_out_staff_id, actual_end_time, final_condition, usage_notes) VALUES
(4001, 1004, 103, '2024-03-08 17:05:00', 'Slightly messy, projector left on.', 'Successful seminar, minor cleanup needed.');

-- Insert data into MaintenanceRecords
-- Maintenance for Project Lab 401 (Space 5)
INSERT INTO MaintenanceRecords (maintenance_id, space_id, reporter_id, assigned_staff_id, problem_description, reported_time, scheduled_start_time, completion_time, maintenance_status, result_note) VALUES
(5001, 5, 101, 103, 'Projector lamp broken, AC not cooling effectively.', '2024-03-05 10:00:00', '2024-03-07 09:00:00', NULL, 'in progress', NULL);

-- Completed maintenance for Classroom 101 (Space 2)
INSERT INTO MaintenanceRecords (maintenance_id, space_id, reporter_id, assigned_staff_id, problem_description, reported_time, scheduled_start_time, completion_time, maintenance_status, result_note) VALUES
(5002, 2, 105, 109, 'Whiteboard marker stains not removable.', '2024-02-28 14:00:00', '2024-03-01 08:00:00', '2024-03-01 10:00:00', 'completed', 'Whiteboard cleaned and restored.');

-- Pending maintenance for Main Auditorium (Space 1)
INSERT INTO MaintenanceRecords (maintenance_id, space_id, reporter_id, assigned_staff_id, problem_description, reported_time, scheduled_start_time, completion_time, maintenance_status, result_note) VALUES
(5003, 1, 107, 103, 'Microphone static noise.', '2024-03-10 11:00:00', '2024-03-12 13:00:00', NULL, 'pending', NULL);

-- Maintenance for Student Workspace 501 (Space 7) - reason for 'temporarily closed'
INSERT INTO MaintenanceRecords (maintenance_id, space_id, reporter_id, assigned_staff_id, problem_description, reported_time, scheduled_start_time, completion_time, maintenance_status, result_note) VALUES
(5004, 7, 102, 109, 'Network issues, several computers offline.', '2024-03-01 09:00:00', '2024-03-02 09:00:00', NULL, 'in progress', 'Requires network specialist intervention.');
```