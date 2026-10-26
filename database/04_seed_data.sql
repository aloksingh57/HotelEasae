-- ============================================================================
-- SCRIPT 04: SEED DATA (HOSTELS, ROOMS, BEDS, SESSIONS, NOTICES, TEMPLATES)
-- Connect to 'hostelease_db' before executing this script!
-- Command: psql -U postgres -d hostelease_db -f 04_seed_data.sql
-- ============================================================================

-- 1. Roles
INSERT INTO roles (id, role_name, description) OVERRIDING SYSTEM VALUE VALUES
(1, 'ADMIN', 'System Administrator with full access to all hostels, users, settings, and reports'),
(2, 'WARDEN', 'Hostel Warden responsible for assigned hostel, attendance, leave approval, and complaints'),
(3, 'STUDENT', 'Hostel Resident with access to leave requests, room details, fee invoices, and complaints');

-- Reset identity sequence for roles
SELECT setval(pg_get_serial_sequence('roles', 'id'), 3);

-- 2. Academic Sessions
INSERT INTO academic_sessions (id, session_name, start_date, end_date, is_current) OVERRIDING SYSTEM VALUE VALUES
(1, '2026-2027 Academic Year', '2026-07-01', '2027-06-30', TRUE),
(2, '2025-2026 Academic Year', '2025-07-01', '2026-06-30', FALSE);

SELECT setval(pg_get_serial_sequence('academic_sessions', 'id'), 2);

-- 3. Hostels
INSERT INTO hostels (id, name, code, type, address, contact_phone, contact_email, total_capacity, is_active) OVERRIDING SYSTEM VALUE VALUES
(1, 'Nilgiri Boys Hostel', 'NBH-01', 'BOYS', 'North Campus, Sector 4, University Road', '+91 98765 43210', 'nilgiri.warden@hostelease.com', 120, TRUE),
(2, 'Aravalli Girls Hostel', 'AGH-01', 'GIRLS', 'South Campus, Green Enclave, University Road', '+91 98765 43211', 'aravalli.warden@hostelease.com', 100, TRUE);

SELECT setval(pg_get_serial_sequence('hostels', 'id'), 2);

-- 4. Buildings
INSERT INTO hostel_buildings (id, hostel_id, building_name, building_code, total_floors) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 'Block A - Aryabhatta', 'NBH-BLK-A', 3),
(2, 1, 'Block B - Ramanujan', 'NBH-BLK-B', 2),
(3, 2, 'Wing 1 - Gargi Block', 'AGH-WNG-1', 2),
(4, 2, 'Wing 2 - Maitreyi Block', 'AGH-WNG-2', 2);

SELECT setval(pg_get_serial_sequence('hostel_buildings', 'id'), 4);

-- 5. Floors
INSERT INTO hostel_floors (id, building_id, floor_number, floor_name, total_rooms) OVERRIDING SYSTEM VALUE VALUES
-- Nilgiri Block A
(1, 1, 0, 'Ground Floor', 4),
(2, 1, 1, 'First Floor', 4),
(3, 1, 2, 'Second Floor', 4),
-- Nilgiri Block B
(4, 2, 0, 'Ground Floor', 3),
(5, 2, 1, 'First Floor', 3),
-- Aravalli Wing 1
(6, 3, 0, 'Ground Floor', 3),
(7, 3, 1, 'First Floor', 3);

SELECT setval(pg_get_serial_sequence('hostel_floors', 'id'), 7);

-- 6. Rooms (12+ Diverse Rooms)
INSERT INTO rooms (id, floor_id, room_number, room_type, capacity, current_occupancy, status) OVERRIDING SYSTEM VALUE VALUES
-- Nilgiri Block A - Floor 0 (Ground)
(1, 1, 'A-G01', 'DELUXE', 2, 2, 'FULL'),
(2, 1, 'A-G02', 'STANDARD', 3, 2, 'AVAILABLE'),
(3, 1, 'A-G03', 'STANDARD', 2, 0, 'AVAILABLE'),
(4, 1, 'A-G04', 'AC', 2, 0, 'MAINTENANCE'),
-- Nilgiri Block A - Floor 1
(5, 2, 'A-101', 'STANDARD', 2, 2, 'FULL'),
(6, 2, 'A-102', 'STANDARD', 2, 1, 'AVAILABLE'),
(7, 2, 'A-103', 'DELUXE', 2, 0, 'AVAILABLE'),
(8, 2, 'A-104', 'AC', 2, 1, 'AVAILABLE'),
-- Nilgiri Block B - Floor 0
(9, 4, 'B-G01', 'STANDARD', 3, 2, 'AVAILABLE'),
(10, 4, 'B-G02', 'STANDARD', 3, 0, 'AVAILABLE'),
-- Aravalli Wing 1 - Floor 0
(11, 6, 'G-01', 'DELUXE', 2, 2, 'FULL'),
(12, 6, 'G-02', 'STANDARD', 2, 1, 'AVAILABLE'),
(13, 6, 'G-03', 'STANDARD', 3, 0, 'AVAILABLE');

