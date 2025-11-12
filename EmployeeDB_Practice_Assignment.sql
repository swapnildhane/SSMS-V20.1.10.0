
-- =========================================
-- EMPLOYEE DB PRACTICE ASSIGNMENT
-- Joins + Subqueries + Stored Procedures
-- =========================================

-- 1️⃣ Create Database
CREATE DATABASE EmployeeDB;
GO
USE EmployeeDB;
GO

-- 2️⃣ Create Tables
CREATE TABLE Department (
    DeptId INT IDENTITY(1,1) PRIMARY KEY,
    DeptName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(100)
);
GO

CREATE TABLE Employee (
    EmpId INT IDENTITY(1,1) PRIMARY KEY,
    EmpName NVARCHAR(100) NOT NULL,
    DeptId INT,
    Salary DECIMAL(10,2),
    HireDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Employee_Department FOREIGN KEY (DeptId) REFERENCES Department(DeptId)
);
GO

-- 3️⃣ Insert Sample Data
INSERT INTO Department (DeptName, Location) VALUES
('IT', 'Mumbai'),
('HR', 'Pune'),
('Finance', 'Delhi'),
('Marketing', 'Bangalore'),
('Operations', 'Hyderabad');
GO

INSERT INTO Employee (EmpName, DeptId, Salary, HireDate) VALUES
('Swapnil', 1, 35000, '2023-02-10'),
('Amit', 2, 40000, '2023-05-15'),
('Priya', 1, 32000, '2022-11-01'),
('Neha', 3, 28000, '2023-08-25'),
('Rohit', 4, 45000, '2024-01-10'),
('Sneha', 2, 37000, '2023-03-05'),
('Vikas', 5, 30000, '2023-06-18'),
('Anjali', 1, 41000, '2023-09-09');
GO

-- =========================================
-- PART 1: JOINS
-- =========================================

-- Q1: Get all employees with department names
SELECT e.EmpName, d.DeptName
FROM Employee e
INNER JOIN Department d ON e.DeptId = d.DeptId;

-- Q2: Show all employees even if they have no department
SELECT e.EmpName, d.DeptName
FROM Employee e
LEFT JOIN Department d ON e.DeptId = d.DeptId;

-- Q3: Show all departments and employees (FULL OUTER JOIN)
SELECT e.EmpName, d.DeptName
FROM Employee e
FULL OUTER JOIN Department d ON e.DeptId = d.DeptId;

-- Q4: Total salary per department
SELECT d.DeptName, SUM(e.Salary) AS TotalSalary
FROM Employee e
INNER JOIN Department d ON e.DeptId = d.DeptId
GROUP BY d.DeptName;

-- Q5: Highest paid employee in each department
SELECT d.DeptName, e.EmpName, e.Salary
FROM Employee e
INNER JOIN Department d ON e.DeptId = d.DeptId
WHERE e.Salary = (
    SELECT MAX(e2.Salary)
    FROM Employee e2
    WHERE e2.DeptId = e.DeptId
);

-- Q6: Employee name, department, and location
SELECT e.EmpName, d.DeptName, d.Location
FROM Employee e
INNER JOIN Department d ON e.DeptId = d.DeptId;

-- Q7: Departments with more than 2 employees
SELECT d.DeptName, COUNT(e.EmpId) AS EmployeeCount
FROM Employee e
INNER JOIN Department d ON e.DeptId = d.DeptId
GROUP BY d.DeptName
HAVING COUNT(e.EmpId) > 2;

-- Q8: Employees with salary above average of their department
SELECT e.EmpName, d.DeptName, e.Salary
FROM Employee e
INNER JOIN Department d ON e.DeptId = d.DeptId
WHERE e.Salary > (
    SELECT AVG(e2.Salary) FROM Employee e2 WHERE e2.DeptId = e.DeptId
);

-- =========================================
-- PART 2: SUBQUERIES
-- =========================================

-- Q1: Employees earning above average salary
SELECT EmpName, Salary
FROM Employee
WHERE Salary > (SELECT AVG(Salary) FROM Employee);

-- Q2: Employees in IT department
SELECT EmpName
FROM Employee
WHERE DeptId = (SELECT DeptId FROM Department WHERE DeptName = 'IT');

-- Q3: Employee with maximum salary
SELECT EmpName, Salary
FROM Employee
WHERE Salary = (SELECT MAX(Salary) FROM Employee);

-- Q4: Departments with no employees
SELECT DeptName
FROM Department
WHERE DeptId NOT IN (SELECT DISTINCT DeptId FROM Employee WHERE DeptId IS NOT NULL);

-- Q5: Second highest salary
SELECT MAX(Salary) AS SecondHighest
FROM Employee
WHERE Salary < (SELECT MAX(Salary) FROM Employee);

-- =========================================
-- PART 3: STORED PROCEDURES
-- =========================================

-- SP1: Get all employees
CREATE PROCEDURE USP_GetAllEmployees
AS
BEGIN
    SELECT e.EmpId, e.EmpName, e.Salary, d.DeptName
    FROM Employee e
    INNER JOIN Department d ON e.DeptId = d.DeptId;
END;
GO

-- SP2: Insert new employee
CREATE PROCEDURE USP_InsertEmployee
    @EmpName NVARCHAR(100),
    @DeptId INT,
    @Salary DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Employee (EmpName, DeptId, Salary)
    VALUES (@EmpName, @DeptId, @Salary);
END;
GO

-- SP3: Update employee salary
CREATE PROCEDURE USP_UpdateEmployeeSalary
    @EmpId INT,
    @Salary DECIMAL(10,2)
AS
BEGIN
    UPDATE Employee SET Salary = @Salary WHERE EmpId = @EmpId;
END;
GO

-- SP4: Get employees by department name
CREATE PROCEDURE USP_GetEmployeesByDept
    @DeptName NVARCHAR(100)
AS
BEGIN
    SELECT e.EmpName, e.Salary, d.DeptName
    FROM Employee e
    INNER JOIN Department d ON e.DeptId = d.DeptId
    WHERE d.DeptName = @DeptName;
END;
GO

-- SP5: Employees above given salary (Bonus)
CREATE PROCEDURE USP_GetEmployeesAboveSalary
    @MinSalary DECIMAL(10,2)
AS
BEGIN
    SELECT EmpName, Salary
    FROM Employee
    WHERE Salary > @MinSalary
    ORDER BY Salary DESC;
END;
GO

-- =========================================
-- END OF SCRIPT
-- =========================================
