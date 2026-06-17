INSERT INTO Users (UserID, FullName, Email, PhoneNumber, Role, DepartmentName, AccountStatus) VALUES
('U001', 'Alice Smith', 'alice.smith@example.edu', '111-222-3333', 'Lecturer', 'Computer Science', 'Active'),
('U002', 'Bob Johnson', 'bob.j@example.edu', '444-555-6666', 'Student', 'Computer Science', 'Active'),
('U003', 'Charlie Brown', 'charlie.b@example.edu', '777-888-9999', 'Facility Staff', 'Facilities Management', 'Active'),
('U004', 'Diana Prince', 'diana.p@example.edu', '123-456-7890', 'Facility Manager', 'Facilities Management', 'Active'),
('U005', 'Eve Adams', 'eve.a@example.edu', '098-765-4321', 'Teaching Assistant', 'Computer Science', 'Active'),
('U006', 'Frank White', 'frank.w@example.edu', '112-334-5566', 'Department Administrator', 'Computer Science', 'Active'),
('U007', 'Grace Hopper', 'grace.h@example.edu', '223-445-6677', 'Lecturer', 'Electrical Engineering', 'Active'),
('U008', 'Harry Potter', 'harry.p@example.edu', '334-556-7788', 'Student', 'Computer Science', 'Active'),
('U009', 'Ivy Green', 'ivy.g@example.edu', '445-667-8899', 'Facility Staff', 'Facilities Management', 'Active'),
('U010', 'Jack Black', 'jack.b@example.edu', '556-778-9900', 'Student', 'Computer Science', 'Inactive');

INSERT INTO Spaces (SpaceCode, SpaceName, SpaceType, Building, Floor, RoomNumber, Capacity, CurrentStatus, UsagePolicy) VALUES
('AUD01', 'Main Auditorium', 'Auditorium', 'Main Building', 1, '101', 300, 'Available', 'Large events, lectures, examinations.'),
('CML01', 'Computer Lab 1', 'Computer Laboratory', 'Science Block', 2, '201', 40, 'Available', 'Computer-based classes, workshops.'),
('CML02', 'Computer Lab 2', 'Computer Laboratory', 'Science Block', 2, '202', 30, 'Under Maintenance', 'Computer-based classes, workshops.'),
('CR001', 'Classroom 1A', 'Classroom', 'Main Building', 2, '203', 50, 'Available', 'Lectures, seminars.'),
('CR002', 'Classroom 1B', 'Classroom', 'Main Building', 2, '204', 25, 'Available', 'Small lectures, meetings.'),
('MTG01', 'Meeting Room A', 'Meeting Room', 'Admin Block', 3, '301', 10, 'Available', 'Staff meetings, project discussions.'),
('PRJ01', 'Project Lab 1', 'Project Laboratory', 'Innovation Hub', 1, '105', 20, 'Available', 'Student projects, group work.'),
('STW01', 'Student Workspace 1', 'Student Workspace', 'Library Annex', 1, '102', 15, 'Available', 'Individual/group study.');

INSERT INTO Facilities (FacilityName, Description) VALUES
('Projector', 'High-definition projector for presentations.'),
('Whiteboard', 'Large magnetic whiteboard with markers.'),
('Microphone', 'Wireless microphone system.'),
('Computer', 'Desktop computer with standard software.'),
('Livestreaming Equipment', 'Cameras and encoders for live streaming.'),
('Air Conditioner', 'Climate control system.'),
('Smart Board', 'Interactive smart board.'),
('Sound System', 'Integrated sound system.');

