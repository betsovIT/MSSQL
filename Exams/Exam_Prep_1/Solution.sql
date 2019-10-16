CREATE DATABASE Airport
GO
USE Airport
GO
--1-DDL
CREATE TABLE Planes
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL,
Seats INT NOT NULL,
[Range] INT NOT NULL
)
GO
CREATE TABLE Flights
(
Id INT PRIMARY KEY IDENTITY,
DepartureTime DATETIME2,
ArrivalTime DATETIME2,
Origin VARCHAR(50) NOT NULL,
Destination VARCHAR(50) NOT NULL,
PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)
GO
CREATE TABLE Passengers
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(30) NOT NULL,
LastName VARCHAR(30) NOT NULL,
Age INT NOT NULL,
[Address] VARCHAR(30) NOT NULL,
PassportId CHAR(11) NOT NULL
)
GO
CREATE TABLE LuggageTypes
(
Id INT PRIMARY KEY IDENTITY,
[Type] VARCHAR(30) NOT NULL
)
GO
CREATE TABLE Luggages
(
Id INT PRIMARY KEY IDENTITY,
LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
)
GO
CREATE TABLE Tickets
(
Id INT PRIMARY KEY IDENTITY,
PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
Price DECIMAL(15,2) NOT NULL
)
GO

--2-Insert
INSERT INTO Planes([Name], Seats, [Range]) VALUES
('Airbus 336', 112, 5132),
('Airbus 330', 432, 5325),
('Boeing 369', 231, 2355),
('Stelt 297', 254, 2143),
('Boeing 338', 165, 5111),
('Airbus 558', 387, 1342),
('Boeing 128', 345, 5541)

INSERT INTO [LuggageTypes]([Type]) VALUES
('Crossbody Bag'),
('School Backpack'),
('Shoulder Bag')

--3-Update
UPDATE Tickets
SET Price = Price*1.13
WHERE FlightId IN (SELECT Id FROM Flights WHERE Destination = 'Carlsbad')

--4-Delete
DELETE Tickets
WHERE FlightId IN (SELECT Id FROM Flights WHERE Destination = 'Ayn Halagim')
DELETE Flights
WHERE Destination = 'Ayn Halagim'

--5-The "Tr" Planes
SELECT * 
FROM Planes
WHERE Name LIKE '%tr%'
ORDER BY Id,Name,Seats,Range

--6-Flight Profits
SELECT FlightId, SUM(Price) AS Price
FROM Tickets
GROUP BY FlightId
ORDER BY Price DESC, FlightId

--7-Passenger Trips
SELECT p.FirstName + ' ' + p.LastName AS [Full Name], f.Origin AS Origin, f.Destination AS Destination
FROM Tickets t
INNER JOIN Flights f ON t.FlightId = f.Id
INNER JOIN Passengers p ON p.Id = t.PassengerId
ORDER BY [Full Name], Origin, Destination

--8-Non Adventures People
SELECT FirstName, LastName, Age
FROM Passengers p
LEFT OUTER JOIN Tickets t ON t.PassengerId = p.Id
WHERE t.Id IS NULL
ORDER BY Age DESC, FirstName, LastName

--9-Full Info
SELECT p.FirstName + ' ' + p.LastName AS [Full Name], pl.[Name] AS [Plane Name], f.Origin + ' - ' + f.Destination AS Trip, lt.[Type] AS [Luggage Type]
FROM Tickets t
INNER JOIN Passengers p ON t.PassengerId = p.Id
INNER JOIN Flights f ON t.FlightId = f.Id
INNER JOIN Planes pl ON f.PlaneId = pl.Id
INNER JOIN Luggages l ON t.LuggageId = l.Id
INNER JOIN LuggageTypes lt ON l.LuggageTypeId = lt.Id
ORDER BY [Full Name], [Name], Origin, Destination, [Luggage Type]

--10-PSP
SELECT p.[Name] AS [Name], p.Seats AS [Seats], COUNT(t.Id) AS [Passengers Count]
FROM Planes p
LEFT OUTER JOIN Flights f ON f.PlaneId = p.Id
LEFT OUTER JOIN Tickets t ON t.FlightId = f.Id
GROUP BY p.[Name], p.Seats
ORDER BY COUNT(t.Id) DESC, [Name], Seats

--11-Vacation
CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @result VARCHAR(100)
	DECLARE @route VARCHAR(100)
	DECLARE @seatCount INT
	DECLARE @pricePerPerson DECIMAL(15,2)

	SET @route = @origin+@destination

	IF(@route NOT IN (SELECT Origin+Destination FROM Flights))
	BEGIN
		SET @result = 'Invalid flight!'
		RETURN @result
	END

	SET @seatCount = (SELECT Seats FROM Planes p INNER JOIN Flights f ON f.PlaneId = p.Id  WHERE Origin+Destination = @route)

	IF(@peopleCount > @seatCount OR @peopleCount < 1)
	BEGIN
		SET @result = 'Invalid people count!'
		RETURN @result
	END

	SET @pricePerPerson = (SELECT t.Price FROM Tickets t INNER JOIN Flights f ON t.FlightId = f.Id WHERE f.Origin + f.Destination = @route)

	SET @result = 'Total price ' + CONVERT(VARCHAR(30),@pricePerPerson*@peopleCount)

	RETURN @result
END

--12-Wrong Data
CREATE PROC usp_CancelFlights
AS
UPDATE Flights
SET DepartureTime = NULL, ArrivalTime = NULL
WHERE ArrivalTime > DepartureTime