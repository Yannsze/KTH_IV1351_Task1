-- =============================================
-- EXTENSION SCRIPT: NEW DATA ONLY
-- Assumes existing IDs 1-10 are already used.
-- starting sequences from ID 11.
-- =============================================

-- =============================================
-- STEP 1: New Courses (IDs will be 11-15)
-- =============================================

INSERT INTO course (course_code, course_name) VALUES
  ('CS5050', 'Artificial Intelligence'),
  ('DB6060', 'Database Systems'),
  ('NW7070', 'Network Security'),
  ('SE8080', 'Software Architecture'),
  ('PY9090', 'Advanced Python');

-- =============================================
-- STEP 2: Course Layouts ( referencing IDs 11-15)
-- =============================================

INSERT INTO course_layout (course_id, min_student, max_student, hp, valid_from_date) VALUES
  (11, 20, 60, 7.5, '2024-01-01'), -- CS5050
  (12, 25, 50, 6.0, '2024-01-01'), -- DB6060
  (13, 15, 40, 4.5, '2024-01-01'), -- NW7070
  (14, 18, 45, 7.5, '2024-01-01'), -- SE8080
  (15, 30, 70, 5.0, '2024-01-01'); -- PY9090

-- =============================================
-- STEP 3: New People (IDs 11-20)
-- =============================================

INSERT INTO person (personal_number, first_name, last_name, address) VALUES
  ('11111111111', 'Kevin', 'Space', '101 Galaxy Dr, Star City'),
  ('22222222222', 'Laura', 'Time', '202 Clock Rd, Hour Town'),
  ('33333333333', 'Mike', 'Matter', '303 Atom Ave, Particle Village'),
  ('44444444444', 'Nina', 'Energy', '404 Joule St, Power City'),
  ('55555555555', 'Oscar', 'Light', '505 Photon Pl, Ray Town'),
  ('66666666666', 'Paul', 'Sound', '606 Wave Ln, Sonic City'),
  ('77777777777', 'Quinn', 'Force', '707 Newton Blvd, Physics Park'),
  ('88888888888', 'Rachel', 'Motion', '808 Kinetic St, Speed Town'),
  ('99999999999', 'Steve', 'Gravity', '909 Mass Ave, Heavy City'),
  ('00000000000', 'Tina', 'Magnet', '010 Pole Rd, Field Town');

INSERT INTO person_phone (person_id, phone_nr) VALUES
  (11, '111-111-1111'), (12, '222-222-2222'), (13, '333-333-3333'), (14, '444-444-4444'),
  (15, '555-555-5555'), (16, '666-666-6666'), (17, '777-777-7777'), (18, '888-888-8888'),
  (19, '999-999-9999'), (20, '000-000-0000');

-- =============================================
-- STEP 4: New Employees (IDs E011-E020)
-- =============================================

INSERT INTO employee (employment_id, person_id, job_title_id, supervisor, department_id) VALUES
  ('E011', 11, 1, NULL, 1), -- Kevin (CS Prof)
  ('E012', 12, 2, NULL, 1), -- Laura (CS Assoc Prof)
  ('E013', 13, 3, NULL, 1), -- Mike (CS Lecturer)
  ('E014', 14, 10, NULL, 1), -- Nina (TA)
  ('E015', 15, 1, NULL, 2), -- Oscar (Math)
  ('E016', 16, 3, NULL, 2), -- Paul (Math)
  ('E017', 17, 2, NULL, 3), -- Quinn (EE)
  ('E018', 18, 4, NULL, 3), -- Rachel (Research Asst)
  ('E019', 19, 10, NULL, 2), -- Steve (TA)
  ('E020', 20, 5, NULL, 3); -- Tina (Tech)

