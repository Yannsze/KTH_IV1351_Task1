-- Base analyze with our queries (without materilized view nor indices)

-- 1. Planned Hours
EXPLAIN ANALYZE SELECT * FROM planned_hours_calculations_view;

-- 2. Actual Allocated Hours for a course
EXPLAIN ANALYZE SELECT * FROM allocated_hours_course_view;

-- 3. Teacher load
EXPLAIN ANALYZE SELECT* FROM allocated_hours_teacher_view;

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