<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Allocations & Transfers" scope="request" />
<c:set var="pageSubtitle" value="Atomic room assignments, bed transfers, and permanent checkout management" scope="request" />
<c:set var="activePage" value="allocations" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocations & Transfers — HostelEase</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <div class="app-container">
        <jsp:include page="../common/sidebar.jsp" />

        <main class="app-main">
            <jsp:include page="../common/header.jsp" />

            <div class="page-body">
                <!-- Action Header -->
                <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
                    <div>
                        <h2 class="fs-4 fw-bold text-dark mb-1">Room Allocation Operations</h2>
                        <p class="text-secondary small mb-0">Transactional bed assignment and clearance workflows</p>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <button type="button" class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#newAllocModal">
                            <i class="bi bi-person-plus-fill me-1"></i>New Bed Allocation
                        </button>
                        <button type="button" class="btn btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#transferModal">
                            <i class="bi bi-arrow-left-right me-1"></i>Transfer Bed
                        </button>
                        <button type="button" class="btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#checkoutModal">
                            <i class="bi bi-box-arrow-right me-1"></i>Permanent Checkout
                        </button>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <!-- Unallocated Students Alert -->
                    <div class="col-lg-5">
                        <div class="content-card h-100">
                            <div class="card-header-flex">
                                <h2><i class="bi bi-person-exclamation text-warning"></i>Unallocated Residents (${unallocatedStudents.size()})</h2>
                            </div>
                            <div class="table-responsive-custom" style="max-height: 380px;">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th>Resident</th>
                                            <th>Course</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="s" items="${unallocatedStudents}">
                                            <tr>
                                                <td>
                                                    <div class="fw-bold text-dark">${s.fullName}</div>
                                                    <div class="small text-muted">${s.rollNumber} &bull; ${s.gender}</div>
                                                </td>
                                                <td class="small text-secondary">${s.course}</td>
                                                <td>
                                                    <button type="button" class="btn btn-sm btn-primary py-1 px-2"
                                                            onclick="quickAssign('${s.id}', '${s.fullName}')">
                                                        Assign
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty unallocatedStudents}">
                                            <tr><td colspan="3" class="text-center text-muted py-4">All registered students currently have active bed allocations.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Available Beds List -->
                    <div class="col-lg-7">
                        <div class="content-card h-100">
                            <div class="card-header-flex">
                                <h2><i class="bi bi-check-circle text-success"></i>Available Beds (${availableBeds.size()})</h2>
                            </div>
                            <div class="table-responsive-custom" style="max-height: 380px;">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th>Hostel</th>
                                            <th>Room</th>
                                            <th>Bed Label</th>
                                            <th>Block & Floor</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="b" items="${availableBeds}">
                                            <tr>
                                                <td class="fw-bold text-dark">${b.hostelName}</td>
                                                <td><span class="badge bg-light text-dark border">${b.roomNumber}</span></td>
                                                <td><span class="badge bg-success-subtle text-success border">${b.bedLabel}</span></td>
                                                <td class="small text-muted">${b.buildingName} &bull; ${b.floorName}</td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty availableBeds}">
                                            <tr><td colspan="4" class="text-center text-muted py-4">No available beds remaining in the selected hostel.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Active Allocations Directory -->
                <div class="content-card">
                    <div class="card-header-flex">
                        <h2><i class="bi bi-people-fill text-primary"></i>Active Bed Allocations Directory (${allocatedBeds.size()})</h2>
                        <input type="text" class="form-input-custom" placeholder="Search allocated resident..." data-table-filter="#allocationsTable">
                    </div>
                    <div class="table-responsive-custom">
                        <table class="table-custom" id="allocationsTable">
                            <thead>
                                <tr>
                                    <th>Resident</th>
                                    <th>Hostel</th>
                                    <th>Room & Bed</th>
                                    <th>Presence State</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="b" items="${allocatedBeds}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark">${b.studentName}</div>
                                            <div class="small text-muted">${b.rollNumber} &bull; ${b.studentPhone}</div>
                                        </td>
                                        <td>${b.hostelName}</td>
                                        <td><span class="badge bg-light text-dark border">${b.roomNumber} (${b.bedLabel})</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.studentPresence == 'PRESENT'}"><span class="badge-custom badge-present">PRESENT</span></c:when>
                                                <c:when test="${b.studentPresence == 'AWAY'}"><span class="badge-custom badge-away">AWAY (VACANT)</span></c:when>
                                                <c:when test="${b.studentPresence == 'RETURN_OVERDUE'}"><span class="badge-custom badge-overdue">OVERDUE</span></c:when>
                                                <c:otherwise><span class="badge-custom badge-expected">${b.studentPresence}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-1">
                                                <button type="button" class="btn btn-outline-secondary btn-sm py-1 px-2"
                                                        onclick="prepTransfer('${b.studentId}', '${b.studentName}', '${b.id}', '${b.roomNumber} - ${b.bedLabel}')">
                                                    Transfer
                                                </button>
                                                <button type="button" class="btn btn-outline-danger btn-sm py-1 px-2"
                                                        onclick="prepCheckout('${b.studentId}', '${b.studentName}')">
                                                    Checkout
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- MODAL 1: New Bed Allocation -->
    <div class="modal fade" id="newAllocModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/allocations" method="post">
                    <input type="hidden" name="action" value="allocate">
                    <input type="hidden" name="csrf_token" value="${sessionScope.CSRF_TOKEN}">

                    <div class="modal-header">
                        <h5 class="modal-title fw-bold"><i class="bi bi-person-plus text-primary me-2"></i>New Room Allocation</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Select Unallocated Student</label>
                            <select name="studentId" id="allocStudentSelect" class="form-select" required>
                                <option value="">-- Choose Student --</option>
                                <c:forEach var="s" items="${unallocatedStudents}">
                                    <option value="${s.id}">${s.fullName} (${s.rollNumber}) &bull; ${s.gender}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Select Available Bed</label>
                            <select name="bedId" class="form-select" required>
                                <option value="">-- Choose Available Bed --</option>
                                <c:forEach var="b" items="${availableBeds}">
                                    <option value="${b.id}">${b.hostelName} &bull; Room ${b.roomNumber} (${b.bedLabel})</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary btn-sm fw-bold">Confirm Allocation</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL 2: Room Transfer -->
    <div class="modal fade" id="transferModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/allocations" method="post">
                    <input type="hidden" name="action" value="transfer">
                    <input type="hidden" name="csrf_token" value="${sessionScope.CSRF_TOKEN}">

                    <div class="modal-header">
                        <h5 class="modal-title fw-bold"><i class="bi bi-arrow-left-right text-primary me-2"></i>Transfer Student Bed</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Student to Transfer</label>
                            <select name="studentId" id="transferStudentId" class="form-select" required onchange="updateCurrentBed(this)">
                                <option value="">-- Choose Allocated Student --</option>
                                <c:forEach var="b" items="${allocatedBeds}">
                                    <option value="${b.studentId}" data-bed-id="${b.id}" data-bed-info="${b.roomNumber} (${b.bedLabel})">
                                        ${b.studentName} (${b.rollNumber})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <input type="hidden" name="currentBedId" id="transferCurrentBedId">
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Current Bed</label>
                            <input type="text" id="transferCurrentBedInfo" class="form-control" readonly disabled value="Select student above">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Select Target Available Bed</label>
                            <select name="targetBedId" class="form-select" required>
                                <option value="">-- Choose Target Bed --</option>
                                <c:forEach var="b" items="${availableBeds}">
                                    <option value="${b.id}">${b.hostelName} &bull; Room ${b.roomNumber} (${b.bedLabel})</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary btn-sm fw-bold">Execute Atomic Transfer</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL 3: Permanent Checkout -->
    <div class="modal fade" id="checkoutModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/allocations" method="post">
                    <input type="hidden" name="action" value="checkout">
                    <input type="hidden" name="csrf_token" value="${sessionScope.CSRF_TOKEN}">

                    <div class="modal-header">
                        <h5 class="modal-title fw-bold text-danger"><i class="bi bi-box-arrow-right me-2"></i>Permanent Checkout</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-warning small">
                            <i class="bi bi-exclamation-triangle me-1"></i>
                            Permanent checkout terminates the active allocation and releases the bed back into the available pool.
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Resident</label>
                            <select name="studentId" id="checkoutStudentId" class="form-select" required>
                                <option value="">-- Choose Student to Checkout --</option>
                                <c:forEach var="b" items="${allocatedBeds}">
                                    <option value="${b.studentId}">${b.studentName} (${b.rollNumber}) &bull; Room ${b.roomNumber}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-secondary text-uppercase">Checkout Remarks / Clearance</label>
                            <textarea name="remarks" class="form-control" rows="2" placeholder="e.g. Degree completed, security deposit settled" required></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-danger btn-sm fw-bold">Execute Permanent Checkout</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="../common/footer.jsp" />

    <script>
        function quickAssign(studentId, studentName) {
            const select = document.getElementById('allocStudentSelect');
            if (select) {
                select.value = studentId;
            }
            const modal = new bootstrap.Modal(document.getElementById('newAllocModal'));
            modal.show();
        }

        function prepTransfer(studentId, studentName, bedId, bedInfo) {
            document.getElementById('transferStudentId').value = studentId;
            document.getElementById('transferCurrentBedId').value = bedId;
            document.getElementById('transferCurrentBedInfo').value = bedInfo;
            const modal = new bootstrap.Modal(document.getElementById('transferModal'));
            modal.show();
        }

        function updateCurrentBed(select) {
            const opt = select.options[select.selectedIndex];
            document.getElementById('transferCurrentBedId').value = opt.getAttribute('data-bed-id') || '';
            document.getElementById('transferCurrentBedInfo').value = opt.getAttribute('data-bed-info') || 'N/A';
        }

        function prepCheckout(studentId, studentName) {
            document.getElementById('checkoutStudentId').value = studentId;
            const modal = new bootstrap.Modal(document.getElementById('checkoutModal'));
            modal.show();
        }
    </script>
</body>
</html>