INSERT INTO salary_history (employee_id, salary_amount, valid_from) VALUES
  (11, 85000, '2024-01-01'), (12, 76000, '2024-01-01'),
  (13, 65000, '2024-01-01'), (14, 35000, '2024-01-01'),
  (15, 84000, '2024-01-01'), (16, 66000, '2024-01-01'),
  (17, 77000, '2024-01-01'), (18, 40000, '2024-01-01'),
  (19, 36000, '2024-01-01'), (20, 42000, '2024-01-01');

-- Update Supervisors for new employees
UPDATE employee SET supervisor = 11 WHERE employment_id IN ('E012', 'E013', 'E014');
UPDATE employee SET supervisor = 15 WHERE employment_id IN ('E016', 'E019');
UPDATE employee SET supervisor = 17 WHERE employment_id IN ('E018', 'E020');

-- =============================================
-- STEP 5: Course Instances (New Courses in 2024, 2025, 2026)
-- =============================================

INSERT INTO course_instance (instance_id, num_students, study_period_id, study_year, course_layout_id) VALUES
  -- AI Course (CS5050) - Runs every year
  ('CS5050ht24', 45, 1, 2024, 11),
  ('CS5050ht25', 55, 1, 2025, 11),
  ('CS5050ht26', 60, 1, 2026, 11),

  -- DB Course (DB6060) - Runs in Period 2
  ('DB6060ht24', 30, 2, 2024, 12),
  ('DB6060ht25', 35, 2, 2025, 12),
  ('DB6060ht26', 40, 2, 2026, 12),

  -- Network Security (NW7070) - 2025 Only
  ('NW7070ht25', 25, 3, 2025, 13),

  -- Python (PY9090) - Multiple periods in same year (Popular course)
  ('PY9090P1ht25', 60, 1, 2025, 15),
  ('PY9090P3ht25', 50, 3, 2025, 15);

-- =============================================
-- STEP 6: Planned Activities
-- =============================================

INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours) VALUES
  -- AI 2025
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 1, 30), -- Lecture
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 2, 20), -- Lab
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 3, 10), -- Tutorial
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 4, 5),  -- Seminar

  -- AI 2024 & 2026
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht24'), 1, 30), 
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht24'), 2, 20),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht26'), 1, 30), 
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht26'), 2, 20),

  -- Database 2025
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'DB6060ht25'), 1, 24), -- Lecture
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'DB6060ht25'), 2, 30), -- Heavy Lab component

  -- Python P1 2025
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 1, 20),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 2, 40),

  -- Python P3 2025
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P3ht25'), 1, 20),
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P3ht25'), 2, 40);


-- =============================================
-- STEP 7: Employee Planned Activities
-- Scenario: Employee 11 (Kevin) is very busy in Period 1 (Max 4 activities)
-- =============================================

INSERT INTO employee_planned_activity (course_instance_id, teaching_activity_id, employee_id) VALUES
  -- Kevin (ID 11) - Period 1 2025 Workload (4 Activities)
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 1, 11), -- AI Lecture
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 4, 11), -- AI Seminar
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 1, 11), -- Python Lecture
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 2, 11), -- Python Lab Supervision

  -- Laura (ID 12) - Helping with AI and DB
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 2, 12), -- AI Lab
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'DB6060ht25'), 1, 12), -- DB Lecture (Period 2)

  -- Nina (ID 14 - TA) - Busy with Labs
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht25'), 3, 14), -- AI Tutorial
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'PY9090P1ht25'), 2, 14), -- Python Lab

  -- Kevin in 2024 (Past)
  ((SELECT course_instance_id FROM course_instance WHERE instance_id = 'CS5050ht24'), 1, 11);


-- =============================================
-- STEP 8: New Skills
-- =============================================
-- Assuming Skill IDs 1-9 exist, adding 10-12
INSERT INTO skill (skill_name) VALUES 
('Deep Learning'), ('Cloud Computing'), ('Cybersecurity');

INSERT INTO employee_skill (employee_id, skill_id) VALUES 
(11, 10), -- Kevin knows Deep Learning
(12, 11), -- Laura knows Cloud
(13, 12); -- Mike knows Security
