<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HostelEase — Smart Hostel Management System</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Custom Style -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .hero-section {
            background: radial-gradient(circle at 10% 20%, rgba(37, 99, 235, 0.15) 0%, transparent 40%),
                        radial-gradient(circle at 90% 80%, rgba(99, 102, 241, 0.15) 0%, transparent 40%),
                        linear-gradient(180deg, #ffffff 0%, var(--slate-50) 100%);
            padding: 90px 20px 70px;
            text-align: center;
            border-bottom: 1px solid var(--slate-200);
        }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 16px;
            background: #eef2ff;
            color: var(--blue-600);
            border-radius: var(--radius-full);
            font-size: 13px;
            font-weight: 700;
            border: 1px solid #c7d2fe;
            margin-bottom: 24px;
        }
        .hero-title {
            font-size: 48px;
            font-weight: 800;
            line-height: 1.15;
            letter-spacing: -1.5px;
            color: var(--navy-950);
            max-width: 840px;
            margin: 0 auto 20px;
        }
        .hero-subtitle {
            font-size: 18px;
            color: var(--navy-600);
            max-width: 640px;
            margin: 0 auto 36px;
        }
        .portal-card {
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 28px;
            border: 1px solid var(--slate-200);
            box-shadow: var(--glass-shadow);
            transition: var(--transition-smooth);
            text-align: left;
            position: relative;
            overflow: hidden;
        }
        .portal-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--card-shadow-hover);
            border-color: var(--blue-500);
        }
    </style>
