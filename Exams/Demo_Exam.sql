CREATE DATABASE Bitbucket
GO
--1-DDL
CREATE TABLE Users(
[Id] INT PRIMARY KEY IDENTITY,
[Username] NVARCHAR(30) NOT NULL,
[Password] NVARCHAR(30) NOT NULL,
[Email] NVARCHAR(50) NOT NULL)
CREATE TABLE Repositories(
[Id] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL)
CREATE TABLE RepositoriesContributors(
[RepositoryId] INT FOREIGN KEY REFERENCES Repositories(Id),
[ContributorId] INT FOREIGN KEY REFERENCES Users(Id),
PRIMARY KEY([RepositoryId],[ContributorId]))
CREATE TABLE Issues(
[Id] INT PRIMARY KEY IDENTITY,
[Title] NVARCHAR(255) NOT NULL,
[IssueStatus] NCHAR(6)NOT NULL,
[RepositoryId] INT FOREIGN KEY REFERENCES Repositories(Id),
[AssigneeId] INT FOREIGN KEY REFERENCES Users(Id))
CREATE TABLE Commits(
[Id] INT PRIMARY KEY IDENTITY,
[Message] NVARCHAR(255) NOT NULL,
[IssueId] INT FOREIGN KEY REFERENCES Issues(Id),
[RepositoryId] INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
[ContributorId] INT FOREIGN KEY REFERENCES Users(Id) NOT NULL)
CREATE TABLE Files(
[Id] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(100) NOT NULL,
[Size] DECIMAL(15,2) NOT NULL,
[ParentId] INT FOREIGN KEY REFERENCES Files(Id),
[CommitId] INT FOREIGN KEY REFERENCES Commits(Id))

--2-Insert
INSERT INTO Files([Name],Size, ParentId, CommitId) VALUES
('Trade.idk',2598.0,1,1),
('menu.net',9238.31,2,2),
('Administrate.soshy',1246.93,3,3),
('Controller.php',7353.15,4,4),
('Find.java',9957.86,5,5),
('Controller.json',14034.87,3,6),
('Operate.xix',7662.92,7,7)

INSERT INTO Issues(Title,IssueStatus,RepositoryId,AssigneeId) VALUES
('Critical Problem with HomeController.cs file', 'open',1,4),
('Typo fix in Judge.html','open',4,3),
('Implement documentation for UsersService.cs','closed',8,2),
('Unreachable code in Index.cs','open',9,8)

--3-Update
UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

--4-Delete
SELECT Id FROM Repositories WHERE [Name] = 'Softuni-Teamwork'
DELETE FROM RepositoriesContributors WHERE RepositoryId = (SELECT Id FROM Repositories WHERE [Name] = 'Softuni-Teamwork')
DELETE FROM Issues WHERE RepositoryId = (SELECT Id FROM Repositories WHERE [Name] = 'Softuni-Teamwork')

--5-Commits
SELECT Id,[Message],RepositoryId, ContributorId FROM Commits
ORDER BY Id ASC, [Message] ASC, RepositoryId ASC, ContributorId ASC

--6-Heavy HTML
SELECT Id, [Name], Size FROM Files
WHERE Size > 1000 AND [Name] LIKE '%html%'
ORDER BY Size DESC, Id, [Name]

--7-Issues and Users
SELECT i.Id, u.Username + ' : ' + i.Title AS IssueAssignee FROM Issues i
INNER JOIN Users u ON i.AssigneeId = u.Id
ORDER BY i.id DESC, IssueAssignee

--8-Non-Directory Files

SELECT b.Id, b.[Name], CONVERT(NVARCHAR(50),b.Size)+'KB' AS Size FROM Files a
RIGHT OUTER JOIN Files b ON a.ParentId = b.Id
WHERE a.Id IS NULL
ORDER BY b.Id, b.[Name], Size DESC

--9-Most Contributed Repositories
SELECT TOP(5) r.Id, r.Name, COUNT(c.id) AS Commits FROM Commits c
INNER JOIN Repositories r ON c.RepositoryId = r.Id
INNER JOIN RepositoriesContributors rc ON rc.RepositoryId = r.Id
GROUP BY r.Id, r.Name
ORDER BY Commits DESC, r.Id, r.Name

--10-User and Files
SELECT u.Username, AVG(f.Size) AS Size FROM Commits c
INNER JOIN Users u ON c.ContributorId = u.Id
INNER JOIN Files f ON f.CommitId = c.Id
GROUP BY u.Username
ORDER BY Size DESC, u.Username ASC

--11-User Total Commits
CREATE FUNCTION udf_UserTotalCommits(@username NVARCHAR(50))
RETURNS INT
AS
BEGIN
	DECLARE @commitCount INT
	SET @commitCount = (SELECT COUNT(c.Id) FROM Commits c INNER JOIN Users u ON c.ContributorId = u.Id WHERE u.Username = @username)
	RETURN @commitCount
END

--12-Find by Extensions
CREATE PROC usp_FindByExtension(@extension NVARCHAR(10))
AS
	SELECT Id, [Name], CONVERT(NVARCHAR(30),Size) + 'KB' AS Size FROM Files WHERE [Name] LIKE '%'+ @extension

EXEC usp_FindByExtension 'txt'

 SELECT *
    FROM [dbo].[Repositories] AS r
	JOIN [dbo].[RepositoriesContributors] AS [rc] ON [r].[Id] = [rc].[RepositoryId]
	JOIN [dbo].[Users] AS [u] ON [rc].[ContributorId] = [u].[Id]
	JOIN [dbo].[Commits] AS [c] ON [r].[Id] = [c].[RepositoryId]