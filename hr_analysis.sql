-- ============================================
-- SQL Dialect: MySQL
-- Project: HR Database Analysis
-- ============================================

USE job_db;

-- View Tables
SELECT * FROM countries_hr_data;
SELECT * FROM department_hr_data;
SELECT * FROM employee_hr_data;
SELECT * FROM job_grades_hr_data;
SELECT * FROM job_history_hr_data;
SELECT * FROM jobs_hr_data;
SELECT * FROM location_hr_data;

-- ============================================
-- BASIC FILTERING QUERIES
-- ============================================

-- Employees with salary > 9000
SELECT first_name, last_name, department_id, salary
FROM employee_hr_data
WHERE salary > 9000;

-- Employees without department
SELECT employee_id, first_name, last_name, email, phone_number, hire_date,
       job_id, salary, commission_pct, manager_id, department_id
FROM employee_hr_data
WHERE department_id IS NULL;

-- Employees without 'T' in first name
SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    hire_date,
    salary,
    department_id
FROM employee_hr_data
WHERE first_name NOT LIKE '%T%' AND first_name NOT LIKE '%t%'
ORDER BY department_id ASC;

-- Employees without commission
SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary
FROM employee_hr_data
WHERE commission_pct IS NULL OR commission_pct = 0;

-- Employees having manager
SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary,
    manager_id
FROM employee_hr_data
WHERE manager_id IS NOT NULL;

-- Pattern match on first name
SELECT *
FROM employee_hr_data
WHERE LOWER(first_name) LIKE '%f%' 
   OR LOWER(first_name) LIKE '%t%' 
   OR LOWER(first_name) LIKE '%m%'
ORDER BY salary DESC;

-- Complex filter
SELECT 
    CONCAT(first_name, ' ', last_name) AS full_name,
    hire_date,
    commission_pct,
    CONCAT(email, '-', phone_number) AS contact_info,
    salary
FROM employee_hr_data
WHERE salary > 12000
   OR SUBSTRING(phone_number, 7, 1) = '3'
ORDER BY first_name DESC;

-- Third letter = 's'
SELECT first_name, last_name, department_id
FROM employee_hr_data
WHERE LOWER(SUBSTRING(first_name, 3, 1)) = 's';

-- ============================================
-- AGGREGATIONS
-- ============================================

-- Employees with more than 2 job histories
SELECT employee_id
FROM job_history_hr_data
GROUP BY employee_id
HAVING COUNT(job_id) > 2;

-- Salary stats by job
SELECT 
    job_id,
    COUNT(*) AS employee_count,
    SUM(salary) AS total_salary,
    MAX(salary) - MIN(salary) AS salary_difference
FROM employee_hr_data
GROUP BY job_id;

-- Managers with employee count
SELECT 
    manager_id,
    COUNT(*) AS number_of_employees
FROM employee_hr_data
WHERE manager_id IS NOT NULL
GROUP BY manager_id;

-- Department-wise average salary
SELECT 
    department_id, 
    AVG(salary) AS average_salary
FROM employee_hr_data
WHERE commission_pct IS NOT NULL
GROUP BY department_id;

-- Departments with more than 10 commissioned employees
SELECT department_id
FROM employee_hr_data
WHERE commission_pct IS NOT NULL
GROUP BY department_id
HAVING COUNT(employee_id) > 10;

-- ============================================
-- SUBQUERIES
-- ============================================

-- Employees earning above company average
SELECT e.employee_id, e.first_name, e.salary
FROM employee_hr_data e
WHERE e.salary > (SELECT AVG(salary) FROM employee_hr_data);

-- Employees in same department as Clara
SELECT first_name, last_name, hire_date
FROM employee_hr_data
WHERE department_id = 
      (SELECT department_id FROM employee_hr_data WHERE first_name = 'Clara')
  AND first_name != 'Clara';

-- ============================================
-- CASE / CONDITIONAL LOGIC
-- ============================================

SELECT 
    employee_id,
    CONCAT(first_name, ' ', last_name) AS name,
    CASE 
        WHEN job_id = 'ST_MAN' THEN 'SALESMAN'
        WHEN job_id = 'IT_PROG' THEN 'DEVELOPER'
        ELSE job_id
    END AS job_role
FROM employee_hr_data;

-- ============================================
-- JOINS
-- ============================================

-- Employee + Department + Location
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    l.city,
    l.state_province
FROM employee_hr_data e
INNER JOIN department_hr_data d 
    ON e.department_id = d.department_id
INNER JOIN location_hr_data l 
    ON d.location_id = l.location_id;

-- Salary grade mapping
SELECT 
    e.first_name,
    e.last_name,
    e.salary,
    g.grade_level
FROM employee_hr_data e
JOIN job_grades_hr_data g 
    ON e.salary BETWEEN g.lowest_sal AND g.highest_sal;

-- Final corrected CONCAT query
SELECT 
    j.job_title,
    d.department_name,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.hire_date AS joining_date
FROM employee_hr_data e
JOIN department_hr_data d 
    ON e.department_id = d.department_id
JOIN jobs_hr_data j
    ON e.job_id = j.job_id
WHERE e.hire_date = '1993-01-01';

-- ============================================
-- WINDOW FUNCTION
-- ============================================

SELECT 
    department_id,
    employee_id,
    salary,
    AVG(salary) OVER (PARTITION BY department_id) AS dept_avg_salary
FROM employee_hr_data;


