-- =============================================
-- STEP 1: New Courses, Layouts, People, and Employees
-- =============================================

-- 1. New Courses
INSERT INTO course (course_code, course_name) VALUES
  ('CS5050', 'Artificial Intelligence'),
  ('DB6060', 'Database Systems'),
  ('NW7070', 'Network Security'),
  ('SE8080', 'Software Architecture'),
  ('PY9090', 'Advanced Python');

-- 2. New Layouts (Assuming IDs 11-15 generated above)
INSERT INTO course_layout (course_id, min_student, max_student, hp, valid_from_date) VALUES
  (11, 20, 60, 7.5, '2024-01-01'), 
  (12, 25, 50, 6.0, '2024-01-01'), 
  (13, 15, 40, 4.5, '2024-01-01'), 
  (14, 18, 45, 7.5, '2024-01-01'), 
  (15, 30, 70, 5.0, '2024-01-01');

-- 3. New People
INSERT INTO person (personal_number, first_name, last_name, address) VALUES
  ('11111111111', 'Kevin', 'Space', 'Star City'),
  ('22222222222', 'Laura', 'Time', 'Hour Town'),
  ('33333333333', 'Mike', 'Matter', 'Particle Village'),
  ('44444444444', 'Nina', 'Energy', 'Power City'),
  ('55555555555', 'Oscar', 'Light', 'Ray Town'),
  ('66666666666', 'Paul', 'Sound', 'Sonic City'),
  ('77777777777', 'Quinn', 'Force', 'Physics Park'),
  ('88888888888', 'Rachel', 'Motion', 'Speed Town'),
  ('99999999999', 'Steve', 'Gravity', 'Heavy City'),
  ('00000000000', 'Tina', 'Magnet', 'Field Town');

INSERT INTO person_phone (person_id, phone_nr) VALUES
  (11, '111-111-1111'), (12, '222-222-2222'), (13, '333-333-3333'), (14, '444-444-4444'),
  (15, '555-555-5555'), (16, '666-666-6666'), (17, '777-777-7777'), (18, '888-888-8888'),
  (19, '999-999-9999'), (20, '000-000-0000');

-- 4. New Employees
INSERT INTO employee (employment_id, person_id, job_title_id, supervisor, department_id) VALUES
  ('E011', 11, 1, NULL, 1),
  ('E012', 12, 2, 11, 1), -- Supervisor set immediately
  ('E013', 13, 3, 11, 1),
  ('E014', 14, 10, 11, 1),
  ('E015', 15, 1, NULL, 2),
  ('E016', 16, 3, 15, 2),
  ('E017', 17, 2, NULL, 3),
  ('E018', 18, 4, 17, 3),
  ('E019', 19, 10, 15, 2),
  ('E020', 20, 5, 17, 3);

INSERT INTO salary_history (employee_id, salary_amount, valid_from) VALUES
  (11, 85000, '2024-01-01'), (12, 76000, '2024-01-01'), (13, 65000, '2024-01-01'), 
  (14, 35000, '2024-01-01'), (15, 84000, '2024-01-01'), (16, 66000, '2024-01-01'),
  (17, 77000, '2024-01-01'), (18, 40000, '2024-01-01'), (19, 36000, '2024-01-01'), 
  (20, 42000, '2024-01-01');

-- =============================================
-- STEP 2: Course Instances
-- =============================================

INSERT INTO course_instance (instance_id, num_students, study_period_id, study_year, course_layout_id) VALUES
  ('CS5050ht24', 45, 1, 2024, 11),
  ('CS5050ht25', 55, 1, 2025, 11),
  ('CS5050ht26', 60, 1, 2026, 11),
  ('DB6060ht24', 30, 2, 2024, 12),
  ('DB6060ht25', 35, 2, 2025, 12),
  ('DB6060ht26', 40, 2, 2026, 12),
  ('NW7070ht25', 25, 3, 2025, 13),
  ('PY9090P1ht25', 60, 1, 2025, 15),
  ('PY9090P3ht25', 50, 3, 2025, 15);

-- =============================================
-- STEP 3: Planned Activities (The Budget)
-- =============================================

INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES
  -- AI 2025
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 1, 30),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 2, 20),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 3, 10),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 4, 5),
  -- AI 2024 & 2026 (Simplified)
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht24'), 1, 30),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht26'), 1, 30),
  -- Database 2025
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'DB6060ht25'), 1, 24),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'DB6060ht25'), 2, 30),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'DB6060ht25'), 3, 12), -- Tutorial added
  -- Python
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 1, 20),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 2, 40),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P3ht25'), 4, 6), -- Seminar added
  -- Network Security
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'NW7070ht25'), 4, 8);

-- =============================================
-- STEP 4: Employee Allocations (FIXED: Added actual_allocated_hours)
-- =============================================

INSERT INTO employee_planned_activity 
(course_instance_id, teaching_activity_id, employee_id, actual_allocated_hours) 
VALUES
  -- Kevin (ID 11)
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 1, 11, 30.0),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 4, 11, 5.0),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 1, 11, 20.0),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 2, 11, 40.0),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht24'), 1, 11, 30.0),

  -- Laura (ID 12)
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 2, 12, 20.0),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'DB6060ht25'), 1, 12, 24.0),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P3ht25'), 4, 12, 6.0),

  -- Nina (ID 14)
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 3, 14, 10.0),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 2, 14, 38.5), -- Slightly different than planned
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'NW7070ht25'), 4, 14, 8.0),

  -- Steve (ID 19)
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'DB6060ht25'), 3, 19, 12.0);

-- =============================================
-- STEP 5: New Skills
-- =============================================

INSERT INTO skill (skill_name) VALUES 
('Deep Learning'), ('Cloud Computing'), ('Cybersecurity');

INSERT INTO employee_skill (employee_id, skill_id) VALUES 
(11, 10), -- Kevin
(12, 11), -- Laura
(13, 12); -- Mike