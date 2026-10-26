<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Resident Student Profile" scope="request" />
<c:set var="pageSubtitle" value="Official university residency record, allocation credentials, and verified guardian contacts" scope="request" />
<c:set var="activePage" value="profile" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resident Profile — HostelEase</title>
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
                <div class="row g-4">
                    <!-- Left: Identity & Allocation Card -->
                    <div class="col-lg-4">
                        <div class="panel-card text-center p-4 mb-4">
                            <div class="user-avatar mx-auto mb-3" style="width: 80px; height: 80px; font-size: 2rem;">
                                ${student.firstName.substring(0, 1)}${student.lastName.substring(0, 1)}
                            </div>
                            <h4 class="fw-bold mb-1">${student.fullName}</h4>
                            <div class="badge bg-light text-dark font-monospace border mb-3 fs-6 px-3 py-1">
                                ${student.registrationNumber}
                            </div>
                            <div class="small text-secondary mb-3">${student.course} • Year ${student.yearOfStudy}</div>
                            <button type="button" class="btn btn-outline-primary btn-sm mb-3 w-100 fw-bold" data-bs-toggle="modal" data-bs-target="#editContactModal">
                                <i class="bi bi-pencil-square me-1"></i>Update Contact Information
                            </button>

                            <div class="p-3 bg-light rounded-3 border text-start">
                                <div class="text-uppercase small text-secondary fw-bold mb-2">Residency Status</div>
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="small text-secondary">Hostel:</span>
                                    <span class="fw-bold text-primary">${student.currentHostelName}</span>
                                </div>
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="small text-secondary">Room:</span>
                                    <span class="fw-bold">Room ${student.currentRoomNumber}</span>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="small text-secondary">Bed:</span>
                                    <span class="fw-bold text-success">${student.currentBedNumber}</span>
                                </div>
                                <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                    <span class="small text-secondary">Presence:</span>
                                    <c:choose>
                                        <c:when test="${student.currentPresenceStatus == 'PRESENT'}">
                                            <span class="badge bg-success-subtle text-success border border-success-subtle">In Hostel</span>
                                        </c:when>
                                        <c:when test="${student.currentPresenceStatus == 'AWAY'}">
                                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Away on Leave</span>
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
                    </div>

                    <!-- Right: Detailed Information Tabs/Tables -->
                    <div class="col-lg-8">
                        <!-- Academic & Personal Details -->
                        <div class="panel-card mb-4">
                            <div class="panel-header">
                                <div class="panel-title"><i class="bi bi-person-lines-fill text-primary"></i> Academic & Personal Records</div>
                            </div>
                            <div class="panel-body p-4">
                                <div class="row g-3">
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Full Name</label>
                                        <div class="fw-semibold">${student.fullName}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Registration Number</label>
                                        <div class="fw-semibold font-monospace">${student.registrationNumber}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Degree & Course</label>
                                        <div class="fw-semibold">${student.course}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Current Academic Year</label>
                                        <div class="fw-semibold">Year ${student.yearOfStudy} (Batch ${student.admissionYear != null ? student.admissionYear : '2026'})</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Email Address</label>
                                        <div class="fw-semibold"><a href="mailto:${student.email}" class="text-decoration-none">${student.email}</a></div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Mobile Phone (SMS & Alerts)</label>
                                        <div class="fw-semibold text-primary"><i class="bi bi-phone me-1"></i>${student.phone}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Gender</label>
                                        <div class="fw-semibold">${student.gender}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Blood Group</label>
                                        <div class="fw-semibold text-danger">${student.bloodGroup != null ? student.bloodGroup : 'Not Specified'}</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Guardian & Emergency Contacts -->
                        <div class="panel-card mb-4">
                            <div class="panel-header">
                                <div class="panel-title"><i class="bi bi-shield-heart text-danger"></i> Parent & Guardian Emergency Contacts</div>
                            </div>
                            <div class="panel-body p-4">
                                <div class="row g-3">
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Parent / Guardian Name</label>
                                        <div class="fw-semibold">${student.guardianName}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Relationship</label>
                                        <div class="fw-semibold">${student.guardianRelationship != null ? student.guardianRelationship : 'Parent'}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Guardian Primary Mobile (SMS Notifications)</label>
                                        <div class="fw-bold text-primary"><i class="bi bi-telephone-fill me-1"></i>${student.guardianPhone}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <label class="small text-secondary text-uppercase fw-bold">Guardian Email (Notifications)</label>
                                        <div class="fw-bold text-dark"><i class="bi bi-envelope me-1"></i>${student.guardianEmail != null ? student.guardianEmail : 'Not set'}</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Permanent Address -->
                        <div class="panel-card">
                            <div class="panel-header">
                                <div class="panel-title"><i class="bi bi-geo-alt text-primary"></i> Permanent Home Address</div>
                            </div>
                            <div class="panel-body p-4">
                                <div class="fw-semibold mb-1">${student.permanentAddress != null ? student.permanentAddress : student.addressLine1}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <jsp:include page="../common/footer.jsp" />
        </main>
    </div>

    <!-- Edit Contact Modal -->
    <div class="modal fade" id="editContactModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <form action="${pageContext.request.contextPath}/student/profile" method="post">
                    <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title fw-bold"><i class="bi bi-pencil-square me-2"></i>Update Contact Information</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-uppercase">Student Mobile Number *</label>
                            <input type="tel" name="phone" class="form-control" value="${student.phone}" required placeholder="+91 98765 43210">
                            <div class="small text-muted mt-1">Direct SMS notifications for gate entries, leaves, and dues will be sent here.</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-uppercase">Guardian Phone Number *</label>
                            <input type="tel" name="guardianPhone" class="form-control" value="${student.guardianPhone}" required placeholder="+91 98111 22334">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-uppercase">Guardian Email Address</label>
                            <input type="email" name="guardianEmail" class="form-control" value="${student.guardianEmail}" placeholder="parent@gmail.com">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-uppercase">Permanent Address</label>
                            <textarea name="address" class="form-control" rows="2">${student.permanentAddress != null ? student.permanentAddress : student.addressLine1}</textarea>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary-custom btn-sm fw-bold">
                            <i class="bi bi-save me-1"></i>Save Changes
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
