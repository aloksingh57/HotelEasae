# Mandatory Special Feature Specification: Student Holiday, Leave & Temporary Vacancy Management

## 1. Executive Summary & Problem Statement
In traditional hostel management systems, a bed is binary: either **Occupied** or **Vacant**. This crude abstraction creates major administrative and safety crises in university hostels:
- When a student goes home for holidays, their bed is empty. If marked as "vacant", another warden might reallocate it to a new student, causing catastrophic double-allocations upon return.
- If left marked as "occupied", wardens and campus security have zero visibility into who is physically inside the building during night roll calls, emergencies, or campus curfews.
- When students overstay leaves or go missing, delayed alerts put student safety at severe risk.

**HostelEase introduces the Temporary Holiday Vacancy Protocol**, an enterprise state-machine architecture that strictly distinguishes between:
1. **Permanently Unallocated Vacant Beds (`UNALLOCATED`)**: Beds with no resident assigned. Available for new room allocations.
2. **Temporarily Vacant Beds (`ALLOCATED` + `AWAY`)**: Beds whose assigned student is away on an approved holiday or leave. The room allocation lock remains 100% active, preventing double-allocation while signaling to wardens, security, and housekeeping that the student is physically off-campus.

---

## 2. Core Comparison Matrix

| Attribute | Permanently Vacant Bed | Temporarily Vacant Bed (On Holiday/Leave) |
|---|---|---|
| **Bed Allocation Status** | `UNALLOCATED` | `ALLOCATED` |
| **Active Student Allocation Record** | None (`is_active = FALSE`) | Present (`is_active = TRUE`, foreign key locked) |
| **Resident Physical Presence** | N/A | `AWAY` |
| **Reallocation Allowed?** | **YES** (Can be assigned to new student) | **NO** (Strictly blocked by database unique index) |
| **Housekeeping & Inspection** | Deep clean / Unoccupied | Routine maintenance / Personal belongings preserved |
| **Gate Check-In Required?** | N/A | **YES** (Must present ID at security gate to transition to `PRESENT`) |
| **Curfew Monitoring** | Disabled | **Active** (Flagged as `OVERDUE` if return date passes) |

---

## 3. Leave & Presence State Machine Lifecycle

```
    [ Student Submits Leave Request ]
                   │
                   ▼
               ( PENDING )
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
   [ REJECTED ]          [ APPROVED ]
  (Remarks logged)            │
                              │ (Student arrives at Security Gate)
                              ▼
                     [ Gate OUT: DEPARTED ]
                     • Student Presence: AWAY
                     • Bed: ALLOCATED (Temp Vacant)
                     • Parent notified via SMS/Email
                              │
               ┌──────────────┴──────────────┐
               │                             │
    (Student Returns on Time)     (End Date Passes without Gate-In)
               │                             │
               ▼                             ▼
       [ Gate IN: RETURNED ]            ( OVERDUE )
       • Student Presence: PRESENT      • Alert warden & parents
       • Bed: Normally Occupied         • Flagged in red pulse
                                             │
                                             │ (Student Returns Late)
                                             ▼
                                     [ Late Gate IN: RETURNED ]
                                     • Restored to PRESENT
```

---

## 4. Technical Implementation Details

### Database Schema Representation
1. Table `students`:
   - `current_presence`: `VARCHAR(30)` CHECK constraint (`PRESENT`, `EXPECTED_TO_LEAVE`, `AWAY`, `RETURN_OVERDUE`).
2. Table `student_leave_requests`:
   - Tracks `departure_datetime`, `expected_return_datetime`, `actual_departure_datetime`, `actual_return_datetime`, `status`.
   - Constraints ensure `expected_return_datetime > departure_datetime`.
3. Table `room_allocations`:
   - Enforced by PostgreSQL Partial Unique Index:
     ```sql
     CREATE UNIQUE INDEX uq_active_bed_allocation 
     ON room_allocations (bed_id) 
     WHERE is_active = TRUE;
     ```
   - When a student departs, `is_active` remains `TRUE`. Therefore, any attempt by an administrator to allocate this bed to another resident triggers a database constraint violation error.

### DAO Layer Atomic Transitions
In `com.hostelease.dao.LeaveDAO`:
- `recordDeparture(leaveId, staffUserId)`:
  - Updates `student_leave_requests` status to `DEPARTED` and sets `actual_departure_datetime = NOW()`.
  - Updates `students` set `current_presence = 'AWAY'`.
  - Inserts log in `leave_history`.
  - Enqueues notification to parents.
- `recordReturn(leaveId, staffUserId)`:
  - Updates `student_leave_requests` status to `RETURNED` and sets `actual_return_datetime = NOW()`.
  - Updates `students` set `current_presence = 'PRESENT'`.
  - Inserts log in `leave_history`.
- `reconcileOverdueLeaves()`:
  - Scans all leave requests where `status = 'DEPARTED'` and `expected_return_datetime < NOW()`.
  - Atomically updates status to `OVERDUE` and sets student presence to `RETURN_OVERDUE`.
  - Dispatches emergency notifications to warden and security.

### Automated Background Worker
In `com.hostelease.config.AppContextListener`:
- Spawns a background `ScheduledExecutorService` running every **15 minutes**.
- Executes `leaveService.reconcileOverdueLeaves()`, guaranteeing that overstaying residents are automatically flagged without manual human intervention.

---

## 5. UI/UX Visual Representation in HostelEase
- **Occupied & Present**: Displayed in vibrant emerald green (`#10b981`), showing resident initials and bed label.
- **Away on Approved Leave (Temporary Vacancy)**: Displayed in amber warning tint (`#f59e0b`) with an airplane icon (`bi-airplane-fill`), explicitly showing "Away on Leave (Bed Temp Vacant)".
- **Return Overdue**: Displayed with glowing pulsating crimson badge (`#ef4444`, `animate-pulse`) with alert icon, immediate guardian call trigger, and high-priority escalation.
- **Unallocated / Vacant**: Displayed in neutral slate-blue with dashed border and "Available" label.
