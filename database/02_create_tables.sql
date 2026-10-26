-- ============================================================================
-- SCRIPT 02: TABLE DEFINITIONS FOR HOSTELEASE DATABASE
-- Connect to 'hostelease_db' before executing this script!
-- Command: psql -U postgres -d hostelease_db -f 02_create_tables.sql
-- ============================================================================

-- Drop tables in reverse dependency order if they already exist
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS notification_logs CASCADE;
DROP TABLE IF EXISTS notification_queue CASCADE;
DROP TABLE IF EXISTS notification_templates CASCADE;
DROP TABLE IF EXISTS visitor_logs CASCADE;
DROP TABLE IF EXISTS visitors CASCADE;
DROP TABLE IF EXISTS complaint_status_history CASCADE;
DROP TABLE IF EXISTS complaints CASCADE;
DROP TABLE IF EXISTS payment_receipts CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS fee_structures CASCADE;
DROP TABLE IF EXISTS leave_history CASCADE;
DROP TABLE IF EXISTS student_leave_requests CASCADE;
DROP TABLE IF EXISTS hostel_holiday_periods CASCADE;
DROP TABLE IF EXISTS room_transfer_requests CASCADE;
DROP TABLE IF EXISTS room_allocations CASCADE;
DROP TABLE IF EXISTS beds CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS hostel_floors CASCADE;
DROP TABLE IF EXISTS hostel_buildings CASCADE;
DROP TABLE IF EXISTS hostels CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS academic_sessions CASCADE;
DROP TABLE IF EXISTS system_settings CASCADE;
DROP TABLE IF EXISTS notices CASCADE;

-- 1. Academic Sessions
CREATE TABLE academic_sessions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    session_name VARCHAR(100) NOT NULL UNIQUE, -- e.g. "2026-2027"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_session_dates CHECK (end_date > start_date)
);

-- 2. Users Table (Core Authentication)
CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Roles Table
CREATE TABLE roles (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE, -- ADMIN, WARDEN, STUDENT
    description VARCHAR(255)
);

-- 4. User Roles Mapping
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

