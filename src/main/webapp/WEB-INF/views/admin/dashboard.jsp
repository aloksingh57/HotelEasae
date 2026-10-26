<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Executive Dashboard" scope="request" />
<c:set var="pageSubtitle" value="Real-time hostel occupancy, revenue, and student presence overview" scope="request" />
<c:set var="activePage" value="dashboard" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Executive Dashboard — HostelEase</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <div class="app-container">
        <!-- Sidebar Navigation -->
        <jsp:include page="../common/sidebar.jsp" />

        <!-- Main Content Area -->
        <main class="app-main">
            <!-- Header -->
            <jsp:include page="../common/header.jsp" />

            <!-- Page Body -->
            <div class="page-body">
                <!-- Hostel Filter Bar -->
                <div class="filter-toolbar">
                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="get" class="filter-group">
                        <label class="small fw-bold text-secondary text-uppercase"><i class="bi bi-filter me-1"></i>Filter by Facility:</label>
                        <select name="hostelId" class="form-select-custom" onchange="this.form.submit()">
                            <option value="">All Campuses & Hostels</option>
                            <c:forEach var="h" items="${hostels}">
                                <option value="${h.id}" ${selectedHostelId == h.id ? 'selected' : ''}>${h.name} (${h.type})</option>
                            </c:forEach>
                        </select>
                    </form>
                    <div class="d-flex align-items-center gap-2">
                        <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-outline-primary btn-sm fw-bold">
                            <i class="bi bi-door-open me-1"></i>Open Bed Matrix
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/allocations" class="btn btn-primary-custom btn-sm">
                            <i class="bi bi-plus-lg me-1"></i>Allocate Room
                        </a>
                    </div>
                </div>

                <!-- Executive Stat Cards -->
                <div class="stat-grid">
                    <!-- Total Rooms -->
                    <div class="stat-card blue">
                        <div class="stat-icon"><i class="bi bi-door-closed"></i></div>
                        <div class="stat-content">
                            <div class="stat-value">${occupancy.totalRooms}</div>
                            <div class="stat-label">Total Rooms</div>
                        </div>
                    </div>

                    <!-- Total Beds -->
                    <div class="stat-card indigo">
                        <div class="stat-icon"><i class="bi bi-grid-3x3"></i></div>
                        <div class="stat-content">
                            <div class="stat-value">${occupancy.totalBeds}</div>
                            <div class="stat-label">Total Beds</div>
                        </div>
                    </div>

                    <!-- Physically Present -->
                    <div class="stat-card emerald">
                        <div class="stat-icon"><i class="bi bi-person-check-fill"></i></div>
                        <div class="stat-content">
                            <div class="stat-value">${occupancy.presentStudents}</div>
                            <div class="stat-label">Present in Hostel</div>
                        </div>
                    </div>

                    <!-- Away on Holiday (Temporarily Vacant) -->
                    <div class="stat-card amber">
                        <div class="stat-icon"><i class="bi bi-airplane-fill"></i></div>
                        <div class="stat-content">
                            <div class="stat-value">${occupancy.awayStudents}</div>
                            <div class="stat-label">Away on Leave (Vacant)</div>
                        </div>
                    </div>

                    <!-- Return Overdue -->
                    <div class="stat-card rose">
                        <div class="stat-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
                        <div class="stat-content">
                            <div class="stat-value">${occupancy.overdueStudents}</div>
                            <div class="stat-label">Return Overdue</div>
                        </div>
                    </div>

                    <!-- Available Beds -->
                    <div class="stat-card blue">
                        <div class="stat-icon"><i class="bi bi-box-arrow-in-down-left"></i></div>
                        <div class="stat-content">
                            <div class="stat-value">${occupancy.availableBeds}</div>
                            <div class="stat-label">Permanently Vacant</div>
                        </div>
                    </div>
                </div>

                <!-- Interactive Charts Row -->
                <div class="row g-4 mb-4">
                    <!-- Occupancy Donut Chart -->
                    <div class="col-lg-6">
                        <div class="content-card h-100">
                            <div class="card-header-flex">
                                <h2><i class="bi bi-pie-chart-fill"></i>Physical Presence & Bed Allocation</h2>
                            </div>
                            <div class="card-body-padded">
                                <div style="height: 280px; position: relative;">
                                    <canvas id="occupancyChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Financial Collection Bar Chart -->
                    <div class="col-lg-6">
                        <div class="content-card h-100">
                            <div class="card-header-flex">
                                <h2><i class="bi bi-cash-stack"></i>Fee Invoicing & Collection Breakdown</h2>
                            </div>
                            <div class="card-body-padded">
                                <div style="height: 280px; position: relative;">
                                    <canvas id="financeChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Action Lists: Pending Approvals & Complaints -->
                <div class="row g-4">
                    <!-- Pending Leave Approvals -->
                    <div class="col-lg-7">
                        <div class="content-card h-100">
                            <div class="card-header-flex">
                                <h2><i class="bi bi-clock-history"></i>Pending Leave Applications</h2>
                                <a href="${pageContext.request.contextPath}/admin/reports?type=away" class="btn btn-sm btn-outline-secondary">View All</a>
                            </div>
                            <div class="table-responsive-custom">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th>Student</th>
                                            <th>Room</th>
                                            <th>Type</th>
                                            <th>Dates</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="req" items="${pendingLeaves}">
                                            <tr>
                                                <td>
                                                    <div class="fw-bold text-dark">${req.studentName}</div>
                                                    <div class="small text-muted">${req.rollNumber}</div>
                                                </td>
                                                <td><span class="badge bg-light text-dark border">${req.roomNumber} (${req.bedLabel})</span></td>
                                                <td><span class="badge bg-secondary-subtle text-secondary-emphasis">${req.leaveType}</span></td>
                                                <td>
                                                    <div class="small fw-semibold text-dark">${req.departureDatetime}</div>
                                                    <div class="small text-muted">to ${req.expectedReturnDatetime}</div>
                                                </td>
                                                <td><span class="badge-custom badge-away">PENDING</span></td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty pendingLeaves}">
                                            <tr><td colspan="5" class="text-center text-muted py-4">No pending leave requests at this time.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Open Maintenance Complaints -->
                    <div class="col-lg-5">
                        <div class="content-card h-100">
                            <div class="card-header-flex">
                                <h2><i class="bi bi-tools"></i>Open Maintenance Tickets</h2>
                                <a href="${pageContext.request.contextPath}/admin/reports?type=complaints" class="btn btn-sm btn-outline-secondary">View All</a>
                            </div>
                            <div class="table-responsive-custom">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th>Code</th>
                                            <th>Category</th>
                                            <th>Priority</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="cmp" items="${recentComplaints}">
                                            <tr>
                                                <td>
                                                    <div class="fw-bold text-dark">${cmp.complaintCode}</div>
                                                    <div class="small text-muted">${cmp.roomNumber} &bull; ${cmp.studentName}</div>
                                                </td>
                                                <td><span class="badge bg-light text-dark border">${cmp.category}</span></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${cmp.priority == 'URGENT'}"><span class="badge bg-danger">URGENT</span></c:when>
                                                        <c:when test="${cmp.priority == 'HIGH'}"><span class="badge bg-warning text-dark">HIGH</span></c:when>
                                                        <c:otherwise><span class="badge bg-secondary">MEDIUM</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty recentComplaints}">
                                            <tr><td colspan="3" class="text-center text-muted py-4">No open complaints reported.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Security Audit Trail -->
                <div class="content-card mt-4">
                    <div class="card-header-flex">
                        <h2><i class="bi bi-journal-text"></i>Recent Security Audit Trail</h2>
                    </div>
                    <div class="table-responsive-custom">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Timestamp</th>
                                    <th>User</th>
                                    <th>Action</th>
                                    <th>Entity</th>
                                    <th>IP Address</th>
                                    <th>Details</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="log" items="${recentAudits}">
                                    <tr>
                                        <td class="small text-muted">${log.createdAt}</td>
                                        <td class="fw-bold text-dark">${log.username != null ? log.username : 'SYSTEM'}</td>
                                        <td><span class="badge bg-primary-subtle text-primary border">${log.action}</span></td>
                                        <td><span class="badge bg-light text-dark border">${log.entityName} #${log.entityId}</span></td>
                                        <td class="small font-monospace">${log.ipAddress}</td>
                                        <td class="small text-secondary">${log.details}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Common Footer & Scripts -->
    <jsp:include page="../common/footer.jsp" />

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Initialize Live Charts
            initOccupancyChart(
                'occupancyChart',
                ${occupancy.presentStudents != null ? occupancy.presentStudents : 0},
                ${occupancy.awayStudents != null ? occupancy.awayStudents : 0},
                ${occupancy.overdueStudents != null ? occupancy.overdueStudents : 0},
                ${occupancy.availableBeds != null ? occupancy.availableBeds : 0},
                ${occupancy.maintenanceBeds != null ? occupancy.maintenanceBeds : 0}
            );

            initFinancialChart(
                'financeChart',
                ${finance.totalBilled != null ? finance.totalBilled : 0},
                ${finance.totalCollected != null ? finance.totalCollected : 0},
                ${finance.totalOutstanding != null ? finance.totalOutstanding : 0}
            );
        });
    </script>
</body>
</html>
