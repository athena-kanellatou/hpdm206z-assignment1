-- HPDM206Z Assignment 1
-- Permanent patient insertion example
--
-- Run against a test/restored database when validating.
-- Unlike Query 4 in queries.sql, this script commits the change.
-- Requires an existing doctor with person_id = 68.

SET @assigned_doctor_id = 68;

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
    'Example New Patient',
    '1995-06-15',
    'Synthetic Assessment Address',
    'Patient',
    @assigned_doctor_id
);

COMMIT;

-- Verify the permanently inserted record.

SELECT
    p.person_id AS patient_id,
    p.name AS patient_name,
    d.name AS assigned_doctor
FROM patients AS p
INNER JOIN doctors AS d
    ON p.doctor_id = d.person_id
WHERE p.person_id = @new_patient_id;
