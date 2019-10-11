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
--13-*Scalar Function: Cash in User Games Odd Rows
CREATE FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS
RETURN
	SELECT SUM(Cash) AS SumCash FROM
	(SELECT [Cash],ROW_NUMBER() OVER (PARTITION BY [Name] ORDER BY [Cash] DESC) AS [Row]
	FROM Games g
	INNER JOIN UsersGames ug ON ug.GameId = g.Id
	WHERE g.Name = @gameName) AS d
	WHERE d.Row % 2 = 1
--14-Create Table Logs
ALTER TABLE Logs(LogId INT PRIMARY KEY IDENTITY, AccountId INT FOREIGN KEY REFERENCES Accounts(Id), OldSum DECIMAL(15,4) NOT NULL, NewSUM DECIMAL(15,4))
GO
CREATE TRIGGER tr_LogTransaction ON Accounts FOR UPDATE
AS
BEGIN
	DECLARE @newSum DECIMAL(15,2) = (SELECT i.Balance FROM [INSERTED] AS i)
	DECLARE @oldSUM DECIMAL(15,2) = (SELECT d.Balance FROM [DELETED] AS d)
	DECLARE @accountID INT = (SELECT i.Id FROM [INSERTED] AS i)

	INSERT INTO Logs(AccountId, OldSum, NewSUM) VALUES
	(@accountID, @oldSUM, @newSum)
END

--15-Create Table Emails
CREATE TABLE NotificationEmails
(Id INT PRIMARY KEY IDENTITY, 
Recipient INT FOREIGN KEY REFERENCES Accounts(Id), 
[Subject] NVARCHAR(200), 
[Body] NVARCHAR(200))

CREATE TRIGGER tr_EmailOnLog ON [Logs] FOR INSERT
AS
BEGIN
	DECLARE @recipient INT = (SELECT AccountId FROM [INSERTED])
	DECLARE @newSum DECIMAL(15,2) = (SELECT NewSUM FROM [INSERTED] AS i)
	DECLARE @oldSum DECIMAL(15,2) = (SELECT OldSUM FROM [DELETED] AS d)
	DECLARE @datetime DATETIME = GETDATE()

	INSERT INTO NotificationEmails([Recipient], [Subject], [Body]) VALUES
	(@recipient,
	'Balance change for account: ' + CONVERT(NVARCHAR(10),@recipient), 
	'On ' + CONVERT(NVARCHAR(50),@datetime) +' your balance was changed from ' + CONVERT(NVARCHAR(10),@oldSum) + ' to ' + CONVERT(NVARCHAR(10),@newSum))
END
--16-Deposit Money
CREATE PROC usp_DepositMoney(@accountId INT, @moneyAmount DECIMAL(15,4))
AS
BEGIN TRANSACTION
	IF(@moneyAmount < 0)
		BEGIN
			ROLLBACK
			RAISERROR('Invalid money amount!',1,16)
			RETURN
		END
	UPDATE Accounts SET Balance = Balance + @moneyAmount
	WHERE @accountId = Id
COMMIT
--17-Withdraw money procedure
CREATE PROC usp_WithdrawMoney(@AccountID INT, @MoneyAmmount DECIMAL(15,4))
AS
BEGIN TRANSACTION
	IF(@MoneyAmmount <= 0)
	BEGIN
		ROLLBACK
		RAISERROR('Invalid money amount!',1,16)
		RETURN
	END

	IF((SELECT Balance FROM Accounts WHERE Id = @AccountID) < @MoneyAmmount)
	BEGIN
		ROLLBACK
		RAISERROR('Not enough money in account',1,16)
		RETURN
	END

	UPDATE Accounts 
	SET Balance = Balance - @MoneyAmmount
	WHERE Id = @AccountID
COMMIT
--18-Money Transfer
CREATE PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(15,4))
AS
BEGIN TRANSACTION
	EXEC usp_WithdrawMoney @SenderId, @Amount
	EXEC usp_DepositMoney @ReceiverId, @Amount
COMMIT
--19-Trigger
--20-Massive Shopping
--21-Employees with Three Projects
CREATE PROC usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
BEGIN TRANSACTION
	IF((SELECT COUNT(*) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId) = 3)
	BEGIN
		ROLLBACK
		RAISERROR('The employee has too many projects!',16,1)
		RETURN
	END

	INSERT INTO EmployeesProjects VALUES
	(@emloyeeId,@projectID)
COMMIT
--22-Delete Employees
CREATE TABLE Deleted_Employees
(EmployeeId INT PRIMARY KEY, 
FirstName VARCHAR(20), 
LastName VARCHAR(20), 
MiddleName VARCHAR(20), 
JobTitle VARCHAR(20), 
DepartmentId INT FOREIGN KEY REFERENCES Departments(DepartmentID), 
Salary DECIMAL(15,2))

CREATE TRIGGER tr_storeDeletedEmployees ON Employees FOR DELETE
AS
BEGIN
	INSERT INTO Deleted_Employees(FirstName,LastName,MiddleName,JobTitle,DepartmentId,Salary) 
	SELECT FirstName,LastName, MiddleName, JobTitle, DepartmentID, Salary FROM [DELETED]
END