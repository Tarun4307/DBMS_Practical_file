-- EXPERIMENT 6
-- AIM: Create stored procedure transfer_employee(emp_id, new_dept_id)
-- with validation/error handling, plus salary validation and audit triggers.
-- Uses the database and Employee/Department tables from Experiment 3.

-- 1. Stored procedure to transfer an employee between departments
DROP PROCEDURE IF EXISTS transfer_employee;
DELIMITER //

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_employee_count INT DEFAULT 0;
    DECLARE v_department_count INT DEFAULT 0;
    DECLARE v_current_dept INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred. Transaction rolled back.' AS message;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_employee_count
    FROM Employee
    WHERE emp_id = p_emp_id;

    IF v_employee_count = 0 THEN
        ROLLBACK;
        SELECT 'Error: Employee does not exist.' AS message;
    ELSE
        SELECT COUNT(*) INTO v_department_count
        FROM Department
        WHERE dept_id = p_new_dept_id;

        IF v_department_count = 0 THEN
            ROLLBACK;
            SELECT 'Error: Department does not exist.' AS message;
        ELSE
            SELECT dept_id INTO v_current_dept
            FROM Employee
            WHERE emp_id = p_emp_id;

            IF v_current_dept = p_new_dept_id THEN
                ROLLBACK;
                SELECT 'Error: Employee is already in this department.' AS message;
            ELSE
                UPDATE Employee
                SET dept_id = p_new_dept_id
                WHERE emp_id = p_emp_id;

                COMMIT;
                SELECT 'Employee transferred successfully.' AS message;
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

-- 2. Test employee department before and after transfer
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE e.emp_id = 101;

CALL transfer_employee(101, 3);

SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE e.emp_id = 101;

-- 3. Edge cases (expected messages)
CALL transfer_employee(999, 3);  -- Employee does not exist
CALL transfer_employee(101, 99); -- Department does not exist
CALL transfer_employee(101, 3);  -- If already in dept 3, reports same department

-- 4. Salary validation trigger for INSERT
DROP TRIGGER IF EXISTS validate_employee_salary;
DELIMITER //

CREATE TRIGGER validate_employee_salary
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary cannot be NULL and must be at least 15000';
    END IF;
END //

DELIMITER ;

-- 5. Test invalid and valid salary inserts.
-- Run the invalid INSERT separately; it is expected to fail.
INSERT INTO Employee (emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES (131, 'Test Employee', 'M', 10000, '2026-09-25', 1);

-- Valid insert (use this if employee 131 was not inserted above)
INSERT INTO Employee (emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES (131, 'Test Employee', 'M', 30000, '2026-09-25', 1);

SELECT emp_id, emp_name, salary FROM Employee WHERE emp_id = 131;

-- 6. Salary validation trigger for UPDATE
DROP TRIGGER IF EXISTS validate_employee_salary_update;
DELIMITER //

CREATE TRIGGER validate_employee_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary cannot be NULL and must be at least 15000';
    END IF;
END //

DELIMITER ;

-- Invalid update; expected to fail
UPDATE Employee SET salary = 5000 WHERE emp_id = 131;

-- 7. Create salary audit table
CREATE TABLE IF NOT EXISTS Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(30)
);

-- 8. Audit salary changes
DROP TRIGGER IF EXISTS salary_audit_trigger;
DELIMITER //

CREATE TRIGGER salary_audit_trigger
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO Salary_Audit (emp_id, old_salary, new_salary, action)
        VALUES (NEW.emp_id, OLD.salary, NEW.salary, 'SALARY UPDATED');
    END IF;
END //

DELIMITER ;

-- 9. Test audit logging
UPDATE Employee SET salary = 35000 WHERE emp_id = 131;
SELECT * FROM Salary_Audit;

UPDATE Employee SET salary = 40000 WHERE emp_id = 131;
UPDATE Employee SET salary = 45000 WHERE emp_id = 131;

SELECT audit_id, emp_id, old_salary, new_salary, action
FROM Salary_Audit
WHERE emp_id = 131;

-- Updating to the same salary should not create a new audit record
UPDATE Employee SET salary = 45000 WHERE emp_id = 131;

-- 10. Verify triggers and procedure
SHOW TRIGGERS;
SHOW PROCEDURE STATUS WHERE Db = DATABASE();
