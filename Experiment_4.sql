-- EXPERIMENT 4: SQL JOINs, Subqueries, Set Operations, and EXPLAIN
-- Requires the EmployeeManagement database created by Experiment 3.
-- SQL dialect: MySQL

USE EmployeeManagement;

-- INNER JOIN
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id;

-- LEFT JOIN
SELECT d.dept_id, d.dept_name, e.emp_name
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id;

-- SELF JOIN: pairs of employees in the same department
SELECT
    e1.emp_name AS Employee1,
    e2.emp_name AS Employee2,
    e1.dept_id
FROM Employee e1
JOIN Employee e2
    ON e1.dept_id = e2.dept_id
   AND e1.emp_id < e2.emp_id;

-- 3-way JOIN (as written in the practical: joins Employee, Department,
-- Employee_Project, and Project)
SELECT e.emp_name, d.dept_name, p.project_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
JOIN Employee_Project ep ON e.emp_id = ep.emp_id
JOIN Project p ON ep.project_id = p.project_id;

-- Additional JOIN query from the practical
SELECT e.emp_name, d.dept_name, e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
JOIN Project p ON d.dept_id = p.dept_id;

-- Correlated subquery: employees earning above their department average
SELECT e.emp_id, e.emp_name, e.salary, e.dept_id
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);

-- EXISTS: employees assigned to at least one project
SELECT e.emp_id, e.emp_name
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Employee_Project ep
    WHERE ep.emp_id = e.emp_id
);

-- Simulated INTERSECT: employees in department 1 assigned to project 201
SELECT e.emp_id, e.emp_name
FROM Employee e
WHERE e.dept_id = 1
  AND EXISTS (
      SELECT 1
      FROM Employee_Project ep
      WHERE ep.emp_id = e.emp_id
        AND ep.project_id = 201
  );

-- Simulated EXCEPT: employees in department 1 not assigned to project 201
SELECT e.emp_id, e.emp_name
FROM Employee e
WHERE e.dept_id = 1
  AND NOT EXISTS (
      SELECT 1
      FROM Employee_Project ep
      WHERE ep.emp_id = e.emp_id
        AND ep.project_id = 201
  );

-- Compare execution plans using EXPLAIN: INNER JOIN
EXPLAIN
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id;

-- EXPLAIN: LEFT JOIN
EXPLAIN
SELECT d.dept_name, e.emp_name
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id;

-- EXPLAIN: correlated subquery
EXPLAIN
SELECT e.emp_name, e.salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);

-- EXPLAIN: EXISTS
EXPLAIN
SELECT e.emp_id, e.emp_name
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Employee_Project ep
    WHERE ep.emp_id = e.emp_id
);
