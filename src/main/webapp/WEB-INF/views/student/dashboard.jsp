<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Resident Student Portal" scope="request" />
<c:set var="pageSubtitle" value="Welcome, ${student.fullName} — Room ${student.currentRoomNumber}, Bed ${student.currentBedNumber} (${student.currentHostelName})" scope="request" />
<c:set var="activePage" value="dashboard" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resident Portal — HostelEase</title>
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
                <!-- Resident Identity & Room Badge -->
                <div class="facility-banner p-4 mb-4 rounded-3 text-white d-flex justify-content-between align-items-center flex-wrap gap-3"
                     style="background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); box-shadow: 0 4px 15px rgba(2, 132, 199, 0.2);">
                    <div class="d-flex align-items-center gap-3">
                        <div class="user-avatar" style="width: 56px; height: 56px; font-size: 1.4rem; background: rgba(255,255,255,0.25);">
                            ${student.firstName.substring(0, 1)}${student.lastName.substring(0, 1)}
                        </div>
                        <div>
                            <div class="text-uppercase small tracking-wider opacity-75 fw-bold">Resident Profile</div>
                            <h4 class="fw-bold mb-0">${student.fullName}</h4>
                            <div class="small opacity-90 mt-1">
                                <span class="badge bg-white text-dark font-monospace me-2">${student.registrationNumber}</span>
                                <span>${student.course} • Year ${student.yearOfStudy}</span>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex align-items-center gap-3 bg-white bg-opacity-10 p-3 rounded-3 border border-white border-opacity-25">
                        <div class="text-center px-2">
                            <div class="small opacity-75 text-uppercase" style="font-size: 0.7rem;">Assigned Facility</div>
                            <div class="fw-bold">${student.currentHostelName}</div>
                        </div>
                        <div class="vr bg-white opacity-25"></div>
                        <div class="text-center px-2">
                            <div class="small opacity-75 text-uppercase" style="font-size: 0.7rem;">Room & Bed</div>
                            <div class="fw-bold text-warning">Room ${student.currentRoomNumber} • ${student.currentBedNumber}</div>
                        </div>
                        <div class="vr bg-white opacity-25"></div>
                        <div class="text-center px-2">
                            <div class="small opacity-75 text-uppercase" style="font-size: 0.7rem;">Presence</div>
                            <c:choose>
                                <c:when test="${student.currentPresenceStatus == 'PRESENT'}">
                                    <span class="badge bg-success">In Hostel</span>
                                </c:when>
                                <c:when test="${student.currentPresenceStatus == 'AWAY'}">
                                    <span class="badge bg-warning text-dark">Away on Leave</span>
                                </c:when>
                                <c:when test="${student.currentPresenceStatus == 'OVERDUE'}">
                                    <span class="badge bg-danger animate-pulse">Overdue Return</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">Unknown</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Quick Action Tiles -->
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <a href="${pageContext.request.contextPath}/student/leaves" class="text-decoration-none">
                            <div class="stat-card h-100 hover-elevate">
                                <div class="stat-icon icon-primary"><i class="bi bi-airplane-engines"></i></div>
                                <div>
                                    <div class="fw-bold text-dark fs-6">Holiday & Leave Request</div>
                                    <div class="text-secondary small">Apply for home visit or vacation</div>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="${pageContext.request.contextPath}/student/complaints" class="text-decoration-none">
                            <div class="stat-card h-100 hover-elevate">
                                <div class="stat-icon icon-warning"><i class="bi bi-tools"></i></div>
                                <div>
                                    <div class="fw-bold text-dark fs-6">Maintenance Ticket</div>
                                    <div class="text-secondary small">Report electrical, plumbing, or room issues</div>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="col-md-4">
                        <a href="${pageContext.request.contextPath}/student/fees" class="text-decoration-none">
                            <div class="stat-card h-100 hover-elevate">
                                <div class="stat-icon icon-success"><i class="bi bi-wallet2"></i></div>
                                <div>
                                    <div class="fw-bold text-dark fs-6">Fee Invoices & Receipts</div>
                                    <div class="text-secondary small">Check dues and simulate online payment</div>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>

                <!-- Content Grid: Notices and Recent Movements -->
                <div class="row g-4 mb-4">
                    <!-- Left: Notices & Circulars -->
                    <div class="col-lg-6">
                        <div class="panel-card h-100">
                            <div class="panel-header d-flex justify-content-between align-items-center">
                                <div class="panel-title">
                                    <i class="bi bi-megaphone-fill text-primary"></i> Hostel Notices & Announcements
                                </div>
                                <span class="badge bg-primary-subtle text-primary">Official Circulars</span>
                            </div>
                            <div class="panel-body p-3">
                                <c:choose>
                                    <c:when test="${empty notices}">
                                        <div class="text-center py-4 text-secondary">
                                            <i class="bi bi-bell-slash fs-3 d-block mb-2"></i>
                                            No announcements posted at this time.
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="d-flex flex-column gap-3">
                                            <c:forEach var="n" items="${notices}">
                                                <div class="p-3 rounded-2 border bg-light">
                                                    <div class="d-flex justify-content-between align-items-start mb-1">
                                                        <h6 class="fw-bold mb-0 text-dark">${n.title}</h6>
                                                        <span class="badge ${n.priority == 'HIGH' ? 'bg-danger' : 'bg-secondary'} small">
                                                            ${n.priority}
                                                        </span>
                                                    </div>
                                                    <p class="small text-secondary mb-2">${n.content}</p>
                                                    <div class="small text-muted" style="font-size: 0.75rem;">
                                                        <i class="bi bi-calendar3 me-1"></i>Posted on: ${n.publishedAt != null ? n.publishedAt.toString().substring(0, 10) : 'Recent'}
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Right: Active/Recent Leave History -->
                    <div class="col-lg-6">
                        <div class="panel-card h-100">
                            <div class="panel-header d-flex justify-content-between align-items-center">
                                <div class="panel-title">
                                    <i class="bi bi-clock-history text-info"></i> Your Recent Leaves & Gate Movement
                                </div>
                                <a href="${pageContext.request.contextPath}/student/leaves" class="btn btn-outline-primary btn-sm">All Leaves</a>
                            </div>
                            <div class="panel-body p-0">
                                <div class="table-responsive">
                                    <table class="table-custom mb-0">
                                        <thead>
                                            <tr>
                                                <th>Type</th>
                                                <th>Dates</th>
                                                <th>Destination</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty leaves}">
                                                    <tr>
                                                        <td colspan="4" class="text-center py-4 text-secondary">
                                                            No leave applications recorded.
                                                        </td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="l" items="${leaves}" end="3">
                                                        <tr>
                                                            <td><span class="badge bg-light text-dark border">${l.leaveType}</span></td>
                                                            <td>
                                                                <div class="small fw-semibold">${l.startDate} to ${l.endDate}</div>
                                                                <div class="small text-muted">${l.totalDays} Day(s)</div>
                                                            </td>
                                                            <td class="small">${l.destinationCity}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${l.status == 'PENDING'}">
                                                                        <span class="badge bg-warning-subtle text-warning">Pending Review</span>
                                                                    </c:when>
                                                                    <c:when test="${l.status == 'APPROVED'}">
                                                                        <span class="badge bg-info-subtle text-info">Approved</span>
                                                                    </c:when>
                                                                    <c:when test="${l.status == 'DEPARTED'}">
                                                                        <span class="badge bg-primary-subtle text-primary">Away on Leave</span>
                                                                    </c:when>
                                                                    <c:when test="${l.status == 'OVERDUE'}">
                                                                        <span class="badge bg-danger animate-pulse">Overdue</span>
                                                                    </c:when>
                                                                    <c:when test="${l.status == 'RETURNED'}">
                                                                        <span class="badge bg-success-subtle text-success">Returned</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge bg-secondary">${l.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
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

                <!-- Recent Complaints Section -->
                <div class="panel-card">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-tools text-primary"></i> Your Maintenance Tickets
                        </div>
                        <a href="${pageContext.request.contextPath}/student/complaints" class="btn btn-outline-primary btn-sm">Report New Issue</a>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Ticket #</th>
                                        <th>Category</th>
                                        <th>Subject</th>
                                        <th>Priority</th>
                                        <th>Status</th>
                                        <th>Date Logged</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty complaints}">
                                            <tr>
                                                <td colspan="6" class="text-center py-4 text-secondary">
                                                    No active maintenance tickets filed.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="c" items="${complaints}" end="4">
                                                <tr>
                                                    <td><span class="font-monospace fw-bold text-primary">${c.ticketNumber}</span></td>
                                                    <td><span class="badge bg-light text-dark border">${c.category}</span></td>
                                                    <td>
                                                        <div class="fw-semibold">${c.title}</div>
                                                        <div class="small text-secondary text-truncate" style="max-width: 250px;">${c.description}</div>
                                                    </td>
                                                    <td>
                                                        <span class="badge ${c.priority == 'HIGH' ? 'bg-danger' : 'bg-warning'}">${c.priority}</span>
                                                    </td>
                                                    <td>
                                                        <span class="badge ${c.status == 'RESOLVED' ? 'bg-success' : 'bg-primary'}">${c.status}</span>
                                                    </td>
                                                    <td class="small text-secondary">${c.createdAt != null ? c.createdAt.toString().substring(0, 10) : 'N/A'}</td>
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

            <!-- Footer -->
            <jsp:include page="../common/footer.jsp" />
        </main>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
