<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Room & Bed Matrix" scope="request" />
<c:set var="pageSubtitle" value="Interactive visual occupancy grid and temporary vacancy inspector" scope="request" />
<c:set var="activePage" value="rooms" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room & Bed Matrix — HostelEase</title>
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
                <!-- Filter & Legend Toolbar -->
                <div class="filter-toolbar">
                    <form action="${pageContext.request.contextPath}/admin/rooms" method="get" class="filter-group">
                        <select name="hostelId" class="form-select-custom" onchange="this.form.submit()">
                            <option value="">All Hostels</option>
                            <c:forEach var="h" items="${hostels}">
                                <option value="${h.id}" ${selectedHostelId == h.id ? 'selected' : ''}>${h.name}</option>
                            </c:forEach>
                        </select>

                        <select name="presence" class="form-select-custom" onchange="this.form.submit()">
                            <option value="">All Presence States</option>
                            <option value="PRESENT" ${selectedPresence == 'PRESENT' ? 'selected' : ''}>Present in Hostel</option>
                            <option value="AWAY" ${selectedPresence == 'AWAY' ? 'selected' : ''}>Away on Leave (Temporarily Vacant)</option>
                            <option value="RETURN_OVERDUE" ${selectedPresence == 'RETURN_OVERDUE' ? 'selected' : ''}>Return Overdue</option>
                            <option value="EXPECTED_TO_LEAVE" ${selectedPresence == 'EXPECTED_TO_LEAVE' ? 'selected' : ''}>Expected to Leave</option>
                        </select>

                        <select name="allocation" class="form-select-custom" onchange="this.form.submit()">
                            <option value="">All Allocation States</option>
                            <option value="ALLOCATED" ${selectedAllocation == 'ALLOCATED' ? 'selected' : ''}>Allocated Beds</option>
                            <option value="UNALLOCATED" ${selectedAllocation == 'UNALLOCATED' ? 'selected' : ''}>Unallocated (Available)</option>
                            <option value="MAINTENANCE" ${selectedAllocation == 'MAINTENANCE' ? 'selected' : ''}>Under Maintenance</option>
                        </select>
                    </form>

                    <div class="d-flex align-items-center gap-2">
                        <input type="text" class="form-input-custom" placeholder="Search room, student..." data-table-filter=".table-custom">
                        <button type="button" class="btn btn-primary-custom btn-sm" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                            <i class="bi bi-door-open-fill me-1"></i>Add Room
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/allocations" class="btn btn-outline-primary btn-sm">
                            <i class="bi bi-plus-lg me-1"></i>New Allocation
                        </a>
                    </div>
                </div>

                <!-- Matrix Color Legend -->
                <div class="matrix-legend">
                    <div class="legend-item">
                        <div class="legend-dot" style="background: var(--emerald-500);"></div>
                        <span>Occupied &bull; Present</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background: var(--amber-500);"></div>
                        <span>Temporarily Vacant &bull; Away on Leave</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background: var(--rose-500);"></div>
                        <span>Return Overdue</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background: var(--blue-500);"></div>
                        <span>Permanently Vacant (Available)</span>
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background: #94a3b8;"></div>
                        <span>Maintenance / Blocked</span>
                    </div>
                    <div class="ms-auto small text-muted">
                        <i class="bi bi-info-circle me-1"></i>Click any bed card to inspect resident profile or holiday details.
                    </div>
                </div>

                <!-- Interactive Visual Room & Bed Matrix -->
                <div class="matrix-container mb-5">
                    <c:forEach var="room" items="${rooms}">
                        <div class="room-card">
                            <div class="room-card-header">
                                <div class="room-number-badge">
                                    <i class="bi bi-door-closed-fill text-primary"></i>
                                    <span>${room.roomNumber}</span>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <span class="room-type-tag">${room.roomType}</span>
                                    <span class="badge bg-light text-dark border small">${room.currentOccupancy}/${room.capacity}</span>
                                </div>
                            </div>
                            <div class="small text-muted mb-2">${room.buildingName} &bull; ${room.floorName}</div>

                            <div class="beds-grid">
                                <c:forEach var="bed" items="${room.beds}">
                                    <c:set var="bedClass" value="available-bed" />
                                    <c:choose>
                                        <c:when test="${bed.allocationStatus == 'MAINTENANCE'}">
                                            <c:set var="bedClass" value="maintenance-bed" />
                                        </c:when>
                                        <c:when test="${bed.allocationStatus == 'ALLOCATED' && bed.studentPresence == 'AWAY'}">
                                            <c:set var="bedClass" value="occupied-present temporarily-vacant" />
                                        </c:when>
                                        <c:when test="${bed.allocationStatus == 'ALLOCATED' && bed.studentPresence == 'RETURN_OVERDUE'}">
                                            <c:set var="bedClass" value="occupied-present return-overdue" />
                                        </c:when>
                                        <c:when test="${bed.allocationStatus == 'ALLOCATED'}">
                                            <c:set var="bedClass" value="occupied-present" />
                                        </c:when>
                                    </c:choose>

                                    <div class="bed-box ${bedClass}"
                                         data-bed-id="${bed.id}"
                                         data-room-number="${room.roomNumber}"
                                         data-hostel-name="${room.hostelName}"
                                         data-bed-label="${bed.bedLabel}"
                                         data-allocation-status="${bed.allocationStatus}"
                                         data-student-name="${bed.studentName != null ? bed.studentName : 'Unallocated'}"
                                         data-roll-number="${bed.rollNumber != null ? bed.rollNumber : 'None'}"
                                         data-student-phone="${bed.studentPhone != null ? bed.studentPhone : 'N/A'}"
                                         data-student-presence="${bed.studentPresence != null ? bed.studentPresence : 'UNALLOCATED'}"
                                         data-leave-type="${bed.leaveType != null ? bed.leaveType : 'None'}"
                                         data-departure="${bed.departureDatetime != null ? bed.departureDatetime : 'N/A'}"
                                         data-expected-return="${bed.expectedReturnDatetime != null ? bed.expectedReturnDatetime : 'N/A'}">
                                        <div class="bed-box-top">
                                            <span class="bed-label">${bed.bedLabel}</span>
                                            <span class="bed-status-indicator"></span>
                                        </div>
                                        <div class="bed-occupant-name">${bed.studentName != null ? bed.studentName : 'Available'}</div>
                                        <span class="bed-presence-badge">
                                            <c:choose>
                                                <c:when test="${bed.allocationStatus == 'UNALLOCATED'}">FREE</c:when>
                                                <c:when test="${bed.allocationStatus == 'MAINTENANCE'}">BLOCKED</c:when>
                                                <c:when test="${bed.studentPresence == 'AWAY'}">AWAY (VACANT)</c:when>
                                                <c:when test="${bed.studentPresence == 'RETURN_OVERDUE'}">OVERDUE</c:when>
                                                <c:otherwise>PRESENT</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Detailed Table View -->
                <div class="content-card">
                    <div class="card-header-flex">
                        <h2><i class="bi bi-list-check"></i>Bed-by-Bed Directory & Occupancy Status</h2>
                    </div>
                    <div class="table-responsive-custom">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Hostel & Room</th>
                                    <th>Bed</th>
                                    <th>Allocation Status</th>
                                    <th>Occupant</th>
                                    <th>Presence</th>
                                    <th>Leave Info</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="b" items="${beds}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark">${b.roomNumber}</div>
                                            <div class="small text-muted">${b.hostelName} &bull; ${b.buildingName}</div>
                                        </td>
                                        <td><span class="badge bg-light text-dark border fw-bold">${b.bedLabel}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.allocationStatus == 'ALLOCATED'}"><span class="badge-custom badge-allocated">ALLOCATED</span></c:when>
                                                <c:when test="${b.allocationStatus == 'MAINTENANCE'}"><span class="badge-custom badge-maintenance">MAINTENANCE</span></c:when>
                                                <c:otherwise><span class="badge-custom badge-unallocated">AVAILABLE</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty b.studentName}">
                                                    <div class="fw-bold text-dark">${b.studentName}</div>
                                                    <div class="small text-muted">${b.rollNumber} &bull; ${b.studentPhone}</div>
                                                </c:when>
                                                <c:otherwise><span class="text-muted fst-italic">None</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${b.studentPresence == 'PRESENT'}"><span class="badge-custom badge-present">PRESENT</span></c:when>
                                                <c:when test="${b.studentPresence == 'AWAY'}"><span class="badge-custom badge-away">AWAY (VACANT)</span></c:when>
                                                <c:when test="${b.studentPresence == 'RETURN_OVERDUE'}"><span class="badge-custom badge-overdue">RETURN OVERDUE</span></c:when>
                                                <c:when test="${b.studentPresence == 'EXPECTED_TO_LEAVE'}"><span class="badge-custom badge-expected">EXPECTED TO LEAVE</span></c:when>
                                                <c:otherwise><span class="text-muted small">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty b.leaveType}">
                                                    <div class="small fw-bold text-dark">${b.leaveType}</div>
                                                    <div class="small text-muted">Return: ${b.expectedReturnDatetime}</div>
                                                </c:when>
                                                <c:otherwise><span class="text-muted small">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-1">
                                                <c:if test="${b.allocationStatus == 'ALLOCATED'}">
                                                    <a href="${pageContext.request.contextPath}/admin/allocations" class="btn btn-outline-secondary btn-sm py-1 px-2">
                                                        <i class="bi bi-arrow-left-right me-1"></i>Transfer
                                                    </a>
                                                </c:if>
                                                <c:if test="${b.allocationStatus == 'UNALLOCATED'}">
                                                    <a href="${pageContext.request.contextPath}/admin/allocations" class="btn btn-primary btn-sm py-1 px-2">
                                                        <i class="bi bi-person-plus me-1"></i>Assign
                                                    </a>
                                                    <form action="${pageContext.request.contextPath}/admin/rooms" method="post" class="d-inline">
                                                        <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">
                                                        <input type="hidden" name="action" value="updateBedStatus">
                                                        <input type="hidden" name="bedId" value="${b.id}">
                                                        <input type="hidden" name="status" value="MAINTENANCE">
                                                        <button type="submit" class="btn btn-outline-warning btn-sm py-1 px-2" title="Mark Under Maintenance">
                                                            <i class="bi bi-tools"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${b.allocationStatus == 'MAINTENANCE'}">
                                                    <form action="${pageContext.request.contextPath}/admin/rooms" method="post" class="d-inline">
                                                        <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">
                                                        <input type="hidden" name="action" value="updateBedStatus">
                                                        <input type="hidden" name="bedId" value="${b.id}">
                                                        <input type="hidden" name="status" value="UNALLOCATED">
                                                        <button type="submit" class="btn btn-outline-success btn-sm py-1 px-2" title="Mark Available">
                                                            <i class="bi bi-check-circle me-1"></i>Available
                                                        </button>
                                                    </form>
                                                </c:if>
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

    <!-- Add Room Modal -->
    <div class="modal fade" id="addRoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <form action="${pageContext.request.contextPath}/admin/rooms" method="post">
                    <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">
                    <input type="hidden" name="action" value="createRoom">
                    <div class="modal-header bg-light">
                        <h5 class="modal-title fw-bold"><i class="bi bi-door-open-fill me-2 text-primary"></i>Add Room Unit</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label small fw-bold">Select Floor *</label>
                                <select name="floorId" class="form-select" required>
                                    <c:forEach var="fl" items="${floors}">
                                        <option value="${fl.floorId}">${fl.hostelName} — ${fl.buildingName} (${fl.floorName})</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Room Number *</label>
                                <input type="text" name="roomNumber" class="form-control" placeholder="e.g. 101, B-204" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Room Type *</label>
                                <select name="roomType" class="form-select" required>
                                    <option value="SINGLE">Single Room</option>
                                    <option value="DOUBLE" selected>Double Sharing</option>
                                    <option value="TRIPLE">Triple Sharing</option>
                                    <option value="DORMITORY">Dormitory (4+ Beds)</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label small fw-bold">Bed Capacity *</label>
                                <input type="number" name="capacity" class="form-control" value="2" min="1" max="8" required>
                                <small class="text-muted">Beds (Bed A, Bed B...) will be automatically initialized for this room.</small>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary-custom btn-sm"><i class="bi bi-check-circle me-1"></i>Create Room & Beds</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="../common/footer.jsp" />
</body>
</html>
