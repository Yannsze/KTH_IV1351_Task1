-- DROP tables (for debugging)
DROP INDEX IF EXISTS index_pa_course_instance;
DROP INDEX IF EXISTS index_epa_employee;
DROP INDEX IF EXISTS index_epa_course_instance;
DROP INDEX IF EXISTS index_ci_study_period;

-- FK is not automatically indexed in SQL 
-- In order to find for e.g. planned hours per course instance, we look for the table pa and find ci 
CREATE INDEX index_pa_course_instance ON planned_activity (course_instance_id);

CREATE INDEX index_epa_employee ON employee_planned_activity(employee_id);
CREATE INDEX index_epa_course_instance ON employee_planned_activity(course_instance_id);

CREATE INDEX index_ci_study_period ON course_instance(study_period_id);