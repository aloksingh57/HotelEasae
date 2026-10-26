# HostelEase — Observability, Logging & Health Monitoring

## 1. Logging Architecture
HostelEase utilizes the **SLF4J 2.0.x** facade with structured category logging across controllers, services, and security boundaries.

### Log Categories:
1. `com.hostelease.security.SecurityFilter`: Authorization violations, CSRF token failures, unauthenticated access attempts.
2. `com.hostelease.service.AuthService`: Authentication events, successful logins, IP addresses, failed password attempts.
3. `com.hostelease.service.LeaveService`: State transitions, approvals, departure check-outs, return check-ins, overdue alerts.
4. `com.hostelease.notification`: Background dispatcher status, email delivery attempts, SMS provider responses.
5. `com.hostelease.config.DatabaseConfig`: Pool utilization, connection lifecycle, HikariCP metrics.

---

## 2. Audit Trail Persistence
Critical administrative actions are stored in PostgreSQL table `audit_logs`:
- User identifier & role
- Action type (`LOGIN_SUCCESS`, `LOGIN_FAILED`, `ALLOCATION_CREATED`, `LEAVE_DEPARTURE`, `PAYMENT_RECORDED`)
- Target entity reference (e.g. `STUDENT #4`, `ROOM #101`)
- Client IP address and detailed remarks
- Precise timestamp

---

## 3. Real-Time Health Check Endpoint
- **URL**: `GET /health`
- **Output (JSON)**:
  ```json
  {
    "status": "HEALTHY",
    "database_reachable": true,
    "query_execution": true,
    "tables_detected": 30,
    "database_version": "17.11",
    "timestamp": 1793005602738
  }
  ```
- Use this endpoint for container liveness probes (Docker/Kubernetes) or uptime monitoring services (UptimeKuma, Datadog, Pingdom).
