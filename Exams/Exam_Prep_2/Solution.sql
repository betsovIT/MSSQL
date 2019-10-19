CREATE DATABASE School
GO
USE School
GO

--1-DDL
CREATE TABLE Students
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
MiddleName NVARCHAR(25),
LastName NVARCHAR(30) NOT NULL,
Age INT CHECK (Age > 0),
[Address] NVARCHAR(50),
Phone NCHAR(10)
)
GO
CREATE TABLE Subjects
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
Lessons INT NOT NULL
)
GO
CREATE TABLE StudentsSubjects
(
Id INT PRIMARY KEY IDENTITY,
StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
Grade DECIMAL(3,2) CHECK (Grade >= 2 AND Grade <= 6) NOT NULL
)
GO
CREATE TABLE Exams
(
Id INT PRIMARY KEY IDENTITY,
[Date] DATETIME2,
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)
GO
CREATE TABLE StudentsExams
(
StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
GRADE DECIMAL(3,2) CHECK (Grade >= 2 AND Grade <= 6) NOT NULL
PRIMARY KEY(StudentId, ExamId)
)
GO
CREATE TABLE Teachers
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(20) NOT NULL,
LastName NVARCHAR(20) NOT NULL,
[Address] NVARCHAR(20) NOT NULL,
Phone NCHAR(10),
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)
GO
CREATE TABLE StudentsTeachers
(
StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL,
PRIMARY KEY (StudentId, TeacherId)
)
GO

--2-Insert
INSERT INTO Teachers(FirstName, LastName, [Address], Phone, SubjectId) VALUES
('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
('Merrile', 'Lambdin', '81 Dahle Plaza', '4373065154', 5),
('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects([Name],Lessons) VALUES
('Geometry', 12),
('Health', 10),
('Drama', 7),
('Sports', 9)

--3-Update
UPDATE StudentsSubjects
SET Grade = 6
WHERE SubjectId IN (1,2) AND Grade >= 5.50

--4-Delete
SELECT Id FROM Teachers WHERE Phone LIKE '%72%'
DELETE FROM StudentsTeachers
WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')
DELETE Teachers
WHERE Phone LIKE '%72%'

--5-Teen Students
SELECT FirstName, LastName, Age
FROM Students
WHERE Age >= 12
ORDER BY FirstName, LastName

--6-Students Teachers
SELECT s.FirstName, s.LastName, COUNT(t.Id) AS TeachersCount
FROM Students s
INNER JOIN StudentsTeachers st ON st.StudentId = s.Id
INNER JOIN Teachers t ON st.TeacherId = t.Id
GROUP BY s.FirstName, S.LastName

--7-Students to Go
SELECT FirstName + ' ' + LastName AS [Full Name]
FROM Students s
LEFT OUTER JOIN StudentsExams se ON se.StudentId = s.Id
WHERE se.ExamId IS NULL
ORDER BY [Full Name]

--8-Top Students
SELECT TOP(10) FirstName, LastName, CONVERT(DECIMAL(3,2),AVG(Grade)) AS Grade
FROM Students s
INNER JOIN StudentsExams se ON se.StudentId = s.Id
GROUP BY FirstName, LastName
ORDER BY Grade DESC, FirstName, LastName

--9-Not So In The Studying
SELECT FirstName + ' ' + ISNULL(MiddleName + ' ','') + LastName AS [Full Name]
FROM Students s
LEFT OUTER JOIN StudentsSubjects ss ON s.Id = ss.StudentId
WHERE ss.Id IS NULL
ORDER BY [Full Name]

--10-Average Grade per Subject
SELECT [Name], Grade FROM
(SELECT s.Id AS Id, [Name], AVG(ss.Grade) AS Grade
FROM Subjects s
INNER JOIN StudentsSubjects ss ON s.Id = ss.SubjectId
GROUP BY [Name], s.Id) j
ORDER BY j.Id

--11-Exam Grades
CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(3,2))
RETURNS NVARCHAR(200)
AS
BEGIN
	DECLARE @result NVARCHAR(200)
	DECLARE @topRange DECIMAL(3,2)
	DECLARE @studentFirstName NVARCHAR(20)
	DECLARE @gradesToUpdate INT

	IF((SELECT COUNT(*) FROM Students WHERE Id = @studentId) = 0)
	BEGIN
		SET @result = 'The student with provided id does not exist in the school!'
		RETURN @result
	END

	IF(@grade > 6)
	BEGIN
		SET @result = 'Grade cannot be above 6.00!'
		RETURN @result
	END

	SET @topRange = @grade + 0.5

	IF(@topRange > 6)
	BEGIN
		SET @topRange = 6
	END

	SET @studentFirstName = (SELECT FirstName FROM Students WHERE Id = @studentId)

	SET @gradesToUpdate = (SELECT COUNT(*)
							FROM Students s
							INNER JOIN StudentsExams ss ON s.Id = ss.StudentId
							WHERE s.Id = @studentId AND ss.Grade >= @grade AND ss.Grade <= @topRange)
	SET @result = 'You have to update ' + CONVERT(nvarchar(3),@gradesToUpdate)+ ' grades for the student ' + @studentFirstName

	RETURN @result

END

--12-Exclude from school
CREATE PROC usp_ExcludeFromSchool(@StudentId INT)
AS
	IF((SELECT COUNT(*) FROM Students WHERE Id = @StudentId) = 0)
	BEGIN
		RAISERROR('This school has no student with the provided id!',16,1)
	END

	DELETE FROM StudentsExams WHERE StudentId = @StudentId
	DELETE FROM StudentsTeachers WHERE StudentId = @StudentId
	DELETE FROM StudentsSubjects WHERE StudentId = @StudentId
	DELETE FROM Students WHERE Id = @studentId

EXEC usp_ExcludeFromSchool 23