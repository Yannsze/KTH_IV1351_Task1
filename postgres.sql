-- =============================================
-- 1. CLEANUP: Drop old tables if they exist
-- =============================================
DROP TABLE IF EXISTS employee_planned_activity CASCADE;
DROP TABLE IF EXISTS planned_activity CASCADE;
DROP TABLE IF EXISTS person_phone CASCADE;
DROP TABLE IF EXISTS course_instance CASCADE;
DROP TABLE IF EXISTS teaching_activity CASCADE;
DROP TABLE IF EXISTS phone CASCADE;
DROP TABLE IF EXISTS salary_history CASCADE; -- New table
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS job_title CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS course_layout CASCADE;

-- =============================================
-- 2. CREATE TABLES (Higher Grade Structure)
-- =============================================

-- Modified: Includes versioning (valid_from_date) and removed UNIQUE from course_code
CREATE TABLE course_layout (
    course_layout_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code VARCHAR(50) NOT NULL, 
    course_name VARCHAR(100) NOT NULL,
    min_student INT NOT NULL,
    max_student INT NOT NULL,
    hp FLOAT NOT NULL,
    valid_from_date DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (course_code, valid_from_date) 
);

CREATE TABLE department (
    department_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    manager INT -- We will add the FK constraint later
);

CREATE TABLE person (
    person_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    personal_number VARCHAR(12) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL
);

CREATE TABLE job_title (
    job_title_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_title VARCHAR(100) UNIQUE NOT NULL
);

-- Modified: Salary removed from here
CREATE TABLE employee (
    employee_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employment_id VARCHAR(10) UNIQUE NOT NULL,
    interest_or_skill_set VARCHAR(500) NOT NULL,
    person_id INT NOT NULL,
    job_title_id INT NOT NULL,
    supervisor_or_manager INT,
    department_id INT
);

-- NEW TABLE: Handles Salary History
CREATE TABLE salary_history (
    salary_history_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id INT NOT NULL,
    salary_amount INT NOT NULL,
    valid_from DATE NOT NULL DEFAULT CURRENT_DATE,
    valid_to DATE
);

CREATE TABLE phone (
    phone_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    phone_no VARCHAR(20) NOT NULL
);

CREATE TABLE teaching_activity (
    teaching_activity_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    factor FLOAT NOT NULL,
    activity_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE course_instance (
    course_instance_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    instance_id VARCHAR(100) UNIQUE NOT NULL,
    num_students INT NOT NULL,
    study_period VARCHAR(2) NOT NULL,
    study_year INT NOT NULL,
    course_layout_id INT NOT NULL
);

CREATE TABLE person_phone (
    phone_id INT NOT NULL,
    person_id INT NOT NULL,
    PRIMARY KEY (phone_id, person_id)
);

CREATE TABLE planned_activity (
    planned_activity_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_instance_id INT NOT NULL,
    planned_hours INT NOT NULL,
    teaching_activity_id INT NOT NULL
);

CREATE TABLE employee_planned_activity (
    planned_activity_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (planned_activity_id, employee_id)
);

-- =============================================
-- 3. ADD CONSTRAINTS (Foreign Keys)
-- =============================================

ALTER TABLE department
    ADD CONSTRAINT fk_department_manager
    FOREIGN KEY (manager) REFERENCES employee (employee_id);

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_person
    FOREIGN KEY (person_id) REFERENCES person (person_id);

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_job_title
    FOREIGN KEY (job_title_id) REFERENCES job_title (job_title_id);

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_supervisor
    FOREIGN KEY (supervisor_or_manager) REFERENCES employee (employee_id);

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_department
    FOREIGN KEY (department_id) REFERENCES department (department_id);

-- New FK for Salary History
ALTER TABLE salary_history
    ADD CONSTRAINT fk_salary_employee
    FOREIGN KEY (employee_id) REFERENCES employee (employee_id);

ALTER TABLE course_instance
    ADD CONSTRAINT fk_course_instance_layout
    FOREIGN KEY (course_layout_id) REFERENCES course_layout (course_layout_id);

ALTER TABLE person_phone
    ADD CONSTRAINT fk_person_phone_phone
    FOREIGN KEY (phone_id) REFERENCES phone (phone_id);

ALTER TABLE person_phone
    ADD CONSTRAINT fk_person_phone_person
    FOREIGN KEY (person_id) REFERENCES person (person_id);

ALTER TABLE planned_activity
    ADD CONSTRAINT fk_planned_activity_instance
    FOREIGN KEY (course_instance_id) REFERENCES course_instance (course_instance_id);

ALTER TABLE planned_activity
    ADD CONSTRAINT fk_planned_activity_teaching
    FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity (teaching_activity_id);

ALTER TABLE employee_planned_activity
    ADD CONSTRAINT fk_emp_planned_activity_activity
    FOREIGN KEY (planned_activity_id) REFERENCES planned_activity (planned_activity_id);

ALTER TABLE employee_planned_activity
    ADD CONSTRAINT fk_emp_planned_activity_employee
    FOREIGN KEY (employee_id) REFERENCES employee (employee_id);

-- =============================================
-- 4. ADVANCED LOGIC: Max 4 Courses Trigger
-- =============================================

-- Function to check the workload
CREATE OR REPLACE FUNCTION check_teacher_workload() 
RETURNS TRIGGER AS $$
DECLARE
    target_period VARCHAR(2);
    target_year INT;
    current_course_count INT;
    is_already_teaching_this_course BOOLEAN;
BEGIN
    -- Get period and year for the new activity
    SELECT ci.study_period, ci.study_year
    INTO target_period, target_year
    FROM planned_activity pa
    JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
    WHERE pa.planned_activity_id = NEW.planned_activity_id;

    -- Count existing courses for this teacher in this period
    SELECT COUNT(DISTINCT ci.course_instance_id)
    INTO current_course_count
    FROM employee_planned_activity epa
    JOIN planned_activity pa ON epa.planned_activity_id = pa.planned_activity_id
    JOIN course_instance ci ON pa.course_instance_id = ci.course_instance_id
    WHERE epa.employee_id = NEW.employee_id
      AND ci.study_period = target_period
      AND ci.study_year = target_year;

    -- If limit reached, verify if they are adding a NEW course or just more hours to an EXISTING course
    IF current_course_count >= 4 THEN
        SELECT EXISTS (
            SELECT 1
            FROM employee_planned_activity epa
            JOIN planned_activity pa ON epa.planned_activity_id = pa.planned_activity_id
            WHERE epa.employee_id = NEW.employee_id
              AND pa.course_instance_id = (
                  SELECT course_instance_id 
                  FROM planned_activity 
                  WHERE planned_activity_id = NEW.planned_activity_id
              )
        ) INTO is_already_teaching_this_course;

        IF NOT is_already_teaching_this_course THEN
            RAISE EXCEPTION 'Teacher % is already allocated to 4 courses in Period %-%', 
                NEW.employee_id, target_period, target_year;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach the Trigger
CREATE TRIGGER enforce_max_course_load
BEFORE INSERT ON employee_planned_activity
FOR EACH ROW
EXECUTE FUNCTION check_teacher_workload();