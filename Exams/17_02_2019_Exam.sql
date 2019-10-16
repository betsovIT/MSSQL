CREATE DATABASE School
GO
USE School
GO
--1-DDL
CREATE TABLE Students(
[Id] INT PRIMARY KEY IDENTITY,
[FirstName] NVARCHAR(30) NOT NULL,
[MiddleName] NVARCHAR(25),
[LastName] NVARCHAR(30) NOT NULL,
[Age] INT CHECK(Age >= 0),
[Address] NVARCHAR(50),
[Phone] NCHAR(10))

CREATE TABLE Subjects(
[Id] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
[Lessons] INT)

CREATE TABLE StudentsSubjects(
[Id] INT PRIMARY KEY IDENTITY,
[StudentId] INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
[SubjectId] INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
[Grade] DECIMAL(15,2) CHECK ([Grade] >= 2 AND [Grade] <= 6))

CREATE TABLE Exams(
[Id] INT PRIMARY KEY IDENTITY,
[Date] DATETIME2,
[SubjectId] INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL)

CREATE TABLE StudentsExams(
[StudentId] INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
[ExamId] INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
[Grade] DECIMAL(15,2) CHECK ([Grade] >= 2 AND [Grade] <= 6)
PRIMARY KEY(StudentId, ExamId))

CREATE TABLE Teachers(
[Id] INT PRIMARY KEY IDENTITY,
[FirstName] NVARCHAR(20) NOT NULL,
[LastName] NVARCHAR(20) NOT NULL,
[Address] NVARCHAR(20) NOT NULL,
[Phone] CHAR(10),
[SubjectId] INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL)

CREATE TABLE StudentsTeachers(
[StudentId] INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
[TeacherId] INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL,
PRIMARY KEY(StudentId, TeacherId))

--2-Insert
INSERT INTO Teachers([FirstName], [LastName], [Address], [Phone], [SubjectId]) VALUES
('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
('Merrile', 'Lambdin', '81 Dahle Plaza', '4373065154', 5),
('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects([Name], [Lessons]) VALUES
('Geometry', 12),
('Health', 10),
('Drama', 7),
('Sports', 9)

--3-Update
UPDATE StudentsSubjects
SET Grade = 6
WHERE SubjectId IN (1,2) AND Grade >= 5.50

--4-Delete
DELETE StudentsTeachers WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')
DELETE Teachers WHERE Id IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')

--5-Teen Students
SELECT FirstName, LastName, Age 
FROM Students
WHERE Age>= 12
ORDER BY FirstName, LastName

--6-Cool Addresses
SELECT FirstName + ' ' + ISNULL(MiddleName,'') + ' ' + LastName AS [Full Name] , Address
FROM Students
WHERE [Address] LIKE '%road%'
ORDER BY FirstName, LastName, Address

--7-42 Phones
SELECT FirstName, [Address], Phone 
FROM Students
WHERE MiddleName IS NOT NULL AND Phone LIKE '42%'
ORDER BY FirstName

--8-Students Teachers
SELECT FirstName, LastName, COUNT(st.TeacherId) AS TeachersCount
FROM Students s
JOIN StudentsTeachers st ON s.Id = st.StudentId
GROUP BY FirstName, LastName

--9- Subjects with Students
SELECT FullName, Subjects, COUNT(Ids) AS Students FROM
(SELECT FirstName + ' ' + LastName AS FullName, s.Name + '-' + CONVERT(NVARCHAR(10),s.Lessons) AS Subjects, st.StudentId AS Ids
FROM Teachers t
INNER JOIN Subjects s ON t.SubjectId = s.Id
INNER JOIN StudentsTeachers st ON t.Id = st.TeacherId) j
GROUP BY FullName, Subjects
ORDER BY Students DESC, FullName, Subjects

--10-Students to Go
SELECT FirstName + ' ' + LastName AS FullName
FROM Students s
LEFT OUTER JOIN StudentsExams se ON se.StudentId = s.Id
WHERE ExamId IS NULL
ORDER BY FullName

--11-Busiest Teachers 
SELECT TOP(10) FirstName, LastName, COUNT(Ids) AS Students FROM
(SELECT FirstName, LastName , st.StudentId AS Ids
FROM Teachers t
INNER JOIN Subjects s ON t.SubjectId = s.Id
INNER JOIN StudentsTeachers st ON t.Id = st.TeacherId) j
GROUP BY FirstName, LastName
ORDER BY Students DESC, FirstName

--12-Top Students
SELECT TOP(10) FirstName, LastName, CONVERT(DECIMAL(10,2),AVG(Grade)) AS Grade
FROM Students s
INNER JOIN StudentsExams se ON s.Id = se.StudentId
GROUP BY FirstName, LastName
ORDER BY Grade DESC, FirstName, LastName

--13-Second Highest Grade
SELECT FirstName, LastName, Grade
FROM (SELECT FirstName, LastName, se.Grade, ROW_NUMBER() OVER(PARTITION BY FirstName, LastName ORDER BY Grade DESC) AS [Rank]
FROM Students s 
INNER JOIN StudentsSubjects se ON s.Id = se.StudentId) j
WHERE Rank = 2
ORDER BY FirstName, LastName

--14-Not So In The Studying
SELECT FirstName + ' ' + ISNULL(MiddleName + ' ','') +  LastName AS [Full Name]
FROM Students s
LEFT OUTER JOIN StudentsSubjects ss ON s.Id = ss.StudentId
WHERE ss.Id IS NULL
ORDER BY [Full Name]

--15-Top Student per Teacher
SELECT [Teacher Full Name], [Subject Name], [Student Full Name], AVG(Grade)
FROM (SELECT t.FirstName + ' ' + t.LastName AS [Teacher Full Name], sb.[Name] AS [Subject Name], su.FirstName + ' ' + su.LastName AS [Student Full Name], Grade
FROM Teachers t
INNER JOIN StudentsTeachers st ON t.Id = st.TeacherId
INNER JOIN Students su ON st.StudentId = su.Id
INNER JOIN StudentsSubjects ss ON su.Id = ss.StudentId
INNER JOIN Subjects sb ON ss.SubjectId = sb.Id) j
GROUP BY [Teacher Full Name], [Subject Name], [Student Full Name]
ORDER BY [Subject Name], [Teacher Full Name]

--16-Average Grade per Subject
SELECT [Name], AVG(Grade) AS AverageGrade
FROM Subjects s
INNER JOIN StudentsSubjects ss ON ss.SubjectId = s.Id
GROUP BY [Name], SubjectId
ORDER BY SubjectId

--17-Exams Information
