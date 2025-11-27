-- Base analyze without materilizing
-- Planned Hours
EXPLAIN ANALYZE
WITH base AS (
    SELECT
        c.course_code AS course_code,
        ci.instance_id AS course_instance_id,
        cl.hp AS hp,
        sp.period_code AS study_period,
        ci.num_students AS num_students,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS lecture_hours,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS tutorial_hours,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Lab' THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS lab_hours,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS seminar_hours,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Other Overhead' THEN pa.planned_hours * ta.factor ELSE 0 END)::numeric, 2) AS other_overhead_hours
    FROM course_instance ci
    JOIN course_layout cl   ON cl.course_layout_id = ci.course_layout_id
    JOIN course c           ON c.course_id = cl.course_id
    JOIN study_period sp    ON sp.study_period_id = ci.study_period_id
    JOIN planned_activity pa  ON pa.course_instance_id = ci.course_instance_id
    JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
    WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY c.course_code, ci.instance_id, cl.hp, sp.period_code, ci.num_students
)
SELECT 
    *, 
    ROUND((32 + 0.725 * num_students)::numeric, 2) AS exam_hours,
    ROUND((2 * hp + 28 + 0.2 * num_students)::numeric, 2) AS admin_hours, 
    ROUND(
        lecture_hours + tutorial_hours + lab_hours + seminar_hours + other_overhead_hours + 
        (32 + 0.725 * num_students) + (2 * hp + 28 + 0.2 * num_students) 
    ) AS total_hours
FROM base 
ORDER BY course_code, course_instance_id;


-- Actual Allocated Hours
EXPLAIN ANALYZE
SELECT 
        c.course_code AS course_code,
        ci.instance_id AS course_instance_id,
        cl.hp AS hp,
        p.first_name || ' ' || p.last_name AS teacher_name,
        jt.job_title AS designation,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS lecture_hours,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS tutorial_hours,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Lab' THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS lab_hours,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS seminar_hours,
        ROUND(SUM(CASE WHEN ta.activity_name = 'Other Overhead' THEN epa.actual_allocated_hours * ta.factor ELSE 0 END)::numeric, 2) AS other_overhead_hours,
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

WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE) 
AND c.course_code = 'AL7106' -- This WHERE clause is what the Index will speed up later!

GROUP BY c.course_code, ci.instance_id, cl.hp, p.first_name, p.last_name, jt.job_title, ci.num_students
ORDER BY c.course_code, ci.instance_id, teacher_name;

-- Teacher load
EXPLAIN ANALYZE
SELECT 
        c.course_code AS course_code,
        ci.instance_id AS course_instance_id,
        cl.hp AS hp,
        sp.period_code AS period_code,
        p.first_name ||' '|| p.last_name AS teacher_name,
        SUM(epa.actual_allocated_hours * ta.factor) AS total_actual_hours

FROM course_instance ci
JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id
JOIN course c on c.course_id = cl.course_id
JOIN planned_activity pa ON pa.course_instance_id = ci.course_instance_id
JOIN study_period sp ON sp.study_period_id = ci.study_period_id
JOIN teaching_activity ta ON ta.teaching_activity_id = pa.teaching_activity_id
JOIN employee_planned_activity epa ON epa.teaching_activity_id = ta.teaching_activity_id AND epa.course_instance_id = ci.course_instance_id
JOIN employee e ON e.employee_id = epa.employee_id
JOIN person p ON p.person_id = e.person_id

WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE) 
AND p.first_name = 'Alice' -- The target for optimization
AND p.last_name = 'Johnson'

GROUP BY c.course_code, ci.instance_id, cl.hp, p.first_name, p.last_name, ci.num_students, sp.period_code

ORDER BY c.course_code, ci.instance_id, teacher_name;

-- High workload check
EXPLAIN ANALYZE
SELECT 
        e.employee_id AS employee,
        p.first_name || ' ' || p.last_name AS teacher_name, 
        sp.period_code AS study_period,
        COUNT(DISTINCT ci.course_instance_id) AS num_courses
FROM employee e
JOIN person p ON p.person_id = e.person_id
JOIN employee_planned_activity epa ON epa.employee_id = e.employee_id
JOIN course_instance ci ON ci.course_instance_id = epa.course_instance_id
JOIN study_period sp ON sp.study_period_id = ci.study_period_id

GROUP BY e.employee_id, e.employment_id, p.first_name, p.last_name, sp.period_code

HAVING COUNT(DISTINCT ci.course_instance_id) > 1 -- Using 1 for test data, or 4 for real scenario

ORDER BY e.employment_id, teacher_name, sp.period_code, num_courses;

-- Materilized benchmark
-- Planned hours
EXPLAIN ANALYZE SELECT * FROM allocated_hours_course_view;

-- Test the Indices
EXPLAIN ANALYZE 
SELECT * FROM allocated_hours_course_view 
WHERE course_code = 'AL7106';

-- Test Overloaded Teachers
EXPLAIN ANALYZE 
SELECT e.employment_id, COUNT(DISTINCT ci.course_instance_id) 
FROM employee e
JOIN employee_planned_activity epa ON epa.employee_id = e.employee_id
JOIN course_instance ci ON ci.course_instance_id = epa.course_instance_id
GROUP BY e.employment_id
HAVING COUNT(DISTINCT ci.course_instance_id) > 4;

-- Course instances with planned vs actual variance > 15%
EXPLAIN ANALYZE
SELECT 
    mv.course_code,
    mv.total_planned_hours,
    actuals.total_actual_hours
FROM mv_planned_hours_calculations mv
JOIN (
    -- This subquery calculates live actuals
    SELECT 
        ci.course_instance_id,
        SUM(epa.actual_allocated_hours * ta.factor) + MAX(32 + 0.725 * ci.num_students) + MAX(2 * cl.hp + 28 + 0.2 * ci.num_students) AS total_actual_hours
    FROM course_instance ci
    JOIN course_layout cl ON cl.course_layout_id = ci.course_layout_id
    JOIN employee_planned_activity epa ON epa.course_instance_id = ci.course_instance_id
    JOIN teaching_activity ta ON ta.teaching_activity_id = epa.teaching_activity_id
    GROUP BY ci.course_instance_id
) actuals ON actuals.course_instance_id = mv.course_instance_id
WHERE ABS(actuals.total_actual_hours - mv.total_planned_hours) / NULLIF(mv.total_planned_hours,0) > 0.15;