-- Location Table
CREATE TABLE Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    LocationName VARCHAR(100) UNIQUE NOT NULL
);

-- Role Table
CREATE TABLE Role (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    RoleTitle VARCHAR(100) UNIQUE NOT NULL
);

-- Turnover Status Table
CREATE TABLE TurnoverStatus (
    StatusID INT PRIMARY KEY AUTO_INCREMENT,
    StatusName VARCHAR(100) UNIQUE NOT NULL
);

-- Employee Table
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeName VARCHAR(100) NOT NULL,
    RoleID INT,
    LocationID INT,
    ExperienceRange VARCHAR(20),
    IsActive CHAR(1),
    LastWorkingDay DATE,
    StatusID INT,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID),
    FOREIGN KEY (StatusID) REFERENCES TurnoverStatus(StatusID)
);

-- Compensation Table
CREATE TABLE Compensation (
    CompID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    CurrentComp DECIMAL(15,2),
    IndustryComp DECIMAL(15,2),
    CompDifference DECIMAL(15,2),
    Bonus DECIMAL(15,2),
    StockUnits DECIMAL(15,2),
    TotalComp DECIMAL(15,2),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);



-- Insert unique Roles
INSERT IGNORE INTO Role (RoleTitle)
SELECT DISTINCT Role FROM StagingEmployee;

-- Insert unique Locations
INSERT IGNORE INTO Location (LocationName)
SELECT DISTINCT Location FROM StagingEmployee;

-- Insert unique Turnover Statuses
INSERT IGNORE INTO TurnoverStatus (StatusName)
SELECT DISTINCT TurnoverStatus FROM StagingEmployee;

-- Insert into Employee table
INSERT INTO Employee (
    EmployeeName, RoleID, LocationID, ExperienceRange, IsActive, LastWorkingDay, StatusID
)
SELECT
    S.Name,
    R.RoleID,
    L.LocationID,
    S.ExperienceRange,
    S.IsActive,
    S.LastWorkingDay,
    T.StatusID
FROM StagingEmployee S
JOIN Role R ON S.Role = R.RoleTitle
JOIN Location L ON S.Location = L.LocationName
JOIN TurnoverStatus T ON S.TurnoverStatus = T.StatusName;

-- Insert into Compensation table
INSERT INTO Compensation (
    EmployeeID, CurrentComp, IndustryComp, CompDifference, Bonus, StockUnits, TotalComp
)
SELECT
    E.EmployeeID,
    S.CurrentComp,
    S.IndustryComp,
    S.CompDiff,
    S.Bonus,
    S.StockUnits,
    S.TotalComp
FROM StagingEmployee S
JOIN Employee E ON S.Name = E.EmployeeName;
