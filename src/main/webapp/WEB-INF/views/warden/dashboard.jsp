<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Warden Operations Center" scope="request" />
<c:set var="pageSubtitle" value="Supervision console for ${hostel.name} (${hostel.type}) — student movement, gate control, and facility care" scope="request" />
<c:set var="activePage" value="dashboard" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warden Console — HostelEase</title>
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
                <!-- Facility Banner -->
                <div class="facility-banner p-3 mb-4 rounded-3 text-white d-flex justify-content-between align-items-center flex-wrap gap-3"
                     style="background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 100%); box-shadow: 0 4px 15px rgba(37, 99, 235, 0.2);">
                    <div class="d-flex align-items-center gap-3">
                        <div class="p-3 bg-white bg-opacity-20 rounded-circle text-white fs-3">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <div>
                            <div class="text-uppercase small tracking-wider opacity-75 fw-bold">Active Hostel Facility</div>
                            <h4 class="fw-bold mb-0">${hostel.name} <span class="badge bg-white text-primary ms-2 fs-6">${hostel.type}</span></h4>
                            <div class="small opacity-75 mt-1"><i class="bi bi-geo-alt me-1"></i>${hostel.address}</div>
                        </div>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/warden/presence" class="btn btn-light btn-sm fw-bold">
                            <i class="bi bi-geo-alt me-1 text-primary"></i>Gate Checkpoint
                        </a>
                        <a href="${pageContext.request.contextPath}/warden/leaves" class="btn btn-outline-light btn-sm fw-bold">
                            <i class="bi bi-calendar-check me-1"></i>Leave Reviews (${pendingLeaves.size()})
                        </a>
                    </div>
                </div>

                <!-- Operational Metrics -->
                <div class="stat-grid mb-4">
                    <div class="stat-card">
                        <div class="stat-icon icon-primary"><i class="bi bi-door-closed"></i></div>
                        <div>
                            <div class="stat-value">${occupancy.occupiedBeds} / ${occupancy.totalBeds}</div>
                            <div class="stat-label">Allocated Beds</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-warning"><i class="bi bi-airplane-engines-fill"></i></div>
                        <div>
                            <div class="stat-value text-warning">${awayLeaves.size()}</div>
                            <div class="stat-label">Away on Approved Leave</div>
                            <div class="text-muted" style="font-size: 0.72rem;">Bed Temporarily Vacant</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-danger"><i class="bi bi-exclamation-octagon-fill"></i></div>
                        <div>
                            <div class="stat-value text-danger animate-pulse">${overdueLeaves.size()}</div>
                            <div class="stat-label">Overdue Student Returns</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-info"><i class="bi bi-person-badge-fill"></i></div>
                        <div>
                            <div class="stat-value text-info">${activeVisitors.size()}</div>
                            <div class="stat-label">Active Visitors in Campus</div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <!-- Left Column: Pending Leaves to Review -->
                    <div class="col-lg-7">
                        <div class="panel-card h-100">
                            <div class="panel-header d-flex justify-content-between align-items-center">
                                <div class="panel-title">
                                    <i class="bi bi-hourglass-split text-warning"></i> Pending Leave Applications (${pendingLeaves.size()})
                                </div>
                                <a href="${pageContext.request.contextPath}/warden/leaves" class="btn btn-outline-primary btn-sm">View All</a>
                            </div>
                            <div class="panel-body p-0">
                                <div class="table-responsive">
                                    <table class="table-custom mb-0">
                                        <thead>
                                            <tr>
                                                <th>Student</th>
                                                <th>Dates</th>
                                                <th>Type & Reason</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty pendingLeaves}">
                                                    <tr>
                                                        <td colspan="4" class="text-center py-4 text-secondary">
                                                            <i class="bi bi-check-circle text-success me-1"></i>No pending leave applications requiring approval.
                                                        </td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="l" items="${pendingLeaves}">
                                                        <tr>
                                                            <td>
                                                                <div class="fw-bold">${l.studentName}</div>
                                                                <div class="small text-secondary font-monospace">Room ${l.roomNumber} • Bed ${l.bedNumber}</div>
                                                            </td>
                                                            <td>
                                                                <div class="small fw-semibold text-primary">${l.startDate} to ${l.endDate}</div>
                                                                <div class="small text-muted">${l.totalDays} Day(s)</div>
                                                            </td>
                                                            <td>
                                                                <span class="badge bg-light text-dark border">${l.leaveType}</span>
                                                                <div class="small text-secondary text-truncate" style="max-width: 150px;">${l.reason}</div>
                                                            </td>
                                                            <td>
                                                                <a href="${pageContext.request.contextPath}/warden/leaves?status=PENDING" class="btn btn-primary-custom btn-sm">
                                                                    Review
                                                                </a>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column: Critical Overdue Returns & Action Protocols -->
                    <div class="col-lg-5">
                        <div class="panel-card h-100">
                            <div class="panel-header d-flex justify-content-between align-items-center bg-danger-subtle text-danger">
                                <div class="panel-title text-danger">
                                    <i class="bi bi-bell-fill me-1"></i> Overdue Return Alerts (${overdueLeaves.size()})
                                </div>
                                <a href="${pageContext.request.contextPath}/warden/presence" class="btn btn-danger btn-sm">Gate Roster</a>
                            </div>
                            <div class="panel-body p-0">
                                <div class="table-responsive">
                                    <table class="table-custom mb-0">
                                        <thead>
                                            <tr>
                                                <th>Student</th>
                                                <th>Expected</th>
                                                <th>Guardian Call</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty overdueLeaves}">
                                                    <tr>
                                                        <td colspan="3" class="text-center py-4 text-success fw-semibold">
                                                            <i class="bi bi-shield-check me-1"></i>All resident students are safely accounted for.
                                                        </td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="ov" items="${overdueLeaves}">
                                                        <tr>
                                                            <td>
                                                                <div class="fw-bold text-danger">${ov.studentName}</div>
                                                                <div class="small text-secondary">Room ${ov.roomNumber}</div>
                                                            </td>
                                                            <td>
                                                                <div class="fw-bold text-danger">${ov.endDate}</div>
                                                                <div class="small text-muted">Overdue</div>
                                                            </td>
                                                            <td>
                                                                <a href="tel:${ov.emergencyContactPhone}" class="btn btn-outline-danger btn-sm">
                                                                    <i class="bi bi-telephone-outbound me-1"></i>Call
                                                                </a>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Active Visitors & Open Complaints -->
                <div class="row g-4">
                    <div class="col-lg-6">
                        <div class="panel-card">
                            <div class="panel-header d-flex justify-content-between align-items-center">
                                <div class="panel-title">
                                    <i class="bi bi-people text-info"></i> Active Campus Visitors (${activeVisitors.size()})
                                </div>
                                <a href="${pageContext.request.contextPath}/warden/visitors" class="btn btn-outline-info btn-sm">Visitor Log</a>
                            </div>
                            <div class="panel-body p-0">
                                <div class="table-responsive">
                                    <table class="table-custom mb-0">
                                        <thead>
                                            <tr>
                                                <th>Visitor Name</th>
                                                <th>Visiting Resident</th>
                                                <th>Entry Time</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty activeVisitors}">
                                                    <tr>
                                                        <td colspan="4" class="text-center py-3 text-secondary">No outside visitors currently registered inside facility.</td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="v" items="${activeVisitors}">
                                                        <tr>
                                                            <td>
                                                                <div class="fw-bold">${v.visitorName}</div>
                                                                <div class="small text-secondary">${v.contactNumber}</div>
                                                            </td>
                                                            <td>
                                                                <div class="fw-semibold">${v.studentName}</div>
                                                                <div class="small text-secondary">Room ${v.roomNumber}</div>
                                                            </td>
                                                            <td>${v.entryTime != null ? v.entryTime.toString().substring(11, 16) : 'N/A'}</td>
                                                            <td>
                                                                <form action="${pageContext.request.contextPath}/warden/visitors" method="post" class="d-inline">
                                                                    <input type="hidden" name="action" value="exit">
                                                                    <input type="hidden" name="logId" value="${v.id}">
                                                                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                                                    <button type="submit" class="btn btn-outline-danger btn-sm">
                                                                        <i class="bi bi-box-arrow-right me-1"></i>Check Out
                                                                    </button>
                                                                </form>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-6">
                        <div class="panel-card">
                            <div class="panel-header d-flex justify-content-between align-items-center">
                                <div class="panel-title">
                                    <i class="bi bi-tools text-primary"></i> Pending Maintenance Tickets (${openComplaints.size()})
                                </div>
                                <a href="${pageContext.request.contextPath}/warden/complaints" class="btn btn-outline-primary btn-sm">Manage</a>
                            </div>
                            <div class="panel-body p-0">
                                <div class="table-responsive">
                                    <table class="table-custom mb-0">
                                        <thead>
                                            <tr>
                                                <th>Ticket #</th>
                                                <th>Room</th>
                                                <th>Category</th>
                                                <th>Priority</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty openComplaints}">
                                                    <tr>
                                                        <td colspan="4" class="text-center py-3 text-secondary">All facility complaints resolved.</td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="c" items="${openComplaints}">
                                                        <tr>
                                                            <td>
                                                                <span class="font-monospace fw-bold">${c.ticketNumber}</span>
                                                                <div class="small text-secondary text-truncate" style="max-width: 140px;">${c.title}</div>
                                                            </td>
                                                            <td>Room ${c.roomNumber}</td>
                                                            <td><span class="badge bg-light text-dark border">${c.category}</span></td>
                                                            <td>
                                                                <span class="badge ${c.priority == 'CRITICAL' || c.priority == 'HIGH' ? 'bg-danger' : 'bg-warning'}">
                                                                    ${c.priority}
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <jsp:include page="../common/footer.jsp" />
        </main>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
