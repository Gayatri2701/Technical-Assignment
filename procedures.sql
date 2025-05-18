DELIMITER $$

CREATE PROCEDURE FilterEmployees(
    IN p_RoleID INT,
    IN p_LocationID INT,
    IN p_IncludeInactive BOOLEAN
)
BEGIN
    SELECT 
        E.EmployeeName,
        R.RoleTitle,
        L.LocationName,
        C.CurrentComp
    FROM 
        Employee E
        JOIN Role R ON E.RoleID = R.RoleID
        JOIN Location L ON E.LocationID = L.LocationID
        JOIN Compensation C ON E.EmployeeID = C.EmployeeID
    WHERE 
        (p_RoleID IS NULL OR E.RoleID = p_RoleID)
        AND (p_LocationID IS NULL OR E.LocationID = p_LocationID)
        AND (p_IncludeInactive OR E.IsActive = 'Y');
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE CalculateAverageCompensation()
BEGIN
    SELECT 
        L.LocationName,
        ROUND(AVG(C.CurrentComp), 2) AS AvgCompensation
    FROM 
        Employee E
        JOIN Location L ON E.LocationID = L.LocationID
        JOIN Compensation C ON E.EmployeeID = C.EmployeeID
    GROUP BY 
        L.LocationName;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ApplyIncrement(
    IN p_Percent DECIMAL(5,2)
)
BEGIN
    UPDATE Compensation
    SET 
        CurrentComp = ROUND(CurrentComp * (1 + p_Percent / 100), 2),
        Bonus = ROUND((CurrentComp * 0.10), 2),
        StockUnits = ROUND((CurrentComp * 0.12), 2),
        TotalComp = ROUND(CurrentComp + (CurrentComp * 0.10) + (CurrentComp * 0.12), 2);
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE GetFilteredData()
BEGIN
    SELECT 
        E.EmployeeName AS Name,
        R.RoleTitle AS Role,
        L.LocationName AS Location,
        E.ExperienceRange AS Experience,
        C.CurrentComp AS Compensation,
        E.IsActive AS Status
    FROM 
        Employee E
        JOIN Role R ON E.RoleID = R.RoleID
        JOIN Location L ON E.LocationID = L.LocationID
        JOIN Compensation C ON E.EmployeeID = C.EmployeeID;
END$$

DELIMITER ;
