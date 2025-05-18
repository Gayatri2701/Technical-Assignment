-- Create Database
CREATE DATABASE EmployeeDB;
USE EmployeeDB;


CREATE TABLE StagingEmployee (
    Name VARCHAR(100),
    Role VARCHAR(100),
    Location VARCHAR(100),
    ExperienceRange VARCHAR(20),
    IsActive CHAR(1),
    CurrentComp DECIMAL(15,2),
    LastWorkingDay DATE,
    TurnoverStatus VARCHAR(100),
    IndustryComp DECIMAL(15,2),
    CompDiff DECIMAL(15,2),
    Bonus DECIMAL(15,2),
    StockUnits DECIMAL(15,2),
    TotalComp DECIMAL(15,2)
);


LOAD DATA LOCAL INFILE 'C:/Users/USER/EmployeeData.csv'
INTO TABLE StagingEmployee
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
