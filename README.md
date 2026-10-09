# Hospital Database Management Using MySQL

**HPDM206Z — Computational Skills and Python for Health and Life Sciences**

**Assignment 1 | MSc Health Data Science | University of Exeter**

## 1. Project Overview

The aim of this assignment was to design and implement a relational database for managing information about hospitals, doctors, patients and prescriptions.

I used MySQL 8.0 to create the database from four supplied CSV files, establish relationships between the tables, and develop six SQL operations to retrieve and manage the information.

My main priorities were to maintain the integrity of the original data, use appropriate relational database structures, and make the implementation reproducible. I also used Git to document the main stages of development.

## 2. Dataset and Database Structure

The database contains four tables and 1,240 records imported from the supplied datasets.

| Table | Records | Primary key |
|---|---:|---|
| `hospitals` | 40 | `hospital_id` |
| `doctors` | 100 | `person_id` |
| `patients` | 600 | `person_id` |
| `prescriptions` | 500 | `prescription_id` |
| **Total** | **1,240** | |

The tables are connected through four foreign-key relationships:

- `doctors.hospital_id` references `hospitals.hospital_id`.
- `patients.doctor_id` references `doctors.person_id`.
- `prescriptions.patient_id` references `patients.person_id`.
- `prescriptions.doctor_id` references `doctors.person_id`.

Each doctor belongs to one hospital, and each patient is assigned to exactly one doctor. Prescriptions are linked to both the patient receiving the medication and the doctor prescribing it.

I kept the patient's assigned doctor and the prescribing doctor as separate relationships because the supplied data does not require these to be the same person.

The database uses InnoDB, integer primary keys, `NOT NULL` constraints and foreign keys to enforce referential integrity. A `CHECK` constraint also prevents hospital capacity from being zero or negative.

A full Entity Relationship Diagram, including attributes, data types and relationship cardinalities, is available in [`docs/erd.md`](docs/erd.md).

## 3. Repository Organisation

| File | Description |
|---|---|
| `README.md` | Project overview, setup instructions and results |
| `sql/schema.sql` | MySQL table definitions and constraints |
| `sql/hospital_database.sql` | Complete database export, including all records |
| `sql/queries.sql` | The six required SQL operations |
| `docs/erd.md` | Entity Relationship Diagram and explanation of relationships |
| `docs/planning.md` | Design decisions, pseudocode and verification approach |

The complete database export is provided separately from the schema so that the structure can be examined independently, while the populated database can also be restored directly.

## 4. Implementation Approach

I began by inspecting the CSV files using Python's `csv` module to understand the attributes, data types and relationships before creating the tables.

This included checking for missing values, duplicate identifiers and foreign-key references that did not match existing records. No missing values, duplicate primary keys or invalid foreign-key references were identified.

I then created the tables in dependency order:

1. Hospitals
2. Doctors
3. Patients
4. Prescriptions

This order was important because the parent records needed to exist before importing records containing references to them.

After creating the schema, I imported the datasets using `LOAD DATA LOCAL INFILE`. All 1,240 records were imported successfully, without skipped records or MySQL warnings.

The implementation and query logic are documented further in [`docs/planning.md`](docs/planning.md).

## 5. Required SQL Operations

The six operations are implemented in [`sql/queries.sql`](sql/queries.sql).

| Query | Purpose | SQL concepts |
|---|---|---|
| 1 | List doctors working at a selected hospital | `INNER JOIN`, `WHERE`, `ORDER BY` |
| 2 | Retrieve a patient's prescriptions in chronological order | Multiple `JOIN`s, date ordering |
| 3 | Retrieve prescriptions issued by a selected doctor | Multiple `JOIN`s, filtering |
| 4 | Insert a new patient assigned to an existing doctor | `INSERT`, transactions, `ROLLBACK` |
| 5 | Identify the doctor with the most prescriptions | `COUNT`, `GROUP BY`, `ORDER BY`, `LIMIT` |
| 6 | List doctors working at the largest hospital | `MAX`, subquery, `JOIN` |

