CREATE DATABASE [Service]
GO
USE [Service]
GO
--1-DDL
CREATE TABLE Users
(
Id INT PRIMARY KEY IDENTITY,
Username NVARCHAR(30) UNIQUE NOT NULL,
[Password] NVARCHAR(50) NOT NULL,
[Name] NVARCHAR(50),
Birthdate DATETIME2,
Age INT CHECK (Age>=14 AND Age <= 110),
Email NVARCHAR(50) NOT NULL
)
GO
CREATE TABLE Departments
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL
)
GO
CREATE TABLE Employees
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25),
LastName NVARCHAR(25),
Birthdate DATETIME2,
Age INT CHECK(Age >= 18 AND Age <= 110),
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)
GO
CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)
GO
CREATE TABLE [Status]
(
Id INT PRIMARY KEY IDENTITY,
Label NVARCHAR(30) NOT NULL
)
GO
CREATE TABLE Reports
(
Id INT PRIMARY KEY IDENTITY,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
OpenDate DATETIME2 NOT NULL,
CloseDate DATETIME2,
[Description] NVARCHAR(200) NOT NULL,
UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)
GO

--2-Insert
INSERT INTO Employees (FirstName, LastName, Birthdate, DepartmentId) VALUES
('Marlo', 'O''Malley', '1958-9-21', 1),
('Niki', 'Stanaghan', '1969-11-26', 4),
('Ayrton', 'Senna', '1960-03-21', 9),
('Ronnie', 'Peterson', '1944-02-14', 9),
('Giovanna', 'Amati', '1959-07-20', 5)

INSERT INTO Reports (CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId) VALUES
(1,1,'2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2),
(6,3,'2015-09-05', '2015-12-06', 'Charity trail running', 3, 5),
(14,2,'2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2),
(4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1)

--3-Update
UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

--4-Delete
DELETE Reports
WHERE StatusId = 4

--5-Unassigned Reports 
SELECT Description, FORMAT(OpenDate, 'dd-MM-yyyy') AS OpenDate
FROM Reports r
WHERE EmployeeId IS NULL
ORDER BY r.OpenDate, Description

--6-Reports & Categories
SELECT Description, c.Name AS CategoryName
FROM Reports r
INNER JOIN Categories c ON r.CategoryId = c.Id
ORDER BY Description, CategoryName

--7-Most Reported Category
SELECT TOP(5) c.Name AS CategoryName, COUNT(r.Id) AS ReportsNumber
FROM Reports r
INNER JOIN Categories c ON r.CategoryId = c.Id
GROUP BY c.Name
ORDER BY ReportsNumber DESC, CategoryName

--8-Birthday Report
SELECT u.Username, c.Name AS CategoryName
FROM Reports r
INNER JOIN Users u ON r.UserId = u.Id
INNER JOIN Categories c ON r.CategoryId = c.Id
WHERE FORMAT(r.OpenDate, 'dd-MM') = FORMAT (u.Birthdate, 'dd-MM')
ORDER BY Username, CategoryName

--9-Users per Employee 
SELECT FirstName + ' ' + LastName AS [Full Name], COUNT(u.Id) AS UsersCount
FROM Employees e
LEFT OUTER JOIN Reports r ON r.EmployeeId = e.Id
LEFT OUTER JOIN Users u ON r.UserId = u.Id
GROUP BY FirstName + ' ' + LastName
ORDER BY UsersCount DESC, [Full Name]

--10-Full Info
SELECT ISNULL(FirstName + ' ' + LastName, 'None') AS Employee, ISNULL(d.[Name], 'None') AS Department, c.[Name] AS Category, r.[Description] AS [Description], FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate, s.Label AS [Status], ISNULL(u.[Name], 'None') AS [User]
FROM Reports r
LEFT OUTER JOIN Employees e ON r.EmployeeId = e.Id
LEFT OUTER JOIN Categories c ON r.CategoryId = c.Id
LEFT OUTER JOIN Users u ON r.UserId = u.Id
LEFT OUTER  JOIN Departments d ON e.DepartmentId = d.Id
LEFT OUTER JOIN [Status] s ON r.StatusId = s.Id
ORDER BY e.FirstName DESC, e.LastName DESC, Department ASC, Category ASC , [Description] ASC, r.OpenDate, [Status] ASC, [User] ASC

--11-Hours to Complete
CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN
	IF(@StartDate IS NULL OR @EndDate IS NULL)
	BEGIN
		RETURN 0
	END
	DECLARE @result INT
	SET @result = DATEDIFF(HOUR,@StartDate, @EndDate)
	RETURN @result
END

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
FROM Reports

--12-Assign Employee
CREATE PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
	DECLARE @employeeDepartmentId INT = (SELECT DepartmentId FROM Employees WHERE Id = @EmployeeId)
	DECLARE @reportDepartmentId INT = (SELECT c.DepartmentId FROM Reports r INNER JOIN Categories c ON r.CategoryId = c.Id WHERE r.Id = @ReportId)

	IF(@employeeDepartmentId <> @reportDepartmentId)
	BEGIN
		RAISERROR('Employee doesn''t belong to the appropriate department!',16,1)
		RETURN
	END

	UPDATE Reports
	SET EmployeeId = @EmployeeId
	WHERE Id = @ReportId

EXEC usp_AssignEmployeeToReport 1,1
