<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Student Residents Directory" scope="request" />
<c:set var="pageSubtitle" value="Complete resident register with active bed allocations and real-time physical presence tracking" scope="request" />
<c:set var="activePage" value="students" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resident Students — HostelEase</title>
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
                <!-- Presence & Roster Summary Cards -->
                <div class="stat-grid mb-4">
                    <div class="stat-card">
                        <div class="stat-icon icon-primary"><i class="bi bi-people-fill"></i></div>
                        <div>
                            <div class="stat-value">${students.size()}</div>
                            <div class="stat-label">Total Filtered Residents</div>
                        </div>
                    </div>

                    <c:set var="countPresent" value="0" />
                    <c:set var="countAway" value="0" />
                    <c:set var="countOverdue" value="0" />
                    <c:forEach var="st" items="${students}">
                        <c:choose>
                            <c:when test="${st.currentPresenceStatus == 'PRESENT'}"><c:set var="countPresent" value="${countPresent + 1}" /></c:when>
                            <c:when test="${st.currentPresenceStatus == 'AWAY'}"><c:set var="countAway" value="${countAway + 1}" /></c:when>
                            <c:when test="${st.currentPresenceStatus == 'OVERDUE'}"><c:set var="countOverdue" value="${countOverdue + 1}" /></c:when>
                        </c:choose>
                    </c:forEach>

                    <div class="stat-card">
                        <div class="stat-icon icon-success"><i class="bi bi-house-check-fill"></i></div>
                        <div>
                            <div class="stat-value text-success">${countPresent}</div>
                            <div class="stat-label">Present in Hostel</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-warning"><i class="bi bi-airplane-engines-fill"></i></div>
                        <div>
                            <div class="stat-value text-warning">${countAway}</div>
                            <div class="stat-label">Away on Approved Leave</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-danger"><i class="bi bi-exclamation-triangle-fill"></i></div>
                        <div>
                            <div class="stat-value text-danger">${countOverdue}</div>
                            <div class="stat-label">Return Overdue Alert</div>
                        </div>
                    </div>
                </div>

                <!-- Filter & Search Toolbar -->
                <div class="filter-toolbar mb-4">
                    <form action="${pageContext.request.contextPath}/admin/students" method="get" class="d-flex flex-wrap align-items-center gap-3 flex-grow-1">
                        <div class="input-group" style="max-width: 320px;">
                            <span class="input-group-text bg-transparent border-end-0 text-secondary"><i class="bi bi-search"></i></span>
                            <input type="text" name="search" class="form-control border-start-0" placeholder="Search name, reg #, course..." value="${search != null ? search : ''}">
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <label class="small fw-bold text-secondary text-uppercase mb-0">Hostel:</label>
                            <select name="hostelId" class="form-select-custom">
                                <option value="">All Facilities</option>
                                <c:forEach var="h" items="${hostels}">
                                    <option value="${h.id}" ${selectedHostelId == h.id ? 'selected' : ''}>${h.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <label class="small fw-bold text-secondary text-uppercase mb-0">Presence:</label>
                            <select name="presence" class="form-select-custom">
                                <option value="">All Presence States</option>
                                <option value="PRESENT" ${selectedPresence == 'PRESENT' ? 'selected' : ''}>Present</option>
                                <option value="AWAY" ${selectedPresence == 'AWAY' ? 'selected' : ''}>Away (On Leave)</option>
                                <option value="OVERDUE" ${selectedPresence == 'OVERDUE' ? 'selected' : ''}>Overdue Return</option>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-primary-custom btn-sm">
                            <i class="bi bi-filter me-1"></i>Apply Filter
                        </button>

                        <c:if test="${not empty search || not empty selectedHostelId || not empty selectedPresence}">
                            <a href="${pageContext.request.contextPath}/admin/students" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-x-circle me-1"></i>Reset
                            </a>
                        </c:if>
                    </form>

                    <div class="d-flex align-items-center gap-2">
                        <button type="button" class="btn btn-primary-custom btn-sm fw-bold" data-bs-toggle="modal" data-bs-target="#addStudentModal">
                            <i class="bi bi-person-plus-fill me-1"></i>Register Resident
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/allocations" class="btn btn-outline-primary btn-sm fw-bold">
                            <i class="bi bi-box-arrow-in-right me-1"></i>New Allocation
                        </a>
                    </div>
                </div>

                <!-- Students Table Card -->
                <div class="panel-card">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-person-lines-fill text-primary"></i> Registered Residents (${students.size()})
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <input type="text" id="quickTableSearch" class="form-control form-control-sm" style="width: 200px;" placeholder="Filter rows in page...">
                        </div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0" id="studentsTable">
                                <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>Reg Number</th>
                                        <th>Hostel & Room</th>
                                        <th>Academic Info</th>
                                        <th>Contact</th>
                                        <th>Presence Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty students}">
                                            <tr>
                                                <td colspan="7" class="text-center py-5">
                                                    <div class="empty-state">
                                                        <i class="bi bi-people display-4 text-secondary mb-3 d-block"></i>
                                                        <h5 class="fw-bold">No Students Found</h5>
                                                        <p class="text-secondary small">Try adjusting your search criteria or facility filter.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="s" items="${students}">
                                                <tr>
                                                    <td>
                                                        <div class="d-flex align-items-center gap-3">
                                                            <div class="user-avatar" style="width: 38px; height: 38px; font-size: 0.9rem;">
                                                                ${s.firstName.substring(0, 1)}${s.lastName.substring(0, 1)}
                                                            </div>
                                                            <div>
                                                                <div class="fw-bold">${s.fullName}</div>
                                                                <div class="small text-secondary">${s.gender} • DOB: ${s.dateOfBirth != null ? s.dateOfBirth : 'N/A'}</div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-light text-dark font-monospace px-2 py-1 border">${s.registrationNumber}</span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty s.currentHostelName}">
                                                                <div class="fw-semibold text-primary">${s.currentHostelName}</div>
                                                                <div class="small text-secondary">
                                                                    Room <strong>${s.currentRoomNumber}</strong> • Bed <strong>${s.currentBedNumber}</strong>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">Unallocated</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold">${s.course != null ? s.course : 'General'}</div>
                                                        <div class="small text-secondary">Year ${s.yearOfStudy != null ? s.yearOfStudy : '1'} • Batch ${s.admissionYear != null ? s.admissionYear : '2026'}</div>
                                                    </td>
                                                    <td>
                                                        <div><i class="bi bi-envelope me-1 text-secondary"></i><a href="mailto:${s.email}" class="text-decoration-none">${s.email}</a></div>
                                                        <div class="small text-secondary"><i class="bi bi-telephone me-1"></i>${s.phone != null ? s.phone : 'N/A'}</div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${s.currentPresenceStatus == 'PRESENT'}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                                                    <i class="bi bi-check-circle-fill me-1"></i>Present
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${s.currentPresenceStatus == 'AWAY'}">
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1">
                                                                    <i class="bi bi-airplane-fill me-1"></i>Away on Leave
                                                                </span>
                                                                <div class="text-muted" style="font-size: 0.72rem;">Bed Temporarily Vacant</div>
                                                            </c:when>
                                                            <c:when test="${s.currentPresenceStatus == 'OVERDUE'}">
                                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1 animate-pulse">
                                                                    <i class="bi bi-exclamation-octagon-fill me-1"></i>Overdue Return
                                                                </span>
                                                                <div class="text-danger fw-bold" style="font-size: 0.72rem;">Action Required</div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary-subtle text-secondary px-2 py-1">Checked Out</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div class="btn-group btn-group-sm">
                                                            <button type="button" class="btn btn-outline-secondary" title="View Resident Profile"
                                                                    onclick="viewStudentProfile('${s.fullName}', '${s.registrationNumber}', '${s.email}', '${s.phone}', '${s.course}', '${s.yearOfStudy}', '${s.currentHostelName}', '${s.currentRoomNumber}', '${s.currentBedNumber}', '${s.currentPresenceStatus}', '${s.guardianName}', '${s.guardianPhone}', '${s.emergencyContactPhone}', '${s.bloodGroup}', '${s.addressLine1}')">
                                                                <i class="bi bi-eye"></i>
                                                            </button>
                                                            <button type="button" class="btn btn-outline-warning" title="Edit Student Profile"
                                                                    onclick="openEditStudentModal('${s.id}', '${s.course}', '${s.batchYear}', '${s.phone}', '${s.guardianName}', '${s.guardianPhone}', '${s.guardianEmail}', '${s.permanentAddress}')">
                                                                <i class="bi bi-pencil"></i>
                                                            </button>
                                                            <a href="${pageContext.request.contextPath}/admin/allocations?search=${s.registrationNumber}" class="btn btn-outline-primary" title="Manage Allocation">
                                                                <i class="bi bi-arrow-left-right"></i>
                                                            </a>
                                                        </div>
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

    <!-- Student Detail Modal -->
    <div class="modal fade" id="studentDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold" id="modalStudentName"><i class="bi bi-person-badge me-2 text-primary"></i>Resident Profile</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-4">
                        <div class="col-md-6">
                            <h6 class="text-uppercase fw-bold text-secondary small mb-3"><i class="bi bi-info-circle me-1"></i>Academic & Contact Details</h6>
                            <table class="table table-sm table-borderless">
                                <tr>
                                    <td class="text-secondary" style="width: 40%;">Registration #:</td>
                                    <td class="fw-bold font-monospace" id="modalRegNum"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Course & Year:</td>
                                    <td class="fw-semibold" id="modalCourse"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Email:</td>
                                    <td id="modalEmail"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Phone:</td>
                                    <td class="fw-semibold" id="modalPhone"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Blood Group:</td>
                                    <td id="modalBloodGroup"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Address:</td>
                                    <td class="small" id="modalAddress"></td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6 border-start">
                            <h6 class="text-uppercase fw-bold text-secondary small mb-3"><i class="bi bi-house-door me-1"></i>Hostel Residency & Guardian</h6>
                            <table class="table table-sm table-borderless">
                                <tr>
                                    <td class="text-secondary" style="width: 40%;">Assigned Hostel:</td>
                                    <td class="fw-bold text-primary" id="modalHostel"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Room & Bed:</td>
                                    <td class="fw-bold" id="modalRoomBed"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Presence Status:</td>
                                    <td id="modalPresence"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Guardian Name:</td>
                                    <td class="fw-semibold" id="modalGuardian"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Guardian Phone:</td>
                                    <td class="fw-semibold text-danger" id="modalGuardianPhone"></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Emergency Phone:</td>
                                    <td class="fw-semibold text-danger" id="modalEmergencyPhone"></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                    <a href="#" id="modalAllocationLink" class="btn btn-primary-custom btn-sm">
                        <i class="bi bi-arrow-left-right me-1"></i>Manage Allocation
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Register Student Modal -->
    <div class="modal fade" id="addStudentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 shadow">
                <form action="${pageContext.request.contextPath}/admin/students" method="post">
                    <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-header bg-light">
                        <h5 class="modal-title fw-bold"><i class="bi bi-person-plus-fill me-2 text-primary"></i>Register New Student Resident</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12"><h6 class="text-primary fw-bold small text-uppercase mb-2"><i class="bi bi-key-fill me-1"></i>Account & Identity</h6></div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">First Name *</label>
                                <input type="text" name="firstName" class="form-control" required placeholder="e.g. Rahul">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Last Name *</label>
                                <input type="text" name="lastName" class="form-control" required placeholder="e.g. Verma">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Username *</label>
                                <input type="text" name="username" class="form-control" required placeholder="e.g. rahul.v">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Password *</label>
                                <input type="password" name="password" class="form-control" required placeholder="Min 8 characters">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Gender *</label>
                                <select name="gender" class="form-select" required>
                                    <option value="MALE">Male</option>
                                    <option value="FEMALE">Female</option>
                                    <option value="OTHER">Other</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Email Address *</label>
                                <input type="email" name="email" class="form-control" required placeholder="student@college.edu">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Mobile Number *</label>
                                <input type="tel" name="phone" class="form-control" required placeholder="+91 98765 43210">
                            </div>

                            <div class="col-12 mt-4"><h6 class="text-primary fw-bold small text-uppercase mb-2"><i class="bi bi-mortarboard-fill me-1"></i>Academic & Demographic Information</h6></div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Roll / Reg Number *</label>
                                <input type="text" name="rollNumber" class="form-control font-monospace" required placeholder="e.g. CS26B101">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Course *</label>
                                <input type="text" name="course" class="form-control" required placeholder="e.g. B.Tech CSE">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Admission Batch Year *</label>
                                <input type="number" name="batchYear" class="form-control" value="2026" required min="2020" max="2030">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Date of Birth</label>
                                <input type="date" name="dob" class="form-control" value="2005-01-01">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Blood Group</label>
                                <select name="bloodGroup" class="form-select">
                                    <option value="O+">O+</option>
                                    <option value="O-">O-</option>
                                    <option value="A+">A+</option>
                                    <option value="A-">A-</option>
                                    <option value="B+">B+</option>
                                    <option value="B-">B-</option>
                                    <option value="AB+">AB+</option>
                                    <option value="AB-">AB-</option>
                                </select>
                            </div>

                            <div class="col-12 mt-4"><h6 class="text-primary fw-bold small text-uppercase mb-2"><i class="bi bi-people-fill me-1"></i>Guardian & Emergency Contact</h6></div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Guardian Name</label>
                                <input type="text" name="guardianName" class="form-control" placeholder="Parent / Guardian Name">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Guardian Phone *</label>
                                <input type="tel" name="guardianPhone" class="form-control" required placeholder="+91 98111 22334">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Guardian Email</label>
                                <input type="email" name="guardianEmail" class="form-control" placeholder="parent@gmail.com">
                            </div>
                            <div class="col-12">
                                <label class="form-label small fw-bold">Permanent Address</label>
                                <textarea name="permanentAddress" class="form-control" rows="2" placeholder="Street, City, State, PIN Code"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary-custom btn-sm"><i class="bi bi-check-circle me-1"></i>Save & Register</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Student Modal -->
    <div class="modal fade" id="editStudentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 shadow">
                <form action="${pageContext.request.contextPath}/admin/students" method="post">
                    <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="studentId" id="editStudentId">
                    <div class="modal-header bg-light">
                        <h5 class="modal-title fw-bold"><i class="bi bi-pencil-square me-2 text-warning"></i>Update Student Resident Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Course</label>
                                <input type="text" name="course" id="editCourse" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Batch Year</label>
                                <input type="number" name="batchYear" id="editBatchYear" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Student Phone</label>
                                <input type="tel" name="phone" id="editPhone" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Guardian Name</label>
                                <input type="text" name="guardianName" id="editGuardianName" class="form-control">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Guardian Phone</label>
                                <input type="tel" name="guardianPhone" id="editGuardianPhone" class="form-control">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Guardian Email</label>
                                <input type="email" name="guardianEmail" id="editGuardianEmail" class="form-control">
                            </div>
                            <div class="col-12">
                                <label class="form-label small fw-bold">Permanent Address</label>
                                <textarea name="permanentAddress" id="editAddress" class="form-control" rows="2"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-warning btn-sm fw-bold"><i class="bi bi-save me-1"></i>Update Profile</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script>
        document.getElementById('quickTableSearch')?.addEventListener('keyup', function() {
            const query = this.value.toLowerCase();
            document.querySelectorAll('#studentsTable tbody tr').forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(query) ? '' : 'none';
            });
        });

        function viewStudentProfile(name, reg, email, phone, course, year, hostel, room, bed, presence, guardian, guardianPhone, emergencyPhone, blood, address) {
            document.getElementById('modalStudentName').innerHTML = '<i class="bi bi-person-badge me-2 text-primary"></i>' + name;
            document.getElementById('modalRegNum').textContent = reg || 'N/A';
            document.getElementById('modalCourse').textContent = (course || 'N/A') + ' (Year ' + (year || '1') + ')';
            document.getElementById('modalEmail').textContent = email || 'N/A';
            document.getElementById('modalPhone').textContent = phone || 'N/A';
            document.getElementById('modalBloodGroup').textContent = blood || 'Not Specified';
            document.getElementById('modalAddress').textContent = address || 'N/A';
            document.getElementById('modalHostel').textContent = hostel || 'Not Allocated';
            document.getElementById('modalRoomBed').textContent = room ? ('Room ' + room + ' • Bed ' + bed) : 'N/A';
            document.getElementById('modalGuardian').textContent = guardian || 'N/A';
            document.getElementById('modalGuardianPhone').textContent = guardianPhone || 'N/A';
            document.getElementById('modalEmergencyPhone').textContent = emergencyPhone || 'N/A';

            let presenceBadge = '<span class="badge bg-secondary">Unknown</span>';
            if (presence === 'PRESENT') {
                presenceBadge = '<span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1"><i class="bi bi-check-circle-fill me-1"></i>Present in Hostel</span>';
            } else if (presence === 'AWAY') {
                presenceBadge = '<span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1"><i class="bi bi-airplane-fill me-1"></i>Away on Approved Leave</span>';
            } else if (presence === 'OVERDUE') {
                presenceBadge = '<span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1 animate-pulse"><i class="bi bi-exclamation-octagon-fill me-1"></i>Overdue Return</span>';
            }
            document.getElementById('modalPresence').innerHTML = presenceBadge;

            document.getElementById('modalAllocationLink').href = '${pageContext.request.contextPath}/admin/allocations?search=' + encodeURIComponent(reg);

            new bootstrap.Modal(document.getElementById('studentDetailModal')).show();
        }

        function openEditStudentModal(id, course, batchYear, phone, gName, gPhone, gEmail, address) {
            document.getElementById('editStudentId').value = id;
            document.getElementById('editCourse').value = course || '';
            document.getElementById('editBatchYear').value = batchYear || 2026;
            document.getElementById('editPhone').value = phone || '';
            document.getElementById('editGuardianName').value = gName || '';
            document.getElementById('editGuardianPhone').value = gPhone || '';
            document.getElementById('editGuardianEmail').value = gEmail || '';
            document.getElementById('editAddress').value = address || '';

            new bootstrap.Modal(document.getElementById('editStudentModal')).show();
        }
    </script>
</body>
</html>
