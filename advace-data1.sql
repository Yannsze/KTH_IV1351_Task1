-- TEST 1: Salary History
INSERT INTO salary_history (employee_id, salary_amount, valid_from) 
VALUES (1, 95000, CURRENT_DATE);

-- Verify: Check that John has two salary records now.
SELECT p.first_name, p.last_name, s.salary_amount, s.valid_from
FROM salary_history s
JOIN employee e ON s.employee_id = e.employee_id
JOIN person p ON e.person_id = p.person_id
WHERE e.employee_id = 1
ORDER BY s.valid_from DESC;

-- TEST 2: Course Layout Versioning
INSERT INTO course_layout (course_id, min_student, max_student, hp, valid_from_date)
VALUES (1, 23, 37, 10.0, CURRENT_DATE + 1);

-- Verify: We join tables to see the code and the different HP versions.
SELECT c.course_code, cl.hp, cl.valid_from_date 
FROM course_layout cl
JOIN course c ON cl.course_id = c.course_id
WHERE c.course_code = 'AL7106';


-- TEST 3: "Max 4 Courses" Constraint
INSERT INTO course_instance (instance_id, num_students, study_period_id, study_year, course_layout_id) VALUES
  ('TEST_COURSE_A', 20, 1, 2025, 5), 
  ('TEST_COURSE_B', 20, 1, 2025, 6), 
  ('TEST_COURSE_C', 20, 1, 2025, 7), 
  ('TEST_COURSE_d', 20, 1, 2025, 8); 
INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES
  (11, 1, 10), 
  (12, 1, 10), 
  (13, 1, 10), 
  (14, 1, 10); 
INSERT INTO employee_planned_activity (employee_id, teaching_activity_id, course_instance_id, actual_allocated_hours) VALUES 
  (1, 1, 11,10),
  (1, 1, 12,10),
  (1, 1, 13,10);

-- Verify: Should recive a error message.
INSERT INTO employee_planned_activity (employee_id, teaching_activity_id, course_instance_id, actual_allocated_hours) VALUES 
(1, 1, 14,10);
