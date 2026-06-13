```sql
-- 07-query-design-GXX.sql

-- Query 1: Find available spaces for a specific time range and type
-- Business Question: Which 'Classroom' spaces are available between '2023-10-26 09:00:00' and '2023-10-26 11:00:00'?
-- Target User(s): Lecturers, Students, Teaching Assistants, Staff
-- Explanation of Utility: This query allows users to quickly identify spaces of a specific type that are free for booking within a desired time window. It considers existing approved/checked-in bookings and ongoing maintenance, helping prevent booking conflicts and streamlining the space reservation process.
SELECT
    s.SpaceID,
    s.SpaceName,
    s.Building,
    s.Floor,
    s.RoomNumber,
    s.Capacity
FROM
    Spaces s
WHERE
    s.SpaceType = 'Classroom'
    AND s.CurrentStatus NOT IN ('Temporarily Closed', 'Retired') -- 'Under Maintenance' is handled by the NOT EXISTS clause
    AND NOT EXISTS (
        -- Check for conflicting approved/checked-in bookings
        SELECT 1
        FROM Bookings b
        WHERE
            b.SpaceID = s.SpaceID
            AND b.BookingStatus IN ('Approved', 'Checked In')
            AND (
                ('2023-10-26 09:00:00' < b.RequestedEndTime AND '2023-10-26 11:00:00' > b.RequestedStartTime)
            )
    )
    AND NOT EXISTS (
        -- Check for ongoing maintenance during the requested time
        SELECT 1
        FROM MaintenanceRecords mr
        WHERE
            mr.SpaceID = s.SpaceID
            AND mr.Status IN ('Pending', 'In Progress')
            AND (
                ('2023-10-26 09:00:00' < COALESCE(mr.CompletionTime, '9999-12-31 23:59:59')) -- If CompletionTime is NULL, assume ongoing indefinitely
                AND ('2023-10-26 11:00:00' > mr.StartTime)
            )
    )
ORDER BY
    s.SpaceName;

-- Query 2: List all approved bookings for a specific space in the next month
-- Business Question: What are the approved bookings for 'Auditorium A' in the next 30 days?
-- Target User(s): Facility Staff, Facility Manager
-- Explanation of Utility: This query helps facility staff and managers to view the upcoming schedule for a particular space, allowing them to plan for setup, cleaning, or any other necessary preparations. It also helps in identifying potential scheduling conflicts or high-demand periods.
SELECT
    b.BookingID,
    s.SpaceName,
    b.RequestedStartTime,
    b.RequestedEndTime,
    b.Purpose,
    b.ExpectedParticipants,
    u.FullName AS RequesterName,
    u.Department AS RequesterDepartment
FROM
    Bookings b
JOIN
    Spaces s ON b.SpaceID = s.SpaceID
JOIN
    Users u ON b.RequesterUserID = u.UserID
WHERE
    s.SpaceName = 'Auditorium A'
    AND b.BookingStatus = 'Approved'
    AND b.RequestedStartTime >= CURRENT_TIMESTAMP
    AND b.RequestedStartTime < CURRENT_TIMESTAMP + INTERVAL '30 days'
ORDER BY
    b.RequestedStartTime;

-- Query 3: Identify spaces currently under maintenance
-- Business Question: Which spaces are currently under active maintenance, and what are the details?
-- Target User(s): Facility Staff, Facility Manager
-- Explanation of Utility: This query provides a real-time overview of all spaces that are currently undergoing maintenance. It helps facility staff prioritize tasks, inform users about unavailable spaces, and track the progress of repairs.
SELECT
    mr.MaintenanceID,
    s.SpaceName,
    s.Building,
    s.RoomNumber,
    mr.ProblemDescription,
    mr.StartTime AS MaintenanceStartTime,
    mr.Status,
    r.FullName AS ReporterName,
    a.FullName AS AssignedStaffName
FROM
    MaintenanceRecords mr
JOIN
    Spaces s ON mr.SpaceID = s.SpaceID
LEFT JOIN
    Users r ON mr.ReporterUserID = r.UserID
LEFT JOIN
    Users a ON mr.AssignedStaffID = a.UserID
WHERE
    mr.Status IN ('Pending', 'In Progress')
ORDER BY
    mr.StartTime;

-- Query 4: Get the booking history for a specific user
-- Business Question: Show all past bookings made by 'John Doe' (UserID: 'U001').
-- Target User(s): Individual Users, Department Administrators, Facility Staff
-- Explanation of Utility: This query enables a user to review their own past bookings, including details about the space, purpose, and outcome. For administrators, it provides an audit trail of a user's space utilization, which can be useful for reporting or resolving issues.
SELECT
    b.BookingID,
    s.SpaceName,
    s.SpaceType,
    b.RequestedStartTime,
    b.RequestedEndTime,
    b.Purpose,
    b.BookingStatus,
    ba.DecisionTime,
    ba.DecisionNote
FROM
    Bookings b
JOIN
    Spaces s ON b.SpaceID = s.SpaceID
LEFT JOIN
    BookingApprovals ba ON b.BookingID = ba.BookingID -- Use LEFT JOIN as not all bookings may have explicit approval records
WHERE
    b.RequesterUserID = 'U001' -- Example UserID for John Doe
    AND b.RequestedEndTime < CURRENT_TIMESTAMP -- Filter for past bookings
ORDER BY
    b.RequestedStartTime DESC;

-- Query 5: Calculate the utilization rate of a space type over a period
-- Business Question: What is the total booked time for 'Computer Laboratory' spaces in October 2023, and what is their average utilization rate?
-- Target User(s): Facility Manager, Department Administrator
-- Explanation of Utility: This query provides valuable insights into the usage patterns of different space types. Facility managers can use this information to assess demand, optimize scheduling, identify underutilized resources, or justify the need for more spaces.
WITH SpaceTypeBookings AS (
    SELECT
        s.SpaceID,
        s.SpaceName,
        b.RequestedStartTime,
        b.RequestedEndTime,
        EXTRACT(EPOCH FROM (b.RequestedEndTime - b.RequestedStartTime)) / 3600 AS BookedHours -- Duration in hours
    FROM
        Bookings b
    JOIN
        Spaces s ON b.SpaceID = s.SpaceID
    WHERE
        s.SpaceType = 'Computer Laboratory'
        AND b.BookingStatus IN ('Approved', 'Checked In', 'Completed') -- Only count actual usage/approved bookings
        AND b.RequestedStartTime >= '22023-10-01 00:00:00'
        AND b.RequestedEndTime < '2023-11-01 00:00:00'
),
TotalAvailableHours AS (
    SELECT
        COUNT(DISTINCT SpaceID) AS NumberOfSpaces,
        -- Assuming 12 hours/day operational for 31 days in October
        (31 * 12) AS TotalHoursPerSpace -- Example: 12 hours operational per day for the month
    FROM
        Spaces
    WHERE
        SpaceType = 'Computer Laboratory'
)
SELECT
    'Computer Laboratory' AS SpaceType,
    SUM(stb.BookedHours) AS TotalBookedHours,
    (SUM(stb.BookedHours) / (TAH.NumberOfSpaces * TAH.TotalHoursPerSpace)) * 100 AS UtilizationRatePercentage
FROM
    SpaceTypeBookings stb,
    TotalAvailableHours TAH
GROUP BY
    'Computer Laboratory', TAH.NumberOfSpaces, TAH.TotalHoursPerSpace;
```