INSERT INTO SpaceFacilities (SpaceCode, FacilityID) VALUES
('AUD01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Projector')),
('AUD01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Microphone')),
('AUD01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Sound System')),
('AUD01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Air Conditioner')),
('CML01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Projector')),
('CML01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Computer')),
('CML01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Whiteboard')),
('CML02', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Projector')),
('CML02', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Computer')),
('CR001', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Projector')),
('CR001', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Whiteboard')),
('CR002', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Smart Board')),
('MTG01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Projector')),
('MTG01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Whiteboard')),
('PRJ01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Whiteboard')),
('STW01', (SELECT FacilityID FROM Facilities WHERE FacilityName = 'Whiteboard'));

INSERT INTO Bookings (RequesterID, SpaceCode, RequestedStartTime, RequestedEndTime, PurposeOfUse, ExpectedParticipants, BookingStatus) VALUES
-- Approved bookings
('U001', 'CR001', '2024-03-10 09:00:00', '2024-03-10 11:00:00', 'Lecture', 45, 'Approved'), -- B001
('U002', 'CML01', '2024-03-10 13:00:00', '2024-03-10 15:00:00', 'Student Activity', 30, 'Approved'), -- B002
('U007', 'AUD01', '2024-03-15 10:00:00', '2024-03-15 12:00:00', 'Seminar', 200, 'Approved'), -- B003
('U001', 'CR001', '2024-03-11 14:00:00', '2024-03-11 16:00:00', 'Lecture', 40, 'Approved'), -- B004
('U005', 'CR002', '2024-03-12 10:00:00', '2024-03-12 11:30:00', 'Workshop', 20, 'Approved'), -- B005
('U006', 'MTG01', '2024-03-13 09:00:00', '2024-03-13 10:00:00', 'Administrative Event', 8, 'Approved'), -- B006
('U008', 'PRJ01', '2024-03-14 10:00:00', '2024-03-14 12:00:00', 'Student Activity', 15, 'Approved'), -- B007

-- Pending bookings
('U002', 'CR001', '2024-03-10 11:00:00', '2024-03-10 12:00:00', 'Student Activity', 20, 'Pending'), -- B008
('U001', 'CR001', '2024-03-10 09:30:00', '2024-03-10 10:30:00', 'Meeting', 5, 'Pending'), -- B009 (Conflicting with B001)
('U008', 'CML02', '2024-03-16 10:00:00', '2024-03-16 12:00:00', 'Workshop', 25, 'Pending'), -- B010 (Space CML02 is under maintenance)

-- Rejected bookings
('U002', 'CR001', '2024-03-09 10:00:00', '2024-03-09 12:00:00', 'Student Activity', 30, 'Rejected'), -- B011
('U001', 'CML02', '2024-03-10 10:00:00', '2024-03-10 12:00:00', 'Lecture', 35, 'Rejected'), -- B012 (Rejected due to maintenance)

-- Cancelled bookings
('U007', 'CR001', '2024-03-17 09:00:00', '2024-03-17 11:00:00', 'Lecture', 40, 'Cancelled'), -- B013

-- Checked-in bookings (past)
('U001', 'CR001', '2024-03-05 09:00:00', '2024-03-05 11:00:00', 'Lecture', 45, 'Checked In'), -- B014

-- Completed bookings (past)
('U001', 'CR001', '2024-03-01 09:00:00', '2024-03-01 11:00:00', 'Lecture', 45, 'Completed'), -- B015
('U002', 'CML01', '2024-03-02 13:00:00', '2024-03-02 15:00:00', 'Student Activity', 30, 'Completed'), -- B016

-- No-show bookings (past)
('U005', 'CR002', '2024-03-03 10:00:00', '2024-03-03 11:30:00', 'Workshop', 20, 'No-Show'); -- B017

INSERT INTO BookingApprovals (BookingID, ApproverID, DecisionTime, DecisionStatus, DecisionNote, RejectionReason) VALUES
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-10 09:00:00'), 'U003', '2024-03-08 10:00:00', 'Approved', 'Standard lecture booking.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U002' AND RequestedStartTime = '2024-03-10 13:00:00'), 'U003', '2024-03-08 10:15:00', 'Approved', 'Student activity approved.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U007' AND RequestedStartTime = '2024-03-15 10:00:00'), 'U004', '2024-03-09 09:00:00', 'Approved', 'Large seminar approved by manager.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-11 14:00:00'), 'U003', '2024-03-09 11:00:00', 'Approved', 'Lecture series.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U005' AND RequestedStartTime = '2024-03-12 10:00:00'), 'U003', '2024-03-10 09:00:00', 'Approved', 'TA workshop.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U006' AND RequestedStartTime = '2024-03-13 09:00:00'), 'U004', '2024-03-11 10:00:00', 'Approved', 'Department meeting.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U008' AND RequestedStartTime = '2024-03-14 10:00:00'), 'U003', '2024-03-12 11:00:00', 'Approved', 'Student project work.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U002' AND RequestedStartTime = '2024-03-09 10:00:00'), 'U003', '2024-03-07 15:00:00', 'Rejected', 'Space not available at requested time.', 'Conflict with existing booking.'),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-10 10:00:00'), 'U003', '2024-03-08 16:00:00', 'Rejected', 'Space under maintenance.', 'Space CML02 is currently under maintenance.'),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-05 09:00:00'), 'U003', '2024-03-04 10:00:00', 'Approved', 'Lecture.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-01 09:00:00'), 'U003', '2024-02-28 10:00:00', 'Approved', 'Lecture.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U002' AND RequestedStartTime = '2024-03-02 13:00:00'), 'U003', '2024-02-29 10:15:00', 'Approved', 'Student activity.', NULL),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U005' AND RequestedStartTime = '2024-03-03 10:00:00'), 'U003', '2024-03-02 09:00:00', 'Approved', 'Workshop.', NULL);


