-- HPDM206Z Assignment 1
-- Hospital Database Validation
--
-- Run against the original populated database
-- or a fresh restoration before test insertions.
-- This script does not modify any records.

-- 1. Verify original dataset counts

SELECT
    'Hospitals' AS validation,
    COUNT(*) AS actual,
    40 AS expected,
    IF(COUNT(*) = 40, 'PASS', 'FAIL') AS result
FROM hospitals

UNION ALL

SELECT 'Doctors', COUNT(*), 100,
       IF(COUNT(*) = 100, 'PASS', 'FAIL')
FROM doctors

UNION ALL

SELECT 'Patients', COUNT(*), 600,
       IF(COUNT(*) = 600, 'PASS', 'FAIL')
FROM patients

UNION ALL

SELECT 'Prescriptions', COUNT(*), 500,
       IF(COUNT(*) = 500, 'PASS', 'FAIL')
FROM prescriptions;


-- 2. Verify foreign-key relationships

SELECT
    'Doctors to hospitals' AS validation,
    COUNT(*) AS invalid_references
FROM doctors d
LEFT JOIN hospitals h
    ON d.hospital_id = h.hospital_id
WHERE h.hospital_id IS NULL

UNION ALL

SELECT
    'Patients to doctors',
    COUNT(*)
FROM patients p
LEFT JOIN doctors d
    ON p.doctor_id = d.person_id
WHERE d.person_id IS NULL

UNION ALL

SELECT
    'Prescriptions to patients',
    COUNT(*)
FROM prescriptions pr
LEFT JOIN patients p
    ON pr.patient_id = p.person_id
WHERE p.person_id IS NULL

UNION ALL

SELECT
    'Prescriptions to doctors',
    COUNT(*)
FROM prescriptions pr
LEFT JOIN doctors d
    ON pr.doctor_id = d.person_id
WHERE d.person_id IS NULL;


-- 3. Verify the number of foreign-key constraints

SELECT
    COUNT(*) AS foreign_key_count,
    IF(COUNT(*) = 4, 'PASS', 'FAIL') AS result
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = DATABASE();


-- 4. Verify the hospital capacity constraint

SELECT
    COUNT(*) AS invalid_hospital_sizes,
    IF(COUNT(*) = 0, 'PASS', 'FAIL') AS result
FROM hospitals
WHERE size <= 0;
