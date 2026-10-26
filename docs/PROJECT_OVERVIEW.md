# HostelEase — Smart Hostel Management System: Comprehensive Project Architecture

## Executive Summary
**HostelEase** is an enterprise-grade, product-ready residential campus management web platform engineered in strict compliance with the **Jakarta EE 10 / Servlet 6.0** specification, running on **Apache Tomcat 10.1.x** with a high-performance **PostgreSQL 17** relational database backend.

The platform eliminates administrative blindspots in higher education hostels by integrating room allocation, financial fee invoicing, maintenance ticketing, visitor security logging, and automated student movement tracking.

---

## Technical Stack & Compatibility Matrix

| Architectural Layer | Selected Enterprise Technology | Version | Purpose / Standards |
|---|---|---|---|
| **Programming Language** | Java (JDK) | 17 LTS (Release target) | Core business logic, thread-safety, pattern matching |
| **Servlet Specification** | Jakarta Servlet API | 6.0.0 (`jakarta.servlet.*`) | Enterprise HTTP request handling and filter chaining |
| **Server / Container** | Apache Tomcat | 10.1.x | Servlet 6.0 & JSP 3.1 compliant web container |
| **Database Engine** | PostgreSQL | 17.x | ACID-compliant relational data store with partial indexing |
| **Connection Pooling** | HikariCP | 5.1.0 | Microsecond-latency JDBC connection pool with health checks |
| **Security & Cryptography** | jBCrypt | 0.4 | Password hashing (Cost factor 10, salting, timing attack prevention) |
| **Data Interchange** | Google Gson | 2.11.0 | RESTful JSON serialization for dynamic client dashboards |
| **Messaging & Notifications** | Jakarta Mail + Twilio Adapter | 2.0.1 / Mock | Multi-channel email and SMS alerts for parents and staff |
| **Frontend Architecture** | JSP 3.1, JSTL 3.0, Vanilla CSS/JS | Modern CSS3 | Glassmorphism, CSS Grid bed matrix, micro-animations |
| **Data Visualizations** | Chart.js | 4.4.x | Real-time occupancy doughnuts and revenue collection bar charts |
| **Test Automation** | JUnit 5 & Mockito | 5.10.2 / 5.11.0 | Unit, integration, concurrency, and business rule tests |

---

## Architectural Principles & Design Patterns

### 1. Pure Jakarta MVC Architecture
- **Model**: POJO models in package `com.hostelease.model` mirroring relational entities with defensive encapsulation.
- **View**: Standard JSP 3.1 pages in `/WEB-INF/views/` (protected from direct browser access), using JSTL `<c:*>` tags and CSS3 design system tokens. Zero Java scriptlet code (`<% ... %>`) is permitted in view templates.
- **Controller**: Strongly-typed HTTP servlets in `com.hostelease.controller` mapped declaratively via `@WebServlet` annotations.

### 2. Multi-Tier Layered Separation
```
[ Browser / Mobile Client ]
         │ (HTTPS / HTTP)
         ▼
[ EncodingFilter & SecurityFilter (RBAC + Session Renewal) ]
         │
[ Controllers (AdminServlet, WardenServlet, StudentServlet) ]
         │
[ Business Service Layer (LeaveService, FeeService, RoomService) ]
         │
[ Data Access Objects (UserDAO, RoomDAO, LeaveDAO, AllocationDAO) ]
         │
[ HikariCP Connection Pool ]
         │ (JDBC)
         ▼
[ PostgreSQL 17 Database (`hostelease_db`) ]
```

### 3. Concurrency & Data Integrity
- **Partial Unique Indexes**: Enforced in PostgreSQL (`uq_active_bed_allocation` and `uq_active_student_allocation`) to physically prohibit double-allocations at the database engine level.
- **Check-and-Set Atomic Transactions**: `AllocationDAO` and `LeaveDAO` execute with `conn.setAutoCommit(false)` and `SELECT ... FOR UPDATE` isolation to guarantee zero race conditions during peak admission or holiday departure rushes.

---

## System Role Capabilities

### 1. Administrator (`ADMIN`)
- **Executive Oversight**: Institutional dashboard with real-time occupancy statistics, revenue totals, and resident counts.
- **Room & Bed Matrix**: Visual color-coded grid of all facilities, floors, and rooms.
- **Allocations & Transfers**: Atomic check-and-set room allocation, inter-room transfers, and permanent student checkout.
- **Fee Management**: Invoice generation, outstanding fee tracking, and manual payment posting with digital receipts.
- **Audit & Compliance**: Searchable analytical reports across occupancy, temporary holiday vacancies, overdue returns, and financials.

### 2. Warden (`WARDEN`)
- **Facility Operations**: Live supervision dashboard restricted to the warden's assigned residential building.
- **Leave Authorizations**: Review student leave applications, verify parent consent, and approve/reject with logged remarks.
- **Gate Checkpoint**: Security checkpoint recording physical departure (student set to `AWAY`) and return (student set to `PRESENT`).
- **Overdue Tracking**: Automated detection and alerting for resident students who have not returned past approved curfew.
- **Visitor Security Pass**: Register outside visitors, capture government photo IDs, and record checkout timestamps.
- **Maintenance Dispatch**: Update repair tickets and coordinate technicians.

### 3. Student Resident (`STUDENT`)
- **Resident Dashboard**: Personalized overview of allocated room, bed, fees, and campus notices.
- **Holiday & Leave Request**: Submit planned vacation or emergency absence applications with automated parent notification.
- **Maintenance Ticketing**: Lodge room repair requests (electrical, plumbing, carpentry, internet) with SLA tracking.
- **Fee Payment Portal**: View invoiced semester charges, outstanding balances, and simulate online payments.
- **Profile & Credential Verification**: View academic records, room credentials, and verified emergency contacts.
