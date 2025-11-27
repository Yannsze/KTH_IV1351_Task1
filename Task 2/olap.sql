-- DROP tables (for debugging)
DROP VIEW [planned_hours_calculations_view];
DROP VIEW [allocated_hours_course_view];
DROP VIEW [allocated_hours_teacher];
DROP VIEW [allocated_employee_courses_view];

-- 1. Planend hours calculations  

-- Calculate the total hours (with the multiplication factor) along with the break-ups for each activity, 
-- current years' course instances 

CREATE VIEW planned_hours_calculations_view AS 
With base AS ( -- temporary calculates stored hours
    SELECT
        -- renaming (AS) for the output
        c.course_code AS course_code,
        ci.instance_id AS course_instance_id,
        cl.hp AS hp,
        sp.period_code AS study_period,
        ci.num_students AS num_students,

        -- Sum of individual activity categories
        -- ROUND requires the data type in numeric, 2 = 2 decimals
        ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture'
                THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS lecture_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial'
                THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS tutorial_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Lab'
                THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS lab_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar'
                THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS seminar_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Other Overhead'
                THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS other_overhead_hours

    -- inner join 
    FROM course_instance ci
    JOIN course_layout cl   ON cl.course_layout_id = ci.course_layout_id
    JOIN course c           ON c.course_id = cl.course_id
    JOIN study_period sp    ON sp.study_period_id = ci.study_period_id
    JOIN planned_activity pa  ON pa.course_instance_id = ci.course_instance_id
    JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id

    -- only current year's course instances
    WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)

    -- adds together SUM row
    GROUP BY 
        c.course_code,
        ci.instance_id,
        cl.hp,
        sp.period_code,
        ci.num_students
)

SELECT -- add derived hours and totals 
-- SQL does not allow alias to be used in the same SELECT list
    *, 
    ROUND((32 + 0.725 * num_students)::numeric, 2) AS exam_hours,
    ROUND((2 * hp + 28 + 0.2 * num_students)::numeric, 2) AS admin_hours, 

    ROUND(
        lecture_hours + tutorial_hours + lab_hours + seminar_hours + other_overhead_hours + 
        (32 + 0.725 * num_students) + (2 * hp + 28 + 0.2 * num_students) 
    ) AS total_hours

FROM base 
ORDER BY course_code, course_instance_id;
-- Use SELECT * FROM planned_hours_calculations_view; to see the table


-- 2. Actual allocated hours for a course
-- Total allocated hours (with multiplication factors) for a teacher, only for the current years' course instances 

