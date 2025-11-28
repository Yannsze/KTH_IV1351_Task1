-- Benchmark after indices & materialized view is performed.

-- Drop if exists to avoid conflicts during testing
DROP MATERIALIZED VIEW IF EXISTS mv_planned_hours_calculations CASCADE;

CREATE MATERIALIZED VIEW mv_planned_hours_calculations AS 
With base AS ( 
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

    -- group together rows in a table that has the same values
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

FROM base;


-------- Create indices --------

-- Create an Index on the MV to make joining it later (for the Variance query) fast
CREATE INDEX idx_mv_planned_instance ON mv_planned_hours_calculations(course_instance_id);

-- 1. Index for filtering by Year (used in all queries)
CREATE INDEX idx_ci_study_year ON course_instance(study_year);
-- 2. Index for filtering by Course Code (used in Query 2)
CREATE INDEX idx_course_code ON course(course_code);
-- 3. Index for filtering by Teacher Name (used in Query 3)
CREATE INDEX idx_person_name ON person(last_name, first_name);
-- 4. Foreign Key Indexes (Speed up joins between Employee, Activity, and Instance)
CREATE INDEX idx_epa_join ON employee_planned_activity(course_instance_id, teaching_activity_id);
CREATE INDEX idx_pa_join ON planned_activity(course_instance_id, teaching_activity_id);


-------- Perform analyze after indices --------
EXPLAIN ANALYZE SELECT * FROM mv_planned_hours_calculations;

EXPLAIN ANALYZE SELECT * FROM planned_hours_calculations_view;

EXPLAIN ANALYZE SELECT * FROM allocated_hours_course_view;

ExPLAIN ANALYZE SELECT * FROM allocated_hours_teacher_view;

EXPLAIN ANALYZE SELECT * FROM allocated_employee_courses_view;