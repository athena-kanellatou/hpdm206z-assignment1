-- HPDM206Z Assignment 1
-- Hospital Database: Required SQL Operations
-- Database: hpdm206z_assessment1
-- MySQL 8.0
--
-- Run after importing the four supplied CSV datasets.
-- Query 4 uses a transaction and ROLLBACK to preserve
-- the original patient records.


-- =====================================================
-- QUERY 1: Doctors working at a specified hospital
-- =====================================================

SET @hospital_id = 22;

SELECT
    h.name AS hospital_name,
    d.person_id AS doctor_id,
    d.name AS doctor_name
FROM hospitals AS h
INNER JOIN doctors AS d
    ON h.hospital_id = d.hospital_id
WHERE h.hospital_id = @hospital_id
ORDER BY d.name, d.person_id;


-- =====================================================
-- QUERY 2: Prescriptions for a specified patient
-- Ordered chronologically
-- =====================================================

SET @patient_id = 345;

SELECT
    p.person_id AS patient_id,
    p.name AS patient_name,
    pr.prescription_id,
    pr.medication,
    pr.prescription_date,
    d.name AS prescribing_doctor
FROM patients AS p
INNER JOIN prescriptions AS pr
    ON p.person_id = pr.patient_id
INNER JOIN doctors AS d
    ON pr.doctor_id = d.person_id
WHERE p.person_id = @patient_id
ORDER BY pr.prescription_date ASC,
         pr.prescription_id ASC;


-- =====================================================
-- QUERY 3: Prescriptions issued by a specified doctor
-- =====================================================

SET @doctor_id = 68;

SELECT
    d.person_id AS doctor_id,
    d.name AS doctor_name,
    pr.prescription_id,
    p.name AS patient_name,
    pr.medication,
    pr.prescription_date
FROM doctors AS d
INNER JOIN prescriptions AS pr
    ON d.person_id = pr.doctor_id
INNER JOIN patients AS p
    ON pr.patient_id = p.person_id
WHERE d.person_id = @doctor_id
ORDER BY pr.prescription_date ASC,
         pr.prescription_id ASC;


-- =====================================================
-- QUERY 4: Insert a patient and assign an existing doctor
-- The transaction is rolled back after verification.
-- =====================================================

SET @new_patient_id = (
    SELECT COALESCE(MAX(person_id), 0) + 1
    FROM patients
);

START TRANSACTION;

INSERT INTO patients (
    person_id,
    name,
    date_of_birth,
    address,
    role,
    doctor_id
)
VALUES (
    @new_patient_id,
    'Assessment Test Patient',
    '1990-01-01',
    'Synthetic Test Address',
    'Patient',
    68
);

-- Verify the newly inserted patient.

SELECT
    p.person_id AS patient_id,
    p.name AS patient_name,
    d.name AS assigned_doctor,
    h.name AS hospital_name
FROM patients AS p
INNER JOIN doctors AS d
    ON p.doctor_id = d.person_id
INNER JOIN hospitals AS h
    ON d.hospital_id = h.hospital_id
WHERE p.person_id = @new_patient_id;

-- Preserve the original dataset.
ROLLBACK;


-- =====================================================
-- QUERY 5: Doctor who issued the most prescriptions
-- Doctor ID provides deterministic tie-breaking.
-- =====================================================

SELECT
    d.person_id AS doctor_id,
    d.name AS doctor_name,
    COUNT(pr.prescription_id) AS total_prescriptions
FROM doctors AS d
INNER JOIN prescriptions AS pr
    ON d.person_id = pr.doctor_id
GROUP BY d.person_id, d.name
ORDER BY total_prescriptions DESC,
         d.person_id ASC
LIMIT 1;


-- =====================================================
-- QUERY 6: Doctors working at the largest hospital
-- All hospitals tied for maximum size are included.
-- =====================================================

SELECT
    h.hospital_id,
    h.name AS hospital_name,
    h.size AS total_beds,
    d.person_id AS doctor_id,
    d.name AS doctor_name
FROM hospitals AS h
INNER JOIN doctors AS d
    ON h.hospital_id = d.hospital_id
WHERE h.size = (
    SELECT MAX(size)
    FROM hospitals
)
ORDER BY h.hospital_id,
         d.name,
         d.person_id;
