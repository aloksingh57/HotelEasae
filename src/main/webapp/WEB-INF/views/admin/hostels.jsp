<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Hostel Facilities & Blocks" scope="request" />
<c:set var="pageSubtitle" value="Residential complexes, infrastructure specifications, warden supervision, and block capacities" scope="request" />
<c:set var="activePage" value="hostels" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Facilities & Hostels — HostelEase</title>
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
                <!-- Summary Metrics -->
                <!-- Summary Metrics & Action Toolbar -->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0"><i class="bi bi-buildings text-primary me-2"></i>Campus Residential Overview</h5>
                    <button type="button" class="btn btn-primary-custom btn-sm fw-bold" data-bs-toggle="modal" data-bs-target="#addHostelModal">
                        <i class="bi bi-building-add me-1"></i>Add Residential Complex
                    </button>
                </div>

                <div class="stat-grid mb-4">
                    <div class="stat-card">
                        <div class="stat-icon icon-primary"><i class="bi bi-buildings-fill"></i></div>
                        <div>
                            <div class="stat-value">${hostels.size()}</div>
                            <div class="stat-label">Active Residential Complexes</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-info"><i class="bi bi-door-closed-fill"></i></div>
                        <div>
                            <div class="stat-value">${overallStats.totalRooms}</div>
                            <div class="stat-label">Total Furnished Rooms</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-success"><i class="bi bi-layout-three-columns"></i></div>
                        <div>
                            <div class="stat-value text-success">${overallStats.totalBeds}</div>
                            <div class="stat-label">Total Bed Capacity</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-warning"><i class="bi bi-person-check-fill"></i></div>
                        <div>
                            <div class="stat-value text-warning">
                                <fmt:formatNumber value="${(overallStats.occupiedBeds * 100.0) / (overallStats.totalBeds > 0 ? overallStats.totalBeds : 1)}" maxFractionDigits="1" />%
                            </div>
                            <div class="stat-label">Institutional Occupancy</div>
                        </div>
                    </div>
                </div>

                <!-- Hostel Facilities List -->
                <div class="row g-4">
                    <c:forEach var="h" items="${hostels}">
                        <div class="col-lg-6">
                            <div class="panel-card h-100 d-flex flex-column">
                                <div class="panel-header d-flex justify-content-between align-items-center">
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="stat-icon icon-primary p-2 fs-5" style="width: 40px; height: 40px;">
                                            <i class="bi bi-building"></i>
                                        </div>
                                        <div>
                                            <h5 class="fw-bold mb-0">${h.name}</h5>
                                            <span class="badge ${h.type == 'BOYS' ? 'bg-primary-subtle text-primary border border-primary-subtle' : 'bg-danger-subtle text-danger border border-danger-subtle'}">
                                                ${h.type == 'BOYS' ? 'Boys Residential Complex' : 'Girls Residential Complex'}
                                            </span>
                                            <span class="badge bg-light text-dark border font-monospace ms-1">${h.code}</span>
                                        </div>
                                    </div>
                                    <span class="badge bg-success-subtle text-success border border-success-subtle">
                                        <i class="bi bi-check-circle me-1"></i>Operational
                                    </span>
                                </div>
                                <div class="panel-body flex-grow-1">
                                    <p class="text-secondary small mb-3">
                                        ${h.description != null ? h.description : 'Premier air-cooled and ventilated student accommodation with high-speed campus internet, CCTV coverage, and dining hall.'}
                                    </p>

                                    <div class="row g-3 mb-3">
                                        <div class="col-6">
                                            <div class="bg-light p-2 rounded border">
                                                <div class="text-secondary small">Total Capacity</div>
                                                <div class="fw-bold fs-5">${h.totalCapacity > 0 ? h.totalCapacity : h.totalBeds} Beds</div>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="bg-light p-2 rounded border">
                                                <div class="text-secondary small">Total Rooms</div>
                                                <div class="fw-bold fs-5">${h.totalRooms} Rooms</div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <div class="d-flex justify-content-between small fw-semibold mb-1">
                                            <span>Campus Infrastructure:</span>
                                            <span class="text-secondary">${h.address}</span>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <div class="small fw-semibold text-secondary mb-2">Amenities & Campus Utilities:</div>
                                        <div class="d-flex flex-wrap gap-2">
                                            <span class="badge bg-light text-dark border"><i class="bi bi-wifi me-1 text-primary"></i>WiFi 1 Gbps</span>
                                            <span class="badge bg-light text-dark border"><i class="bi bi-water me-1 text-info"></i>RO Purified Water</span>
                                            <span class="badge bg-light text-dark border"><i class="bi bi-sun me-1 text-warning"></i>Solar Hot Water</span>
                                            <span class="badge bg-light text-dark border"><i class="bi bi-camera-video me-1 text-danger"></i>24/7 CCTV</span>
                                            <span class="badge bg-light text-dark border"><i class="bi bi-shield-check me-1 text-success"></i>Guarded Gate</span>
                                            <span class="badge bg-light text-dark border"><i class="bi bi-cup-hot me-1 text-secondary"></i>Mess & Cafeteria</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="panel-footer bg-light p-3 border-top d-flex justify-content-between align-items-center">
                                    <div class="small text-secondary">
                                        <i class="bi bi-geo-alt me-1"></i>Main Academic Campus
                                    </div>
                                    <div class="d-flex gap-2">
                                        <a href="${pageContext.request.contextPath}/admin/rooms?hostelId=${h.id}" class="btn btn-outline-primary btn-sm fw-bold">
                                            <i class="bi bi-grid-3x3-gap me-1"></i>Bed Matrix
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/students?hostelId=${h.id}" class="btn btn-primary-custom btn-sm">
                                            <i class="bi bi-people me-1"></i>Residents
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <!-- Footer -->
            <jsp:include page="../common/footer.jsp" />
        </main>
    </div>

    <!-- Add Hostel Modal -->
    <div class="modal fade" id="addHostelModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <form action="${pageContext.request.contextPath}/admin/hostels" method="post">
                    <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">
                    <input type="hidden" name="action" value="createHostel">
                    <div class="modal-header bg-light">
                        <h5 class="modal-title fw-bold"><i class="bi bi-building-add me-2 text-primary"></i>Add Residential Complex</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label small fw-bold">Complex Name *</label>
                                <input type="text" name="name" class="form-control" placeholder="e.g. Tagore Hall of Residence" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Complex Code *</label>
                                <input type="text" name="code" class="form-control font-monospace text-uppercase" placeholder="e.g. TH-1" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Hostel Type *</label>
                                <select name="type" class="form-select" required>
                                    <option value="BOYS">Boys Hostel</option>
                                    <option value="GIRLS">Girls Hostel</option>
                                    <option value="CO_ED">Co-Ed Complex</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label small fw-bold">Campus Address / Location *</label>
                                <input type="text" name="address" class="form-control" placeholder="e.g. Sector 4, North Campus" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Contact Phone</label>
                                <input type="tel" name="phone" class="form-control" placeholder="+91 98765 00000">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Contact Email</label>
                                <input type="email" name="email" class="form-control" placeholder="hostel@campus.edu">
                            </div>
                            <div class="col-12">
                                <label class="form-label small fw-bold">Total Initial Capacity (Beds)</label>
                                <input type="number" name="capacity" class="form-control" value="100" min="10" required>
                                <small class="text-muted">A starter block (Block A) and floors will be automatically created.</small>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary-custom btn-sm"><i class="bi bi-check-circle me-1"></i>Create Complex</button>
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
