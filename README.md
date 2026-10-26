# 🏢 HostelEase — Smart Hostel Management System

[![Java](https://img.shields.io/badge/Java-17%20LTS-orange.svg)](https://www.oracle.com/java/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10%20(Servlet%206.0)-red.svg)](https://jakarta.ee/)
[![Apache Tomcat](https://img.shields.io/badge/Apache%20Tomcat-10.1.x-yellow.svg)](https://tomcat.apache.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17.x-blue.svg)](https://www.postgresql.org/)
[![HikariCP](https://img.shields.io/badge/Connection%20Pool-HikariCP%205.1-brightgreen.svg)](https://github.com/brettwooldridge/HikariCP)
[![Tests](https://img.shields.io/badge/Tests-13%20Passed%20(100%25)-success.svg)](docs/TESTING_REPORT.md)

**HostelEase** is an enterprise-grade, product-ready Smart Hostel Management Web Application designed for universities, colleges, and residential institutions. Built in strict adherence to the **Jakarta EE 10 / Servlet 6.0** specification, running on **Apache Tomcat 10.1.x** with a high-performance **PostgreSQL 17** relational database backend.

---

## 🌟 Mandatory Special Feature: Holiday, Leave & Temporary Vacancy Management

Traditional hostel systems treat beds as binary: either occupied or vacant. When a student goes home on vacation, their bed is empty. If marked vacant, it risks being reallocated to someone else; if marked occupied, campus wardens lose visibility into who is actually on campus during night roll calls or emergencies.

**HostelEase solves this with the Temporary Holiday Vacancy Protocol:**
- **Preserves Allocation Integrity**: When a student goes on approved leave, their bed remains assigned to them (`status = ALLOCATED`) and is strictly locked by database unique indexes against reallocation.
- **Real-Time Physical Presence Tracking**: The student's presence state transitions from `PRESENT` to `AWAY` upon gate exit, marking the bed as a **Temporary Holiday Vacancy** for warden inspection and housekeeping.
- **Automated Return & Overdue Detection**: When the scheduled return date passes without gate re-entry, the background reconciliation worker automatically flags the student as `RETURN_OVERDUE`, alerts the warden with flashing visual indicators, and displays immediate emergency contact buttons.
- **Re-Entry Restoration**: When the resident scans back in at the gate, their state restores to `PRESENT` and room occupancy is updated instantly.

---

## 👥 Demo User Logins (Ready to Test)

The database comes pre-seeded with realistic operational data, sample rooms, and test accounts:

| Portal | Username / Email | Password | Role & Assigned Facility |
|---|---|---|---|
| **Executive Admin** | `admin` | `Admin@123` | Institutional Administrator (Full Oversight) |
| **Boys Hostel Warden** | `warden.boys` | `Warden@123` | Aryabhatta Boys Hostel (Hostel ID 1) |
| **Girls Hostel Warden** | `warden.girls` | `Warden@123` | Gargi Girls Hostel (Hostel ID 2) |
| **Student 1** | `student1@hostelease.com` (or `rohan.sharma`) | `Student@123` | Room 101, Bed B1 — **Present in Hostel** |
| **Student 2** | `student2@hostelease.com` (or `priya.verma`) | `Student@123` | Room 101, Bed B2 — **Away on Holiday (Temp Vacant)** |
| **Student 3** | `student3@hostelease.com` (or `vikram.singh`) | `Student@123` | Room 101, Bed B3 — **Return Overdue Alert** |

> **Note**: Quick demo-login buttons are provided on the login page (`/login`) for instantaneous one-click testing of each persona!

---

## 🏗️ Architecture & Technical Stack

```
[ Browser / Mobile Client ]
         │ (HTTP / HTTPS)
         ▼
[ EncodingFilter (UTF-8) & SecurityFilter (RBAC + Session Renewal) ]
         │
[ Controllers (AdminServlet, WardenServlet, StudentServlet) ]
         │
[ Business Service Layer (LeaveService, FeeService, RoomService) ]
         │
[ Data Access Objects (UserDAO, RoomDAO, LeaveDAO, AllocationDAO) ]
         │
[ HikariCP High-Performance Connection Pool ]
         │ (JDBC)
         ▼
[ PostgreSQL 17 Database (`hostelease_db`) ]
```

- **Backend**: Java 17 LTS, Jakarta Servlet 6.0, JSP 3.1, JSTL 3.0, HikariCP 5.1.0, jBCrypt 0.4.
- **Database**: PostgreSQL 17.x with partial unique indexes (`uq_active_bed_allocation`), check constraints, and analytical views.
- **Frontend**: Modern HTML5, CSS3 with glassmorphism, responsive CSS Grid bed matrix, micro-animations, and Chart.js 4.4.x.
- **Security**: BCrypt password hashing (Cost factor 10), Anti-CSRF token protection on all state mutations, session ID renewal upon login, role-based URL authorization filters.
- **Notifications**: Jakarta Mail 2.0 (HTML email templates) + pluggable SMS Provider (Twilio + Mock).

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Java**: JDK 17 LTS or higher (JDK 17/21/26).
- **PostgreSQL**: PostgreSQL 17.x installed and running on port `5432`.
- **Tomcat**: Apache Tomcat 10.1.x (for Jakarta EE 10).
- **Maven**: Apache Maven 3.8+ (bundled script auto-detects user Maven).

### 2. Database Setup
Execute the ordered SQL scripts in PostgreSQL:
```bash
# Connect and create database
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -f database/01_create_database.sql

# Create schema and tables
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/02_create_tables.sql

# Create partial unique indexes and performance constraints
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/03_constraints_indexes.sql

# Seed facilities, rooms, beds, and academic sessions
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/04_seed_data.sql

# Seed verified sample accounts and operational states
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/05_sample_accounts.sql

# Create analytical reporting views
"C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -d hostelease_db -f database/06_reports.sql
```

### 3. Verify Environment
Run the automated verification script:
```bat
scripts\verify-environment.bat
```

### 4. Build and Package WAR
Compile the application, run all automated tests, and build `target/HostelEase.war`:
```bat
scripts\build.bat
```

### 5. Run Automated Tests
Execute the 13 automated unit, integration, and concurrency test suites:
```bat
scripts\run-tests.bat
```

### 6. Deploy to Apache Tomcat 10.1
Deploy the WAR archive directly into Tomcat's `webapps` folder:
```bat
scripts\deploy-to-tomcat.bat
```
Or copy `target/HostelEase.war` into your Tomcat `%CATALINA_HOME%\webapps\` directory manually.

Access the application at:
```
http://localhost:8080/HostelEase/
```

---

## 📁 Project Structure

```
project1/
├── pom.xml                               # Maven Project Descriptor (Jakarta EE 10, Java 17, Tomcat 10.1)
├── README.md                             # Master Project Documentation
├── .env.example                          # Configuration template for database, mail, and SMS
├── database/                             # Database Initialization Scripts (PostgreSQL 17)
│   ├── 01_create_database.sql            # Database creation
│   ├── 02_create_tables.sql              # 30 relational tables & constraints
│   ├── 03_constraints_indexes.sql        # Partial unique indexes for allocation isolation
│   ├── 04_seed_data.sql                  # Facilities, blocks, rooms, beds, sessions
│   ├── 05_sample_accounts.sql            # BCrypt-hashed users & realistic operational states
│   └── 06_reports.sql                    # Analytical reporting views
├── docs/                                 # Comprehensive Documentation Suite
│   ├── PROJECT_OVERVIEW.md               # Technical architecture & subsystem design
│   ├── TEMPORARY_VACANCY_SPECIFICATION.md# Mandatory Special Feature technical spec
│   ├── DATABASE_SETUP.md                 # Database schema dictionary & setup instructions
│   ├── ECLIPSE_SETUP.md                  # Eclipse IDE import and server configuration
│   ├── TOMCAT_SETUP.md                   # Tomcat 10.1 installation & deployment guide
│   ├── NOTIFICATION_SETUP.md             # Jakarta Mail and Twilio/Mock SMS setup
│   ├── USER_GUIDE.md                     # End-user operations manual (Admin, Warden, Student)
│   └── TESTING_REPORT.md                 # Automated test suite execution & results
├── scripts/                              # Windows Automation Scripts
│   ├── verify-environment.bat            # Checks Java, Maven, PostgreSQL, and Tomcat
│   ├── build.bat                         # Compiles and packages HostelEase.war
│   ├── run-tests.bat                     # Executes JUnit 5 test suite
│   └── deploy-to-tomcat.bat              # Copies WAR archive to Tomcat webapps
└── src/
    ├── main/
    │   ├── java/com/hostelease/          # Java Enterprise Source Code
    │   │   ├── config/                   # HikariCP, DatabaseConfig, AppContextListener
    │   │   ├── controller/               # Servlets (Admin, Warden, Student, Auth, API)
    │   │   ├── dao/                      # Data Access Objects with atomic transactions
    │   │   ├── model/                    # POJO domain entities
    │   │   ├── notification/             # Jakarta Mail & SMS Provider Adapters
    │   │   ├── security/                 # CSRF protection & role-based authentication filters
    │   │   ├── service/                  # Business logic services
    │   │   └── util/                     # BCrypt password hashing & JSON utilities
    │   ├── resources/
    │   │   └── application.properties    # Database pool & environment configuration
    │   └── webapp/
    │       ├── index.jsp                 # Interactive public landing page with live statistics
    │       ├── login.jsp                 # Authentication portal with quick demo-login triggers
    │       ├── assets/                   # CSS3 stylesheets, vanilla JS, Chart.js integrations
    │       └── WEB-INF/
    │           ├── web.xml               # Servlet 6.0 deployment descriptor
    │           └── views/                # Protected MVC Views
    │               ├── admin/            # Dashboard, Room Matrix, Allocations, Students, Fees, Reports, Hostels
    │               ├── warden/           # Console, Leave Approvals, Gate Checkpoint, Visitors, Complaints, Rooms
    │               ├── student/          # Portal, Leave Form, Maintenance Tickets, Fee Portal, Profile
    │               ├── common/           # Header, Sidebar, Footer components
    │               └── error/            # Custom 403, 404, 500 error pages
    └── test/java/com/hostelease/         # JUnit 5 Automated Test Suites
        ├── service/
        │   ├── AllocationServiceTest.java# Concurrency & double-allocation tests
        │   ├── AuthServiceTest.java      # RBAC authentication & password tests
        │   └── LeaveWorkflowTest.java    # Complete leave lifecycle & temporary vacancy tests
        └── util/
            └── PasswordUtilTest.java     # BCrypt hashing & salt uniqueness tests
```

---

## 💻 Eclipse IDE Import Instructions
1. Open Eclipse IDE for Enterprise Java.
2. Select **File -> Import... -> Maven -> Existing Maven Projects**.
3. Choose the project root folder `c:\Users\Lenovo\OneDrive\Desktop\hostelease\project1`.
4. Add **Apache Tomcat v10.1 Server** in the **Servers** tab.
5. Right-click the project -> **Run As -> Run on Server** -> Select Tomcat 10.1.
6. For full details, see [`docs/ECLIPSE_SETUP.md`](docs/ECLIPSE_SETUP.md).

---

## 🔒 Enterprise Security Features
- **Anti-CSRF Tokens**: Bound to user HTTP session, validated on all POST/PUT actions.
- **Session ID Renewal**: `req.changeSessionId()` prevents session fixation attacks upon login.
- **Partial Unique Indexes**: Concurrency protection against race conditions and double room allocations.
- **Timing-Attack Immune BCrypt**: Safe credential verification with work factor 10.
- **Zero Scriptlet JSPs**: Pure JSTL `<c:*>` and Expression Language (EL) for complete code separation.

---

## 📲 Multi-Channel Email & SMS Notification Engine

HostelEase features an asynchronous, fault-tolerant background notification dispatcher (`NotificationDispatcher` and `NotificationService`) supporting dual delivery channels:

1. **Email Channel (SMTP)**: Dispatches branded HTML transaction notices with automated failover and simulation modes (`EmailService`).
2. **SMS Gateway Channel**: Formats and delivers urgent mobile SMS alerts directly to the student's mobile number, the guardian's phone number, and the assigned hostel warden's registered contact number (`MockSmsProvider` or `TwilioSmsProvider`).

### Supported Lifecycle Triggers:
- **Student Leave Lifecycle**:
  - Application submitted: Instant SMS/Email alert to the assigned hostel warden.
  - Leave approved/rejected: Immediate SMS/Email alert to student and guardian.
  - Campus Gate Departure recorded: Automated SMS to guardian confirming student exit and marking room bed as a temporary vacancy.
  - Campus Gate Return recorded: Confirmation SMS to student and guardian restoring active presence.
  - Overdue return warning: Automated priority SMS alerts to warden and guardian.
- **Maintenance & Complaints**:
  - Complaint registered: SMS/Email to hostel warden with ticket number and room location.
  - Complaint resolved: Status change notification to resident student.
- **Room Allocation & Transfer**:
  - Bed allocated or transferred: Welcome and room assignment SMS/Email with room number and bed label.
  - Permanent checkout: Formal checkout receipt and clearance notification.
- **Fee Management**:
  - Invoice generated: Payment due alert sent to student.
  - Payment recorded: Official payment receipt and transaction reference dispatched.
- **Visitor Security Management**:
  - Visitor checked in at campus gate: Real-time SMS alert to resident student notifying them of their visitor's arrival.

### Delivery Audit Ledger:
Administrators can review and audit all queued, dispatched, and failed notifications in real time via **Admin Console -> Reports & Analytics -> Notifications (SMS & Email)** (`/admin/reports?type=notifications`).

---

## 📜 License
Developed as an enterprise-grade Smart Hostel Management Solution for universities and residential institutions.