SELECT setval(pg_get_serial_sequence('rooms', 'id'), 13);

-- 7. Beds (Beds associated with each room)
INSERT INTO beds (id, room_id, bed_label, allocation_status) OVERRIDING SYSTEM VALUE VALUES
-- Room 1 (A-G01) (Allocated)
(1, 1, 'Bed-A', 'ALLOCATED'),
(2, 1, 'Bed-B', 'ALLOCATED'),
-- Room 2 (A-G02) (Capacity 3)
(3, 2, 'Bed-A', 'ALLOCATED'),
(4, 2, 'Bed-B', 'ALLOCATED'),
(5, 2, 'Bed-C', 'UNALLOCATED'),
-- Room 3 (A-G03) (Available)
(6, 3, 'Bed-A', 'UNALLOCATED'),
(7, 3, 'Bed-B', 'UNALLOCATED'),
-- Room 4 (A-G04) (Maintenance)
(8, 4, 'Bed-A', 'MAINTENANCE'),
(9, 4, 'Bed-B', 'MAINTENANCE'),
-- Room 5 (A-101) (Allocated)
(10, 5, 'Bed-A', 'ALLOCATED'),
(11, 5, 'Bed-B', 'ALLOCATED'), -- Will be temporarily vacant (student away on leave)
-- Room 6 (A-102)
(12, 6, 'Bed-A', 'ALLOCATED'), -- Student with Return Overdue
(13, 6, 'Bed-B', 'UNALLOCATED'),
-- Room 7 (A-103)
(14, 7, 'Bed-A', 'UNALLOCATED'),
(15, 7, 'Bed-B', 'UNALLOCATED'),
-- Room 8 (A-104)
(16, 8, 'Bed-A', 'ALLOCATED'),
(17, 8, 'Bed-B', 'RESERVED'),
-- Room 9 (B-G01)
(18, 9, 'Bed-A', 'ALLOCATED'),
(19, 9, 'Bed-B', 'ALLOCATED'),
(20, 9, 'Bed-C', 'UNALLOCATED'),
-- Room 10 (B-G02)
(21, 10, 'Bed-A', 'UNALLOCATED'),
(22, 10, 'Bed-B', 'UNALLOCATED'),
(23, 10, 'Bed-C', 'UNALLOCATED'),
-- Room 11 (G-01) - Girls Hostel
(24, 11, 'Bed-A', 'ALLOCATED'),
(25, 11, 'Bed-B', 'ALLOCATED'),
-- Room 12 (G-02)
(26, 12, 'Bed-A', 'ALLOCATED'),
(27, 12, 'Bed-B', 'UNALLOCATED'),
-- Room 13 (G-03)
(28, 13, 'Bed-A', 'UNALLOCATED'),
(29, 13, 'Bed-B', 'UNALLOCATED'),
(30, 13, 'Bed-C', 'UNALLOCATED');

SELECT setval(pg_get_serial_sequence('beds', 'id'), 30);

-- 8. Fee Structures
INSERT INTO fee_structures (id, hostel_id, academic_session_id, fee_category, amount, frequency) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 1, 'Semester Room & Maintenance Fee (Standard)', 24000.00, 'SEMESTER'),
(2, 1, 1, 'Semester Room & Maintenance Fee (AC / Deluxe)', 32000.00, 'SEMESTER'),
(3, 1, 1, 'Hostel Caution Deposit (Refundable)', 5000.00, 'ONE_TIME'),
(4, 2, 1, 'Semester Room & Maintenance Fee (Girls Hostel)', 25000.00, 'SEMESTER'),
(5, 2, 1, 'Mess & Dining Charges (Semester)', 18000.00, 'SEMESTER');

SELECT setval(pg_get_serial_sequence('fee_structures', 'id'), 5);

-- 9. Hostel Holiday Periods
INSERT INTO hostel_holiday_periods (id, title, start_date, end_date, hostel_id, applicable_group, instructions, submission_deadline, created_by_user_id) OVERRIDING SYSTEM VALUE VALUES
(1, 'Diwali Festival Break 2026', '2026-11-08', '2026-11-16', 1, 'ALL', 'All students proceeding home must submit leave requests 48 hours prior to departure. Mess will remain closed from 9th Nov to 15th Nov.', '2026-11-06 18:00:00+05:30', NULL),
(2, 'Winter Break 2026', '2026-12-22', '2027-01-05', NULL, 'ALL', 'Hostel premises will undergo deep maintenance. Valuables must be taken or deposited in the hostel cloak room.', '2026-12-18 20:00:00+05:30', NULL);

