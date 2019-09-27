SELECT COUNT(Id) AS [Count] FROM WizzardDeposits
-----
SELECT MAX(MagicWandSize) AS LongestMagicWand FROM WizzardDeposits
-----
SELECT DepositGroup,MAX(MagicWandSize) AS LongestMagicWand FROM WizzardDeposits GROUP BY DepositGroup
-----
SELECT TOP(2) DepositGroup FROM WizzardDeposits GROUP BY DepositGroup ORDER BY AVG(MagicWandSize) ASC
-----
SELECT DepositGroup, SUM(DepositAmount) FROM WizzardDeposits GROUP BY DepositGroup
-----
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum FROM WizzardDeposits WHERE MagicWandCreator = 'Ollivander family' GROUP BY DepositGroup
-----
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum FROM WizzardDeposits WHERE MagicWandCreator = 'Ollivander family' GROUP BY DepositGroup HAVING SUM(DepositAmount) < 150000 ORDER BY TotalSum DESC
-----
SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge FROM WizzardDeposits GROUP BY DepositGroup, MagicWandCreator
-----
SELECT 
	CASE
			WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
			WHEN Age BETWEEN 11 AND 20 THEN '[11-21]'
			WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
			WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
			WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
			WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
			WHEN Age >= 61 THEN '[61+]'
		END AS AgeGroup,
		COUNT(Id) AS WizardCount
FROM WizzardDeposits as [Ages]
GROUP BY (CASE
			WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
			WHEN Age BETWEEN 11 AND 20 THEN '[11-21]'
			WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
			WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
			WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
			WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
			WHEN Age >= 61 THEN '[61+]'
		END)
-----
SELECT LEFT(FirstName,1) AS FirstLetter FROM WizzardDeposits WHERE DepositGroup = 'Troll Chest' GROUP BY LEFT(FirstName,1)
-----
SELECT 
	DepositGroup,
	IsDepositExpired, 
	AVG(DepositInterest) AS AverageInterest 
FROM WizzardDeposits
WHERE DepositStartDate > '1985-01-01'
GROUP BY DepositGroup,IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired ASC
-----
SELECT DepositAmount, LEAD(DepositAmount) OVER(ORDER BY id) AS GuestDeposit FROM WizzardDeposits
SELECT SUM(DepositAmount - GuestDeposit) AS SumDifference FROM (SELECT DepositAmount, LEAD(DepositAmount) OVER(ORDER BY id) AS GuestDeposit FROM WizzardDeposits) e
-----
SELECT DepartmentId, SUM(Salary) TotalSalary FROM Employees GROUP BY DepartmentID
-----
SELECT DepartmentID,MIN(Salary) FROM Employees WHERE DepartmentID IN (2, 5, 7) AND HireDate > '2000-01-01' GROUP BY DepartmentID
-----
 SELECT * INTO NewSalaries FROM Employees WHERE Salary > 30000
 DELETE FROM NewSalaries WHERE ManagerID = 42
 UPDATE NewSalaries SET Salary = Salary + 5000 WHERE DepartmentID = 1
 SELECT DepartmentId, AVG(Salary) FROM NewSalaries GROUP BY DepartmentID
-----
SELECT DepartmentId, MAX(Salary) AS MaxSalary FROM Employees GROUP BY DepartmentID HAVING Max(Salary) NOT BETWEEN 30000 AND 70000
-----
SELECT COUNT(Salary) AS Count FROM Employees WHERE ManagerID IS NULL
-----
SELECT DepartmentId, Salary FROM (SELECT DepartmentId, Salary, DENSE_RANK() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS [Rank] FROM Employees GROUP BY DepartmentID,Salary) e WHERE Rank = 3
-----
SELECT TOP 10 FirstName, LastName, a.DepartmentId FROM Employees a, (SELECT DepartmentId, AVG(Salary) AS AverageDepartmentSalary FROM Employees GROUP BY DepartmentID) b WHERE a.Salary > AverageDepartmentSalary AND a.DepartmentID = b.DepartmentID