<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Interactive Bed Detail Modal -->
<div id="bedDetailModal" class="modal-overlay">
    <div class="modal-content-box">
        <div class="modal-header-custom">
            <h3 id="modalBedTitle"><i class="bi bi-door-closed text-primary me-2"></i>Bed Details</h3>
            <button type="button" class="modal-close-btn" data-close-modal>&times;</button>
        </div>
        <div class="modal-body-custom">
            <div class="d-flex align-items-center justify-content-between p-3 rounded mb-3 bg-light border">
                <div>
                    <div class="text-secondary small fw-bold text-uppercase">Allocation Status</div>
                    <div id="modalBedStatus" class="fw-bold fs-6 text-dark">ALLOCATED</div>
                </div>
                <div>
                    <div class="text-secondary small fw-bold text-uppercase text-end">Physical Presence</div>
                    <div id="modalPresenceBadge" class="badge-custom">PRESENT</div>
                </div>
            </div>

            <div class="mb-3">
                <label class="text-secondary small fw-bold text-uppercase d-block mb-1">Allocated Student</label>
                <div id="modalStudentName" class="fs-5 fw-bold text-dark">Rohan Sharma</div>
                <div class="small text-muted">Roll Number: <span id="modalRollNo" class="fw-semibold text-dark">CS23B101</span> &bull; Phone: <span id="modalPhone" class="fw-semibold text-dark">+91 98111 00001</span></div>
            </div>

            <!-- Temporary Vacation / Absence Notice -->
            <div id="modalAbsenceDetails" class="p-3 rounded border mb-3" style="display: none; background-color: #fffbeb; border-color: #fde68a;">
                <div class="d-flex align-items-center gap-2 text-warning-emphasis fw-bold small mb-2">
                    <i class="bi bi-calendar-event fs-5"></i>
                    <span>TEMPORARY VACANCY DETAILS (STUDENT AWAY)</span>
                </div>
                <div class="row g-2 small">
                    <div class="col-6">
                        <span class="text-secondary d-block">Leave Type</span>
                        <span id="modalLeaveType" class="fw-bold text-dark">Weekend Leave</span>
                    </div>
                    <div class="col-6">
                        <span class="text-secondary d-block">Departure Date</span>
                        <span id="modalDepartureTime" class="fw-bold text-dark">Oct 20, 2026</span>
                    </div>
                    <div class="col-12 mt-1">
                        <span class="text-secondary d-block">Expected Return</span>
                        <span id="modalReturnTime" class="fw-bold text-dark">Oct 25, 2026 (18:00)</span>
                    </div>
                </div>
                <div class="mt-2 small text-muted fst-italic">
                    * The bed remains assigned to this resident throughout leave. It cannot be permanently re-allocated.
                </div>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-4 pt-2 border-top">
                <button type="button" class="btn btn-secondary btn-sm px-3" data-close-modal>Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Toast Notifications Container -->
<div class="toast-container">
    <c:if test="${not empty param.msg}">
        <div class="toast-box success">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-check-circle-fill text-success fs-5"></i>
                <span class="small fw-semibold text-dark">
                    <c:choose>
                        <c:when test="${param.msg == 'allocated_success'}">Bed allocation completed successfully!</c:when>
                        <c:when test="${param.msg == 'transfer_success'}">Room transfer completed atomically!</c:when>
                        <c:when test="${param.msg == 'checkout_success'}">Permanent checkout recorded and bed freed!</c:when>
                        <c:when test="${param.msg == 'payment_recorded'}">Payment recorded & receipt issued successfully!</c:when>
                        <c:when test="${param.msg == 'invoice_created'}">Fee invoice generated and notification sent!</c:when>
                        <c:when test="${param.msg == 'departure_confirmed'}">Student checkout recorded. Student is now AWAY (Bed temporarily vacant).</c:when>
                        <c:when test="${param.msg == 'return_confirmed'}">Student check-in recorded. Student is now PRESENT.</c:when>
                        <c:when test="${param.msg == 'leave_approved'}">Leave request approved successfully!</c:when>
                        <c:when test="${param.msg == 'leave_rejected'}">Leave request rejected.</c:when>
                        <c:when test="${param.msg == 'leave_submitted'}">Leave request submitted for warden review.</c:when>
                        <c:when test="${param.msg == 'complaint_registered'}">Maintenance complaint registered successfully.</c:when>
                        <c:when test="${param.msg == 'status_updated'}">Ticket status updated successfully.</c:when>
                        <c:when test="${param.msg == 'visitor_entered'}">Visitor entry logged at security checkpoint.</c:when>
                        <c:when test="${param.msg == 'visitor_exited'}">Visitor exit recorded.</c:when>
                        <c:when test="${param.msg == 'payment_simulated_success'}">Simulation: Payment successful & receipt generated!</c:when>
                        <c:when test="${param.msg == 'student_created'}">New resident student registered successfully!</c:when>
                        <c:when test="${param.msg == 'student_updated'}">Resident student information updated successfully!</c:when>
                        <c:when test="${param.msg == 'user_status_toggled'}">User account status updated successfully!</c:when>
                        <c:when test="${param.msg == 'room_created'}">New room and bed units created successfully!</c:when>
                        <c:when test="${param.msg == 'bed_updated'}">Bed maintenance status updated!</c:when>
                        <c:when test="${param.msg == 'hostel_created'}">New residential complex created successfully!</c:when>
                        <c:when test="${param.msg == 'profile_updated'}">Contact profile updated successfully!</c:when>
                        <c:otherwise>Action completed successfully.</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <button type="button" class="btn-close btn-close-white small" onclick="this.closest('.toast-box').remove()"></button>
        </div>
    </c:if>

    <c:if test="${not empty param.error}">
        <div class="toast-box error">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-exclamation-triangle-fill text-danger fs-5"></i>
                <span class="small fw-semibold text-dark">
                    <c:choose>
                        <c:when test="${param.error == 'allocation_failed'}">Allocation failed: bed occupied or invalid student.</c:when>
                        <c:when test="${param.error == 'transfer_failed'}">Transfer failed: target bed is unavailable.</c:when>
                        <c:when test="${param.error == 'payment_failed'}">Payment processing failed.</c:when>
                        <c:when test="${param.error == 'student_exists'}">Student registration failed: username, email or roll number already exists.</c:when>
                        <c:when test="${param.error == 'update_failed'}">Update failed. Please check inputs.</c:when>
                        <c:when test="${param.error == 'room_create_failed'}">Room creation failed. Please check room number and floor.</c:when>
                        <c:when test="${param.error == 'bed_update_failed'}">Bed status update failed.</c:when>
                        <c:when test="${param.error == 'hostel_create_failed'}">Hostel creation failed. Code must be unique.</c:when>
                        <c:when test="${param.error == 'invalid_input'}">Invalid input parameters provided.</c:when>
                        <c:otherwise>Operation could not be completed. Please review input.</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <button type="button" class="btn-close btn-close-white small" onclick="this.closest('.toast-box').remove()"></button>
        </div>
    </c:if>
</div>

<!-- Bootstrap 5 Bundle JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<!-- Custom App JS -->
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/chart-init.js"></script>
