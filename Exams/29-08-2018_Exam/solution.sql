CREATE DATABASE Supermarket
GO
USE Supermarket
GO
--1-DDL
CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL
)
GO
CREATE TABLE Items
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
Price DECIMAL(13,2) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
)
GO
CREATE TABLE Employees
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
Phone CHAR(12) NOT NULL,
Salary DECIMAL(13,2) NOT NULL
)
GO
CREATE TABLE Orders
(
Id INT PRIMARY KEY IDENTITY,
[DateTime] DATETIME2 NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL
)
GO
CREATE TABLE OrderItems
(
OrderId INT FOREIGN KEY REFERENCES Orders(Id) NOT NULL,
ItemId INT FOREIGN KEY REFERENCES Items(Id) NOT NULL,
Quantity INT CHECK (Quantity >= 1) NOT NULL,
PRIMARY KEY (OrderId, ItemId)
)
GO
CREATE TABLE Shifts
(
Id INT IDENTITY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
CheckIn DATETIME2 NOT NULL,
CheckOut DATETIME2 NOT NULL,
PRIMARY KEY (Id, EmployeeId),
CONSTRAINT ck_checkout_diff CHECK (CheckOut > CheckIN)
)
GO

--2-Insert
INSERT INTO Employees (FirstName, LastName, Phone, Salary) VALUES
('Stoyan', 'Petrov', '888-785-8573', 500.25),
('Stamat', 'Nikolov', '789-613-1122', 999995.25),
('Evgeni', 'Petkov', '645-369-9517', 1234.51),
('Krasimir', 'Vidolov', '321-471-9982', 50.25)

INSERT INTO Items([Name], Price, CategoryId) VALUES
('Tesla battery', 154.25, 8),
('Chess', 30.25, 8),
('Juice', 5.32, 1),
('Glasses', 10, 8),
('Bottle of water', 1, 1)

--3-Update
UPDATE Items
SET Price = Price*1.27
WHERE CategoryId IN (1,2,3)

--4-Delete
DELETE OrderItems
WHERE OrderId = 48

DELETE Orders
WHERE Id = 48

--5-Richest People
SELECT Id, FirstName FROM Employees
WHERE Salary > 6500
ORDER BY FirstName, Id

--6-Cool Phone Numbers
SELECT FirstName + ' ' + LastName AS [Full Name], Phone AS [Phone Number]
FROM Employees
WHERE Phone LIKE '3%'
ORDER BY [Full Name], [Phone Number]

--7-Employee Statistics
SELECT FirstName, LastName, COUNT(o.Id) AS [Count]
FROM Employees e
INNER JOIN Orders o ON e.Id = o.EmployeeId
GROUP BY FirstName, LastName
ORDER BY [Count] DESC, FirstName

--8-Hard Workers Club
SELECT FirstName, LastName, [Work hours] FROM
(SELECT FirstName, LastName, e.Id AS Id, AVG(DATEDIFF(HOUR, CheckIn, CheckOut)) AS [Work hours]
FROM Employees e
INNER JOIN Shifts s ON e.Id = s.EmployeeId
GROUP BY FirstName, LastName, e.Id) j
WHERE [Work hours] > 7
ORDER BY [Work hours] DESC, Id

--9-The Most Expensive Order
SELECT TOP(1) OrderId, SUM(Price*Quantity) AS [TotalPrice]
FROM Orders o
INNER JOIN  OrderItems oi ON o.Id = oi.OrderId
INNER JOIN Items i ON oi.ItemId = i.Id
GROUP BY OrderId
ORDER BY TotalPrice DESC

--10-Rich Item, Poor Item