SELECT setval(pg_get_serial_sequence('hostel_holiday_periods', 'id'), 2);

-- 10. Notices
INSERT INTO notices (id, title, content, hostel_id, target_role, is_urgent, published_by_user_id, expires_at) OVERRIDING SYSTEM VALUE VALUES
(1, 'Fire Safety & Evacuation Drill Announcement', 'A mandatory fire drill will be held this Saturday at 10:00 AM in the central courtyard. All residents must participate.', 1, 'ALL', TRUE, NULL, '2026-11-01'),
(2, 'Wi-Fi Network Upgrade & Maintenance', 'Campus Wi-Fi in Block A will undergo fiber maintenance between 02:00 AM and 05:00 AM on Wednesday. Connectivity may be intermittent.', 1, 'STUDENT', FALSE, NULL, '2026-10-30'),
(3, 'Mess Committee Monthly Review Meeting', 'Monthly mess committee meeting will be held in the Recreation Hall on Thursday at 7:00 PM. Suggestions for weekly menu are welcome.', NULL, 'ALL', FALSE, NULL, '2026-11-05');

SELECT setval(pg_get_serial_sequence('notices', 'id'), 3);

-- 11. Notification Templates
INSERT INTO notification_templates (id, template_code, channel, subject, body_template) OVERRIDING SYSTEM VALUE VALUES
(1, 'LEAVE_SUBMITTED', 'EMAIL', 'Leave Request Submitted - {REQUEST_ID}', 'Dear {STUDENT_NAME}, your leave request for {START_DATE} to {END_DATE} has been submitted successfully and is pending warden review.'),
(2, 'LEAVE_APPROVED', 'EMAIL', 'Leave Request Approved - {REQUEST_ID}', 'Dear {STUDENT_NAME}, your leave request from {START_DATE} to {END_DATE} has been APPROVED by the hostel warden. Please record your checkout before leaving.'),
(3, 'LEAVE_REJECTED', 'EMAIL', 'Leave Request Update - {REQUEST_ID}', 'Dear {STUDENT_NAME}, your leave request for {START_DATE} has been REJECTED. Remarks: {REMARKS}. Contact your warden for clarification.'),
(4, 'STUDENT_DEPARTED', 'EMAIL', 'Hostel Departure Confirmed', 'Dear {STUDENT_NAME}, your checkout has been recorded at {TIME}. Safe travels! Expected return is {EXPECTED_RETURN}.'),
(5, 'STUDENT_RETURNED', 'EMAIL', 'Hostel Check-in Welcome Back', 'Dear {STUDENT_NAME}, your return has been marked at {TIME}. Welcome back to {HOSTEL_NAME}!'),
(6, 'RETURN_OVERDUE', 'EMAIL', 'URGENT: Return Overdue Alert', 'Dear {STUDENT_NAME}, you were expected to return on {EXPECTED_RETURN}. Your status is currently marked as RETURN OVERDUE. Please contact the warden immediately.'),
(7, 'INVOICE_GENERATED', 'EMAIL', 'New Hostel Fee Invoice: {INVOICE_NO}', 'Dear {STUDENT_NAME}, a new fee invoice of Rs. {AMOUNT} for {CATEGORY} has been generated. Due date: {DUE_DATE}.'),
(8, 'PAYMENT_SUCCESS', 'EMAIL', 'Payment Receipt Confirmed: {RECEIPT_NO}', 'Dear {STUDENT_NAME}, your payment of Rs. {AMOUNT} has been received successfully. Transaction Ref: {TXN_REF}.');

SELECT setval(pg_get_serial_sequence('notification_templates', 'id'), 8);

-- 12. System Settings
INSERT INTO system_settings (id, setting_key, setting_value, description) OVERRIDING SYSTEM VALUE VALUES
(1, 'CURFEW_TIME', '21:30', 'Standard student in-time for hostel gates'),
(2, 'MAX_LEAVE_DAYS', '15', 'Maximum consecutive days for online leave submission'),
(3, 'OVERDUE_GRACE_HOURS', '2', 'Grace period before student is automatically flagged as RETURN_OVERDUE'),
(4, 'SYSTEM_VERSION', '1.0.0-RELEASE', 'HostelEase Core Release Version');

SELECT setval(pg_get_serial_sequence('system_settings', 'id'), 4);
