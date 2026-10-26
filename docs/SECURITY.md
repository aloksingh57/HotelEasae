# HostelEase — Security Architecture & Hardening Guide

## 1. Security Overview
HostelEase implements defense-in-depth security principles across authentication, authorization, session management, data encryption, and input validation.

---

## 2. Authentication & Credential Storage
- **Password Hashing**: BCrypt algorithm (`jBCrypt 0.4`) with cost factor 10.
- **Salt Generation**: Cryptographically secure per-user salt.
- **No Plaintext Passwords**: No cleartext passwords stored in the database or logged in application logs.
- **Zero Secrets in Source**: Database credentials, SMTP tokens, and SMS API keys are loaded strictly from environment variables or protected `.env` files.

---

## 3. Session Security & Fixation Protection
- **Session ID Renewal**: Upon successful login, the existing session is invalidated and an entirely new session ID is issued to defeat Session Fixation attacks:
  ```java
  HttpSession oldSession = request.getSession(false);
  if (oldSession != null) oldSession.invalidate();
  HttpSession newSession = request.getSession(true);
  ```
- **Cookie Flags**:
  - `HttpOnly`: Enforces non-accessibility via JavaScript (`document.cookie`), preventing XSS cookie theft.
  - `SameSite=Lax`: Defends against Cross-Site Request Forgery on cross-origin requests.
  - `Secure`: Required in production over TLS/HTTPS.
- **Session Timeout**: Configured for 60 minutes of inactivity.

---

## 4. Role-Based Access Control (RBAC) & Anti-IDOR
A centralized `SecurityFilter` inspects every incoming HTTP request:
- `/admin/*`: Enforces `role == ADMIN`.
- `/warden/*`: Enforces `role == WARDEN` and validates that the requested resource belongs to the warden's assigned `hostelId`.
- `/student/*`: Enforces `role == STUDENT` and asserts that any requested student ID or invoice matches `sessionUser.getStudentId()`.
- Hiding UI buttons is NEVER considered a security boundary; all checks execute server-side on every request.

---

## 5. Injection Prevention & Database Integrity
- **100% Parameterized JDBC**: All SQL queries use `PreparedStatement` with bound parameters (`?`). Zero dynamic SQL string concatenation.
- **Concurrency Locks**: Partial unique indexes in PostgreSQL (`uq_active_bed_allocation`, `uq_active_student_allocation`) guarantee database-level atomic isolation against concurrent race conditions.

---

## 6. CSRF & Security Headers
- Every state-mutating POST request requires a synchronized Anti-CSRF token stored in the server session.
- HTTP Response Security Headers applied on every request:
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: SAMEORIGIN`
  - `X-XSS-Protection: 1; mode=block`
  - `Referrer-Policy: strict-origin-when-cross-origin`