INSERT INTO BookingCheckIns (BookingID, CheckInTime, CheckInStaffID, InitialConditionNotes) VALUES
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-05 09:00:00'), '2024-03-05 08:55:00', 'U003', 'Room clean, projector working.'),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-01 09:00:00'), '2024-03-01 08:50:00', 'U003', 'Room in good condition.'),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U002' AND RequestedStartTime = '2024-03-02 13:00:00'), '2024-03-02 12:58:00', 'U009', 'All computers functional.'),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-10 09:00:00'), '2024-03-10 08:58:00', 'U003', 'Room ready, A/C on.');


INSERT INTO BookingCompletions (BookingID, CompletionTime, FinalConditionNotes, UsageNotes) VALUES
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U001' AND RequestedStartTime = '2024-03-01 09:00:00'), '2024-03-01 11:05:00', 'Room left tidy, no issues.', 'Successful lecture.'),
((SELECT BookingID FROM Bookings WHERE RequesterID = 'U002' AND RequestedStartTime = '2024-03-02 13:00:00'), '2024-03-02 15:00:00', 'Some chairs moved, otherwise clean.', 'Group project work, no incidents.');

INSERT INTO MaintenanceRecords (SpaceCode, ReporterID, AssignedStaffID, ProblemDescription, ReportedTime, ScheduledStartTime, CompletionTime, Status, ResultNote) VALUES
('CML02', 'U001', 'U003', 'Projector lamp broken.', '2024-03-07 10:00:00', '2024-03-08 09:00:00', NULL, 'In Progress', 'Waiting for replacement part.'),
('CR001', 'U005', 'U009', 'Whiteboard markers missing.', '2024-03-06 14:30:00', '2024-03-06 15:00:00', '2024-03-06 15:15:00', 'Completed', 'Markers replenished.'),
('AUD01', 'U007', 'U003', 'Microphone static noise.', '2024-03-12 09:00:00', '2024-03-13 10:00:00', NULL, 'Pending', 'Scheduled for inspection.'),
('CML01', 'U002', 'U009', 'One computer not booting.', '2024-03-09 11:00:00', '2024-03-09 13:00:00', '2024-03-09 14:30:00', 'Completed', 'Replaced faulty RAM module.');