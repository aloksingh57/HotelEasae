<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Gate Checkpoint & Presence Tracking" scope="request" />
<c:set var="pageSubtitle" value="Physical gate control for student departures, temporary holiday vacancies, and return re-entry verification" scope="request" />
<c:set var="activePage" value="presence" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gate Checkpoint — HostelEase</title>
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
                <!-- Notifications from redirects -->
                <c:if test="${param.msg == 'departure_confirmed'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-airplane-fill fs-5 me-2"></i>
                        <div><strong>Departure Recorded:</strong> Student presence is now set to <strong>AWAY</strong>. The bed is designated as a <em>Temporary Holiday Vacancy</em> while preserving allocation.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.msg == 'return_confirmed'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-house-check-fill fs-5 me-2"></i>
                        <div><strong>Return Confirmed:</strong> Resident is checked back into hostel. Presence restored to <strong>PRESENT</strong> and room occupancy updated.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.msg != null && param.msg.startsWith('reconciled_')}">
                    <div class="alert alert-info alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-arrow-repeat fs-5 me-2"></i>
                        <div><strong>Audit Complete:</strong> Presence scan finished and overdue flags were refreshed.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Gate Action Toolbar -->
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
                    <div class="d-flex align-items-center gap-2">
                        <span class="badge bg-primary px-3 py-2 fs-6">
                            <i class="bi bi-shield-lock me-1"></i>Campus Security Gate Console
                        </span>
                    </div>

                    <form action="${pageContext.request.contextPath}/warden/presence" method="post" class="d-inline">
                        <input type="hidden" name="action" value="reconcile">
                        <input type="hidden" name="leaveId" value="0">
                        <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                        <button type="submit" class="btn btn-outline-danger btn-sm fw-bold">
                            <i class="bi bi-arrow-clockwise me-1"></i>Scan Overdue Returns Now
                        </button>
                    </form>
                </div>

                <!-- 1. OVERDUE RETURNS ALERT (CRITICAL ATTENTION) -->
                <c:if test="${not empty overdueReturns}">
                    <div class="panel-card mb-4 border-danger">
                        <div class="panel-header bg-danger text-white d-flex justify-content-between align-items-center">
                            <div class="panel-title text-white">
                                <i class="bi bi-exclamation-octagon-fill me-2"></i> CRITICAL: Overdue Student Returns (${overdueReturns.size()})
                            </div>
                            <span class="badge bg-white text-danger fw-bold">Immediate Follow-Up Required</span>
                        </div>
                        <div class="panel-body p-0">
                            <div class="table-responsive">
                                <table class="table-custom mb-0">
                                    <thead>
                                        <tr class="table-danger">
                                            <th>Resident Student</th>
                                            <th>Room & Bed</th>
                                            <th>Expected Return</th>
                                            <th>Destination City</th>
                                            <th>Guardian Phone</th>
                                            <th>Gate Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="ov" items="${overdueReturns}">
                                            <tr class="table-danger-subtle">
                                                <td>
                                                    <div class="fw-bold text-danger">${ov.studentName}</div>
                                                    <div class="small font-monospace">${ov.studentRegistrationNumber}</div>
                                                </td>
                                                <td>
                                                    <div class="fw-bold">${ov.hostelName}</div>
                                                    <div class="small text-secondary">Room ${ov.roomNumber} • Bed ${ov.bedNumber}</div>
                                                </td>
                                                <td>
                                                    <div class="fw-bold text-danger">${ov.endDate}</div>
                                                    <div class="badge bg-danger animate-pulse">LATE RETURN</div>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold">${ov.destinationCity}</div>
                                                    <div class="small text-secondary">${ov.reason}</div>
                                                </td>
                                                <td>
                                                    <a href="tel:${ov.emergencyContactPhone}" class="btn btn-sm btn-outline-danger">
                                                        <i class="bi bi-telephone-fill me-1"></i>${ov.emergencyContactPhone}
                                                    </a>
                                                </td>
                                                <td>
                                                    <form action="${pageContext.request.contextPath}/warden/presence" method="post" class="d-inline">
                                                        <input type="hidden" name="action" value="return">
                                                        <input type="hidden" name="leaveId" value="${ov.id}">
                                                        <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                                        <button type="submit" class="btn btn-success btn-sm fw-bold">
                                                            <i class="bi bi-box-arrow-in-down me-1"></i>Confirm Late Return
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- 2. RESIDENTS CURRENTLY AWAY (TEMPORARY VACANCY MANAGEMENT) -->
                <div class="panel-card mb-4">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-airplane-engines text-warning"></i> Residents Away on Leave — Temporary Bed Vacancies (${currentlyAway.size()})
                        </div>
                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle">
                            Allocation Preserved
                        </span>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Resident</th>
                                        <th>Room & Bed</th>
                                        <th>Leave Type</th>
                                        <th>Departed At</th>
                                        <th>Expected Return</th>
                                        <th>Destination</th>
                                        <th>Gate Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty currentlyAway}">
                                            <tr>
                                                <td colspan="7" class="text-center py-4 text-secondary">
                                                    No residents are currently away. All allocated residents are present in hostel.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="aw" items="${currentlyAway}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold">${aw.studentName}</div>
                                                        <div class="small text-secondary font-monospace">${aw.studentRegistrationNumber}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold text-primary">${aw.hostelName}</div>
                                                        <div class="small text-secondary">Room ${aw.roomNumber} • Bed ${aw.bedNumber}</div>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-light text-dark border">${aw.leaveType}</span>
                                                    </td>
                                                    <td>
                                                        <div class="small fw-semibold text-secondary">${aw.startDate}</div>
                                                        <div class="small text-muted">${aw.actualDepartureTime != null ? aw.actualDepartureTime.toString().substring(11, 16) : 'Confirmed'}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold text-primary">${aw.endDate}</div>
                                                        <div class="small text-muted">Awaiting Re-entry</div>
                                                    </td>
                                                    <td>
                                                        <div class="small fw-semibold">${aw.destinationCity}</div>
                                                    </td>
                                                    <td>
                                                        <form action="${pageContext.request.contextPath}/warden/presence" method="post" class="d-inline">
                                                            <input type="hidden" name="action" value="return">
                                                            <input type="hidden" name="leaveId" value="${aw.id}">
                                                            <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                                            <button type="submit" class="btn btn-outline-success btn-sm fw-bold">
                                                                <i class="bi bi-box-arrow-in-left me-1"></i>Confirm Return (Gate In)
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

                <!-- 3. APPROVED DEPARTURES AWAITING GATE EXIT -->
                <div class="panel-card">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-box-arrow-right text-primary"></i> Approved Leaves Awaiting Physical Departure (${departuresPending.size()})
                        </div>
                        <span class="badge bg-info-subtle text-info border border-info-subtle">
                            Pre-Departure Roster
                        </span>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Resident</th>
                                        <th>Room & Bed</th>
                                        <th>Leave Type</th>
                                        <th>Approved Period</th>
                                        <th>Destination</th>
                                        <th>Guardian Phone</th>
                                        <th>Gate Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty departuresPending}">
                                            <tr>
                                                <td colspan="7" class="text-center py-4 text-secondary">
                                                    No approved leaves currently pending physical gate departure.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="dp" items="${departuresPending}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold">${dp.studentName}</div>
                                                        <div class="small text-secondary font-monospace">${dp.studentRegistrationNumber}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold text-primary">${dp.hostelName}</div>
                                                        <div class="small text-secondary">Room ${dp.roomNumber} • Bed ${dp.bedNumber}</div>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-light text-dark border">${dp.leaveType}</span>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold text-primary">${dp.startDate} to ${dp.endDate}</div>
                                                        <div class="small text-muted">${dp.totalDays} Day(s)</div>
                                                    </td>
                                                    <td>
                                                        <div class="small fw-semibold">${dp.destinationCity}</div>
                                                        <div class="small text-secondary text-truncate" style="max-width: 150px;">${dp.reason}</div>
                                                    </td>
                                                    <td>
                                                        <div class="small"><i class="bi bi-telephone me-1"></i>${dp.emergencyContactPhone}</div>
                                                    </td>
                                                    <td>
                                                        <form action="${pageContext.request.contextPath}/warden/presence" method="post" class="d-inline">
                                                            <input type="hidden" name="action" value="depart">
                                                            <input type="hidden" name="leaveId" value="${dp.id}">
                                                            <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                                            <button type="submit" class="btn btn-primary-custom btn-sm fw-bold">
                                                                <i class="bi bi-airplane me-1"></i>Confirm Departure (Gate Out)
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

            <!-- Footer -->
            <jsp:include page="../common/footer.jsp" />
        </main>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
