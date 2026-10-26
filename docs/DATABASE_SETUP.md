# Database Architecture & Setup Guide: PostgreSQL 17

## 1. Prerequisites
- **PostgreSQL**: Version 17.x (tested on PostgreSQL 17.11 64-bit on Windows).
- **Default Port**: `5432`.
- **Database Name**: `hostelease_db`.
- **Administrative User**: `postgres`.

---

## 2. Automated & Scripted Database Installation
All SQL initialization scripts are located in the `database/` folder and MUST be executed in exact sequential order:

```bash
# 1. Connect to PostgreSQL and create database
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -f database/01_create_database.sql

# 2. Create tables, identity columns, foreign keys, and constraints
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/02_create_tables.sql

# 3. Create partial unique indexes and performance query indexes
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/03_constraints_indexes.sql

# 4. Seed academic sessions, facilities, blocks, rooms, beds, and fee structures
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/04_seed_data.sql

# 5. Seed sample accounts with verified BCrypt hashes and operational states
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/05_sample_accounts.sql

# 6. Create reporting views and audit functions
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/06_reports.sql
```

---

## 3. Core Relational Tables & Catalog

| Table Name | Primary Purpose / Constraints |
|---|---|
| `users` | Core authentication credentials, roles (`ADMIN`, `WARDEN`, `STUDENT`), BCrypt hash. |
| `hostels` | Residential facility complexes (e.g., Aryabhatta Boys, Gargi Girls), type, address. |
| `hostel_buildings` | Physical blocks within a hostel complex. |
| `hostel_floors` | Floor definitions per building. |
| `rooms` | Room records, room number, type (SINGLE, DOUBLE, TRIPLE), base capacity. |
| `beds` | Individual physical beds (`bed_label`) inside rooms. |
| `students` | University resident profiles, registration #, course, batch, guardian contact, current presence state. |
| `room_allocations` | Active and historical bed assignments with partial unique index integrity. |
| `student_leave_requests`| Leave and holiday applications, departure/return timestamps, parent contact, status. |
| `leave_history` | Audit trail of every leave state change (PENDING -> APPROVED -> DEPARTED -> RETURNED). |
| `fee_structures` | Invoicing schedule and fee categories per hostel and academic session. |
| `invoices` | Student fee bills, total amount, paid amount, balance, and due date. |
| `payments` | Transaction records, payment modes (UPI, Card, Cash), UTR reference, receipts. |
| `complaints` | Maintenance tickets, category (electrical, plumbing), priority, resolution notes. |
| `visitor_logs` | Security gate pass records, visitor identity, resident visited, in/out timestamps. |
| `notices` | Campus announcements and circulars targeted to residents. |
| `audit_logs` | Immutable security log tracking logins, allocations, payments, and leaves. |
| `notification_queue` | Outbox for asynchronous email (Jakarta Mail) and SMS alerts. |

---

## 4. Crucial Database Integrity Constraints

### Concurrency Protection via Partial Unique Indexes
To prevent double-allocations under concurrent user requests:
```sql
-- Guarantees that a bed can have AT MOST ONE active occupant
CREATE UNIQUE INDEX uq_active_bed_allocation 
ON room_allocations (bed_id) 
WHERE is_active = TRUE;

-- Guarantees that a student can have AT MOST ONE active bed assignment
CREATE UNIQUE INDEX uq_active_student_allocation 
ON room_allocations (student_id) 
WHERE is_active = TRUE;
```

### Date Validation Constraints
```sql
ALTER TABLE student_leave_requests 
ADD CONSTRAINT chk_leave_times 
CHECK (expected_return_datetime > departure_datetime);
```

---

## 5. Seeded Demo Accounts & Credentials

| Role | Username / Login Identifier | Password | Associated Facility / Notes |
|---|---|---|---|
| **System Admin** | `admin` | `Admin@123` | Institutional Administrator (Full privileges) |
| **Boys Warden** | `warden.boys` | `Warden@123` | Assigned to Aryabhatta Boys Hostel (Hostel ID 1) |
| **Girls Warden** | `warden.girls` | `Warden@123` | Assigned to Gargi Girls Hostel (Hostel ID 2) |
| **Student 1** | `student1@hostelease.com` (or `rohan.sharma`) | `Student@123` | Room 101, Bed B1 — State: **PRESENT (In Hostel)** |
| **Student 2** | `student2@hostelease.com` (or `priya.verma`) | `Student@123` | Room 101, Bed B2 — State: **AWAY (On Holiday Leave)** |
| **Student 3** | `student3@hostelease.com` (or `vikram.singh`) | `Student@123` | Room 101, Bed B3 — State: **OVERDUE (Late Return Alert)** |
| **Students 4–16** | `student4@hostelease.com` ... `student16` | `Student@123` | Various rooms across both hostels |
