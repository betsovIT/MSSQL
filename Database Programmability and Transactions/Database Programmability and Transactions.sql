USE SoftUni
GO
--1-Employees with Salary Above 35000
CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
SELECT FirstName, LastName
FROM Employees
WHERE Salary > 35000;
GO
EXEC usp_GetEmployeesSalaryAbove35000
--2-Employees with Salary Above Number
CREATE PROC usp_GetEmployeesSalaryAboveNumber(@tresholdNumber DECIMAL(18,4)) AS
SELECT FirstName, LastName
FROM Employees
WHERE Salary >= @tresholdNumber;
GO
EXEC usp_GetEmployeesSalaryAboveNumber 48100
--3-Town Names Starting With
CREATE PROC usp_GetTownsStartingWith(@startingLetter NVARCHAR(50)) AS
SELECT [Name]
FROM Towns
WHERE [Name] LIKE @startingLetter + '%'
GO
EXEC usp_GetTownsStartingWith 'b'
--4-Employees from Town
CREATE PROC usp_GetEmployeesFromTown(@town NVARCHAR(50)) AS
SELECT FirstName, LastName
FROM Employees e
INNER JOIN Addresses a ON e.AddressID = a.AddressID
INNER JOIN Towns t ON a.TownID = t.TownID
WHERE t.Name = @town
GO
EXEC usp_GetEmployeesFromTown 'Sofia'
--5-Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS NVARCHAR(20) AS
BEGIN
	DECLARE @result NVARCHAR(20)
	IF(@salary < 30000)
	BEGIN
		SET @result = 'Low'
	END
	ELSE IF(@salary >= 30000 AND @salary <= 50000)
	BEGIN
		SET @result = 'Average'
	END
	ELSE
	BEGIN
		SET @result = 'High'
	END
	RETURN @result
END
--6-Employees by Salary Level 
CREATE PROC usp_EmployeesBySalaryLevel(@SalaryLevel NVARCHAR(20)) AS
SELECT FirstName, LastName
FROM Employees
WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel
GO
EXEC usp_EmployeesBySalaryLevel 'High'
--7-Define Function
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(50), @word NVARCHAR(50))
RETURNS BIT AS
BEGIN
	DECLARE @result BIT
	DECLARE @count INT = 1

	WHILE @count <= LEN(@word)
	BEGIN
		DECLARE @currentSymbol VARCHAR(2) = SUBSTRING(@word,@count,1)
		
		IF(CHARINDEX(@currentSymbol,@setOfLetters) > 0)
			BEGIN
				SET @count += 1
				SET @result = 1
			END
		ELSE
			BEGIN
				SET @result = 0
				BREAK
			END
	END				
	RETURN @result
END
GO

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia') AS [ER]
--8-Delete Employees and Departments
CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT) AS
ALTER TABLE Employees ALTER COLUMN ManagerID INT NULL
UPDATE Employees SET ManagerID = NULL WHERE DepartmentID

DELETE FROM Employees
WHERE DepartmentID = @departmentId;
DELETE FROM Departments
WHERE DepartmentID = @departmentId;

SELECT COUNT(*) FROM Employees
WHERE DepartmentID = @departmentId
--9-Find Full Name
CREATE PROC usp_GetHoldersFullName AS
SELECT FirstName + ' ' + LastName AS [Full Name] FROM AccountHolders
--10-People with Balance Higher Than
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@tresholdNumber DECIMAL(18,4)) AS
SELECT FirstName, LastName
FROM Accounts a
INNER JOIN AccountHolders ac ON a.AccountHolderId = ac.ID
GROUP BY FirstName, LastName
HAVING SUM(a.Balance) >= @tresholdNumber
ORDER BY FirstName, LastName

EXEC usp_GetHoldersWithBalanceHigherThan 55000
--11-Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(15,4), @yearlyInterestRate FLOAT, @years INT) 
RETURNS DECIMAL(15,4)
BEGIN
	DECLARE @result DECIMAL(15,4)
	
	SET @result = @sum * POWER((@yearlyInterestRate + 1),@years)

	RETURN @result
END
--12-Calculating Interest
CREATE PROC usp_CalculateFutureValueForAccount(@accountId INT, @interestRate FLOAT)
AS
BEGIN
	SELECT a.Id, ac.FirstName, ac.LastName, a.Balance, dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS 'Balance in 5 years'

	FROM Accounts a
	INNER JOIN AccountHolders ac ON a.AccountHolderId = ac.ID
	WHERE a.Id = @accountId
END

EXEC usp_CalculateFutureValueForAccount 1, 0.1