# Automated Testing & Verification Report: HostelEase

## 1. Test Execution Summary
- **Test Framework**: JUnit 5 (Jupiter Engine 5.10.2) + Mockito 5.11.0.
- **Build Tool**: Apache Maven 3.10.0 (`maven-surefire-plugin:3.2.5`).
- **Database Target**: PostgreSQL 17.11 with live schema and seed data.
- **Execution Date**: October 22, 2026.
- **Test Results**:
  - **Total Tests Run**: 13
  - **Passed**: 13 (100%)
  - **Failures**: 0
  - **Errors**: 0
  - **Skipped**: 0
  - **Execution Time**: ~1.85 seconds

---

## 2. Test Suite Breakdown

### 2.1 Cryptographic & Security Utilities (`PasswordUtilTest`)
| Test Method | Objective | Result |
|---|---|---|
| `testHashAndVerify()` | Validates that BCrypt hashing generates standard `$2a$10$...` hashes that verify correctly against raw passwords. | **PASSED** |
| `testNullAndEmptyPasswords()` | Validates defensive rejection of null, empty, or malformed inputs without throwing unexpected runtime exceptions. | **PASSED** |
| `testSaltUniqueness()` | Confirms that independent salt generation ensures identical plain passwords produce completely distinct hashes. | **PASSED** |

### 2.2 Role-Based Authentication Service (`AuthServiceTest`)
| Test Method | Objective | Result |
|---|---|---|
| `testAdminAuthentication()` | Verifies administrator credentials (`admin` / `Admin@123`), role assignment (`ADMIN`), and active account status. | **PASSED** |
| `testWardenAuthentication()` | Verifies warden credentials (`warden.boys` / `Warden@123`), role assignment (`WARDEN`), and assigned building association (`hostelId = 1`). | **PASSED** |
| `testStudentAuthentication()` | Verifies resident credentials (`student1@hostelease.com` / `Student@123`), role assignment (`STUDENT`), and user resolution. | **PASSED** |
| `testAuthenticationFailsWrongPassword()` | Confirms that incorrect passwords fail gracefully and return null without leaking account existence. | **PASSED** |
| `testAuthenticationFailsUnknownUser()` | Confirms that non-existent accounts fail gracefully and return null. | **PASSED** |
| `testAuthenticationEmptyInputs()` | Confirms that whitespace, null, or empty credentials return null safely. | **PASSED** |

### 2.3 Room Allocation & Concurrency Control (`AllocationServiceTest`)
| Test Method | Objective | Result |
|---|---|---|
| `testDoubleAllocationPrevention()` | Verifies that attempting to allocate an already occupied bed (`Bed 1`) to another resident fails atomically, protected by both application check-and-set and PostgreSQL partial unique index `uq_active_bed_allocation`. | **PASSED** |
| `testGetUnallocatedStudents()` | Confirms that unallocated students query returns students without active bed assignments. | **PASSED** |

### 2.4 Leave Workflow & Temporary Vacancy Preservation (`LeaveWorkflowTest`)
| Test Method | Objective | Result |
|---|---|---|
| `testCompleteLeaveLifecycleAndAllocationPreservation()` | **Mandatory Special Feature Validation**:<br>1. Submits leave application (Status: `PENDING`).<br>2. Warden approves (Status: `APPROVED`).<br>3. Security Gate marks departure (Status: `DEPARTED`, Student Presence: `AWAY`).<br>4. **CRITICAL INTEGRITY CHECK**: Confirms bed allocation remains active (`status = ALLOCATED`), proving that the bed is flagged as a temporary holiday vacancy while preserving the student's room lock against reallocation.<br>5. Security Gate marks return (Status: `RETURNED`, Student Presence: `PRESENT`). | **PASSED** |
| `testInvalidLeaveDatesRejected()` | Validates that leave applications where expected return date is earlier than departure date are rejected by validation constraints. | **PASSED** |

---

## 3. Security & Non-Functional Verification
1. **CSRF Protection**: All POST endpoints (`/admin/allocations`, `/admin/fees`, `/warden/leaves`, `/warden/presence`, `/student/leaves`, etc.) enforce session-bound anti-CSRF token verification via `CsrfProtection.java`.
2. **Session Hijacking Mitigation**: `LoginServlet` invokes `req.changeSessionId()` upon successful credential authentication, preventing session fixation vulnerabilities.
3. **Role-Based Access Control**: `SecurityFilter` strictly intercepts all `/admin/*`, `/warden/*`, and `/student/*` requests, redirecting unauthorized users with HTTP 403 / Login challenges.
4. **No Scriptlets in JSPs**: All views use pure JSTL `<c:*>` and EL expressions. Zero Java scriptlets (`<% ... %>`) are used, ensuring clean separation of presentation and business logic.
