<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Holiday & Leave Application" scope="request" />
<c:set var="pageSubtitle" value="Submit departure requests for home visits, vacations, or emergencies with parental notification" scope="request" />
<c:set var="activePage" value="leaves" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Leave — HostelEase</title>
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
                <c:if test="${param.msg == 'leave_submitted'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-check-circle-fill fs-5 me-2"></i>
                        <div><strong>Leave Application Submitted!</strong> Your request has been queued for warden review and your guardian has been notified.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'submission_failed'}">
                    <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill fs-5 me-2"></i>
                        <div><strong>Submission Failed:</strong> Please verify your input and ensure all dates are valid.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'invalid_dates'}">
                    <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-calendar-x fs-5 me-2"></i>
                        <div><strong>Invalid Date Range:</strong> Return date must be strictly after the departure date.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Temporary Vacancy Guarantee Banner -->
                <div class="alert alert-info border-info-subtle d-flex align-items-center mb-4" role="alert">
                    <i class="bi bi-shield-check fs-3 me-3 text-primary"></i>
                    <div>
                        <h6 class="alert-heading fw-bold mb-1">Your Bed Allocation is Protected</h6>
                        <p class="small mb-0">
                            When your leave is approved and you depart, your bed (<strong>Room ${student.currentRoomNumber}, Bed ${student.currentBedNumber}</strong> in ${student.currentHostelName})
                            is designated as a <em>Temporary Holiday Vacancy</em> for hostel tracking, but <strong>your room allocation is guaranteed and locked</strong> until you return.
                        </p>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <!-- Left Column: Leave Application Form -->
                    <div class="col-lg-7">
                        <div class="panel-card">
                            <div class="panel-header">
                                <div class="panel-title">
                                    <i class="bi bi-pencil-square text-primary"></i> New Leave / Vacation Request
                                </div>
                            </div>
                            <div class="panel-body p-4">
                                <form action="${pageContext.request.contextPath}/student/leaves" method="post" id="leaveApplicationForm">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">

                                    <div class="row g-3 mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Leave Category <span class="text-danger">*</span></label>
                                            <select name="leaveType" class="form-select" required>
                                                <option value="HOME">Home Visit / Weekend</option>
                                                <option value="VACATION">Official Semester Vacation / Holiday</option>
                                                <option value="MEDICAL">Medical Treatment / Sick Leave</option>
                                                <option value="EMERGENCY">Family Emergency</option>
                                                <option value="ACADEMIC_OD">Academic On-Duty / Competition</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Emergency / Guardian Contact <span class="text-danger">*</span></label>
                                            <input type="tel" name="emergencyContact" class="form-control" value="${student.guardianPhone}" required>
                                        </div>
                                    </div>

                                    <div class="row g-3 mb-3">
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Departure Date & Time <span class="text-danger">*</span></label>
                                            <input type="datetime-local" name="departureDatetime" id="depDateTime" class="form-control" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Expected Return Date & Time <span class="text-danger">*</span></label>
                                            <input type="datetime-local" name="expectedReturnDatetime" id="retDateTime" class="form-control" required>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-semibold">Destination City & Full Address <span class="text-danger">*</span></label>
                                        <input type="text" name="destinationAddress" class="form-control" placeholder="e.g. Flat 402, Green Valley Apartments, Mumbai, Maharashtra" required>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label fw-semibold">Reason for Absence <span class="text-danger">*</span></label>
                                        <textarea name="reason" class="form-control" rows="3" placeholder="Provide detailed explanation for your leave application..." required></textarea>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2">
                                        <button type="reset" class="btn btn-outline-secondary btn-sm">Clear Form</button>
                                        <button type="submit" class="btn btn-primary-custom btn-sm fw-bold">
                                            <i class="bi bi-send-fill me-1"></i>Submit Leave Application
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column: Guidelines Card -->
                    <div class="col-lg-5">
                        <div class="panel-card h-100">
                            <div class="panel-header">
                                <div class="panel-title"><i class="bi bi-info-circle text-primary"></i> Leave Rules & Protocol</div>
                            </div>
                            <div class="panel-body p-4">
                                <div class="d-flex gap-3 mb-3">
                                    <div class="stat-icon icon-primary p-2" style="width: 38px; height: 38px;"><i class="bi bi-bell"></i></div>
                                    <div>
                                        <h6 class="fw-bold mb-1">Guardian Verification</h6>
                                        <p class="small text-secondary mb-0">SMS notification will be dispatched to your parent/guardian upon application submission.</p>
                                    </div>
                                </div>

                                <div class="d-flex gap-3 mb-3">
                                    <div class="stat-icon icon-warning p-2" style="width: 38px; height: 38px;"><i class="bi bi-geo-alt"></i></div>
                                    <div>
                                        <h6 class="fw-bold mb-1">Gate Check-Out Required</h6>
                                        <p class="small text-secondary mb-0">Once approved, report to the security gate checkpoint before leaving the campus premises.</p>
                                    </div>
                                </div>

                                <div class="d-flex gap-3 mb-3">
                                    <div class="stat-icon icon-danger p-2" style="width: 38px; height: 38px;"><i class="bi bi-clock-history"></i></div>
                                    <div>
                                        <h6 class="fw-bold mb-1">Strict Curfew Compliance</h6>
                                        <p class="small text-secondary mb-0">Overdue returns trigger automated security alerts to both the hostel warden and your parents.</p>
                                    </div>
                                </div>

                                <div class="d-flex gap-3">
                                    <div class="stat-icon icon-success p-2" style="width: 38px; height: 38px;"><i class="bi bi-house-check"></i></div>
                                    <div>
                                        <h6 class="fw-bold mb-1">Re-entry Confirmation</h6>
                                        <p class="small text-secondary mb-0">Check back in at the security gate immediately upon arriving back at your hostel.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bottom Panel: Student Leave History -->
                <div class="panel-card">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-journal-text text-primary"></i> Your Leave Application History (${leaves.size()})
                        </div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Application Date</th>
                                        <th>Category</th>
                                        <th>Leave Period</th>
                                        <th>Duration</th>
                                        <th>Destination</th>
                                        <th>Status</th>
                                        <th>Warden Remarks</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty leaves}">
                                            <tr>
                                                <td colspan="7" class="text-center py-4 text-secondary">
                                                    No prior leave requests recorded.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="l" items="${leaves}">
                                                <tr>
                                                    <td class="small text-secondary">
                                                        ${l.createdAt != null ? l.createdAt.toString().substring(0, 10) : 'N/A'}
                                                    </td>
                                                    <td><span class="badge bg-light text-dark border">${l.leaveType}</span></td>
                                                    <td>
                                                        <div class="small fw-semibold text-primary">${l.startDate} to ${l.endDate}</div>
                                                    </td>
                                                    <td class="small">${l.totalDays} Day(s)</td>
                                                    <td>
                                                        <div class="small fw-semibold">${l.destinationCity}</div>
                                                        <div class="small text-secondary text-truncate" style="max-width: 180px;">${l.reason}</div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${l.status == 'PENDING'}">
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">
                                                                    <i class="bi bi-hourglass-split me-1"></i>Pending Review
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${l.status == 'APPROVED'}">
                                                                <span class="badge bg-info-subtle text-info border border-info-subtle">
                                                                    <i class="bi bi-check2-circle me-1"></i>Approved (Ready)
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${l.status == 'DEPARTED'}">
                                                                <span class="badge bg-primary-subtle text-primary border border-primary-subtle">
                                                                    <i class="bi bi-airplane-fill me-1"></i>Away on Leave
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${l.status == 'OVERDUE'}">
                                                                <span class="badge bg-danger animate-pulse">
                                                                    <i class="bi bi-exclamation-triangle-fill me-1"></i>Return Overdue
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${l.status == 'RETURNED'}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle">
                                                                    <i class="bi bi-check-circle-fill me-1"></i>Returned
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary-subtle text-secondary">${l.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="small text-secondary">
                                                        ${l.remarks != null ? l.remarks : '—'}
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
    <script>
        // Set minimum dates to now
        const now = new Date();
        now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
        const minIso = now.toISOString().slice(0, 16);
        document.getElementById('depDateTime').min = minIso;
        document.getElementById('retDateTime').min = minIso;

        document.getElementById('depDateTime').addEventListener('change', function() {
            document.getElementById('retDateTime').min = this.value;
        });
    </script>
</body>
</html>
