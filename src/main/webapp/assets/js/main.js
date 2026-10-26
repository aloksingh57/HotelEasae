/**
 * HostelEase - Main Frontend Interactivity, Modal System, and Bed Visualizer
 */

document.addEventListener('DOMContentLoaded', function () {
    // 1. Mobile Sidebar Toggle
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.app-sidebar');
    if (sidebarToggle && sidebar) {
        sidebarToggle.addEventListener('click', function () {
            sidebar.classList.toggle('show');
        });
    }

    // 2. Interactive Bed Click Handlers (Occupancy & Absence Details Modal)
    const bedBoxes = document.querySelectorAll('.bed-box');
    const bedModal = document.getElementById('bedDetailModal');

    bedBoxes.forEach(box => {
        box.addEventListener('click', function () {
            const bedId = this.getAttribute('data-bed-id');
            const roomNumber = this.getAttribute('data-room-number') || 'N/A';
            const hostelName = this.getAttribute('data-hostel-name') || 'Hostel';
            const bedLabel = this.getAttribute('data-bed-label') || 'Bed';
            const allocationStatus = this.getAttribute('data-allocation-status') || 'UNALLOCATED';
            const studentName = this.getAttribute('data-student-name') || 'None';
            const rollNumber = this.getAttribute('data-roll-number') || 'N/A';
            const studentPhone = this.getAttribute('data-student-phone') || 'N/A';
            const presence = this.getAttribute('data-student-presence') || 'N/A';
            const leaveType = this.getAttribute('data-leave-type') || 'N/A';
            const departure = this.getAttribute('data-departure') || 'N/A';
            const returnDate = this.getAttribute('data-expected-return') || 'N/A';

            if (bedModal) {
                document.getElementById('modalBedTitle').textContent = `${hostelName} — Room ${roomNumber} (${bedLabel})`;
                document.getElementById('modalBedStatus').textContent = allocationStatus;
                document.getElementById('modalStudentName').textContent = studentName;
                document.getElementById('modalRollNo').textContent = rollNumber;
                document.getElementById('modalPhone').textContent = studentPhone;

                const presenceBadge = document.getElementById('modalPresenceBadge');
                presenceBadge.textContent = presence;
                presenceBadge.className = 'badge-custom ' + getPresenceBadgeClass(presence);

                // Vacation info block
                const absenceBlock = document.getElementById('modalAbsenceDetails');
                if (presence === 'AWAY' || presence === 'RETURN_OVERDUE' || presence === 'EXPECTED_TO_LEAVE') {
                    if (absenceBlock) {
                        absenceBlock.style.display = 'block';
                        document.getElementById('modalLeaveType').textContent = leaveType;
                        document.getElementById('modalDepartureTime').textContent = departure;
                        document.getElementById('modalReturnTime').textContent = returnDate;
                    }
                } else {
                    if (absenceBlock) absenceBlock.style.display = 'none';
                }

                // Show modal with animation
                bedModal.classList.add('active');
            }
        });
    });

    // Close Modal triggers
    document.querySelectorAll('[data-close-modal]').forEach(btn => {
        btn.addEventListener('click', function () {
            const modal = this.closest('.modal-overlay');
            if (modal) modal.classList.remove('active');
        });
    });

    window.addEventListener('click', function (e) {
        if (e.target.classList.contains('modal-overlay')) {
            e.target.classList.remove('active');
        }
    });

    // 3. Quick Table Client Search Filter
    const searchInputs = document.querySelectorAll('[data-table-filter]');
    searchInputs.forEach(input => {
        input.addEventListener('input', function () {
            const tableSelector = this.getAttribute('data-table-filter');
            const table = document.querySelector(tableSelector);
            if (!table) return;

            const query = this.value.toLowerCase().trim();
            const rows = table.querySelectorAll('tbody tr');

            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    });

    // 4. Auto-dismissing Toast Notifications
    const toasts = document.querySelectorAll('.toast-box');
    toasts.forEach(toast => {
        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(-10px)';
            toast.style.transition = 'all 0.3s ease';
            setTimeout(() => toast.remove(), 300);
        }, 4500);
    });

    // Helper: Presence Badge Class
    function getPresenceBadgeClass(presence) {
        switch (presence.toUpperCase()) {
            case 'PRESENT': return 'badge-present';
            case 'AWAY': return 'badge-away';
            case 'RETURN_OVERDUE': return 'badge-overdue';
            case 'EXPECTED_TO_LEAVE': return 'badge-expected';
            default: return 'badge-unallocated';
        }
    }
});