</head>
<body>

    <!-- Top Navigation Header -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom sticky-top py-3">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center gap-2 fw-bold fs-4 text-dark" href="${pageContext.request.contextPath}/">
                <div class="brand-icon" style="width: 36px; height: 36px; font-size: 18px;">
                    <i class="bi bi-buildings"></i>
                </div>
                <span>Hostel<span class="text-primary">Ease</span></span>
            </a>
            <div class="d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/health" class="btn btn-sm btn-outline-secondary d-none d-sm-inline-flex align-items-center gap-1" target="_blank">
                    <span class="p-1 bg-success rounded-circle"></span>
                    <span>System Health</span>
                </a>
                <c:choose>
                    <c:when test="${sessionScope.CURRENT_USER != null}">
                        <a href="${pageContext.request.contextPath}/${sessionScope.CURRENT_USER.role.toLowerCase()}/dashboard" class="btn btn-primary-custom">
                            <i class="bi bi-grid-fill"></i>
                            <span>Go to Dashboard</span>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary-custom">
                            <i class="bi bi-box-arrow-in-right"></i>
                            <span>Sign In</span>
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <div class="hero-badge">
                <i class="bi bi-shield-check"></i>
                <span>Enterprise Production Ready &bull; PostgreSQL 17 &bull; Tomcat 10</span>
            </div>
            <h1 class="hero-title">Intelligent Campus Living & <span class="text-primary">Smart Hostel Management</span></h1>
            <p class="hero-subtitle">
                Unified operational platform featuring real-time room occupancy, temporary student vacancy tracking, automated fee invoicing, and seamless leave approvals.
            </p>

            <div class="d-flex flex-wrap justify-content-center gap-3 mb-5">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-lg px-4 py-3 fw-bold rounded-3 shadow">
                    <i class="bi bi-door-open me-2"></i>Access Portal
                </a>
                <a href="#stats-section" class="btn btn-outline-dark btn-lg px-4 py-3 fw-bold rounded-3">
                    <i class="bi bi-bar-chart-line me-2"></i>Live Occupancy Metrics
                </a>
            </div>

            <!-- Live Metrics Snapshot -->
            <div class="row g-3 justify-content-center" id="stats-section">
                <div class="col-6 col-md-2">
                    <div class="bg-white p-3 rounded-3 border shadow-sm">
                        <div class="fs-3 fw-bold text-dark">${stats.totalRooms != null ? stats.totalRooms : 13}</div>
                        <div class="small text-secondary fw-semibold">Total Rooms</div>
                    </div>
                </div>
                <div class="col-6 col-md-2">
                    <div class="bg-white p-3 rounded-3 border shadow-sm">
                        <div class="fs-3 fw-bold text-primary">${stats.totalBeds != null ? stats.totalBeds : 30}</div>
                        <div class="small text-secondary fw-semibold">Total Beds</div>
                    </div>
                </div>
                <div class="col-6 col-md-2">
                    <div class="bg-white p-3 rounded-3 border shadow-sm">
                        <div class="fs-3 fw-bold text-success">${stats.presentStudents != null ? stats.presentStudents : 10}</div>
                        <div class="small text-secondary fw-semibold">Present in Hostel</div>
                    </div>
                </div>
                <div class="col-6 col-md-2">
                    <div class="bg-white p-3 rounded-3 border shadow-sm" style="border-bottom: 3px solid var(--amber-500) !important;">
                        <div class="fs-3 fw-bold text-warning">${stats.awayStudents != null ? stats.awayStudents : 1}</div>
                        <div class="small text-secondary fw-semibold">Away on Holiday</div>
                    </div>
                </div>
                <div class="col-6 col-md-2">
                    <div class="bg-white p-3 rounded-3 border shadow-sm">
                        <div class="fs-3 fw-bold text-info">${stats.availableBeds != null ? stats.availableBeds : 14}</div>
                        <div class="small text-secondary fw-semibold">Vacant Beds</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Role Portals Grid -->
    <section class="py-5 bg-white">
        <div class="container py-4">
            <div class="text-center mb-5">
                <h2 class="fw-bold">Role-Based Operational Portals</h2>
                <p class="text-secondary">Designed with strict access boundaries and role-tailored dashboards.</p>
            </div>

            <div class="row g-4">
                <!-- Admin Portal Card -->
                <div class="col-md-4">
                    <div class="portal-card h-100 d-flex flex-direction-column justify-content-between">
                        <div>
                            <div class="stat-icon blue mb-3" style="width: 48px; height: 48px;">
                                <i class="bi bi-shield-lock-fill fs-4"></i>
                            </div>
                            <h4 class="fw-bold mb-2">Administrator Portal</h4>
                            <p class="text-secondary small mb-4">
                                Complete administrative governance. Facility configuration, atomic room allocations and transfers, fee schedules, and audit records.
                            </p>
                            <ul class="list-unstyled small text-secondary mb-4">
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Executive Analytics & Charts</li>
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Room & Bed Matrix Visualizer</li>
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Fee Invoicing & Payment Records</li>
                            </ul>
                        </div>
                        <a href="${pageContext.request.contextPath}/login?role=admin" class="btn btn-outline-primary w-100 fw-bold">
                            Login as Admin &rarr;
                        </a>
                    </div>
                </div>

                <!-- Warden Portal Card -->
                <div class="col-md-4">
                    <div class="portal-card h-100 d-flex flex-direction-column justify-content-between">
                        <div>
                            <div class="stat-icon emerald mb-3" style="width: 48px; height: 48px;">
                                <i class="bi bi-clipboard2-check-fill fs-4"></i>
                            </div>
                            <h4 class="fw-bold mb-2">Warden Portal</h4>
                            <p class="text-secondary small mb-4">
                                Hostel floor supervision. Student holiday approvals, physical gate departure checkouts, returns tracking, and visitor security management.
                            </p>
                            <ul class="list-unstyled small text-secondary mb-4">
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Holiday Leave Review & Approval</li>
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Temporary Vacancy Monitoring</li>
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Visitor Check-In & Gate Records</li>
                            </ul>
                        </div>
                        <a href="${pageContext.request.contextPath}/login?role=warden" class="btn btn-outline-success w-100 fw-bold">
                            Login as Warden &rarr;
                        </a>
                    </div>
                </div>

                <!-- Student Portal Card -->
                <div class="col-md-4">
                    <div class="portal-card h-100 d-flex flex-direction-column justify-content-between">
                        <div>
                            <div class="stat-icon indigo mb-3" style="width: 48px; height: 48px;">
                                <i class="bi bi-mortarboard-fill fs-4"></i>
                            </div>
                            <h4 class="fw-bold mb-2">Student Resident Portal</h4>
                            <p class="text-secondary small mb-4">
                                Effortless campus living. Apply for weekend or semester leaves, check allocation details, lodge maintenance tickets, and view fee receipts.
                            </p>
                            <ul class="list-unstyled small text-secondary mb-4">
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Online Leave Application & Gate Pass</li>
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Fee Invoices & Simulated Pay</li>
                                <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i>Maintenance Ticket Tracking</li>
                            </ul>
                        </div>
                        <a href="${pageContext.request.contextPath}/login?role=student" class="btn btn-outline-dark w-100 fw-bold">
                            Login as Resident &rarr;
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Campus Notices & Facilities Section -->
    <section class="py-5 bg-light border-top">
        <div class="container py-2">
            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="content-card h-100">
                        <div class="card-header-flex">
                            <h3><i class="bi bi-megaphone"></i>Recent Campus Notices</h3>
                        </div>
                        <div class="card-body-padded">
                            <c:forEach var="notice" items="${notices}">
                                <div class="p-3 rounded border mb-3 bg-white">
                                    <div class="d-flex align-items-center justify-content-between mb-1">
                                        <h5 class="fs-6 fw-bold mb-0 text-dark">${notice.title}</h5>
                                        <c:if test="${notice.urgent}">
                                            <span class="badge bg-danger">Urgent</span>
                                        </c:if>
                                    </div>
                                    <p class="small text-secondary mb-2">${notice.content}</p>
                                    <div class="small text-muted d-flex align-items-center gap-3">
                                        <span><i class="bi bi-person me-1"></i>${notice.publishedByName}</span>
                                        <span><i class="bi bi-clock me-1"></i>${notice.createdAt}</span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="content-card h-100">
                        <div class="card-header-flex">
                            <h3><i class="bi bi-building-check"></i>Hostel Facilities</h3>
                        </div>
                        <div class="card-body-padded">
                            <c:forEach var="h" items="${hostels}">
                                <div class="p-3 rounded border mb-3 bg-white">
                                    <div class="d-flex align-items-center justify-content-between mb-2">
                                        <div>
                                            <h5 class="fs-6 fw-bold mb-0">${h.name}</h5>
                                            <span class="small text-muted">Code: ${h.code} &bull; Type: ${h.type}</span>
                                        </div>
                                        <span class="badge bg-primary px-3 py-2">${h.totalCapacity} Beds</span>
                                    </div>
                                    <div class="small text-secondary mb-2"><i class="bi bi-geo-alt me-1"></i>${h.address}</div>
                                    <div class="small text-secondary"><i class="bi bi-telephone me-1"></i>${h.contactPhone}</div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-dark text-white py-4 border-top">
        <div class="container text-center">
            <div class="d-flex align-items-center justify-content-center gap-2 mb-2">
                <i class="bi bi-buildings text-primary fs-5"></i>
                <span class="fw-bold fs-5">HostelEase</span>
            </div>
            <p class="small text-secondary mb-0">Smart Hostel Management System &bull; Java 17 &bull; Jakarta Servlets &bull; PostgreSQL 17</p>
        </div>
    </footer>

    <!-- Bootstrap 5 Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
