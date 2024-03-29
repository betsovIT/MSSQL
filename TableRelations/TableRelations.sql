CREATE TABLE Passports(PassportID INT PRIMARY KEY, PassportNumber NVARCHAR(20) NOT NULL)
INSERT INTO Passports(PassportID,PassportNumber) VALUES
(101,'N34FG21B'),
(102,'K65LO4R7'),
(103,'ZE657QP2')

CREATE TABLE Persons(PersonID INT PRIMARY KEY IDENTITY, FirstName NVARCHAR(20) NOT NULL, Salary DECIMAL(10,2) NOT NULL,PassportID INT NOT NULL, CONSTRAINT FK_Persons_Passports FOREIGN KEY (PassportID) REFERENCES Passports(PassportID))
INSERT INTO Persons(FirstName, Salary, PassportID) VALUES
('Roberto',43300,102),
('Tom',56100,103),
('Yana',60200,101)
-----

CREATE TABLE Manufacturers (ManufacturerID INT PRIMARY KEY IDENTITY, [Name] NVARCHAR(10), EstablishedOn DATE)
INSERT INTO Manufacturers ([Name],EstablishedOn) VALUES
('BMW','1916-03-07'),
('Tesla','2003-01-01'),
('Lada','1966-05-01')

CREATE TABLE Models (ModelID INT PRIMARY KEY, [Name] NVARCHAR(20), ManufacturerID INT FOREIGN KEY REFERENCES Manufacturers(ManufacturerID))
INSERT INTO Models(ModelID, [Name],ManufacturerID) VALUES
(101,'X1',1),
(102,'i6',1),
(103,'Model S',2),
(104,'Model X',2),
(105,'Model 3',2),
(106,'Nova',3)
------

CREATE TABLE Students 
(
	StudentID INT PRIMARY KEY IDENTITY NOT NULL, 
	[Name] VARCHAR(30) NOT NULL
);

INSERT INTO Students VALUES
('Mila'),
('Toni'),
('Ron');

CREATE TABLE Exams
(
	ExamID INT PRIMARY KEY NOT NULL, 
	[Name] VARCHAR(30) NOT NULL
)

INSERT INTO Exams(ExamID,Name) VALUES
(101,'SpringMVC'),
(102,'Neo4j'),
(103,'Oracle 11g');

CREATE TABLE StudentsExams
(
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL, 
	ExamID INT FOREIGN KEY REFERENCES Exams(ExamID) NOT NULL, 
	CONSTRAINT PK_StudentExams PRIMARY KEY (StudentID,ExamID)
)

INSERT INTO StudentsExams(StudentID,ExamID) VALUES
(1,101),
(1,102),
(2,101),
(3,103),
(2,102),
(2,103);

-----
CREATE TABLE Teachers(TeacherID INT PRIMARY KEY NOT NULL, [Name] NVARCHAR(20) NOT NULL, ManagerID INT NULL FOREIGN KEY REFERENCES Teachers(TeacherID))

INSERT INTO Teachers(TeacherID, [Name], ManagerID) VALUES
(101,'John',Null),
(102,'Maya',106),
(103,'Silvia',106),
(104,'Ted',105),
(105,'Mark',101),
(106,'Greta',101)

-----

CREATE DATABASE OnlineStore
USE OnlineStore

CREATE TABLE Cities (CityID INT PRIMARY KEY IDENTITY, [Name] VARCHAR(50))
CREATE TABLE ItemTypes(ItemTypeID INT PRIMARY KEY IDENTITY, [Name] VARCHAR(50))
CREATE TABLE Items(ItemID INT PRIMARY KEY IDENTITY, [Name] VARCHAR(50), ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID))
CREATE TABLE Customers(CustomerID INT PRIMARY KEY IDENTITY, [Name] VARCHAR(50), Birthday DATE, CityID INT FOREIGN KEY REFERENCES Cities(CityID))
CREATE TABLE Orders(OrderID INT PRIMARY KEY IDENTITY, CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID))
CREATE TABLE OrderItems(OrderID INT FOREIGN KEY REFERENCES Orders(OrderID), ItemID INT FOREIGN KEY REFERENCES Items(ItemID), CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, ItemID))

-----

CREATE DATABASE UniversityDatabase
USE UniversityDatabase

CREATE TABLE Majors(MajorID INT PRIMARY KEY IDENTITY, [Name] VARCHAR(50))
CREATE TABLE Subjects(SubjectID INT PRIMARY KEY IDENTITY, SubjectName VARCHAR(50))
CREATE TABLE Students(StudentID INT PRIMARY KEY IDENTITY, StudentNumber INT, StudentName VARCHAR(50), MajorID INT FOREIGN KEY REFERENCES Majors(MajorID))
CREATE TABLE Payments(PaymnetID INT PRIMARY KEY IDENTITY, PaymentDate DATE, PaymentAmount DECIMAL(10,2), StudentID INT FOREIGN KEY REFERENCES Students(StudentID))
CREATE TABLE Agenda(StudentID INT FOREIGN KEY REFERENCES Students(StudentID), SubjectID INT FOREIGN KEY REFERENCES Subjects(SubjectID), CONSTRAINT PK_Agenda PRIMARY KEY (StudentID, SubjectID))

-----
USE Geography

SELECT MountainRange, p.PeakName, p.Elevation FROM Peaks p JOIN Mountains m ON p.MountainId = m.Id WHERE MountainRange = 'Rila' ORDER BY p.Elevation DESC