-- 5. Hostels Table
CREATE TABLE hostels (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    code VARCHAR(30) NOT NULL UNIQUE,
    type VARCHAR(30) NOT NULL CHECK (type IN ('BOYS', 'GIRLS', 'CO_ED')),
    address TEXT,
    contact_phone VARCHAR(30),
    contact_email VARCHAR(150),
    total_capacity INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Staff Table (Wardens, Admins, Support)
CREATE TABLE staff (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    staff_code VARCHAR(50) NOT NULL UNIQUE,
    designation VARCHAR(100) NOT NULL, -- e.g. "Chief Warden", "Hostel Warden"
    assigned_hostel_id BIGINT REFERENCES hostels(id) ON DELETE SET NULL,
    emergency_contact VARCHAR(30),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Students Table
CREATE TABLE students (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    roll_number VARCHAR(50) NOT NULL UNIQUE,
    registration_no VARCHAR(50) UNIQUE,
    course VARCHAR(100) NOT NULL,
    batch_year INT NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    dob DATE,
    blood_group VARCHAR(10),
    guardian_name VARCHAR(150),
    guardian_phone VARCHAR(30),
    guardian_email VARCHAR(150),
    permanent_address TEXT,
    current_presence VARCHAR(30) DEFAULT 'PRESENT' 
        CHECK (current_presence IN ('PRESENT', 'EXPECTED_TO_LEAVE', 'AWAY', 'RETURN_OVERDUE')),
    email_notification_opt_in BOOLEAN DEFAULT TRUE,
    sms_notification_opt_in BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Hostel Buildings
CREATE TABLE hostel_buildings (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hostel_id BIGINT NOT NULL REFERENCES hostels(id) ON DELETE CASCADE,
    building_name VARCHAR(100) NOT NULL,
    building_code VARCHAR(30) NOT NULL,
    total_floors INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_building UNIQUE(hostel_id, building_code)
);

-- 9. Hostel Floors
CREATE TABLE hostel_floors (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    building_id BIGINT NOT NULL REFERENCES hostel_buildings(id) ON DELETE CASCADE,
    floor_number INT NOT NULL,
    floor_name VARCHAR(50) NOT NULL,
    total_rooms INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_floor UNIQUE(building_id, floor_number)
);

-- 10. Rooms Table
CREATE TABLE rooms (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    floor_id BIGINT NOT NULL REFERENCES hostel_floors(id) ON DELETE CASCADE,
    room_number VARCHAR(30) NOT NULL,
    room_type VARCHAR(30) NOT NULL DEFAULT 'STANDARD' CHECK (room_type IN ('STANDARD', 'DELUXE', 'AC', 'NON_AC')),
    capacity INT NOT NULL DEFAULT 2 CHECK (capacity > 0),
    current_occupancy INT NOT NULL DEFAULT 0 CHECK (current_occupancy >= 0),
    status VARCHAR(30) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'FULL', 'MAINTENANCE', 'DECOMMISSIONED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_room_floor UNIQUE(floor_id, room_number)
);

-- 11. Beds Table
CREATE TABLE beds (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    room_id BIGINT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    bed_label VARCHAR(30) NOT NULL, -- e.g. "Bed-A", "Bed-B"
    allocation_status VARCHAR(30) NOT NULL DEFAULT 'UNALLOCATED'
        CHECK (allocation_status IN ('UNALLOCATED', 'ALLOCATED', 'RESERVED', 'MAINTENANCE', 'ALLOCATION_ENDED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_room_bed UNIQUE(room_id, bed_label)
);

-- 12. Room Allocations Table (Transactional History)
CREATE TABLE room_allocations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    bed_id BIGINT NOT NULL REFERENCES beds(id) ON DELETE RESTRICT,
    academic_session_id BIGINT REFERENCES academic_sessions(id) ON DELETE SET NULL,
    allocated_from DATE NOT NULL,
    allocated_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    allocated_by_user_id BIGINT REFERENCES users(id),
    checkout_date TIMESTAMP WITH TIME ZONE,
    checkout_remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 13. Room Transfer Requests
CREATE TABLE room_transfer_requests (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    current_bed_id BIGINT NOT NULL REFERENCES beds(id),
    target_bed_id BIGINT REFERENCES beds(id),
    reason TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED')),
    reviewed_by_user_id BIGINT REFERENCES users(id),
    review_remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE
);

-- 14. Hostel Holiday Periods (General Announcements)
CREATE TABLE hostel_holiday_periods (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    hostel_id BIGINT REFERENCES hostels(id) ON DELETE CASCADE,
    applicable_group VARCHAR(100) DEFAULT 'ALL',
    instructions TEXT,
    submission_deadline TIMESTAMP WITH TIME ZONE,
    created_by_user_id BIGINT REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_holiday_dates CHECK (end_date >= start_date)
);

-- 15. Student Leave Requests (Special Feature: Temporary Vacancy)
CREATE TABLE student_leave_requests (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    leave_type VARCHAR(50) NOT NULL 
        CHECK (leave_type IN ('WEEKEND', 'SEMESTER_HOLIDAY', 'FESTIVAL', 'PERSONAL', 'MEDICAL', 'OTHER', 'HOME', 'VACATION', 'EMERGENCY', 'ACADEMIC_OD')),
    reason TEXT NOT NULL,
    departure_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    expected_return_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    actual_departure_datetime TIMESTAMP WITH TIME ZONE,
    actual_return_datetime TIMESTAMP WITH TIME ZONE,
    emergency_contact VARCHAR(50),
    destination_address TEXT,
    status VARCHAR(30) DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'DEPARTED', 'RETURNED', 'OVERDUE')),
    reviewed_by_user_id BIGINT REFERENCES users(id),
    review_remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_leave_times CHECK (expected_return_datetime > departure_datetime)
);

-- 16. Leave History Log
CREATE TABLE leave_history (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    leave_request_id BIGINT NOT NULL REFERENCES student_leave_requests(id) ON DELETE CASCADE,
    previous_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by_user_id BIGINT REFERENCES users(id),
    change_reason TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 17. Fee Structures
CREATE TABLE fee_structures (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hostel_id BIGINT NOT NULL REFERENCES hostels(id) ON DELETE CASCADE,
    academic_session_id BIGINT NOT NULL REFERENCES academic_sessions(id) ON DELETE CASCADE,
    fee_category VARCHAR(100) NOT NULL, -- e.g. "Hostel Maintenance & Rent", "Mess Security"
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    frequency VARCHAR(30) NOT NULL DEFAULT 'SEMESTER' CHECK (frequency IN ('MONTHLY', 'SEMESTER', 'ANNUAL', 'ONE_TIME')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 18. Student Invoices
CREATE TABLE invoices (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_number VARCHAR(100) NOT NULL UNIQUE,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    fee_structure_id BIGINT REFERENCES fee_structures(id) ON DELETE SET NULL,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    paid_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (paid_amount >= 0),
    due_date DATE NOT NULL,
    late_fee NUMERIC(12, 2) DEFAULT 0.00,
    status VARCHAR(30) DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'PAID', 'PARTIALLY_PAID', 'OVERDUE', 'CANCELLED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 19. Payments
CREATE TABLE payments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id BIGINT NOT NULL REFERENCES invoices(id) ON DELETE RESTRICT,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('CASH', 'BANK_TRANSFER', 'UPI', 'CARD', 'ONLINE_SIMULATION')),
    transaction_reference VARCHAR(150),
    recorded_by_user_id BIGINT REFERENCES users(id),
    status VARCHAR(30) DEFAULT 'PAID' CHECK (status IN ('PENDING', 'PAID', 'FAILED', 'CANCELLED', 'REFUNDED')),
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 20. Payment Receipts
CREATE TABLE payment_receipts (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_id BIGINT NOT NULL UNIQUE REFERENCES payments(id) ON DELETE CASCADE,
    receipt_number VARCHAR(100) NOT NULL UNIQUE,
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    receipt_pdf_path VARCHAR(255)
);

-- 21. Complaints
CREATE TABLE complaints (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    complaint_code VARCHAR(50) NOT NULL UNIQUE,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    hostel_id BIGINT NOT NULL REFERENCES hostels(id) ON DELETE CASCADE,
    room_id BIGINT REFERENCES rooms(id) ON DELETE SET NULL,
    category VARCHAR(50) NOT NULL 
        CHECK (category IN ('ELECTRICITY', 'WATER', 'CLEANING', 'FURNITURE', 'INTERNET', 'MAINTENANCE', 'SECURITY', 'OTHER')),
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    attachment_path VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN' 
        CHECK (status IN ('OPEN', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REOPENED')),
    assigned_staff_id BIGINT REFERENCES staff(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 22. Complaint Status History
CREATE TABLE complaint_status_history (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    complaint_id BIGINT NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    previous_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    updated_by_user_id BIGINT REFERENCES users(id),
    remarks TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 23. Visitors
CREATE TABLE visitors (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visitor_name VARCHAR(150) NOT NULL,
    contact_number VARCHAR(30) NOT NULL,
    government_id_type VARCHAR(50),
    government_id_number VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 24. Visitor Logs
CREATE TABLE visitor_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    visitor_id BIGINT NOT NULL REFERENCES visitors(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    hostel_id BIGINT NOT NULL REFERENCES hostels(id) ON DELETE CASCADE,
    purpose TEXT NOT NULL,
    entry_datetime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    exit_datetime TIMESTAMP WITH TIME ZONE,
    recorded_by_user_id BIGINT REFERENCES users(id),
    status VARCHAR(30) DEFAULT 'IN_HOSTEL' CHECK (status IN ('IN_HOSTEL', 'EXITED', 'OVERSTAYED'))
);

-- 25. Notices Table
CREATE TABLE notices (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    hostel_id BIGINT REFERENCES hostels(id) ON DELETE CASCADE, -- NULL = All hostels
    target_role VARCHAR(50) DEFAULT 'ALL',
    is_urgent BOOLEAN DEFAULT FALSE,
    published_by_user_id BIGINT REFERENCES users(id),
    expires_at DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 26. Notification Templates
CREATE TABLE notification_templates (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    template_code VARCHAR(100) NOT NULL UNIQUE,
    channel VARCHAR(20) NOT NULL CHECK (channel IN ('EMAIL', 'SMS')),
    subject VARCHAR(200),
    body_template TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 27. Notification Queue
CREATE TABLE notification_queue (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idempotency_key VARCHAR(150) UNIQUE,
    recipient_email VARCHAR(150),
    recipient_phone VARCHAR(30),
    channel VARCHAR(20) NOT NULL CHECK (channel IN ('EMAIL', 'SMS')),
    notification_type VARCHAR(100) NOT NULL,
    subject VARCHAR(200),
    message_content TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'PENDING' 
        CHECK (status IN ('PENDING', 'PROCESSING', 'SENT', 'FAILED', 'NOT_CONFIGURED', 'RETRY_SCHEDULED')),
    retry_count INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    scheduled_for TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 28. Notification Logs
CREATE TABLE notification_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    queue_id BIGINT REFERENCES notification_queue(id) ON DELETE SET NULL,
    recipient VARCHAR(150) NOT NULL,
    channel VARCHAR(20) NOT NULL,
    notification_type VARCHAR(100) NOT NULL,
    delivery_status VARCHAR(30) NOT NULL,
    provider_response TEXT,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 29. Audit Logs
CREATE TABLE audit_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL, -- e.g. "ROOM_ALLOCATED", "LEAVE_APPROVED", "PAYMENT_RECORDED"
    entity_name VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    ip_address VARCHAR(50),
    details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 30. System Settings
CREATE TABLE system_settings (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description VARCHAR(255),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