CREATE VIEW allocated_hours_course_view AS
SELECT 
        c.course_code AS course_code,
        ci.instance_id AS course_instance_id,
        cl.hp AS hp,
        p.first_name || ' ' || p.last_name AS teacher_name,
        jt.job_title AS designation,

        -- Sum activity per teacher
        ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS lecture_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS tutorial_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Lab'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS lab_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS seminar_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Other Overhead'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS other_overhead_hours,

        -- Derived
        ROUND((32 + 0.725 * num_students)::numeric, 2) AS exam_hours,
        ROUND((2 * hp + 28 + 0.2 * num_students)::numeric, 2) AS admin_hours, 

        (
                ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +

                ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +

                ROUND(SUM(CASE WHEN ta.activity_name = 'Lab'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +

                ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +

                ROUND(SUM(CASE WHEN ta.activity_name = 'Other Overhead'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +
                ROUND((32 + 0.725 * num_students)::numeric, 2) +
                ROUND((2 * hp + 28 + 0.2 * num_students)::numeric, 2)
        ) AS total_hours

FROM course_instance ci
JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id
JOIN course c on c.course_id = cl.course_id
JOIN planned_activity pa ON pa.course_instance_id = ci.course_instance_id
JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
JOIN employee_planned_activity epa ON epa.teaching_activity_id = ta.teaching_activity_id AND epa.course_instance_id = ci.course_instance_id
JOIN employee e ON e.employee_id = epa.employee_id
JOIN person p ON p.person_id = e.person_id
JOIN job_title jt ON jt.job_title_id = e.job_title_id

-- Only current year & specific course
WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE) 
AND c.course_code = 'AL7106' -- to show only one course 

-- Group
GROUP BY
        c.course_code, 
        ci.instance_id,
        cl.hp,
        p.first_name,
        p.last_name,
        jt.job_title,
        ci.num_students

ORDER BY 
        c.course_code,
        ci.instance_id,
        teacher_name; 


-- 3. Total allocated hours for one teacher (only current year's course)

CREATE VIEW allocated_hours_teacher AS
SELECT 
        c.course_code AS course_code,
        ci.instance_id AS course_instance_id,
        cl.hp AS hp,
        sp.period_code AS period_code,
        p.first_name ||' '|| p.last_name AS teacher_name,

        -- Sum activity per teacher
        ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS lecture_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS tutorial_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Lab'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS lab_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS seminar_hours,

        ROUND(SUM(CASE WHEN ta.activity_name = 'Other Overhead'
                THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS other_overhead_hours,

        -- Derived
        ROUND((32 + 0.725 * num_students)::numeric, 2) AS exam_hours,
        ROUND((2 * hp + 28 + 0.2 * num_students)::numeric, 2) AS admin_hours, 

        (
                ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +

                ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +

                ROUND(SUM(CASE WHEN ta.activity_name = 'Lab'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +

                ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +

                ROUND(SUM(CASE WHEN ta.activity_name = 'Other Overhead'
                        THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) +
                ROUND((32 + 0.725 * num_students)::numeric, 2) +
                ROUND((2 * hp + 28 + 0.2 * num_students)::numeric, 2)
        ) AS total_hours

FROM course_instance ci
JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id
JOIN course c on c.course_id = cl.course_id
JOIN planned_activity pa ON pa.course_instance_id = ci.course_instance_id
JOIN study_period sp ON sp.study_period_id = ci.study_period_id
JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
JOIN employee_planned_activity epa ON epa.teaching_activity_id = ta.teaching_activity_id AND epa.course_instance_id = ci.course_instance_id
JOIN employee e ON e.employee_id = epa.employee_id
JOIN person p ON p.person_id = e.person_id

-- Only current year & specific teacher
WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE) 
AND p.first_name = 'Alice' -- to show only one teaaher 
AND p.last_name = 'Johnson'

-- Group
GROUP BY
        c.course_code, 
        ci.instance_id,
        cl.hp,
        p.first_name,
        p.last_name,
        ci.num_students,
        sp.period_code

ORDER BY 
        c.course_code,
        ci.instance_id,
        teacher_name; 

-- 4. List employee ids & names of all teachers who are allocated in more than a specific number of course instances during current period 
CREATE OR REPLACE VIEW allocated_employee_courses_view AS
SELECT 
    e.employee_id AS employee,
    p.first_name || ' ' || p.last_name AS teacher_name, 
    ci.study_year,
    sp.period_code AS study_period,
    COUNT(DISTINCT ci.course_instance_id) AS num_courses
FROM employee e
JOIN person p ON p.person_id = e.person_id
JOIN employee_planned_activity epa ON epa.employee_id = e.employee_id
JOIN course_instance ci ON ci.course_instance_id = epa.course_instance_id
JOIN study_period sp ON sp.study_period_id = ci.study_period_id
GROUP BY 
    e.employee_id,
    e.employment_id, 
    p.first_name,
    p.last_name, 
    ci.study_year,
    sp.period_code
HAVING COUNT(DISTINCT ci.course_instance_id) > 0
ORDER BY
    e.employment_id,
    ci.study_year,
    study_period;

SELECT * FROM allocated_employee_courses_view
WHERE study_year = 2025 AND study_period IN ('P1', 'P4');