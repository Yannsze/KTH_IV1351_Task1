CREATE TABLE course_layout (
 course_layout_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 course_code UNIQUE VARCHAR(50) NOT NULL,
 course_name VARCHAR(100) NOT NULL,
 min_student INT NOT NULL,
 max_student INT NOT NULL,
 hp INT NOT NULL
);

ALTER TABLE course_layout ADD CONSTRAINT PK_course_layout PRIMARY KEY (course_layout_id);


CREATE TABLE department (
 department_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 department_name UNIQUE VARCHAR(100) NOT NULL,
 manager INT GENERATED ALWAYS AS IDENTITY NOT NULL
);

ALTER TABLE department ADD CONSTRAINT PK_department PRIMARY KEY (department_id);


CREATE TABLE employee (
 employee_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 employment_id UNIQUE VARCHAR(10) NOT NULL,
 interest_or_skill_set VARCHAR(500) NOT NULL,
 salary INT NOT NULL,
 person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 job_title_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 supervisor_or_manager INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 department_id INT GENERATED ALWAYS AS IDENTITY NOT NULL
);

ALTER TABLE employee ADD CONSTRAINT PK_employee PRIMARY KEY (employee_id);


CREATE TABLE job_title (
 job_title_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 job_title UNIQUE VARCHAR(100) NOT NULL
);

ALTER TABLE job_title ADD CONSTRAINT PK_job_title PRIMARY KEY (job_title_id);


CREATE TABLE person (
 person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 personal_number UNIQUE VARCHAR(12) NOT NULL,
 first_name VARCHAR(100) NOT NULL,
 last_name VARCHAR(100) NOT NULL,
 address VARCHAR(100) NOT NULL
);

ALTER TABLE person ADD CONSTRAINT PK_person PRIMARY KEY (person_id);


CREATE TABLE phone (
 phone_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 phone_no VARCHAR(20) NOT NULL
);

ALTER TABLE phone ADD CONSTRAINT PK_phone PRIMARY KEY (phone_id);


CREATE TABLE teaching_activity (
 teaching_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 factor FLOAT(10) NOT NULL,
 activity_name UNIQUE VARCHAR(100) NOT NULL
);

ALTER TABLE teaching_activity ADD CONSTRAINT PK_teaching_activity PRIMARY KEY (teaching_activity_id);


CREATE TABLE course_instance (
 course_instance_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 instance_id UNIQUE VARCHAR(100) NOT NULL,
 num_students INT NOT NULL,
 study_period VARCHAR(2) NOT NULL,
 study_year INT NOT NULL,
 course_layout_id INT GENERATED ALWAYS AS IDENTITY NOT NULL
);

ALTER TABLE course_instance ADD CONSTRAINT PK_course_instance PRIMARY KEY (course_instance_id);


CREATE TABLE person_phone (
 phone_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL
);

ALTER TABLE person_phone ADD CONSTRAINT PK_person_phone PRIMARY KEY (phone_id,person_id);


CREATE TABLE planned_activity (
 course_instance_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 planned_hours INT NOT NULL,
 teaching_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL
);

ALTER TABLE planned_activity ADD CONSTRAINT PK_planned_activity PRIMARY KEY (course_instance_id);


CREATE TABLE employee_planned_activity (
 course_instance_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 employee_id INT GENERATED ALWAYS AS IDENTITY NOT NULL
);

ALTER TABLE employee_planned_activity ADD CONSTRAINT PK_employee_planned_activity PRIMARY KEY (course_instance_id,employee_id);


ALTER TABLE department ADD CONSTRAINT FK_department_0 FOREIGN KEY (manager) REFERENCES employee (employee_id);


ALTER TABLE employee ADD CONSTRAINT FK_employee_0 FOREIGN KEY (person_id) REFERENCES person (person_id);
ALTER TABLE employee ADD CONSTRAINT FK_employee_1 FOREIGN KEY (job_title_id) REFERENCES job_title (job_title_id);
ALTER TABLE employee ADD CONSTRAINT FK_employee_2 FOREIGN KEY (supervisor_or_manager) REFERENCES employee (employee_id);
ALTER TABLE employee ADD CONSTRAINT FK_employee_3 FOREIGN KEY (department_id) REFERENCES department (department_id);


ALTER TABLE course_instance ADD CONSTRAINT FK_course_instance_0 FOREIGN KEY (course_layout_id) REFERENCES course_layout (course_layout_id);


ALTER TABLE person_phone ADD CONSTRAINT FK_person_phone_0 FOREIGN KEY (phone_id) REFERENCES phone (phone_id);
ALTER TABLE person_phone ADD CONSTRAINT FK_person_phone_1 FOREIGN KEY (person_id) REFERENCES person (person_id);


ALTER TABLE planned_activity ADD CONSTRAINT FK_planned_activity_0 FOREIGN KEY (course_instance_id) REFERENCES course_instance (course_instance_id);
ALTER TABLE planned_activity ADD CONSTRAINT FK_planned_activity_1 FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity (teaching_activity_id);


ALTER TABLE employee_planned_activity ADD CONSTRAINT FK_employee_planned_activity_0 FOREIGN KEY (course_instance_id) REFERENCES planned_activity (course_instance_id);
ALTER TABLE employee_planned_activity ADD CONSTRAINT FK_employee_planned_activity_1 FOREIGN KEY (employee_id) REFERENCES employee (employee_id);


