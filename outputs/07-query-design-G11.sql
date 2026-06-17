-- Query 1: Retrieve upcoming approved bookings for a specific space.
-- Business Question: What are the upcoming approved bookings for 'Auditorium A'?
-- Target User(s): Facility Staff, Department Administrator, Users.
-- Usefulness: Helps facility staff manage space schedules, informs users about future availability, and prevents manual booking conflicts.
SELECT
    B.BookingID,
    S.SpaceName,
    S.SpaceCode,
    B.RequestedStartTime,
    B.RequestedEndTime,
    B.Purpose,
    U.FullName AS RequesterName,
    U.Email AS RequesterEmail
FROM
    Bookings AS B
JOIN
    Spaces AS S ON B.SpaceID = S.SpaceID
JOIN
    Users AS U ON B.RequesterUserID = U.UserID
WHERE
    S.SpaceName = 'Auditorium A'
    AND B.BookingStatus = 'approved'
    AND B.RequestedEndTime > GETDATE() -- For SQL Server, use NOW() for MySQL/PostgreSQL
ORDER BY
    B.RequestedStartTime;

-- Query 2: List all spaces that are currently under active maintenance.
-- Business Question: Which spaces are currently under active maintenance?
-- Target User(s): Facility Staff, Facility Manager.
-- Usefulness: Essential for operational awareness, preventing booking of unavailable spaces, and prioritizing maintenance tasks.
SELECT
    S.SpaceCode,
    S.SpaceName,
    S.Building,
    S.Floor,
    S.RoomNumber,
    MR.ProblemDescription,
    MR.StartTime AS MaintenanceStartTime,
    U_Reporter.FullName AS ReporterName,
    U_Assigned.FullName AS AssignedStaffName
FROM
    Spaces AS S
JOIN
    MaintenanceRecords AS MR ON S.SpaceID = MR.SpaceID
JOIN
    Users AS U_Reporter ON MR.ReporterUserID = U_Reporter.UserID
LEFT JOIN
    Users AS U_Assigned ON MR.AssignedStaffID = U_Assigned.UserID
WHERE
    MR.Status IN ('pending', 'in progress')
ORDER BY
    S.SpaceCode;

-- Query 3: Show all completed bookings made by a specific user, including their role.
-- Business Question: Show all completed bookings made by 'Alice Smith' (UserID: 101) and her role.
-- Target User(s): User, Department Administrator, Facility Manager.
-- Usefulness: Allows users to review their past activities, helps administrators track usage patterns by individuals, and supports auditing.
SELECT
    B.BookingID,
    S.SpaceName,
    S.SpaceCode,
    B.Purpose,
    B.ActualStartTime,
    B.ActualEndTime,
    U.FullName AS RequesterName,
    U.Role AS RequesterRole,
    B.BookingStatus
FROM
    Bookings AS B
JOIN
    Spaces AS S ON B.SpaceID = S.SpaceID
JOIN
    Users AS U ON B.RequesterUserID = U.UserID
WHERE
    U.FullName = 'Alice Smith' -- Assuming UserID 101 corresponds to Alice Smith
    AND B.BookingStatus = 'completed'
ORDER BY
    B.ActualStartTime DESC;

-- Query 4: List all spaces that have both a 'Projector' and 'Livestreaming Equipment'.
-- Business Question: Which spaces are equipped with both a projector and livestreaming equipment?
-- Target User(s): Lecturers, Event Organizers, Facility Staff.
-- Usefulness: Helps users find suitable spaces for specific technical requirements, aids facility planning and resource allocation.
SELECT
    S.SpaceCode,
    S.SpaceName,
    S.SpaceType,
    S.Capacity,
    S.Building,
    S.Floor
FROM
    Spaces AS S
JOIN
    SpaceFacilities AS SF1 ON S.SpaceID = SF1.SpaceID
JOIN
    Facilities AS F1 ON SF1.FacilityID = F1.FacilityID
JOIN
    SpaceFacilities AS SF2 ON S.SpaceID = SF2.SpaceID
JOIN
    Facilities AS F2 ON SF2.FacilityID = F2.FacilityID
WHERE
    F1.FacilityName = 'Projector'
    AND F2.FacilityName = 'Livestreaming Equipment'
GROUP BY
    S.SpaceID, S.SpaceCode, S.SpaceName, S.SpaceType, S.Capacity, S.Building, S.Floor
HAVING
    COUNT(DISTINCT F1.FacilityID) = 1 AND COUNT(DISTINCT F2.FacilityID) = 1; -- Ensure both distinct facilities are present

-- Query 5: Identify 'no-show' bookings for the last 30 days, including the space and requester details.
-- Business Question: List all bookings that were marked as 'no-show' in the past 30 days, including the space and requester details.
-- Target User(s): Facility Manager, Department Administrator.
-- Usefulness: Helps identify patterns of non-compliance, allows for policy adjustments, and improves space utilization by potentially freeing up slots.
SELECT
    B.BookingID,
    S.SpaceCode,
    S.SpaceName,
    B.RequestedStartTime,
    B.RequestedEndTime,
    U.FullName AS RequesterName,
    U.Email AS RequesterEmail,
    B.Purpose
FROM
    Bookings AS B
JOIN
    Spaces AS S ON B.SpaceID = S.SpaceID
JOIN
    Users AS U ON B.RequesterUserID = U.UserID
WHERE
    B.BookingStatus = 'no-show'
    AND B.RequestedStartTime >= DATEADD(day, -30, GETDATE()) -- For SQL Server, use NOW() - INTERVAL '30 days' for PostgreSQL/MySQL
ORDER BY
    B.RequestedStartTime DESC;