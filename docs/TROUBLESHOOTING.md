# HostelEase — Troubleshooting & Diagnostic Guide

## 1. Common Issues & Solutions

### A. Database Connection Refused (`port 5432` vs `port 5433`)
- **Symptom**: `Connection to localhost:5432 refused (0x0000274D/10061)`.
- **Cause**: On many Windows machines with multiple PostgreSQL versions, PostgreSQL 17 listens on port `5433` instead of `5432`.
- **Resolution**:
  Set `DB_PORT=5433` in `.env` or in Tomcat's `bin/setenv.bat`. Run `netstat -ano | findstr 5432 5433` to verify the active listening port.

### B. Tomcat `JAVA_HOME` or `JRE_HOME` Not Defined
- **Symptom**: `Neither the JAVA_HOME nor the JRE_HOME environment variable is defined`.
- **Resolution**: Create or verify `setenv.bat` in `C:\apache-tomcat-10.1\bin\setenv.bat`:
  ```batch
  set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
  set "CATALINA_HOME=C:\apache-tomcat-10.1"
  ```

### C. `PropertyNotFoundException` on EL Evaluation
- **Symptom**: `Property [bedNumber] not found on type [com.hostelease.model.LeaveRequest]`.
- **Resolution**: Model classes provide getter aliases (`getBedNumber()` -> `bedLabel`, `getEntryTime()` -> `entryDatetime`, `getTicketNumber()` -> `complaintCode`). Always use the Java Bean getter naming convention.

### D. Anti-CSRF Token Mismatch
- **Symptom**: Form submission returns `403 Forbidden: Invalid CSRF Token`.
- **Resolution**: Ensure all POST forms include the hidden input:
  ```jsp
  <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
  ```

### E. Health Check Diagnostic
Access `http://localhost:8080/HostelEase/health` in your browser. It tests:
1. Driver initialization
2. Database reachability
3. `SELECT 1` execution
4. Count of detected relational tables (must be 30).
