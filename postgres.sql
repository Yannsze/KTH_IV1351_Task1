-- PostgreSQL-compatible schema

CREATE TABLE course_layout (
    course_layout_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code VARCHAR(50) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    min_student INT NOT NULL,
    max_student INT NOT NULL,
    hp FLOAT NOT NULL
);

CREATE TABLE department (
    department_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    manager INT
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

CREATE TABLE employee (
    employee_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employment_id VARCHAR(10) UNIQUE NOT NULL,
    interest_or_skill_set VARCHAR(500) NOT NULL,
    salary INT NOT NULL,
    person_id INT NOT NULL,
    job_title_id INT NOT NULL,
    supervisor_or_manager INT,
    department_id INT
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

-- Foreign keys

ALTER TABLE department
    ADD CONSTRAINT fk_department_manager
    FOREIGN KEY (manager)
    REFERENCES employee (employee_id);

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_person
    FOREIGN KEY (person_id)
    REFERENCES person (person_id);

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_job_title
    FOREIGN KEY (job_title_id)
    REFERENCES job_title (job_title_id);

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_supervisor
    FOREIGN KEY (supervisor_or_manager)
    REFERENCES employee (employee_id);

ALTER TABLE employee
    ADD CONSTRAINT fk_employee_department
    FOREIGN KEY (department_id)
    REFERENCES department (department_id);

ALTER TABLE course_instance
    ADD CONSTRAINT fk_course_instance_layout
    FOREIGN KEY (course_layout_id)
    REFERENCES course_layout (course_layout_id);

ALTER TABLE person_phone
    ADD CONSTRAINT fk_person_phone_phone
    FOREIGN KEY (phone_id)
    REFERENCES phone (phone_id);

ALTER TABLE person_phone
    ADD CONSTRAINT fk_person_phone_person
    FOREIGN KEY (person_id)
    REFERENCES person (person_id);

ALTER TABLE planned_activity
    ADD CONSTRAINT fk_planned_activity_instance
    FOREIGN KEY (course_instance_id)
    REFERENCES course_instance (course_instance_id);

ALTER TABLE planned_activity
    ADD CONSTRAINT fk_planned_activity_teaching
    FOREIGN KEY (teaching_activity_id)
    REFERENCES teaching_activity (teaching_activity_id);

ALTER TABLE employee_planned_activity
    ADD CONSTRAINT fk_emp_planned_activity_activity
    FOREIGN KEY (planned_activity_id)
    REFERENCES planned_activity (planned_activity_id);

ALTER TABLE employee_planned_activity
    ADD CONSTRAINT fk_emp_planned_activity_employee
    FOREIGN KEY (employee_id)
    REFERENCES employee (employee_id);
