-- ============================================================================
-- SCRIPT 05: SAMPLE ACCOUNTS AND REALISTIC OPERATIONAL DATA
-- Connect to 'hostelease_db' before executing this script!
-- Command: psql -U postgres -d hostelease_db -f 05_sample_accounts.sql
-- ============================================================================

-- Passwords:
-- Admin:   Admin@123   (Hash: $2a$10$goSinH4jFPbqCfo2MVQWneTFdrLKohySXyAhwCtQ6THPXvyebEC6C)
-- Warden:  Warden@123  (Hash: $2a$10$wXJNEFEXrGNzGLr7MnzHfeTMdf4tA2IAuo2c.87XUafm6JOVAYeQy)
-- Student: Student@123 (Hash: $2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu)

-- 1. Insert Users
INSERT INTO users (id, username, email, phone_number, password_hash, first_name, last_name, is_active) OVERRIDING SYSTEM VALUE VALUES
-- Admin (ID 1)
(1, 'admin', 'admin@hostelease.com', '+91 99999 00001', '$2a$10$goSinH4jFPbqCfo2MVQWneTFdrLKohySXyAhwCtQ6THPXvyebEC6C', 'Chief', 'Administrator', TRUE),
-- Wardens (ID 2, 3)
(2, 'warden.boys', 'warden.boys@hostelease.com', '+91 99999 00002', '$2a$10$wXJNEFEXrGNzGLr7MnzHfeTMdf4tA2IAuo2c.87XUafm6JOVAYeQy', 'Rajesh', 'Kumar', TRUE),
(3, 'warden.girls', 'warden.girls@hostelease.com', '+91 99999 00003', '$2a$10$wXJNEFEXrGNzGLr7MnzHfeTMdf4tA2IAuo2c.87XUafm6JOVAYeQy', 'Sunita', 'Sharma', TRUE),
-- Students (ID 4 - 19)
(4, 'rohan.sharma', 'student1@hostelease.com', '+91 98111 00001', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Rohan', 'Sharma', TRUE),
(5, 'amit.verma', 'student2@hostelease.com', '+91 98111 00002', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Amit', 'Verma', TRUE),
(6, 'vikram.singh', 'student3@hostelease.com', '+91 98111 00003', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Vikram', 'Singh', TRUE),
(7, 'rahul.mehta', 'student4@hostelease.com', '+91 98111 00004', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Rahul', 'Mehta', TRUE),
(8, 'ananya.sen', 'student5@hostelease.com', '+91 98111 00005', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Ananya', 'Sen', TRUE),
(9, 'priya.nair', 'student6@hostelease.com', '+91 98111 00006', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Priya', 'Nair', TRUE),
(10, 'sneha.patel', 'student7@hostelease.com', '+91 98111 00007', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Sneha', 'Patel', TRUE),
(11, 'karthik.iyer', 'student8@hostelease.com', '+91 98111 00008', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Karthik', 'Iyer', TRUE),
(12, 'nikhil.joshi', 'student9@hostelease.com', '+91 98111 00009', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Nikhil', 'Joshi', TRUE),
(13, 'aarav.gupta', 'student10@hostelease.com', '+91 98111 00010', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Aarav', 'Gupta', TRUE),
(14, 'devendra.yadav', 'student11@hostelease.com', '+91 98111 00011', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Devendra', 'Yadav', TRUE),
(15, 'manpreet.singh', 'student12@hostelease.com', '+91 98111 00012', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Manpreet', 'Singh', TRUE),
(16, 'tanmay.kulkarni', 'student13@hostelease.com', '+91 98111 00013', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Tanmay', 'Kulkarni', TRUE),
(17, 'harsh.agarwal', 'student14@hostelease.com', '+91 98111 00014', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Harsh', 'Agarwal', TRUE),
(18, 'siddharth.roy', 'student15@hostelease.com', '+91 98111 00015', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Siddharth', 'Roy', TRUE),
(19, 'neha.sharma', 'student16@hostelease.com', '+91 98111 00016', '$2a$10$P55Jt080JwDWeimnMEzNwuqW/R7vjDekgdI0AU9gl5W2DKDYmeUMu', 'Neha', 'Sharma', TRUE);

SELECT setval(pg_get_serial_sequence('users', 'id'), 19);

-- 2. User Roles Assignment
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), -- Admin
(2, 2), -- Warden Boys
(3, 2), -- Warden Girls
(4, 3), (5, 3), (6, 3), (7, 3), (8, 3), (9, 3), (10, 3),
(11, 3), (12, 3), (13, 3), (14, 3), (15, 3), (16, 3), (17, 3), (18, 3), (19, 3);

-- 3. Staff Records
INSERT INTO staff (id, user_id, staff_code, designation, assigned_hostel_id, emergency_contact) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 'STF-ADM-01', 'Chief Hostel Administrator', NULL, '+91 99999 11111'),
(2, 2, 'STF-WRD-01', 'Hostel Warden', 1, '+91 99999 22222'),
(3, 3, 'STF-WRD-02', 'Hostel Warden', 2, '+91 99999 33333');

SELECT setval(pg_get_serial_sequence('staff', 'id'), 3);

-- 4. Student Records (16 Students)
INSERT INTO students (id, user_id, roll_number, registration_no, course, batch_year, gender, dob, blood_group, guardian_name, guardian_phone, current_presence) OVERRIDING SYSTEM VALUE VALUES
(1, 4, 'CS23B101', 'REG-2023-0101', 'B.Tech Computer Science', 2023, 'MALE', '2005-04-12', 'B+', 'Suresh Sharma', '+91 94111 11111', 'PRESENT'),
(2, 5, 'CS23B102', 'REG-2023-0102', 'B.Tech Computer Science', 2023, 'MALE', '2005-08-20', 'O+', 'Mahesh Verma', '+91 94111 22222', 'AWAY'),
(3, 6, 'ME23B201', 'REG-2023-0201', 'B.Tech Mechanical Engg', 2023, 'MALE', '2004-12-05', 'A+', 'Ranjit Singh', '+91 94111 33333', 'RETURN_OVERDUE'),
(4, 7, 'EE23B301', 'REG-2023-0301', 'B.Tech Electrical Engg', 2023, 'MALE', '2005-02-14', 'AB+', 'Sunil Mehta', '+91 94111 44444', 'PRESENT'),
(5, 8, 'CS23B103', 'REG-2023-0103', 'B.Tech Computer Science', 2023, 'FEMALE', '2005-09-18', 'O-', 'Debashis Sen', '+91 94111 55555', 'PRESENT'),
(6, 9, 'EC23B401', 'REG-2023-0401', 'B.Tech Electronics & Comm', 2023, 'FEMALE', '2005-06-25', 'B-', 'K. G. Nair', '+91 94111 66666', 'PRESENT'),
(7, 10, 'BT23B501', 'REG-2023-0501', 'B.Tech Biotechnology', 2023, 'FEMALE', '2005-11-30', 'A-', 'Bhavesh Patel', '+91 94111 77777', 'PRESENT'),
(8, 11, 'CS23B104', 'REG-2023-0104', 'B.Tech Computer Science', 2023, 'MALE', '2005-01-10', 'O+', 'G. Iyer', '+91 94111 88888', 'EXPECTED_TO_LEAVE'),
(9, 12, 'CE23B601', 'REG-2023-0601', 'B.Tech Civil Engineering', 2023, 'MALE', '2004-10-15', 'B+', 'Pramod Joshi', '+91 94111 99999', 'PRESENT'),
(10, 13, 'CS23B105', 'REG-2023-0105', 'B.Tech Computer Science', 2023, 'MALE', '2005-03-22', 'A+', 'Alok Gupta', '+91 94112 00001', 'PRESENT'),
(11, 14, 'ME23B202', 'REG-2023-0202', 'B.Tech Mechanical Engg', 2023, 'MALE', '2005-07-09', 'AB+', 'Ramendra Yadav', '+91 94112 00002', 'PRESENT'),
(12, 15, 'EE23B302', 'REG-2023-0302', 'B.Tech Electrical Engg', 2023, 'MALE', '2004-05-19', 'O+', 'Gurpreet Singh', '+91 94112 00003', 'PRESENT'),
(13, 16, 'CS23B106', 'REG-2023-0106', 'B.Tech Computer Science', 2023, 'MALE', '2005-12-01', 'B+', 'Shrikant Kulkarni', '+91 94112 00004', 'PRESENT'),
(14, 17, 'CH23B701', 'REG-2023-0701', 'B.Tech Chemical Engg', 2023, 'MALE', '2005-08-11', 'A+', 'Pawan Agarwal', '+91 94112 00005', 'PRESENT'),
(15, 18, 'CS23B107', 'REG-2023-0107', 'B.Tech Computer Science', 2023, 'MALE', '2005-04-04', 'O-', 'Subrata Roy', '+91 94112 00006', 'PRESENT'),
(16, 19, 'EC23B402', 'REG-2023-0402', 'B.Tech Electronics & Comm', 2023, 'FEMALE', '2005-02-28', 'B+', 'Vinod Sharma', '+91 94112 00007', 'PRESENT');

SELECT setval(pg_get_serial_sequence('students', 'id'), 16);

-- 5. Active Room Allocations (Beds 1 to 26 allocated)
INSERT INTO room_allocations (id, student_id, bed_id, academic_session_id, allocated_from, is_active, allocated_by_user_id) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1, 1, '2026-07-15', TRUE, 1),   -- Rohan -> A-G01 Bed-A
(2, 4, 2, 1, '2026-07-15', TRUE, 1),   -- Rahul -> A-G01 Bed-B
(3, 8, 3, 1, '2026-07-16', TRUE, 1),   -- Karthik -> A-G02 Bed-A
(4, 9, 4, 1, '2026-07-16', TRUE, 1),   -- Nikhil -> A-G02 Bed-B
(5, 10, 10, 1, '2026-07-17', TRUE, 1), -- Aarav -> A-101 Bed-A
(6, 2, 11, 1, '2026-07-17', TRUE, 1),  -- Amit -> A-101 Bed-B (AWAY)
(7, 3, 12, 1, '2026-07-18', TRUE, 1),  -- Vikram -> A-102 Bed-A (OVERDUE)
(8, 11, 16, 1, '2026-07-18', TRUE, 1), -- Devendra -> A-104 Bed-A
(9, 12, 18, 1, '2026-07-19', TRUE, 1), -- Manpreet -> B-G01 Bed-A
(10, 13, 19, 1, '2026-07-19', TRUE, 1),-- Tanmay -> B-G01 Bed-B
(11, 5, 24, 1, '2026-07-15', TRUE, 1), -- Ananya -> Girls G-01 Bed-A
(12, 6, 25, 1, '2026-07-15', TRUE, 1), -- Priya -> Girls G-01 Bed-B
(13, 7, 26, 1, '2026-07-16', TRUE, 1); -- Sneha -> Girls G-02 Bed-A

SELECT setval(pg_get_serial_sequence('room_allocations', 'id'), 13);

-- 6. Leave Requests (Demonstrating Special Vacation / Temporary Vacancy Features)
INSERT INTO student_leave_requests (id, student_id, leave_type, reason, departure_datetime, expected_return_datetime, actual_departure_datetime, actual_return_datetime, status, reviewed_by_user_id, review_remarks) OVERRIDING SYSTEM VALUE VALUES
-- Student 2 (Amit Verma): Approved, Departed, Currently AWAY (Bed 11 is Temporarily Vacant!)
(1, 2, 'SEMESTER_HOLIDAY', 'Visiting hometown for family reunion', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP + INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '2 days', NULL, 'DEPARTED', 2, 'Approved. Maintain attendance record.'),
-- Student 3 (Vikram Singh): Approved, Departed, Return was expected yesterday -> OVERDUE!
(2, 3, 'WEEKEND', 'Attending cousin wedding in Delhi', CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '4 days', NULL, 'OVERDUE', 2, 'Overdue return notice flagged. Warden called parent.'),
-- Student 8 (Karthik Iyer): Approved, expected to leave tomorrow
(3, 8, 'FESTIVAL', 'Attending local festival rites', CURRENT_TIMESTAMP + INTERVAL '1 day', CURRENT_TIMESTAMP + INTERVAL '4 days', NULL, NULL, 'APPROVED', 2, 'Approved. Gate pass issued.'),
-- Student 1 (Rohan Sharma): Submitted, PENDING approval
(4, 1, 'PERSONAL', 'Medical checkup appointment at Apollo hospital', CURRENT_TIMESTAMP + INTERVAL '2 days', CURRENT_TIMESTAMP + INTERVAL '3 days', NULL, NULL, 'PENDING', NULL, NULL),
-- Student 5 (Ananya Sen): Past completed leave (RETURNED)
(5, 5, 'WEEKEND', 'Home visit for festival celebration', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '7 days', 'RETURNED', 3, 'Approved and returned on time.');

SELECT setval(pg_get_serial_sequence('student_leave_requests', 'id'), 5);

-- 7. Leave History
INSERT INTO leave_history (leave_request_id, previous_status, new_status, changed_by_user_id, change_reason) VALUES
(1, 'PENDING', 'APPROVED', 2, 'Leave request approved by warden'),
(1, 'APPROVED', 'DEPARTED', 2, 'Departure confirmed at security checkpoint'),
(2, 'PENDING', 'APPROVED', 2, 'Weekend leave approved'),
(2, 'APPROVED', 'DEPARTED', 2, 'Security checkout recorded'),
(2, 'DEPARTED', 'OVERDUE', 2, 'Expected return window expired without check-in'),
(3, 'PENDING', 'APPROVED', 2, 'Festival leave approved'),
(5, 'PENDING', 'APPROVED', 3, 'Approved by Girls Hostel warden'),
(5, 'APPROVED', 'DEPARTED', 3, 'Departed'),
(5, 'DEPARTED', 'RETURNED', 3, 'Returned and presence marked PRESENT');

-- 8. Invoices
INSERT INTO invoices (id, invoice_number, student_id, fee_structure_id, amount, paid_amount, due_date, status) OVERRIDING SYSTEM VALUE VALUES
(1, 'INV-2026-0001', 1, 1, 24000.00, 24000.00, '2026-08-10', 'PAID'),
(2, 'INV-2026-0002', 2, 1, 24000.00, 24000.00, '2026-08-10', 'PAID'),
(3, 'INV-2026-0003', 3, 1, 24000.00, 12000.00, '2026-08-10', 'PARTIALLY_PAID'),
(4, 'INV-2026-0004', 4, 1, 24000.00, 0.00, '2026-10-15', 'OVERDUE'),
(5, 'INV-2026-0005', 5, 4, 25000.00, 25000.00, '2026-08-10', 'PAID'),
(6, 'INV-2026-0006', 8, 1, 24000.00, 0.00, '2026-11-15', 'PENDING');

SELECT setval(pg_get_serial_sequence('invoices', 'id'), 6);

-- 9. Payments & Receipts
INSERT INTO payments (id, invoice_id, student_id, amount, payment_method, transaction_reference, recorded_by_user_id, status, payment_date) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1, 24000.00, 'UPI', 'UPI/2026/893478912', 1, 'PAID', '2026-08-05 11:20:00+05:30'),
(2, 2, 2, 24000.00, 'BANK_TRANSFER', 'NEFT/SBI/00912837', 1, 'PAID', '2026-08-06 14:15:00+05:30'),
(3, 3, 3, 12000.00, 'CASH', 'CASH/RCP-003', 2, 'PAID', '2026-08-08 16:30:00+05:30'),
(4, 5, 5, 25000.00, 'UPI', 'UPI/2026/447812990', 1, 'PAID', '2026-08-07 10:45:00+05:30');

SELECT setval(pg_get_serial_sequence('payments', 'id'), 4);

INSERT INTO payment_receipts (payment_id, receipt_number, receipt_pdf_path) VALUES
(1, 'RCP-2026-0001', 'receipts/RCP-2026-0001.pdf'),
(2, 'RCP-2026-0002', 'receipts/RCP-2026-0002.pdf'),
(3, 'RCP-2026-0003', 'receipts/RCP-2026-0003.pdf'),
(4, 'RCP-2026-0004', 'receipts/RCP-2026-0004.pdf');

-- 10. Complaints
INSERT INTO complaints (id, complaint_code, student_id, hostel_id, room_id, category, priority, subject, description, status, assigned_staff_id) OVERRIDING SYSTEM VALUE VALUES
(1, 'CMP-2026-001', 1, 1, 1, 'INTERNET', 'HIGH', 'LAN port in Room A-G01 not working', 'The RJ45 ethernet wall port has loose contact. No internet connectivity since yesterday.', 'IN_PROGRESS', 2),
(2, 'CMP-2026-002', 4, 1, 1, 'ELECTRICITY', 'MEDIUM', 'Ceiling fan making clicking noise at speed 4', 'Fan in room A-G01 produces rhythmic screeching noise during nighttime.', 'OPEN', 2),
(3, 'CMP-2026-003', 5, 2, 11, 'WATER', 'URGENT', 'Bathroom tap dripping continuously in G-01', 'Water waste and puddle formed near washbasin.', 'RESOLVED', 3),
(4, 'CMP-2026-004', 10, 1, 5, 'FURNITURE', 'LOW', 'Study table drawer lock stuck', 'The right side drawer key is stuck inside the tumbler.', 'OPEN', 2);

SELECT setval(pg_get_serial_sequence('complaints', 'id'), 4);

INSERT INTO complaint_status_history (complaint_id, previous_status, new_status, updated_by_user_id, remarks) VALUES
(1, 'OPEN', 'IN_PROGRESS', 2, 'Assigned to campus network technician Mr. Sharma'),
(3, 'OPEN', 'IN_PROGRESS', 3, 'Plumber dispatched'),
(3, 'IN_PROGRESS', 'RESOLVED', 3, 'Washer replaced and tap flow verified');

-- 11. Visitors and Visitor Logs
INSERT INTO visitors (id, visitor_name, contact_number, government_id_type, government_id_number) OVERRIDING SYSTEM VALUE VALUES
(1, 'Suresh Sharma', '+91 94111 11111', 'AADHAAR', 'XXXX-XXXX-1234'),
(2, 'Deepak Verma', '+91 94111 22222', 'DRIVING_LICENSE', 'DL-042018009231');

SELECT setval(pg_get_serial_sequence('visitors', 'id'), 2);

INSERT INTO visitor_logs (visitor_id, student_id, hostel_id, purpose, entry_datetime, exit_datetime, recorded_by_user_id, status) VALUES
(1, 1, 1, 'Delivering home essentials and study books', CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '1 hour', 2, 'EXITED'),
(2, 2, 1, 'Visiting for emergency health review', CURRENT_TIMESTAMP - INTERVAL '45 minutes', NULL, 2, 'IN_HOSTEL');

-- 12. Audit Logs
INSERT INTO audit_logs (user_id, action, entity_name, entity_id, ip_address, details) VALUES
(1, 'SYSTEM_INITIALIZATION', 'SYSTEM', '1', '127.0.0.1', 'HostelEase system database seeded successfully with initial operational data'),
(2, 'LEAVE_STATUS_UPDATE', 'STUDENT_LEAVE', '1', '127.0.0.1', 'Student Amit Verma marked DEPARTED. Bed 11 flagged as Temporarily Vacant.'),
(2, 'LEAVE_OVERDUE_FLAG', 'STUDENT_LEAVE', '2', '127.0.0.1', 'Student Vikram Singh flagged RETURN_OVERDUE after 24hr expiry.');
