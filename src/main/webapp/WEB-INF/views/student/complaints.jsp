<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Room Maintenance & Complaints" scope="request" />
<c:set var="pageSubtitle" value="Lodge room repair requests, electrical/plumbing issues, or mess grievances with tracked resolution" scope="request" />
<c:set var="activePage" value="complaints" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintenance Tickets — HostelEase</title>
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
                <c:if test="${param.msg == 'complaint_registered'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-check-circle-fill fs-5 me-2"></i>
                        <div><strong>Ticket Registered!</strong> Your maintenance request has been dispatched to facility staff.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'registration_failed'}">
                    <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill fs-5 me-2"></i>
                        <div><strong>Failed to Lodge Ticket:</strong> Please complete all required fields.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <div class="row g-4 mb-4">
                    <!-- Left: Lodge Ticket Form -->
                    <div class="col-lg-7">
                        <div class="panel-card">
                            <div class="panel-header">
                                <div class="panel-title">
                                    <i class="bi bi-tools text-primary"></i> Register Maintenance Complaint
                                </div>
                            </div>
                            <div class="panel-body p-4">
                                <form action="${pageContext.request.contextPath}/student/complaints" method="post">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">

                                    <div class="row g-3 mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Complaint Category <span class="text-danger">*</span></label>
                                            <select name="category" class="form-select" required>
                                                <option value="ELECTRICAL">Electrical (Lights, Fans, Switches)</option>
                                                <option value="PLUMBING">Plumbing (Taps, Showers, Drainage)</option>
                                                <option value="CARPENTRY">Carpentry (Bed, Desk, Cupboard)</option>
                                                <option value="CLEANLINESS">Housekeeping & Cleanliness</option>
                                                <option value="INTERNET">WiFi & Campus Network</option>
                                                <option value="MESS">Mess / Dining Hall Food</option>
                                                <option value="SECURITY">Security & Noise Disturbance</option>
                                                <option value="OTHER">Other Issues</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Severity / Priority <span class="text-danger">*</span></label>
                                            <select name="priority" class="form-select" required>
                                                <option value="LOW">Low (Cosmetic / Routine)</option>
                                                <option value="MEDIUM" selected>Medium (Standard Repair)</option>
                                                <option value="HIGH">High (Urgent Attention)</option>
                                                <option value="CRITICAL">Critical (Safety Hazard / Complete Outage)</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Issue Subject <span class="text-danger">*</span></label>
                                        <input type="text" name="subject" class="form-control" placeholder="e.g. Study lamp switch sparking in Room ${student.currentRoomNumber}" required>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label fw-semibold">Detailed Description <span class="text-danger">*</span></label>
                                        <textarea name="description" class="form-control" rows="4" placeholder="Describe the problem, exact location in room, and convenient time for technician visit..." required></textarea>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2">
                                        <button type="reset" class="btn btn-outline-secondary btn-sm">Reset</button>
                                        <button type="submit" class="btn btn-primary-custom btn-sm fw-bold">
                                            <i class="bi bi-send-check me-1"></i>Lodge Ticket
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Right: Maintenance SLAs -->
                    <div class="col-lg-5">
                        <div class="panel-card h-100">
                            <div class="panel-header">
                                <div class="panel-title"><i class="bi bi-clock-history text-primary"></i> Service Resolution SLAs</div>
                            </div>
                            <div class="panel-body p-4">
                                <div class="p-3 bg-danger-subtle rounded-2 mb-3 border border-danger-subtle">
                                    <div class="fw-bold text-danger mb-1"><i class="bi bi-lightning-charge me-1"></i>Critical Priority: &lt; 4 Hours</div>
                                    <p class="small text-secondary mb-0">Total power failure, gas leak, severe water pipeline burst, or emergency hazard.</p>
                                </div>

                                <div class="p-3 bg-warning-subtle rounded-2 mb-3 border border-warning-subtle">
                                    <div class="fw-bold text-warning-emphasis mb-1"><i class="bi bi-exclamation-circle me-1"></i>High Priority: &lt; 12 Hours</div>
                                    <p class="small text-secondary mb-0">Room fan malfunction, lock jam, geyser failure, or single-point electrical shortage.</p>
                                </div>

                                <div class="p-3 bg-light rounded-2 border">
                                    <div class="fw-bold text-dark mb-1"><i class="bi bi-clock me-1"></i>Standard Priority: 24 to 48 Hours</div>
                                    <p class="small text-secondary mb-0">Carpentry fixes, routine painting touchup, mattress replacement, or general queries.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bottom: Complaint History -->
                <div class="panel-card">
                    <div class="panel-header">
                        <div class="panel-title"><i class="bi bi-card-checklist text-primary"></i> Your Registered Complaints (${complaints.size()})</div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Ticket #</th>
                                        <th>Category</th>
                                        <th>Subject & Description</th>
                                        <th>Priority</th>
                                        <th>Status</th>
                                        <th>Logged Date</th>
                                        <th>Resolution Remarks</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty complaints}">
                                            <tr>
                                                <td colspan="7" class="text-center py-4 text-secondary">
                                                    No past maintenance tickets registered.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="c" items="${complaints}">
                                                <tr>
                                                    <td><span class="badge bg-light text-dark font-monospace border px-2 py-1">${c.ticketNumber}</span></td>
                                                    <td><span class="badge bg-light text-dark border">${c.category}</span></td>
                                                    <td>
                                                        <div class="fw-bold">${c.title}</div>
                                                        <div class="small text-secondary text-truncate" style="max-width: 250px;">${c.description}</div>
                                                    </td>
                                                    <td>
                                                        <span class="badge ${c.priority == 'HIGH' || c.priority == 'CRITICAL' ? 'bg-danger' : 'bg-warning'}">
                                                            ${c.priority}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <span class="badge ${c.status == 'RESOLVED' || c.status == 'CLOSED' ? 'bg-success' : 'bg-primary'}">
                                                            ${c.status}
                                                        </span>
                                                    </td>
                                                    <td class="small text-secondary">${c.createdAt != null ? c.createdAt.toString().substring(0, 10) : 'N/A'}</td>
                                                    <td class="small text-secondary">${c.resolutionNotes != null ? c.resolutionNotes : 'Pending technician assignment'}</td>
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
