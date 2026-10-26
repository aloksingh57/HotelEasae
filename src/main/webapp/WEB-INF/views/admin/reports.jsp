<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Intelligence & Audit Reports" scope="request" />
<c:set var="pageSubtitle" value="Official institution reports for hostel occupancy, temporary holiday vacancies, overdue presence, and revenue" scope="request" />
<c:set var="activePage" value="reports" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Audits — HostelEase</title>
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
                <!-- Report Tabs Navigation -->
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-4">
                    <ul class="nav nav-pills custom-nav-pills">
                        <li class="nav-item">
                            <a class="nav-link ${reportType == 'occupancy' ? 'active' : ''}" 
                               href="${pageContext.request.contextPath}/admin/reports?type=occupancy&hostelId=${selectedHostelId != null ? selectedHostelId : ''}">
                                <i class="bi bi-grid-3x3-gap me-1"></i>Occupancy Matrix
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${reportType == 'away' || reportType == 'vacancies' ? 'active' : ''}" 
                               href="${pageContext.request.contextPath}/admin/reports?type=away&hostelId=${selectedHostelId != null ? selectedHostelId : ''}">
                                <i class="bi bi-airplane me-1"></i>Holiday Away & Vacancies
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${reportType == 'overdue' ? 'active' : ''}" 
                               href="${pageContext.request.contextPath}/admin/reports?type=overdue&hostelId=${selectedHostelId != null ? selectedHostelId : ''}">
                                <i class="bi bi-exclamation-triangle me-1"></i>Overdue Returns
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${reportType == 'finance' ? 'active' : ''}" 
                               href="${pageContext.request.contextPath}/admin/reports?type=finance&hostelId=${selectedHostelId != null ? selectedHostelId : ''}">
                                <i class="bi bi-cash-stack me-1"></i>Fee Collections
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${reportType == 'complaints' ? 'active' : ''}" 
                               href="${pageContext.request.contextPath}/admin/reports?type=complaints&hostelId=${selectedHostelId != null ? selectedHostelId : ''}">
                                <i class="bi bi-tools me-1"></i>Complaints & Maintenance
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${reportType == 'notifications' ? 'active' : ''}" 
                               href="${pageContext.request.contextPath}/admin/reports?type=notifications&hostelId=${selectedHostelId != null ? selectedHostelId : ''}">
                                <i class="bi bi-broadcast me-1"></i>Notifications (SMS & Email)
                            </a>
                        </li>
                    </ul>

                    <div class="d-flex align-items-center gap-2">
                        <form action="${pageContext.request.contextPath}/admin/reports" method="get" class="d-inline-flex align-items-center gap-2">
                            <input type="hidden" name="type" value="${reportType}">
                            <select name="hostelId" class="form-select-custom form-select-sm" onchange="this.form.submit()">
                                <option value="">All Facilities</option>
                                <c:forEach var="h" items="${hostels}">
                                    <option value="${h.id}" ${selectedHostelId == h.id ? 'selected' : ''}>${h.name}</option>
                                </c:forEach>
                            </select>
                        </form>
                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">
                            <i class="bi bi-printer me-1"></i>Print Report
                        </button>
                    </div>
                </div>

                <!-- TAB 1: Occupancy Matrix Report -->
                <c:if test="${reportType == 'occupancy'}">
                    <div class="panel-card mb-4">
                        <div class="panel-header d-flex justify-content-between align-items-center">
                            <div class="panel-title">
                                <i class="bi bi-pie-chart text-primary"></i> Facility Occupancy Summary
                            </div>
                            <span class="badge bg-primary">Live Institutional Census</span>
                        </div>
                        <div class="panel-body">
                            <div class="stat-grid mb-3">
                                <div class="stat-card">
                                    <div class="stat-icon icon-primary"><i class="bi bi-door-closed"></i></div>
                                    <div>
                                        <div class="stat-value">${stats.totalRooms}</div>
                                        <div class="stat-label">Total Rooms</div>
                                    </div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-icon icon-info"><i class="bi bi-layout-three-columns"></i></div>
                                    <div>
                                        <div class="stat-value">${stats.totalBeds}</div>
                                        <div class="stat-label">Total Bed Capacity</div>
                                    </div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-icon icon-success"><i class="bi bi-person-check-fill"></i></div>
                                    <div>
                                        <div class="stat-value text-success">${stats.occupiedBeds}</div>
                                        <div class="stat-label">Allocated Beds</div>
                                    </div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-icon icon-warning"><i class="bi bi-door-open-fill"></i></div>
                                    <div>
                                        <div class="stat-value text-warning">${stats.availableBeds}</div>
                                        <div class="stat-label">Unallocated Vacant Beds</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="panel-card">
                        <div class="panel-header">
                            <div class="panel-title"><i class="bi bi-table text-primary"></i> Detailed Room Allocation Register</div>
                        </div>
                        <div class="panel-body p-0">
                            <div class="table-responsive">
                                <table class="table-custom mb-0">
                                    <thead>
                                        <tr>
                                            <th>Hostel</th>
                                            <th>Building / Floor</th>
                                            <th>Room #</th>
                                            <th>Type</th>
                                            <th>Capacity</th>
                                            <th>Occupied</th>
                                            <th>Available</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="r" items="${matrix}">
                                            <tr>
                                                <td class="fw-bold text-primary">${r.hostelName}</td>
                                                <td>${r.buildingName} • Floor ${r.floorNumber}</td>
                                                <td class="fw-bold font-monospace">${r.roomNumber}</td>
                                                <td>${r.roomType}</td>
                                                <td>${r.capacity} Beds</td>
                                                <td class="fw-bold text-success">${r.occupiedBeds}</td>
                                                <td class="fw-bold text-secondary">${r.availableBeds}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.availableBeds == 0}">
                                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle">Full</span>
                                                        </c:when>
                                                        <c:when test="${r.occupiedBeds == 0}">
                                                            <span class="badge bg-success-subtle text-success border border-success-subtle">Vacant</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle">Partial</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- TAB 2: Temporary Vacancies & Holiday Leaves (Mandatory Special Feature) -->
                <c:if test="${reportType == 'away' || reportType == 'vacancies'}">
                    <div class="alert alert-info border-info-subtle d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-info-circle-fill fs-4 me-3 text-info"></i>
                        <div>
                            <h6 class="alert-heading fw-bold mb-1">Temporary Holiday Vacancy Protocol</h6>
                            <p class="small mb-0">
                                This institutional audit specifically distinguishes <strong>Beds with Residents Away on Approved Holiday/Leave</strong> 
                                from <strong>Permanently Unallocated Vacant Beds</strong>. In HostelEase, approved leave marks the bed as temporarily unoccupied for housekeeping, 
                                but preserves the resident's allocation lock against double-allocation.
                            </p>
                        </div>
                    </div>

                    <div class="panel-card mb-4">
                        <div class="panel-header">
                            <div class="panel-title"><i class="bi bi-airplane-fill text-warning"></i> Active Approved Leaves & Departed Residents (${awayLeaves.size()})</div>
                        </div>
                        <div class="panel-body p-0">
                            <div class="table-responsive">
                                <table class="table-custom mb-0">
                                    <thead>
                                        <tr>
                                            <th>Resident Student</th>
                                            <th>Allocated Bed</th>
                                            <th>Leave Category</th>
                                            <th>Departure Date</th>
                                            <th>Expected Return</th>
                                            <th>Destination / Reason</th>
                                            <th>Parent / Emergency Contact</th>
                                            <th>Presence Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty awayLeaves}">
                                                <tr>
                                                    <td colspan="8" class="text-center py-4 text-secondary">
                                                        No students are currently away on approved leave. All allocated residents are present.
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="l" items="${awayLeaves}">
                                                    <tr>
                                                        <td>
                                                            <div class="fw-bold">${l.studentName}</div>
                                                            <div class="small text-secondary font-monospace">${l.studentRegistrationNumber}</div>
                                                        </td>
                                                        <td>
                                                            <div class="fw-bold text-primary">${l.hostelName}</div>
                                                            <div class="small">Room ${l.roomNumber} • Bed ${l.bedNumber}</div>
                                                        </td>
                                                        <td>
                                                            <span class="badge bg-light text-dark border">${l.leaveType}</span>
                                                        </td>
                                                        <td>
                                                            <div class="fw-semibold text-danger">${l.startDate}</div>
                                                            <div class="small text-muted">Departed: ${l.actualDepartureTime != null ? l.actualDepartureTime.toString().substring(0, 16) : 'Confirmed'}</div>
                                                        </td>
                                                        <td>
                                                            <div class="fw-bold text-success">${l.endDate}</div>
                                                            <div class="small text-muted">Expected Gate Check</div>
                                                        </td>
                                                        <td>
                                                            <div class="small fw-semibold">${l.destinationCity}</div>
                                                            <div class="small text-secondary text-truncate" style="max-width: 200px;">${l.reason}</div>
                                                        </td>
                                                        <td>
                                                            <div class="small"><i class="bi bi-telephone me-1"></i>${l.emergencyContactPhone}</div>
                                                            <div class="small text-muted">Parent: ${l.parentConsentVerified ? 'Verified' : 'Pending'}</div>
                                                        </td>
                                                        <td>
                                                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1">
                                                                <i class="bi bi-airplane me-1"></i>AWAY (Temp Vacant)
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
                </c:if>

                <!-- TAB 3: Overdue Returns Report -->
                <c:if test="${reportType == 'overdue'}">
                    <div class="alert alert-danger border-danger-subtle d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill fs-4 me-3 text-danger"></i>
                        <div>
                            <h6 class="alert-heading fw-bold mb-1">Critical Overdue Return Alerts</h6>
                            <p class="small mb-0">
                                The following resident students have not checked back in past their approved leave return date. 
                                Immediate warden dispatch and parent contact protocols are required.
                            </p>
                        </div>
                    </div>

                    <div class="panel-card">
                        <div class="panel-header">
                            <div class="panel-title"><i class="bi bi-bell-fill text-danger"></i> Overdue Student Return Roster (${overdueLeaves.size()})</div>
                        </div>
                        <div class="panel-body p-0">
                            <div class="table-responsive">
                                <table class="table-custom mb-0">
                                    <thead>
                                        <tr>
                                            <th>Resident Student</th>
                                            <th>Hostel & Bed</th>
                                            <th>Departure Date</th>
                                            <th>Scheduled Return</th>
                                            <th>Days Overdue</th>
                                            <th>Destination</th>
                                            <th>Guardian & Phone</th>
                                            <th>Action Protocol</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty overdueLeaves}">
                                                <tr>
                                                    <td colspan="8" class="text-center py-4 text-success fw-bold">
                                                        <i class="bi bi-check-circle me-1"></i> Zero overdue returns recorded! All resident students are accounted for.
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="ov" items="${overdueLeaves}">
                                                    <tr class="table-danger-subtle">
                                                        <td>
                                                            <div class="fw-bold text-danger">${ov.studentName}</div>
                                                            <div class="small font-monospace">${ov.studentRegistrationNumber}</div>
                                                        </td>
                                                        <td>
                                                            <div class="fw-bold text-primary">${ov.hostelName}</div>
                                                            <div class="small">Room ${ov.roomNumber} • Bed ${ov.bedNumber}</div>
                                                        </td>
                                                        <td>${ov.startDate}</td>
                                                        <td class="fw-bold text-danger">${ov.endDate}</td>
                                                        <td>
                                                            <span class="badge bg-danger animate-pulse px-2 py-1">OVERDUE</span>
                                                        </td>
                                                        <td>
                                                            <div class="small fw-semibold">${ov.destinationCity}</div>
                                                            <div class="small text-secondary">${ov.reason}</div>
                                                        </td>
                                                        <td>
                                                            <div class="small fw-bold"><i class="bi bi-telephone-fill me-1 text-danger"></i>${ov.emergencyContactPhone}</div>
                                                        </td>
                                                        <td>
                                                            <a href="tel:${ov.emergencyContactPhone}" class="btn btn-danger btn-sm">
                                                                <i class="bi bi-telephone-outbound me-1"></i>Call Guardian
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
                </c:if>

                <!-- TAB 4: Financial Collection Summary -->
                <c:if test="${reportType == 'finance'}">
                    <div class="stat-grid mb-4">
                        <div class="stat-card">
                            <div class="stat-icon icon-primary"><i class="bi bi-receipt"></i></div>
                            <div>
                                <div class="stat-value">₹<fmt:formatNumber value="${summary.totalBilled}" pattern="#,##0" /></div>
                                <div class="stat-label">Total Invoiced</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon icon-success"><i class="bi bi-cash-stack"></i></div>
                            <div>
                                <div class="stat-value text-success">₹<fmt:formatNumber value="${summary.totalCollected}" pattern="#,##0" /></div>
                                <div class="stat-label">Total Collected</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon icon-danger"><i class="bi bi-exclamation-circle"></i></div>
                            <div>
                                <div class="stat-value text-danger">₹<fmt:formatNumber value="${summary.totalPending}" pattern="#,##0" /></div>
                                <div class="stat-label">Total Outstanding Dues</div>
                            </div>
                        </div>
                    </div>

                    <div class="panel-card">
                        <div class="panel-header">
                            <div class="panel-title"><i class="bi bi-cash text-primary"></i> Fee Invoice Audit Ledger (${invoices.size()})</div>
                        </div>
                        <div class="panel-body p-0">
                            <div class="table-responsive">
                                <table class="table-custom mb-0">
                                    <thead>
                                        <tr>
                                            <th>Invoice #</th>
                                            <th>Resident Student</th>
                                            <th>Hostel</th>
                                            <th>Total Bill</th>
                                            <th>Paid</th>
                                            <th>Balance</th>
                                            <th>Due Date</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="inv" items="${invoices}">
                                            <tr>
                                                <td class="font-monospace fw-bold">${inv.invoiceNumber}</td>
                                                <td>
                                                    <div class="fw-bold">${inv.studentName}</div>
                                                    <div class="small text-secondary">${inv.studentRegistrationNumber}</div>
                                                </td>
                                                <td>${inv.hostelName}</td>
                                                <td class="fw-bold">₹<fmt:formatNumber value="${inv.totalAmount}" pattern="#,##0.00" /></td>
                                                <td class="text-success fw-bold">₹<fmt:formatNumber value="${inv.paidAmount}" pattern="#,##0.00" /></td>
                                                <td class="fw-bold ${inv.balanceAmount > 0 ? 'text-danger' : 'text-success'}">
                                                    ₹<fmt:formatNumber value="${inv.balanceAmount}" pattern="#,##0.00" />
                                                </td>
                                                <td>${inv.dueDate}</td>
                                                <td>
                                                    <span class="badge ${inv.status == 'PAID' ? 'bg-success' : (inv.status == 'OVERDUE' ? 'bg-danger' : 'bg-warning')}">
                                                        ${inv.status}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- TAB 5: Maintenance & Complaints Report -->
                <c:if test="${reportType == 'complaints'}">
                    <div class="panel-card">
                        <div class="panel-header">
                            <div class="panel-title"><i class="bi bi-wrench-adjustable text-primary"></i> Maintenance & Complaints Register (${complaints.size()})</div>
                        </div>
                        <div class="panel-body p-0">
                            <div class="table-responsive">
                                <table class="table-custom mb-0">
                                    <thead>
                                        <tr>
                                            <th>Ticket #</th>
                                            <th>Resident</th>
                                            <th>Hostel & Room</th>
                                            <th>Category</th>
                                            <th>Title & Details</th>
                                            <th>Priority</th>
                                            <th>Status</th>
                                            <th>Logged Date</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty complaints}">
                                                <tr>
                                                    <td colspan="8" class="text-center py-4 text-secondary">
                                                        No maintenance tickets found for the selected facility.
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="c" items="${complaints}">
                                                    <tr>
                                                        <td class="font-monospace fw-bold">${c.ticketNumber}</td>
                                                        <td>
                                                            <div class="fw-bold">${c.studentName}</div>
                                                            <div class="small text-secondary">${c.studentRegistrationNumber}</div>
                                                        </td>
                                                        <td>
                                                            <div class="fw-bold text-primary">${c.hostelName}</div>
                                                            <div class="small">Room ${c.roomNumber}</div>
                                                        </td>
                                                        <td><span class="badge bg-light text-dark border">${c.category}</span></td>
                                                        <td>
                                                            <div class="fw-bold">${c.title}</div>
                                                            <div class="small text-secondary text-truncate" style="max-width: 250px;">${c.description}</div>
                                                        </td>
                                                        <td>
                                                            <span class="badge ${c.priority == 'HIGH' || c.priority == 'CRITICAL' ? 'bg-danger' : (c.priority == 'MEDIUM' ? 'bg-warning' : 'bg-secondary')}">
                                                                ${c.priority}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <span class="badge ${c.status == 'RESOLVED' || c.status == 'CLOSED' ? 'bg-success' : 'bg-primary'}">
                                                                ${c.status}
                                                            </span>
                                                        </td>
                                                        <td class="small text-secondary">
                                                            ${c.createdAt != null ? c.createdAt.toString().substring(0, 10) : 'N/A'}
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
                </c:if>

                <!-- TAB 6: Notifications Log Report -->
                <c:if test="${reportType == 'notifications'}">
                    <div class="panel-card">
                        <div class="panel-header d-flex justify-content-between align-items-center">
                            <div class="panel-title"><i class="bi bi-broadcast text-primary"></i> Real-Time SMS & Email Notification Dispatches (${notificationLogs.size()})</div>
                            <span class="badge bg-success">Automated Multi-Channel Dispatcher</span>
                        </div>
                        <div class="panel-body p-0">
                            <div class="table-responsive">
                                <table class="table-custom mb-0">
                                    <thead>
                                        <tr>
                                            <th>Recipient (Email / Phone)</th>
                                            <th>Channel</th>
                                            <th>Notification Type</th>
                                            <th>Delivery Status</th>
                                            <th>Provider Response</th>
                                            <th>Timestamp</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty notificationLogs}">
                                                <tr>
                                                    <td colspan="6" class="text-center py-4 text-secondary">
                                                        No recent notification dispatches recorded.
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="n" items="${notificationLogs}">
                                                    <tr>
                                                        <td>
                                                            <div class="fw-bold font-monospace">${n.recipient}</div>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${n.channel == 'EMAIL'}">
                                                                    <span class="badge bg-primary-subtle text-primary border"><i class="bi bi-envelope me-1"></i>EMAIL</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-success-subtle text-success border"><i class="bi bi-chat-dots me-1"></i>SMS</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <span class="badge bg-light text-dark border">${n.type}</span>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${n.status == 'SENT'}">
                                                                    <span class="badge bg-success"><i class="bi bi-check2-circle me-1"></i>DELIVERED</span>
                                                                </c:when>
                                                                <c:when test="${n.status == 'FAILED'}">
                                                                    <span class="badge bg-danger"><i class="bi bi-x-circle me-1"></i>FAILED</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-warning text-dark"><i class="bi bi-clock me-1"></i>PENDING</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <div class="small font-monospace text-muted">${n.response != null ? n.response : 'SUCCESS'}</div>
                                                        </td>
                                                        <td class="small text-secondary">
                                                            ${n.attemptedAt}
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
                </c:if>
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
