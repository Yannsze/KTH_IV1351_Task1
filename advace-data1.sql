-- =============================================
-- TEST 1: Salary History
-- =============================================
-- Scenario: John Doe gets a raise. We don't overwrite the old salary; we add a new record.
INSERT INTO salary_history (employee_id, salary_amount, valid_from) 
VALUES (1, 95000, CURRENT_DATE);

-- Verify: Check history for Employee 1 (John Doe)
SELECT p.first_name, p.last_name, s.salary_amount, s.valid_from
FROM salary_history s
JOIN employee e ON s.employee_id = e.employee_id
JOIN person p ON e.person_id = p.person_id
WHERE e.employee_id = 1
ORDER BY s.valid_from DESC; 
-- Result should show 2 rows: 95000 (today) and 80000 (2024-01-01).

-- =============================================
-- TEST 2: Course Layout Versioning
-- =============================================
-- Scenario: 'AL7106' changes HP from 7.5 to 10.0 starting tomorrow.
INSERT INTO course_layout (course_code, course_name, min_student, max_student, hp, valid_from_date)
VALUES ('AL7106', 'Digital design', 23, 37, 10.0, CURRENT_DATE + 1);

-- Verify: We now have two layouts for AL7106.
SELECT course_code, hp, valid_from_date 
FROM course_layout 
WHERE course_code = 'AL7106';

-- =============================================
-- TEST 3: "Max 4 Courses" Constraint (The Big One)
-- =============================================
-- Scenario: We will try to assign Employee 1 (John Doe) to 5 DIFFERENT courses in Period P1 2025.
-- Note: John is already assigned to Course Instance 1 and 5 in Period P1 (from previous script).
-- So he has 2 courses allocated. We need to add 3 more to trigger the error.

-- 1. Create extra courses for P1 so we have enough targets
INSERT INTO course_instance (instance_id, num_students, study_period, study_year, course_layout_id) VALUES
  ('TEST_COURSE_A', 20, 'P1', 2025, 6),
  ('TEST_COURSE_B', 20, 'P1', 2025, 7),
  ('TEST_COURSE_C', 20, 'P1', 2025, 8);

-- 2. Create planned activities for these courses
INSERT INTO planned_activity (course_instance_id, planned_hours, teaching_activity_id) VALUES
  (11, 10, 1), -- Activity ID 11 (for TEST_COURSE_A)
  (12, 10, 1), -- Activity ID 12 (for TEST_COURSE_B)
  (13, 10, 1); -- Activity ID 13 (for TEST_COURSE_C)

-- 3. Assign John to Course A (This is his 3rd course) -> Should SUCCESS
INSERT INTO employee_planned_activity (planned_activity_id, employee_id) VALUES (11, 1);

-- 4. Assign John to Course B (This is his 4th course) -> Should SUCCESS
INSERT INTO employee_planned_activity (planned_activity_id, employee_id) VALUES (12, 1);

-- 5. Assign John to Course C (This is his 5th course) -> Should FAIL
-- Expected Error: "Teacher 1 is already allocated to 4 courses in Period P1-2025"
INSERT INTO employee_planned_activity (planned_activity_id, employee_id) VALUES (13, 1);


-- !!!!! Here is for the report!!!!
-- Why use a Trigger instead of Java/Python code?

--     Data Integrity: If you enforce the "Max 4" rule in a Java app, a database administrator could still manually run an SQL script to insert a 5th course, breaking the rule. By putting the Trigger in the database, the rule is enforced always, no matter how the data is accessed.

-- Why Versioning?

--     Reproducibility: If you just changed the HP from 7.5 to 10.0 in the old table, you would change history. A student who took the course in 2020 (when it was 7.5hp) would suddenly look like they took 10.0hp. Your new model preserves historical truth.







-- ============================================================
-- SCENARIO: Course Layout Changes between Period 1 and Period 2
-- ============================================================

-- 1. Create the Original Layout (Version 1)
-- Valid from Jan 1st, 2025. HP is 7.5.
INSERT INTO course_layout (course_code, course_name, min_student, max_student, hp, valid_from_date)
VALUES ('IV1351', 'Data Storage Paradigms', 50, 150, 7.5, '2025-01-01');

-- 2. Create the Course Instance for PERIOD 1
-- We link this to the layout we just created (let's assume it got ID 11 or we select it)
INSERT INTO course_instance (instance_id, num_students, study_period, study_year, course_layout_id)
VALUES ('IV1351-P1-2025', 100, 'P1', 2025, 
    (SELECT course_layout_id FROM course_layout WHERE course_code = 'IV1351' AND hp = 7.5)
);

-- 3. The University decides to change the course for Period 2.
-- We Create a NEW Layout (Version 2). 
-- Valid from June 1st, 2025. HP is changed to 15.0.
INSERT INTO course_layout (course_code, course_name, min_student, max_student, hp, valid_from_date)
VALUES ('IV1351', 'Data Storage Paradigms', 50, 150, 15.0, '2025-06-01');

-- 4. Create the Course Instance for PERIOD 2
-- We link this to the NEW layout (15.0 HP)
INSERT INTO course_instance (instance_id, num_students, study_period, study_year, course_layout_id)
VALUES ('IV1351-P2-2025', 120, 'P2', 2025, 
    (SELECT course_layout_id FROM course_layout WHERE course_code = 'IV1351' AND hp = 15.0)
);

-- ============================================================
-- VERIFICATION: Check the results
-- ============================================================

SELECT 
    ci.instance_id,
    ci.study_period,
    cl.course_code,
    cl.hp AS credits_awarded,
    cl.valid_from_date
FROM course_instance ci
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
WHERE cl.course_code = 'IV1351'
ORDER BY ci.study_period;