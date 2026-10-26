<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Visitor Security & Gate Passes" scope="request" />
<c:set var="pageSubtitle" value="Gate access logs, government ID verification, and resident visitor security check-in/out" scope="request" />
<c:set var="activePage" value="visitors" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visitor Management — HostelEase</title>
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
                <c:if test="${param.msg == 'visitor_entered'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-person-check-fill fs-5 me-2"></i>
                        <div><strong>Visitor Registered:</strong> Entry logged and temporary gate pass generated.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.msg == 'visitor_exited'}">
                    <div class="alert alert-info alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-box-arrow-right fs-5 me-2"></i>
                        <div><strong>Exit Recorded:</strong> Visitor checkout timestamp has been archived in the security log.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Filter & Action Toolbar -->
                <div class="filter-toolbar mb-4">
                    <form action="${pageContext.request.contextPath}/warden/visitors" method="get" class="d-flex align-items-center gap-3">
                        <label class="small fw-bold text-secondary text-uppercase mb-0">Status:</label>
                        <select name="status" class="form-select-custom" onchange="this.form.submit()">
                            <option value="">All Visitors</option>
                            <option value="IN_HOSTEL" ${selectedStatus == 'IN_HOSTEL' ? 'selected' : ''}>Inside Hostel</option>
                            <option value="EXITED" ${selectedStatus == 'EXITED' ? 'selected' : ''}>Exited / Checked Out</option>
                        </select>
                        <c:if test="${not empty selectedStatus}">
                            <a href="${pageContext.request.contextPath}/warden/visitors" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-x-circle me-1"></i>Reset
                            </a>
                        </c:if>
                    </form>

                    <div class="d-flex align-items-center gap-2">
                        <button type="button" class="btn btn-primary-custom btn-sm" data-bs-toggle="modal" data-bs-target="#newVisitorModal">
                            <i class="bi bi-person-plus me-1"></i>Register New Visitor
                        </button>
                    </div>
                </div>

                <!-- Visitors Table Card -->
                <div class="panel-card">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-person-vcard text-primary"></i> Visitor Gate Register (${visitors.size()})
                        </div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Visitor Details</th>
                                        <th>Resident Visited</th>
                                        <th>Govt ID Proof</th>
                                        <th>Purpose</th>
                                        <th>Entry Timestamp</th>
                                        <th>Exit Timestamp</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty visitors}">
                                            <tr>
                                                <td colspan="8" class="text-center py-5">
                                                    <div class="empty-state">
                                                        <i class="bi bi-people display-4 text-secondary mb-3 d-block"></i>
                                                        <h5 class="fw-bold">No Visitor Records Found</h5>
                                                        <p class="text-secondary small">No visitor gate entries match the filter.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="v" items="${visitors}">
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold">${v.visitorName}</div>
                                                        <div class="small text-secondary"><i class="bi bi-telephone me-1"></i>${v.contactNumber}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold text-primary">${v.studentName}</div>
                                                        <div class="small text-secondary">Room ${v.roomNumber}</div>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-light text-dark border">${v.governmentIdType}</span>
                                                        <div class="small text-muted font-monospace">${v.governmentIdNumber}</div>
                                                    </td>
                                                    <td>
                                                        <div class="small text-truncate" style="max-width: 180px;">${v.purpose}</div>
                                                    </td>
                                                    <td>
                                                        <div class="small fw-semibold text-success">${v.entryTime != null ? v.entryTime.toString().substring(0, 16) : 'N/A'}</div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${v.exitTime != null}">
                                                                <div class="small text-secondary">${v.exitTime.toString().substring(0, 16)}</div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle">Still Inside</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${v.status == 'IN_HOSTEL'}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                                                    <i class="bi bi-dot"></i>Active Inside
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary-subtle text-secondary px-2 py-1">Exited</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${v.status == 'IN_HOSTEL'}">
                                                            <form action="${pageContext.request.contextPath}/warden/visitors" method="post" class="d-inline">
                                                                <input type="hidden" name="action" value="exit">
                                                                <input type="hidden" name="logId" value="${v.id}">
                                                                <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                                                <button type="submit" class="btn btn-outline-danger btn-sm fw-bold">
                                                                    <i class="bi bi-box-arrow-right me-1"></i>Check Out
                                                                </button>
                                                            </form>
                                                        </c:if>
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

    <!-- Register Visitor Modal -->
    <div class="modal fade" id="newVisitorModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="bi bi-person-plus-fill me-2"></i>Register Campus Visitor</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/warden/visitors" method="post">
                    <input type="hidden" name="action" value="entry">
                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">

                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Visitor Full Name <span class="text-danger">*</span></label>
                            <input type="text" name="visitorName" class="form-control" placeholder="e.g. Rajesh Kumar" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Visitor Mobile Number <span class="text-danger">*</span></label>
                            <input type="tel" name="contactNumber" class="form-control" placeholder="+91 98765 43210" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Hostel Resident to Visit <span class="text-danger">*</span></label>
                            <select name="studentId" class="form-select" required>
                                <option value="">Select Resident Student...</option>
                                <c:forEach var="st" items="${students}">
                                    <option value="${st.id}">${st.fullName} (${st.registrationNumber}) — Room ${st.currentRoomNumber}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label fw-semibold">Govt ID Proof <span class="text-danger">*</span></label>
                                <select name="governmentIdType" class="form-select" required>
                                    <option value="AADHAAR">Aadhaar Card</option>
                                    <option value="DRIVING_LICENSE">Driving License</option>
                                    <option value="PASSPORT">Passport</option>
                                    <option value="VOTER_ID">Voter ID</option>
                                </select>
                            </div>
                            <div class="col-6">
                                <label class="form-label fw-semibold">ID Number <span class="text-danger">*</span></label>
                                <input type="text" name="governmentIdNumber" class="form-control" placeholder="ID document #" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Purpose of Visit</label>
                            <input type="text" name="purpose" class="form-control" placeholder="e.g. Parent visit, luggage delivery">
                        </div>
                    </div>

                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary-custom btn-sm fw-bold">
                            <i class="bi bi-check-circle me-1"></i>Issue Gate Entry Pass
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
