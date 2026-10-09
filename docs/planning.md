# Hospital Database — Design and Implementation Plan

## 1. Project Objective

Design, implement, and validate a relational hospital database
using MySQL 8.0 and four datasets supplied for HPDM206Z.

The database must represent hospitals, doctors, patients,
and prescriptions, preserve their relationships, and support
six required SQL operations.

## 2. Requirements Analysis

The database must:

1. Import the four supplied CSV datasets accurately.
2. Define appropriate primary and foreign keys.
3. Assign every patient to exactly one existing doctor.
4. Maintain valid doctor-to-hospital relationships.
5. Associate prescriptions with patients and doctors.
6. Support all six specified SQL operations.
7. Provide reproducible SQL scripts and documentation.
8. Demonstrate meaningful development through Git.

## 3. Input Data

| Dataset | Records | Primary Key |
|---------|---------|-------------|
| hospitals.csv | 40 | hospital_id |
| doctors.csv | 100 | person_id |
| patients.csv | 600 | person_id |
| prescriptions.csv | 500 | prescription_id |

Total: 1,240 records.

### Initial Data Validation

The original CSV files were inspected using Python's csv module.

The validation checked:
- Record counts and column names
- Missing values
- Duplicate primary-key identifiers
- Invalid foreign-key references
- Maximum observed field lengths
- Hospital size range

Results:
- Missing values: 0
- Duplicate primary keys: 0
- Invalid foreign-key references: 0
- Hospital sizes: 52–494

These checks informed the subsequent schema design.

## 4. Database Design

The database uses four separate relational tables.

### Primary Keys

Each table uses an integer primary key to uniquely identify
its records.

### Foreign Keys

- doctors.hospital_id references hospitals.hospital_id
- patients.doctor_id references doctors.person_id
- prescriptions.patient_id references patients.person_id
- prescriptions.doctor_id references doctors.person_id

All foreign-key columns are NOT NULL.

### Cardinality

Each hospital may have multiple doctors.

Each doctor belongs to exactly one hospital and may have
multiple assigned patients.

Each patient is assigned to exactly one doctor and may
have multiple prescriptions.

Each prescription belongs to exactly one patient and
references exactly one prescribing doctor.

### Data Types

INT represents identifiers and hospital capacity.

VARCHAR represents names, addresses, medication names,
roles, hospital types, and accreditation statuses.

DATE represents birth dates and prescription dates.

String lengths were selected with capacity beyond the
maximum values observed in the original datasets.

### Integrity and Normalisation

Hospital, doctor, and patient attributes are stored in
separate tables to avoid repeating their descriptive
information in prescription records.

Foreign keys enforce referential integrity.

A CHECK constraint enforces positive hospital capacity.

The patient's assigned doctor is distinct from the
prescribing doctor in the database model. This preserves
the relationships present in the source data.

InnoDB provides transactional support and foreign-key
enforcement.

## 5. Implementation Workflow

### Database Construction Pseudocode

BEGIN

    Inspect the four CSV files

    Identify entities, attributes, and relationships

    Validate source IDs and missing values

    Create the hospital database

    Create HOSPITALS table

    Create DOCTORS table
        Reference HOSPITALS

    Create PATIENTS table
        Reference DOCTORS

    Create PRESCRIPTIONS table
        Reference PATIENTS and DOCTORS

    Import hospitals.csv
    Import doctors.csv
    Import patients.csv
    Import prescriptions.csv

    Verify record counts

    Verify foreign-key relationships

    Execute six required SQL operations

    Verify outputs and database integrity

END

### Import Order

The import sequence follows foreign-key dependencies:

1. Hospitals
2. Doctors
3. Patients
4. Prescriptions

This avoids importing child records before their
referenced parent records exist.

## 6. SQL Operations — Pseudocode

### Query 1: Doctors at a Selected Hospital

INPUT: hospital_id

JOIN hospitals with doctors using hospital_id

FILTER records by selected hospital_id

RETURN hospital name, doctor ID, and doctor name

SORT by doctor name and ID

### Query 2: Patient Prescription History

INPUT: patient_id

JOIN patients with prescriptions using patient_id

JOIN prescriptions with doctors using doctor_id

FILTER by selected patient_id

RETURN medication, prescription date, and doctor

SORT by prescription date and prescription ID

### Query 3: Prescriptions Issued by a Doctor

INPUT: doctor_id

JOIN doctors with prescriptions using doctor_id

JOIN prescriptions with patients using patient_id

FILTER by selected doctor_id

RETURN prescription and patient information

SORT chronologically

### Query 4: Insert a New Patient

INPUT: patient details and existing doctor_id

IDENTIFY an unused patient ID

BEGIN transaction

INSERT patient record with assigned doctor_id

VERIFY new patient and doctor relationship

ROLLBACK test transaction to preserve source data

END

The insertion was tested successfully before rollback.

A persistent insertion would use COMMIT instead of
ROLLBACK after successful verification.

### Query 5: Doctor with Most Prescriptions

JOIN doctors with prescriptions

GROUP records by doctor identifier and name

COUNT prescriptions for each doctor

SORT counts in descending order

BREAK ties using ascending doctor ID

RETURN the first result

The supplied dataset was checked for ties at the maximum.

### Query 6: Doctors at the Largest Hospital

CALCULATE maximum hospital bed capacity

SELECT hospitals matching that maximum

JOIN those hospitals with their doctors

RETURN hospital and doctor information

SORT by hospital ID and doctor name

This handles hospitals sharing the same maximum capacity.

## 7. Verification Strategy

### Structural Verification

- Confirm four tables exist.
- Confirm all primary keys.
- Confirm four foreign-key relationships.
- Confirm the positive hospital-size constraint.

### Import Verification

Expected table counts:

- Hospitals: 40
- Doctors: 100
- Patients: 600
- Prescriptions: 500

All four CSV imports completed with zero warnings
and zero skipped records.

### Query Verification

All six required operations were executed in MySQL.

Selected verified results:

- Query 1: Hospital 22 includes Dr. Joshua Wright.
- Query 2: Patient 345 has a Lisinopril prescription.
- Query 3: Doctor 68 issued seven prescriptions.
- Query 4: A test patient was inserted and rolled back.
- Query 5: Doctor 19 issued the most prescriptions (13).
- Query 6: Hospital 11 has 494 beds and four doctors.

The complete saved SQL query script was also executed
successfully, with the original row counts preserved.

## 8. Reproducibility

The project separates:

- Database schema definitions
- Required SQL operations
- Database design documentation
- Planning and pseudocode
- Database export and restoration instructions

The schema is stored in sql/schema.sql.

The queries are stored in sql/queries.sql.

The ERD is stored in docs/erd.md.

Database restoration was independently tested using a separate
MySQL database, with all 1,240 records recovered and the
six required SQL operations successfully executed.

## 9. Design Limitations and Assumptions

The original column names are preserved to maintain
compatibility with the supplied CSV files.

Hospital size is interpreted as bed capacity, consistent
with the assignment's largest-hospital requirement.

The data model does not require the prescribing doctor
to equal the patient's assigned doctor.

The insertion example uses a rollback so repeated tests
do not permanently modify the original dataset.

The current design models the required entities and
relationships without introducing unnecessary tables
or unsupported clinical assumptions.
