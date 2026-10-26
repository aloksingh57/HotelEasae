<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Leave & Holiday Authorizations" scope="request" />
<c:set var="pageSubtitle" value="Evaluate student leave applications, verify parent consent, and manage temporary absence permissions" scope="request" />
<c:set var="activePage" value="leaves" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Management — HostelEase</title>
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
                <c:if test="${param.msg == 'leave_approved'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-check-circle-fill fs-5 me-2"></i>
                        <div><strong>Leave Approved:</strong> The student has been authorized for departure at the gate.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.msg == 'leave_rejected'}">
                    <div class="alert alert-warning alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-info-circle-fill fs-5 me-2"></i>
                        <div><strong>Leave Rejected:</strong> Application has been declined and resident notified.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Filter Toolbar -->
                <div class="filter-toolbar mb-4">
                    <form action="${pageContext.request.contextPath}/warden/leaves" method="get" class="d-flex flex-wrap align-items-center gap-3 flex-grow-1">
                        <div class="d-flex align-items-center gap-2">
                            <label class="small fw-bold text-secondary text-uppercase mb-0">Status:</label>
                            <select name="status" class="form-select-custom" onchange="this.form.submit()">
                                <option value="">All Statuses</option>
                                <option value="PENDING" ${selectedStatus == 'PENDING' ? 'selected' : ''}>Pending Review</option>
                                <option value="APPROVED" ${selectedStatus == 'APPROVED' ? 'selected' : ''}>Approved (Pre-Departure)</option>
                                <option value="DEPARTED" ${selectedStatus == 'DEPARTED' ? 'selected' : ''}>Away on Leave</option>
                                <option value="OVERDUE" ${selectedStatus == 'OVERDUE' ? 'selected' : ''}>Overdue Returns</option>
                                <option value="RETURNED" ${selectedStatus == 'RETURNED' ? 'selected' : ''}>Completed Returns</option>
                                <option value="REJECTED" ${selectedStatus == 'REJECTED' ? 'selected' : ''}>Rejected</option>
                            </select>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <label class="small fw-bold text-secondary text-uppercase mb-0">Leave Type:</label>
                            <select name="type" class="form-select-custom" onchange="this.form.submit()">
                                <option value="">All Types</option>
                                <option value="HOME" ${selectedType == 'HOME' ? 'selected' : ''}>Home Visit</option>
                                <option value="VACATION" ${selectedType == 'VACATION' ? 'selected' : ''}>Holiday Vacation</option>
                                <option value="MEDICAL" ${selectedType == 'MEDICAL' ? 'selected' : ''}>Medical Leave</option>
                                <option value="EMERGENCY" ${selectedType == 'EMERGENCY' ? 'selected' : ''}>Emergency</option>
                                <option value="ACADEMIC_OD" ${selectedType == 'ACADEMIC_OD' ? 'selected' : ''}>Academic OD</option>
                            </select>
                        </div>

                        <c:if test="${not empty selectedStatus || not empty selectedType}">
                            <a href="${pageContext.request.contextPath}/warden/leaves" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-x-circle me-1"></i>Reset
                            </a>
                        </c:if>
                    </form>

                    <div>
                        <input type="text" id="quickLeaveFilter" class="form-control form-control-sm" style="width: 220px;" placeholder="Search student or destination...">
                    </div>
                </div>

                <!-- Leave Applications Table -->
                <div class="panel-card">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-file-earmark-text text-primary"></i> Leave Applications & Moving Roster (${leaves.size()})
                        </div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0" id="leavesTable">
                                <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>Room & Bed</th>
                                        <th>Leave Type</th>
                                        <th>Duration</th>
                                        <th>Destination & Purpose</th>
                                        <th>Emergency Contact</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty leaves}">
                                            <tr>
                                                <td colspan="8" class="text-center py-5">
                                                    <div class="empty-state">
                                                        <i class="bi bi-calendar-x display-4 text-secondary mb-3 d-block"></i>
                                                        <h5 class="fw-bold">No Leave Applications Found</h5>
                                                        <p class="text-secondary small">No records match the current filter criteria.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="l" items="${leaves}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold">${l.studentName}</div>
                                                        <div class="small text-secondary font-monospace">${l.studentRegistrationNumber}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold text-primary">${l.hostelName}</div>
                                                        <div class="small text-secondary">Room ${l.roomNumber} • Bed ${l.bedNumber}</div>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-light text-dark border px-2 py-1">${l.leaveType}</span>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold text-primary">${l.startDate} to ${l.endDate}</div>
                                                        <div class="small text-muted">${l.totalDays} Day(s)</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold">${l.destinationCity}</div>
                                                        <div class="small text-secondary text-truncate" style="max-width: 200px;" title="${l.reason}">${l.reason}</div>
                                                    </td>
                                                    <td>
                                                        <div class="small"><i class="bi bi-telephone me-1"></i>${l.emergencyContactPhone}</div>
                                                        <div class="small text-muted">Parent: ${l.parentConsentVerified ? 'Verified' : 'Unconfirmed'}</div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${l.status == 'PENDING'}">
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1">
                                                                    <i class="bi bi-hourglass-split me-1"></i>Pending Review
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${l.status == 'APPROVED'}">
                                                                <span class="badge bg-info-subtle text-info border border-info-subtle px-2 py-1">
                                                                    <i class="bi bi-check2-circle me-1"></i>Approved
                                                                </span>
                                                                <div class="text-muted" style="font-size: 0.72rem;">Awaiting Departure</div>
                                                            </c:when>
                                                            <c:when test="${l.status == 'DEPARTED'}">
                                                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">
                                                                    <i class="bi bi-airplane-fill me-1"></i>Away on Leave
                                                                </span>
                                                                <div class="text-muted" style="font-size: 0.72rem;">Bed Temp Vacant</div>
                                                            </c:when>
                                                            <c:when test="${l.status == 'OVERDUE'}">
                                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1 animate-pulse">
                                                                    <i class="bi bi-exclamation-triangle-fill me-1"></i>Overdue Return
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${l.status == 'RETURNED'}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                                                    <i class="bi bi-house-check me-1"></i>Returned
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary-subtle text-secondary px-2 py-1">Rejected</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${l.status == 'PENDING'}">
                                                                <div class="btn-group btn-group-sm">
                                                                    <button type="button" class="btn btn-success" title="Approve Leave"
                                                                            onclick="openDecisionModal(${l.id}, '${l.studentName}', 'approve')">
                                                                        <i class="bi bi-check-lg"></i>
                                                                    </button>
                                                                    <button type="button" class="btn btn-outline-danger" title="Reject Leave"
                                                                            onclick="openDecisionModal(${l.id}, '${l.studentName}', 'reject')">
                                                                        <i class="bi bi-x-lg"></i>
                                                                    </button>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${l.status == 'APPROVED' || l.status == 'DEPARTED' || l.status == 'OVERDUE'}">
                                                                <a href="${pageContext.request.contextPath}/warden/presence" class="btn btn-outline-primary btn-sm" title="Gate Checkpoint">
                                                                    <i class="bi bi-geo-alt"></i> Gate
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted small">—</span>
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

            <!-- Footer -->
            <jsp:include page="../common/footer.jsp" />
        </main>
    </div>

    <!-- Leave Decision Modal -->
    <div class="modal fade" id="leaveDecisionModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header" id="modalHeaderStyle">
                    <h5 class="modal-title fw-bold" id="modalDecisionTitle">Authorize Leave</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/warden/leaves" method="post">
                    <input type="hidden" name="action" id="decisionAction">
                    <input type="hidden" name="leaveId" id="decisionLeaveId">
                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">

                    <div class="modal-body p-4">
                        <p class="mb-3">
                            Confirm decision for resident student: <strong id="decisionStudentName"></strong>
                        </p>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Warden Authorization Remarks</label>
                            <textarea name="remarks" class="form-control" rows="3" placeholder="e.g. Parental consent verified via phone call..."></textarea>
                        </div>
                    </div>

                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-sm fw-bold" id="decisionSubmitBtn">Confirm</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script>
        document.getElementById('quickLeaveFilter')?.addEventListener('keyup', function() {
            const query = this.value.toLowerCase();
            document.querySelectorAll('#leavesTable tbody tr').forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(query) ? '' : 'none';
            });
        });

        function openDecisionModal(leaveId, studentName, action) {
            document.getElementById('decisionLeaveId').value = leaveId;
            document.getElementById('decisionStudentName').textContent = studentName;
            document.getElementById('decisionAction').value = action;

            const header = document.getElementById('modalHeaderStyle');
            const btn = document.getElementById('decisionSubmitBtn');
            const title = document.getElementById('modalDecisionTitle');

            if (action === 'approve') {
                header.className = 'modal-header bg-success text-white';
                btn.className = 'btn btn-success btn-sm fw-bold';
                btn.innerHTML = '<i class="bi bi-check-circle me-1"></i>Approve Leave';
                title.textContent = 'Approve Student Leave Application';
            } else {
                header.className = 'modal-header bg-danger text-white';
                btn.className = 'btn btn-danger btn-sm fw-bold';
                btn.innerHTML = '<i class="bi bi-x-circle me-1"></i>Reject Leave';
                title.textContent = 'Reject Student Leave Application';
            }

            new bootstrap.Modal(document.getElementById('leaveDecisionModal')).show();
        }
    </script>
</body>
</html>
