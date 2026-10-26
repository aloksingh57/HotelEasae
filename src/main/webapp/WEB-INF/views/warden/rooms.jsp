<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Facility Bed Matrix & Inspection" scope="request" />
<c:set var="pageSubtitle" value="Live visual bed layout, resident presence, and temporary vacancies for ${hostel.name}" scope="request" />
<c:set var="activePage" value="rooms" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Matrix — HostelEase</title>
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
                <!-- Facility Stats Cards -->
                <div class="stat-grid mb-4">
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
                            <div class="stat-label">Vacant Unallocated</div>
                        </div>
                    </div>
                </div>

                <!-- Legend & Filter Bar -->
                <div class="filter-toolbar mb-4">
                    <div class="d-flex flex-wrap align-items-center gap-3">
                        <span class="small fw-bold text-secondary text-uppercase"><i class="bi bi-palette me-1"></i>Bed Status Legend:</span>
                        <div class="d-flex align-items-center gap-1 small">
                            <span class="badge bg-success" style="width: 12px; height: 12px; padding: 0;"></span>
                            <span>Occupied (Present)</span>
                        </div>
                        <div class="d-flex align-items-center gap-1 small">
                            <span class="badge bg-warning" style="width: 12px; height: 12px; padding: 0;"></span>
                            <span>Away on Leave (Temp Vacant)</span>
                        </div>
                        <div class="d-flex align-items-center gap-1 small">
                            <span class="badge bg-danger animate-pulse" style="width: 12px; height: 12px; padding: 0;"></span>
                            <span>Return Overdue</span>
                        </div>
                        <div class="d-flex align-items-center gap-1 small">
                            <span class="badge bg-primary" style="width: 12px; height: 12px; padding: 0;"></span>
                            <span>Available (Unallocated)</span>
                        </div>
                    </div>

                    <div>
                        <input type="text" id="roomSearchInput" class="form-control form-control-sm" style="width: 200px;" placeholder="Filter room number...">
                    </div>
                </div>

                <!-- Interactive Visual Room Matrix -->
                <div class="panel-card mb-4">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-grid-3x3-gap-fill text-primary"></i> ${hostel.name} Floor Layout & Room Matrix
                        </div>
                        <span class="badge bg-light text-dark border">Click any Bed to Inspect</span>
                    </div>
                    <div class="panel-body">
                        <div class="room-grid" id="matrixGrid">
                            <c:forEach var="rm" items="${rooms}">
                                <div class="room-card" data-room-number="${rm.roomNumber}">
                                    <div class="room-card-header d-flex justify-content-between align-items-center">
                                        <div>
                                            <span class="fw-bold fs-6">Room ${rm.roomNumber}</span>
                                            <span class="small text-secondary d-block">${rm.roomType}</span>
                                        </div>
                                        <span class="badge ${rm.availableBeds == 0 ? 'bg-danger-subtle text-danger' : (rm.occupiedBeds == 0 ? 'bg-success-subtle text-success' : 'bg-primary-subtle text-primary')}">
                                            ${rm.occupiedBeds}/${rm.capacity} Beds
                                        </span>
                                    </div>
                                    <div class="room-beds-container">
                                        <c:forEach var="b" items="${rm.beds}">
                                            <c:set var="bedClass" value="bed-available" />
                                            <c:set var="statusLabel" value="Available" />
                                            <c:if test="${b.status == 'ALLOCATED'}">
                                                <c:choose>
                                                    <c:when test="${b.currentPresenceStatus == 'AWAY'}">
                                                        <c:set var="bedClass" value="bed-away" />
                                                        <c:set var="statusLabel" value="Away on Leave" />
                                                    </c:when>
                                                    <c:when test="${b.currentPresenceStatus == 'OVERDUE'}">
                                                        <c:set var="bedClass" value="bed-overdue" />
                                                        <c:set var="statusLabel" value="Return Overdue" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:set var="bedClass" value="bed-occupied" />
                                                        <c:set var="statusLabel" value="Present" />
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>

                                            <div class="bed-chip ${bedClass}"
                                                 onclick="inspectBed(${b.id}, '${b.bedNumber}', '${rm.roomNumber}', '${hostel.name}', '${b.status}', '${b.currentStudentName}', '${b.currentStudentRegNumber}', '${b.currentPresenceStatus}', '${b.emergencyContactPhone}')">
                                                <div class="bed-icon"><i class="bi bi-layout-three-columns"></i></div>
                                                <div class="bed-info">
                                                    <div class="bed-num">${b.bedNumber}</div>
                                                    <div class="bed-student text-truncate">
                                                        <c:choose>
                                                            <c:when test="${not empty b.currentStudentName}">
                                                                ${b.currentStudentName}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">Vacant</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <jsp:include page="../common/footer.jsp" />
        </main>
    </div>

    <!-- Bed Inspection Modal -->
    <div class="modal fade" id="bedInspectModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold" id="inspectModalTitle"><i class="bi bi-info-circle me-2 text-primary"></i>Bed Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <table class="table table-sm table-borderless mb-0">
                        <tr>
                            <td class="text-secondary" style="width: 40%;">Hostel & Room:</td>
                            <td class="fw-bold" id="modalHostelRoom"></td>
                        </tr>
                        <tr>
                            <td class="text-secondary">Bed Identifier:</td>
                            <td class="fw-bold font-monospace" id="modalBedIdentifier"></td>
                        </tr>
                        <tr>
                            <td class="text-secondary">Allocation Status:</td>
                            <td id="modalAllocationStatus"></td>
                        </tr>
                        <tr>
                            <td class="text-secondary">Resident Student:</td>
                            <td class="fw-bold text-primary" id="modalStudentName"></td>
                        </tr>
                        <tr>
                            <td class="text-secondary">Registration #:</td>
                            <td class="font-monospace" id="modalRegNum"></td>
                        </tr>
                        <tr>
                            <td class="text-secondary">Physical Presence:</td>
                            <td id="modalPresenceStatus"></td>
                        </tr>
                        <tr>
                            <td class="text-secondary">Emergency Phone:</td>
                            <td class="fw-semibold text-danger" id="modalEmergency"></td>
                        </tr>
                    </table>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                    <a href="${pageContext.request.contextPath}/warden/presence" class="btn btn-primary-custom btn-sm">
                        <i class="bi bi-geo-alt me-1"></i>Gate Checkpoint
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script>
        document.getElementById('roomSearchInput')?.addEventListener('keyup', function() {
            const query = this.value.toLowerCase();
            document.querySelectorAll('#matrixGrid .room-card').forEach(card => {
                const roomNum = card.getAttribute('data-room-number').toLowerCase();
                card.style.display = roomNum.includes(query) ? '' : 'none';
            });
        });

        function inspectBed(id, bedNum, roomNum, hostelName, status, studentName, regNum, presence, emergency) {
            document.getElementById('inspectModalTitle').innerHTML = '<i class="bi bi-layout-three-columns me-2 text-primary"></i>Bed ' + bedNum + ' (Room ' + roomNum + ')';
            document.getElementById('modalHostelRoom').textContent = hostelName + ' — Room ' + roomNum;
            document.getElementById('modalBedIdentifier').textContent = bedNum;
            document.getElementById('modalAllocationStatus').innerHTML = status === 'ALLOCATED' 
                ? '<span class="badge bg-success-subtle text-success border border-success-subtle">Allocated</span>'
                : '<span class="badge bg-primary-subtle text-primary border border-primary-subtle">Vacant (Unallocated)</span>';
            document.getElementById('modalStudentName').textContent = studentName || 'None';
            document.getElementById('modalRegNum').textContent = regNum || 'N/A';
            document.getElementById('modalEmergency').textContent = emergency || 'N/A';

            let pBadge = '<span class="badge bg-secondary">Vacant Bed</span>';
            if (presence === 'PRESENT') {
                pBadge = '<span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1"><i class="bi bi-check-circle-fill me-1"></i>Present in Hostel</span>';
            } else if (presence === 'AWAY') {
                pBadge = '<span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1"><i class="bi bi-airplane-fill me-1"></i>Away on Approved Leave (Temp Vacant)</span>';
            } else if (presence === 'OVERDUE') {
                pBadge = '<span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1 animate-pulse"><i class="bi bi-exclamation-triangle-fill me-1"></i>Return Overdue</span>';
            }
            document.getElementById('modalPresenceStatus').innerHTML = pBadge;

            new bootstrap.Modal(document.getElementById('bedInspectModal')).show();
        }
    </script>
</body>
</html>
