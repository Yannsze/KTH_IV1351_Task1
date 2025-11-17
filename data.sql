-- =============================================
-- STEP 1: Independent Tables (No Foreign Keys)
-- =============================================

INSERT INTO job_title (job_title) VALUES
  ('Professor'), ('Associate Professor'), ('Lecturer'), ('Research Assistant'), 
  ('Lab Technician'), ('Course Coordinator'), ('Department Head'), 
  ('Administrator'), ('HR Manager'), ('Teaching Assistant');

INSERT INTO person (personal_number, first_name, last_name, address) VALUES
  ('12345678901', 'John', 'Doe', '123 Main St, Cityville'),
  ('23456789012', 'Jane', 'Smith', '456 Oak St, Townsville'),
  ('34567890123', 'Alice', 'Johnson', '789 Pine St, Villageburg'),
  ('45678901234', 'Bob', 'Brown', '101 Maple St, Suburbia'),
  ('56789012345', 'Carol', 'White', '202 Birch St, Countryside'),
  ('67890123456', 'David', 'Green', '303 Cedar St, Metrocity'),
  ('78901234567', 'Eve', 'Black', '404 Elm St, Urbania'),
  ('89012345678', 'Frank', 'Blue', '505 Redwood St, Lakeside'),
  ('90123456789', 'Grace', 'Yellow', '606 Fir St, Coastcity'),
  ('12345678902', 'Henry', 'Red', '707 Palm St, Hilltop');

INSERT INTO phone (phone_no) VALUES
  ('123-456-7890'), ('234-567-8901'), ('345-678-9012'), ('456-789-0123'),
  ('567-890-1234'), ('678-901-2345'), ('789-012-3456'), ('890-123-4567'),
  ('901-234-5678'), ('012-345-6789');

INSERT INTO teaching_activity (factor, activity_name) VALUES
  (3.6, 'Lecture'), (2.4, 'Lab'), (2.4, 'tutorial'), (1.8, 'Seminar');

INSERT INTO course_layout (course_code, course_name, min_student, max_student, hp) VALUES
  ('AL7106','Digital design',23,37,7.5),
  ('OM9831','Calculus',24,35,4.5),
  ('HW1213','Linear Algebra',18,53,3.5),
  ('OB4248','Signal processing',18,54,6.5),
  ('HW4527','Embeded system',17,59,3.5),
  ('NJ2179','Data storage',25,36,5.5),
  ('TT5533','Discrete Mathematics',22,51,6.5),
  ('WX3742','Algebra and Geometry',22,41,5.5),
  ('QR3473','Basic Economics',17,57,7.5),
  ('GL2258','Advance Economics',21,51,5.5);

-- =============================================
-- STEP 2: Tables with Partial Dependencies
-- =============================================

-- Insert Departments WITHOUT Manager first (avoid circular dependency)
INSERT INTO department (department_name, manager) VALUES
  ('Computer Science', NULL),
  ('Mathematics', NULL),
  ('Electrical Engineering', NULL);

-- Insert Person_Phone links
INSERT INTO person_phone (phone_id, person_id) VALUES
  (1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

-- Insert Employees (Removed Salary, Set Supervisor to NULL initially)
INSERT INTO employee (employment_id, interest_or_skill_set, person_id, job_title_id, supervisor_or_manager, department_id) VALUES
  ('1', 'Machine Learning, AI', 1, 1, NULL, 1),
  ('2', 'Calculus, Analysis', 2, 2, NULL, 2),
  ('3', 'Digital Design, Embedded Systems', 3, 3, NULL, 3),
  ('4', 'Signal Processing, Algorithms', 4, 4, NULL, 3),
  ('5', 'Networking, Databases', 5, 5, NULL, 1),
  ('6', 'Econometrics, Finance', 6, 6, NULL, 2),
  ('7', 'Quantum Physics, Optics', 7, 7, NULL, 3),
  ('8', 'Construction Engineering, Project Management', 8, 8, NULL, 3),
  ('9', 'Business Strategy, Marketing', 9, 9, NULL, 1),
  ('0', 'Legal Studies, Ethics', 10, 10, NULL, 2);

-- =============================================
-- STEP 3: Fix Circular Dependencies & Add History
-- =============================================

-- Now that Employees exist, we can add their Salary History (Higher Grade Req)
INSERT INTO salary_history (employee_id, salary_amount, valid_from) VALUES
  (1, 80000, '2024-01-01'),
  (2, 75000, '2024-01-01'),
  (3, 72000, '2024-01-01'),
  (4, 78000, '2024-01-01'),
  (5, 74000, '2024-01-01'),
  (6, 80000, '2024-01-01'),
  (7, 77000, '2024-01-01'),
  (8, 76000, '2024-01-01'),
  (9, 79000, '2024-01-01'),
  (10, 82000, '2024-01-01');

-- Update Department Managers
UPDATE department SET manager = 1 WHERE department_name = 'Computer Science';
UPDATE department SET manager = 2 WHERE department_name = 'Mathematics';
UPDATE department SET manager = 3 WHERE department_name = 'Electrical Engineering';

-- Update Employee Supervisors
UPDATE employee SET supervisor_or_manager = 2 WHERE employment_id = '1';
UPDATE employee SET supervisor_or_manager = 3 WHERE employment_id = '2';
UPDATE employee SET supervisor_or_manager = 4 WHERE employment_id = '3';
UPDATE employee SET supervisor_or_manager = 5 WHERE employment_id = '4';
UPDATE employee SET supervisor_or_manager = 6 WHERE employment_id = '5';
UPDATE employee SET supervisor_or_manager = 7 WHERE employment_id = '6';
UPDATE employee SET supervisor_or_manager = 8 WHERE employment_id = '7';
UPDATE employee SET supervisor_or_manager = 9 WHERE employment_id = '8';
UPDATE employee SET supervisor_or_manager = 10 WHERE employment_id = '9';
UPDATE employee SET supervisor_or_manager = 1 WHERE employment_id = '0';

-- =============================================
-- STEP 4: Course Instances and Activities
-- =============================================

INSERT INTO course_instance (instance_id, num_students, study_period, study_year, course_layout_id) VALUES
  ('AL7106ht25', 30, 'P1', 2025, 1),
  ('HW1213ht25', 35, 'P1', 2025, 3),
  ('OM9831ht25', 25, 'P1', 2025, 2),
  ('OB4248ht25', 40, 'P1', 2025, 4),
  ('HW4527ht25', 22, 'P1', 2025, 5),
  ('NJ2179ht25', 29, 'P2', 2025, 6),
  ('TT5533ht25', 38, 'P2', 2025, 7),
  ('WX3742ht25', 26, 'P2', 2025, 8),
  ('QR3473ht25', 32, 'P2', 2025, 9),
  ('GL2258ht25', 33, 'P2', 2025, 10);

INSERT INTO planned_activity (course_instance_id, planned_hours, teaching_activity_id) VALUES
  (1, 24, 1), (1, 16, 2), -- Course 1: Lec, Lab
  (2, 20, 1), (2, 10, 3), -- Course 2: Lec, Tutorial
  (3, 18, 1), (3, 12, 3), -- Course 3: Lec, Tutorial
  (4, 22, 1), (4, 14, 2), -- Course 4: Lec, Lab
  (5, 15, 2), (5, 15, 2); -- Course 5: Lab, Lab

INSERT INTO employee_planned_activity (planned_activity_id, employee_id) VALUES
  (1, 1), (2, 3),
  (3, 2), (4, 2),
  (5, 5), (6, 4),
  (7, 3), (8, 4),
  (9, 1), (10, 5);