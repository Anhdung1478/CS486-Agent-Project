CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20),
    Role VARCHAR(50) NOT NULL CHECK (Role IN ('Student', 'Lecturer', 'Teaching Assistant', 'Facility Staff', 'Department Administrator', 'Facility Manager')),
    Department VARCHAR(100),
    AccountStatus VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (AccountStatus IN ('Active', 'Inactive', 'Suspended'))
);

CREATE TABLE Spaces (
    SpaceCode VARCHAR(50) PRIMARY KEY,
    SpaceName VARCHAR(255) NOT NULL,
    SpaceType VARCHAR(50) NOT NULL CHECK (SpaceType IN ('Auditorium', 'Classroom', 'Computer Laboratory', 'Project Laboratory', 'Meeting Room', 'Student Workspace')),
    Building VARCHAR(100) NOT NULL,
    Floor INT NOT NULL,
    RoomNumber VARCHAR(50) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    CurrentStatus VARCHAR(50) NOT NULL DEFAULT 'Available' CHECK (CurrentStatus IN ('Available', 'In Use', 'Under Maintenance', 'Temporarily Closed', 'Retired')),
    UsagePolicy TEXT
);

CREATE TABLE Facilities (
    FacilityID INT IDENTITY(1,1) PRIMARY KEY,
    FacilityName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE SpaceFacilities (
    SpaceCode VARCHAR(50) NOT NULL,
    FacilityID INT NOT NULL,
    PRIMARY KEY (SpaceCode, FacilityID),
    FOREIGN KEY (SpaceCode) REFERENCES Spaces(SpaceCode),
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID)
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    RequesterID INT NOT NULL,
    SpaceCode VARCHAR(50) NOT NULL,
    RequestedStartTime DATETIME NOT NULL,
    RequestedEndTime DATETIME NOT NULL,
    PurposeOfUse VARCHAR(255) NOT NULL CHECK (PurposeOfUse IN ('Lecture', 'Examination', 'Seminar', 'Workshop', 'Meeting', 'Student Activity', 'Administrative Event')),
    ExpectedParticipants INT NOT NULL CHECK (ExpectedParticipants > 0),
    BookingStatus VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (BookingStatus IN ('Pending', 'Approved', 'Rejected', 'Cancelled', 'Checked In', 'Completed', 'No-Show')),
    ApprovalStaffID INT,
    DecisionTime DATETIME,
    DecisionNote TEXT,
    RejectionReason TEXT,
    ActualStartTime DATETIME,
    CheckInStaffID INT,
    InitialCondition TEXT,
    ActualEndTime DATETIME,
    FinalCondition TEXT,
    UsageNotes TEXT,
    FOREIGN KEY (RequesterID) REFERENCES Users(UserID),
    FOREIGN KEY (SpaceCode) REFERENCES Spaces(SpaceCode),
    FOREIGN KEY (ApprovalStaffID) REFERENCES Users(UserID),
    FOREIGN KEY (CheckInStaffID) REFERENCES Users(UserID),
    CONSTRAINT CHK_BookingTimes CHECK (RequestedEndTime > RequestedStartTime),
    CONSTRAINT CHK_ActualBookingTimes CHECK (ActualEndTime IS NULL OR ActualEndTime > ActualStartTime)
);

CREATE TABLE MaintenanceRecords (
    MaintenanceID INT IDENTITY(1,1) PRIMARY KEY,
    SpaceCode VARCHAR(50) NOT NULL,
    ReporterID INT NOT NULL,
    AssignedStaffID INT,
    ProblemDescription TEXT NOT NULL,
    ReportedTime DATETIME NOT NULL DEFAULT GETDATE(),
    CompletionTime DATETIME,
    MaintenanceStatus VARCHAR(50) NOT NULL DEFAULT 'Reported' CHECK (MaintenanceStatus IN ('Reported', 'In Progress', 'Completed', 'Cancelled')),
    ResultNote TEXT,
    FOREIGN KEY (SpaceCode) REFERENCES Spaces(SpaceCode),
    FOREIGN KEY (ReporterID) REFERENCES Users(UserID),
    FOREIGN KEY (AssignedStaffID) REFERENCES Users(UserID),
    CONSTRAINT CHK_MaintenanceCompletionTime CHECK (CompletionTime IS NULL OR CompletionTime >= ReportedTime)
);