-- ============================================================================
-- SCRIPT 06: REPORTING VIEWS AND ANALYTICAL QUERIES
-- Connect to 'hostelease_db' before executing this script!
-- Command: psql -U postgres -d hostelease_db -f 06_reports.sql
-- ============================================================================

-- 1. Detailed Room Occupancy & Temporary Vacancy Matrix
CREATE OR REPLACE VIEW v_room_occupancy_matrix AS
SELECT 
    h.id AS hostel_id,
    h.name AS hostel_name,
    b.building_name,
    f.floor_name,
    r.id AS room_id,
    r.room_number,
    r.room_type,
    r.capacity,
    COUNT(bd.id) AS total_beds,
    COUNT(CASE WHEN bd.allocation_status = 'ALLOCATED' THEN 1 END) AS allocated_beds,
    COUNT(CASE WHEN bd.allocation_status = 'UNALLOCATED' THEN 1 END) AS permanently_available_beds,
    COUNT(CASE WHEN bd.allocation_status = 'MAINTENANCE' THEN 1 END) AS maintenance_beds,
    COUNT(CASE WHEN s.current_presence = 'PRESENT' THEN 1 END) AS physically_present_students,
    COUNT(CASE WHEN s.current_presence = 'AWAY' THEN 1 END) AS temporarily_away_students,
    COUNT(CASE WHEN s.current_presence = 'RETURN_OVERDUE' THEN 1 END) AS overdue_students
FROM rooms r
JOIN hostel_floors f ON r.floor_id = f.id
JOIN hostel_buildings b ON f.building_id = b.id
JOIN hostels h ON b.hostel_id = h.id
LEFT JOIN beds bd ON r.id = bd.room_id
LEFT JOIN room_allocations ra ON bd.id = ra.bed_id AND ra.is_active = TRUE
LEFT JOIN students s ON ra.student_id = s.id
GROUP BY h.id, h.name, b.building_name, f.floor_name, r.id, r.room_number, r.room_type, r.capacity;

-- 2. Temporary Vacancies View (Beds where allocated student is temporarily away on approved leave)
CREATE OR REPLACE VIEW v_temporary_vacancies AS
SELECT 
    bd.id AS bed_id,
    bd.bed_label,
    r.room_number,
    b.building_name,
    h.name AS hostel_name,
    h.id AS hostel_id,
    s.id AS student_id,
    u.first_name || ' ' || u.last_name AS student_name,
    s.roll_number,
    u.phone_number AS student_phone,
    lr.id AS leave_request_id,
    lr.leave_type,
    lr.departure_datetime,
    lr.expected_return_datetime,
    lr.actual_departure_datetime,
    s.current_presence
FROM beds bd
JOIN rooms r ON bd.room_id = r.id
JOIN hostel_floors f ON r.floor_id = f.id
JOIN hostel_buildings b ON f.building_id = b.id
JOIN hostels h ON b.hostel_id = h.id
JOIN room_allocations ra ON bd.id = ra.bed_id AND ra.is_active = TRUE
JOIN students s ON ra.student_id = s.id
JOIN users u ON s.user_id = u.id
JOIN student_leave_requests lr ON s.id = lr.student_id
WHERE s.current_presence IN ('AWAY', 'RETURN_OVERDUE')
  AND lr.status IN ('DEPARTED', 'OVERDUE');

-- 3. Overdue Returns Report View
CREATE OR REPLACE VIEW v_overdue_returns AS
SELECT 
    lr.id AS leave_id,
    s.id AS student_id,
    s.roll_number,
    u.first_name || ' ' || u.last_name AS student_name,
    u.phone_number AS student_phone,
    s.guardian_name,
    s.guardian_phone,
    h.name AS hostel_name,
    r.room_number,
    bd.bed_label,
    lr.expected_return_datetime,
    NOW() - lr.expected_return_datetime AS overdue_duration,
    lr.emergency_contact
FROM student_leave_requests lr
JOIN students s ON lr.student_id = s.id
JOIN users u ON s.user_id = u.id
JOIN room_allocations ra ON s.id = ra.student_id AND ra.is_active = TRUE
JOIN beds bd ON ra.bed_id = bd.id
JOIN rooms r ON bd.room_id = r.id
JOIN hostel_floors f ON r.floor_id = f.id
JOIN hostel_buildings b ON f.building_id = b.id
JOIN hostels h ON b.hostel_id = h.id
WHERE lr.status = 'OVERDUE' OR (lr.status = 'DEPARTED' AND lr.expected_return_datetime < CURRENT_TIMESTAMP);

-- 4. Financial & Fee Collection Overview View
CREATE OR REPLACE VIEW v_fee_collection_summary AS
SELECT 
    h.id AS hostel_id,
    h.name AS hostel_name,
    COUNT(inv.id) AS total_invoices,
    COALESCE(SUM(inv.amount), 0.00) AS total_billed_amount,
    COALESCE(SUM(inv.paid_amount), 0.00) AS total_collected_amount,
    COALESCE(SUM(inv.amount - inv.paid_amount), 0.00) AS total_outstanding_amount,
    COUNT(CASE WHEN inv.status = 'PAID' THEN 1 END) AS paid_invoices_count,
    COUNT(CASE WHEN inv.status = 'PENDING' THEN 1 END) AS pending_invoices_count,
    COUNT(CASE WHEN inv.status = 'OVERDUE' THEN 1 END) AS overdue_invoices_count
FROM hostels h
LEFT JOIN hostel_buildings b ON h.id = b.hostel_id
LEFT JOIN hostel_floors f ON b.id = f.building_id
LEFT JOIN rooms r ON f.id = r.floor_id
LEFT JOIN beds bd ON r.id = bd.room_id
LEFT JOIN room_allocations ra ON bd.id = ra.bed_id AND ra.is_active = TRUE
LEFT JOIN students s ON ra.student_id = s.id
LEFT JOIN invoices inv ON s.id = inv.student_id
GROUP BY h.id, h.name;
