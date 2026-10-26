-- ============================================================================
-- SCRIPT 03: CONSTRAINTS & PERFORMANCE INDEXES FOR HOSTELEASE
-- Connect to 'hostelease_db' before executing this script!
-- Command: psql -U postgres -d hostelease_db -f 03_constraints_indexes.sql
-- ============================================================================

-- 1. CRITICAL BUSINESS RULE CONSTRAINTS (Prevent race conditions & double-allocation)

-- Guarantee at the database level that no bed can have more than one active allocation
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_bed_allocation 
    ON room_allocations(bed_id) 
    WHERE is_active = TRUE;

-- Guarantee at the database level that no student can have more than one active bed allocation
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_student_allocation 
    ON room_allocations(student_id) 
    WHERE is_active = TRUE;

-- 2. LOOKUP AND FILTER PERFORMANCE INDEXES

-- Room & Bed hierarchy
CREATE INDEX IF NOT EXISTS idx_rooms_floor_status ON rooms(floor_id, status);
CREATE INDEX IF NOT EXISTS idx_beds_room_status ON beds(room_id, allocation_status);

-- Student presence & details
CREATE INDEX IF NOT EXISTS idx_students_presence ON students(current_presence);
CREATE INDEX IF NOT EXISTS idx_students_batch_roll ON students(batch_year, roll_number);
CREATE INDEX IF NOT EXISTS idx_students_user_id ON students(user_id);

-- Leave requests (frequently queried in dashboards & overdue checks)
CREATE INDEX IF NOT EXISTS idx_leave_student_id ON student_leave_requests(student_id);
CREATE INDEX IF NOT EXISTS idx_leave_status ON student_leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_leave_expected_return ON student_leave_requests(expected_return_datetime) 
    WHERE status IN ('APPROVED', 'DEPARTED');

-- Invoices & Payments
CREATE INDEX IF NOT EXISTS idx_invoices_student ON invoices(student_id, status);
CREATE INDEX IF NOT EXISTS idx_invoices_due_date ON invoices(due_date) WHERE status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_payments_invoice ON payments(invoice_id);
CREATE INDEX IF NOT EXISTS idx_payments_student ON payments(student_id);

-- Complaints
CREATE INDEX IF NOT EXISTS idx_complaints_hostel_status ON complaints(hostel_id, status);
CREATE INDEX IF NOT EXISTS idx_complaints_student ON complaints(student_id);
CREATE INDEX IF NOT EXISTS idx_complaints_priority ON complaints(priority, status);

-- Visitors
CREATE INDEX IF NOT EXISTS idx_visitor_logs_hostel_status ON visitor_logs(hostel_id, status);
CREATE INDEX IF NOT EXISTS idx_visitor_logs_student ON visitor_logs(student_id);

-- Notifications
CREATE INDEX IF NOT EXISTS idx_notification_queue_poll ON notification_queue(status, scheduled_for)
    WHERE status IN ('PENDING', 'RETRY_SCHEDULED');
CREATE INDEX IF NOT EXISTS idx_notification_logs_recipient ON notification_logs(recipient);

-- Audit Trail
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_action ON audit_logs(user_id, action, created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_name, entity_id);

-- Notices
CREATE INDEX IF NOT EXISTS idx_notices_hostel_created ON notices(hostel_id, created_at DESC);
