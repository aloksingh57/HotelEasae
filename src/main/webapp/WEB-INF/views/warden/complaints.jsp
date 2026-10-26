<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Facility Maintenance & Complaints" scope="request" />
<c:set var="pageSubtitle" value="Track resident maintenance requests, dispatch technicians, and resolve facility issues" scope="request" />
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
                <c:if test="${param.msg == 'status_updated'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-check-circle-fill fs-5 me-2"></i>
                        <div><strong>Ticket Updated:</strong> Status changed and resident notified of resolution progress.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Filter Toolbar -->
                <div class="filter-toolbar mb-4">
                    <form action="${pageContext.request.contextPath}/warden/complaints" method="get" class="d-flex flex-wrap align-items-center gap-3 flex-grow-1">
                        <div class="d-flex align-items-center gap-2">
                            <label class="small fw-bold text-secondary text-uppercase mb-0">Status:</label>
                            <select name="status" class="form-select-custom" onchange="this.form.submit()">
                                <option value="">All Statuses</option>
                                <option value="OPEN" ${selectedStatus == 'OPEN' ? 'selected' : ''}>Open</option>
                                <option value="IN_PROGRESS" ${selectedStatus == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                                <option value="RESOLVED" ${selectedStatus == 'RESOLVED' ? 'selected' : ''}>Resolved</option>
                                <option value="CLOSED" ${selectedStatus == 'CLOSED' ? 'selected' : ''}>Closed</option>
                            </select>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <label class="small fw-bold text-secondary text-uppercase mb-0">Category:</label>
                            <select name="category" class="form-select-custom" onchange="this.form.submit()">
                                <option value="">All Categories</option>
                                <option value="ELECTRICAL" ${selectedCategory == 'ELECTRICAL' ? 'selected' : ''}>Electrical</option>
                                <option value="PLUMBING" ${selectedCategory == 'PLUMBING' ? 'selected' : ''}>Plumbing</option>
                                <option value="CARPENTRY" ${selectedCategory == 'CARPENTRY' ? 'selected' : ''}>Carpentry</option>
                                <option value="CLEANLINESS" ${selectedCategory == 'CLEANLINESS' ? 'selected' : ''}>Housekeeping</option>
                                <option value="INTERNET" ${selectedCategory == 'INTERNET' ? 'selected' : ''}>WiFi / Internet</option>
                                <option value="MESS" ${selectedCategory == 'MESS' ? 'selected' : ''}>Mess & Food</option>
                            </select>
                        </div>

                        <c:if test="${not empty selectedStatus || not empty selectedCategory}">
                            <a href="${pageContext.request.contextPath}/warden/complaints" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-x-circle me-1"></i>Reset
                            </a>
                        </c:if>
                    </form>

                    <div>
                        <input type="text" id="quickTicketFilter" class="form-control form-control-sm" style="width: 220px;" placeholder="Search ticket or room...">
                    </div>
                </div>

                <!-- Complaints Table -->
                <div class="panel-card">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-tools text-primary"></i> Maintenance Work Orders (${complaints.size()})
                        </div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0" id="ticketsTable">
                                <thead>
                                    <tr>
                                        <th>Ticket #</th>
                                        <th>Resident & Room</th>
                                        <th>Category</th>
                                        <th>Issue Description</th>
                                        <th>Priority</th>
                                        <th>Logged Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty complaints}">
                                            <tr>
                                                <td colspan="8" class="text-center py-5">
                                                    <div class="empty-state">
                                                        <i class="bi bi-check-circle display-4 text-success mb-3 d-block"></i>
                                                        <h5 class="fw-bold">No Maintenance Issues Found</h5>
                                                        <p class="text-secondary small">All facility complaints for this facility are resolved.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="c" items="${complaints}">
                                                <tr>
                                                    <td>
                                                        <span class="badge bg-light text-dark font-monospace border px-2 py-1">${c.ticketNumber}</span>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold">${c.studentName}</div>
                                                        <div class="small text-primary fw-semibold">Room ${c.roomNumber}</div>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-light text-dark border">${c.category}</span>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold">${c.title}</div>
                                                        <div class="small text-secondary text-truncate" style="max-width: 260px;" title="${c.description}">${c.description}</div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${c.priority == 'CRITICAL'}">
                                                                <span class="badge bg-danger animate-pulse">Critical</span>
                                                            </c:when>
                                                            <c:when test="${c.priority == 'HIGH'}">
                                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle">High</span>
                                                            </c:when>
                                                            <c:when test="${c.priority == 'MEDIUM'}">
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Medium</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary-subtle text-secondary">Low</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="small text-secondary">
                                                        ${c.createdAt != null ? c.createdAt.toString().substring(0, 10) : 'N/A'}
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${c.status == 'OPEN'}">
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1">
                                                                    <i class="bi bi-clock me-1"></i>Open
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${c.status == 'IN_PROGRESS'}">
                                                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">
                                                                    <i class="bi bi-gear me-1"></i>In Progress
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${c.status == 'RESOLVED'}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                                                    <i class="bi bi-check-circle me-1"></i>Resolved
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary-subtle text-secondary px-2 py-1">${c.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <button type="button" class="btn btn-outline-primary btn-sm fw-bold"
                                                                onclick="openUpdateTicketModal(${c.id}, '${c.ticketNumber}', '${c.title}', '${c.status}')">
                                                            <i class="bi bi-pencil-square me-1"></i>Update
                                                        </button>
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

    <!-- Update Complaint Modal -->
    <div class="modal fade" id="updateTicketModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="bi bi-wrench-adjustable me-2"></i>Update Maintenance Ticket</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/warden/complaints" method="post">
                    <input type="hidden" name="complaintId" id="modalTicketId">
                    <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">

                    <div class="modal-body p-4">
                        <div class="bg-light p-3 rounded mb-3 border">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="text-secondary small">Ticket Number:</span>
                                <strong class="font-monospace text-primary" id="modalTicketNum"></strong>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-secondary small">Issue Subject:</span>
                                <span class="fw-semibold" id="modalTicketTitle"></span>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">New Ticket Status <span class="text-danger">*</span></label>
                            <select name="newStatus" id="modalTicketStatus" class="form-select" required>
                                <option value="OPEN">Open (Queued)</option>
                                <option value="IN_PROGRESS">In Progress (Technician Dispatched)</option>
                                <option value="RESOLVED">Resolved (Work Completed)</option>
                                <option value="CLOSED">Closed (Verified & Signed Off)</option>
                                <option value="REJECTED">Rejected (Out of Scope)</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Warden / Technician Remarks</label>
                            <textarea name="remarks" class="form-control" rows="3" placeholder="e.g. Electrician replaced switchboard, tested ok."></textarea>
                        </div>
                    </div>

                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary-custom btn-sm fw-bold">
                            <i class="bi bi-check-circle me-1"></i>Save Status Update
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script>
        document.getElementById('quickTicketFilter')?.addEventListener('keyup', function() {
            const query = this.value.toLowerCase();
            document.querySelectorAll('#ticketsTable tbody tr').forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(query) ? '' : 'none';
            });
        });

        function openUpdateTicketModal(id, num, title, currentStatus) {
            document.getElementById('modalTicketId').value = id;
            document.getElementById('modalTicketNum').textContent = num;
            document.getElementById('modalTicketTitle').textContent = title;
            document.getElementById('modalTicketStatus').value = currentStatus;

            new bootstrap.Modal(document.getElementById('updateTicketModal')).show();
        }
    </script>
</body>
</html>
