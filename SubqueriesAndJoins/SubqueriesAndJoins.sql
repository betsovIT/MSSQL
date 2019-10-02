--01-Employee Address
SELECT TOP(5) EmployeeID, JobTitle, e.AddressID, AddressText 
FROM Employees e 
INNER JOIN Addresses a ON e.AddressID = a.AddressID 
ORDER BY e.AddressID;

--02-Addresses with Towns
SELECT TOP(50) FirstName, LastName, t.Name AS Town, AddressText
FROM Employees e
INNER JOIN Addresses a ON e.AddressID = a.AddressID
INNER JOIN Towns t ON a.TownID = t.TownID
ORDER BY FirstName, LastName;

--03-Sales Employee
SELECT EmployeeID, FirstName, LastName, d.Name AS DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY EmployeeID;

--04-Employee Departments
SELECT TOP(5) EmployeeID, FirstName, Salary, d.Name AS DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE Salary > 15000
ORDER BY e.DepartmentID;

--05-Employees Without Project
SELECT TOP(3) e.EmployeeID, FirstName
FROM Employees e
LEFT OUTER JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
WHERE ProjectID IS NULL
ORDER BY EmployeeID;

--06-Employees Hired After
SELECT FirstName, LastName, HireDate, d.Name AS DeptName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE HireDate > '1991-01-01' AND d.Name IN ('Sales', 'Finance')
ORDER BY HireDate;

--07-Employees With Project
SELECT TOP(5) e.EmployeeID, FirstName, p.Name AS ProjectName
FROM Employees e
INNER JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
INNER JOIN Projects p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY EmployeeID;

--08-Employee 24
SELECT e.EmployeeID, FirstName, CASE WHEN p.StartDate > '2005-01-01' THEN NULL ELSE p.Name END AS ProjectName
FROM Employees e
INNER JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
INNER JOIN Projects p ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24;

--09-Employee Manager
SELECT e.EmployeeID, e.FirstName, e.ManagerID, m.FirstName AS ManagerName
FROM Employees e
INNER JOIN Employees m ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID;

--10-Employee Summary
SELECT TOP(50) e.EmployeeID, e.FirstName + ' ' + e.LastName AS EmployeeName, m.FirstName + ' ' + m.LastName AS ManagerName, d.Name AS DepartmentName
FROM Employees e
INNER JOIN Employees m ON e.ManagerID = m.EmployeeID
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;

--11-Min Average Salary
SELECT MIN(c.AverageSalary) AS MinAverageSalary FROM
(SELECT AVG(Salary) AS AverageSalary
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY e.DepartmentID) c;

USE Geography

--12-Highest Peaks in Bulgaria
SELECT CountryCode, MountainRange, PeakName, Elevation
FROM Peaks p
INNER JOIN Mountains m ON p.MountainId = m.Id
INNER JOIN MountainsCountries mc ON m.Id = mc.MountainId
WHERE CountryCode = 'BG' AND Elevation > 2835
ORDER BY Elevation DESC;

--13-Count Mountain Ranges
SELECT CountryCode, COUNT(MountainId) AS MountainRanges
FROM MountainsCountries
WHERE CountryCode IN ('BG', 'US', 'RU')
GROUP BY CountryCode;

--14-Countries With or Without Rivers
SELECT TOP(5) CountryName, RiverName
FROM Countries c
LEFT OUTER JOIN CountriesRivers cr ON c.CountryCode = cr.CountryCode
LEFT OUTER JOIN Rivers r ON cr.RiverId = r.Id
WHERE ContinentCode = 'AF'
ORDER BY CountryName;

--15-Continents and Currencies
SELECT ContinentCode, CurrencyCode, CurrencyUsage
FROM
(SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage, DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY COUNT(CurrencyCode) DESC) AS Drank
FROM Countries
GROUP BY ContinentCode,CurrencyCode
HAVING COUNT(CurrencyCode) > 1) a
WHERE Drank = 1;

--16-Countries without any Mountains
SELECT COUNT(*) AS CountryCode
FROM
(
	SELECT c.CountryCode, mc.MountainId
	FROM Countries c
	LEFT OUTER JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
) a
WHERE MountainId IS NULL;

--17-Highest Peak and Longest River by Country
SELECT TOP(5) CountryName, MAX(Elevation) AS HighestPeakElevation, MAX(Length) AS LongestRiverLength
FROM Countries c
INNER JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
INNER JOIN Mountains m ON m.Id = mc.MountainId
INNER JOIN Peaks p ON p.MountainId = m.Id
INNER JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
INNER JOIN Rivers r ON r.Id = cr.RiverId
GROUP BY CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName;

--18-Highest Peak Name and Elevation by Country
SELECT TOP(5)
Country, 
CASE
	WHEN PeakName IS NULL THEN '(no highest peak)'
	ELSE PeakName
END AS [Highest Peak Name], 
CASE
	WHEN Elevation IS NULL THEN 0
	ELSE Elevation
END AS [Highest Peak Elevation],
CASE
	WHEN MountainRange IS NULL THEN '(no mountain)'
	ELSE MountainRange
END AS [Mountain]
FROM
(
	SELECT CountryName AS Country, PeakName, Elevation, MountainRange, DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY Elevation DESC) AS Ranked
	FROM Countries c
	LEFT OUTER JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
	LEFT OUTER JOIN Mountains m ON mc.MountainId = m.Id
	LEFT OUTER JOIN Peaks p ON m.Id = p.MountainId
) a
WHERE Ranked = 1
ORDER BY Country, [Highest Peak Name];