For Query 4, I tested the insertion within a transaction and used `ROLLBACK` after verifying the new patient's relationship with an existing doctor. This allowed me to demonstrate the operation without permanently changing the original dataset.

Query 5 uses doctor ID as a secondary sorting criterion to give a consistent result in the event of a tie. Query 6 includes hospitals sharing the maximum capacity, if such a tie exists.

## 6. Running the Project

### Requirements

- MySQL 8.0 or compatible
- A MySQL account with permission to create databases and tables
- A terminal or MySQL client
- Git, if cloning the repository

### Restore the Database

Clone this repository, or download its contents and open a terminal in the project directory.

Create an empty MySQL database:

    mysql -u YOUR_USERNAME -p -e "CREATE DATABASE hospital_assignment CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"

Restore the complete database:

    mysql -u YOUR_USERNAME -p hospital_assignment < sql/hospital_database.sql

The export contains the four tables, their constraints and the original 1,240 records. The separate `schema.sql` file is provided for examining the table definitions and should not be imported again after restoring the complete database.

### Execute the SQL Queries

Run the saved SQL operations against the restored database:

    mysql -u YOUR_USERNAME -p --table hospital_assignment < sql/queries.sql

Replace `YOUR_USERNAME` with an account that has the necessary MySQL permissions.

The queries use example identifiers from the supplied datasets. The variables at the beginning of the relevant queries can be changed to examine other doctors, hospitals or patients.

The insertion example uses a transaction that is rolled back, so executing the script does not permanently add the test patient.

## 7. Testing and Validation

I checked the database at several stages rather than relying only on successful SQL execution.

The checks included:

- Confirming that all four tables and four foreign-key relationships were created.
- Checking the number of imported records against the original datasets.
- Verifying that the CSV imports completed without warnings.
- Executing all six required SQL operations.
- Testing the patient insertion and confirming that `ROLLBACK` restored the original patient count.
- Checking the result of the highest-prescribing-doctor query for ties.
- Restoring the complete database export into a separate MySQL database and repeating the SQL operations.

### Selected Results

| Test | Result |
|---|---|
| Doctors at hospital 22 | Dr. Joshua Wright |
| Patient 345 prescription history | Lisinopril, 23 October 2023 |
| Prescriptions issued by doctor 68 | 7 |
| Test patient insertion | Successful; reverted using `ROLLBACK` |
| Highest number of prescriptions | Dr. Taylor Sanchez (ID 19), 13 |
| Largest hospital | Peters, Anderson and Baker Hospital, 494 beds |
| Doctors at largest hospital | 4 |

The independent database restoration recovered the expected 40 hospitals, 100 doctors, 600 patients and 500 prescriptions. The saved query script also executed successfully against the restored database, with the original record counts preserved.

## 8. Design Decisions and Limitations

I chose to preserve the column names from the original CSV files rather than rename fields during import. This made it easier to check the relationship between the supplied data and the implemented database.

The schema uses separate tables for hospitals, doctors, patients and prescriptions, avoiding unnecessary repetition of descriptive information. The foreign-key constraints also help prevent references to records that do not exist.

Hospital `size` is interpreted as bed capacity for the largest-hospital query, in accordance with the assignment requirements.

The project focuses on the relationships and operations specified in the assessment. It is not intended to represent a complete clinical information system. For example, it does not include patient encounters, detailed medication dosing, prescribing authorisation or historical changes in doctor assignments.

These features would be relevant in a larger healthcare database but fall outside the scope of this assignment.

## 9. Conclusion

This assignment helped me apply relational database concepts to a healthcare-related dataset, particularly primary and foreign keys, joins, aggregation and data integrity.

The most useful part of the process was seeing how the database design affected later operations. Establishing the relationships correctly made it possible to retrieve information across multiple tables without duplicating the underlying records.

I also gained practical experience in checking the data before import, using transactions to test changes safely, and validating that a database can be reconstructed from an exported SQL file.

The final implementation provides a reproducible relational database and all six SQL operations required for the assignment.
