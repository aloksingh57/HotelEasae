<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="app-sidebar">
    <div class="sidebar-header">
        <div class="brand-icon">
            <i class="bi bi-buildings"></i>
        </div>
        <div class="brand-name">
            Hostel<span>Ease</span>
        </div>
    </div>

    <div class="sidebar-user">
        <div class="user-avatar">
            ${sessionScope.CURRENT_USER != null ? sessionScope.CURRENT_USER.firstName.substring(0, 1) : 'U'}
        </div>
        <div class="user-info">
            <div class="user-name">${sessionScope.CURRENT_USER != null ? sessionScope.CURRENT_USER.fullName : 'Guest'}</div>
            <div class="user-role-badge">${sessionScope.CURRENT_USER != null ? sessionScope.CURRENT_USER.role : 'USER'}</div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <!-- ADMIN NAVIGATION -->
        <c:if test="${sessionScope.CURRENT_USER.role == 'ADMIN'}">
            <div class="nav-section-title">Administration</div>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item-link ${activePage == 'dashboard' ? 'active' : ''}">
                <i class="bi bi-grid-1x2"></i>
                <span>Executive Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/rooms" class="nav-item-link ${activePage == 'rooms' ? 'active' : ''}">
                <i class="bi bi-door-open"></i>
                <span>Room & Bed Matrix</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/allocations" class="nav-item-link ${activePage == 'allocations' ? 'active' : ''}">
                <i class="bi bi-arrow-left-right"></i>
                <span>Allocations & Transfers</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/hostels" class="nav-item-link ${activePage == 'hostels' ? 'active' : ''}">
                <i class="bi bi-building"></i>
                <span>Hostels & Blocks</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/students" class="nav-item-link ${activePage == 'students' ? 'active' : ''}">
                <i class="bi bi-people"></i>
                <span>Student Directory</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/fees" class="nav-item-link ${activePage == 'fees' ? 'active' : ''}">
                <i class="bi bi-receipt"></i>
                <span>Fee Invoices & Dues</span>
            </a>
            <a href="${pageContext.request.contextPath}/admin/reports" class="nav-item-link ${activePage == 'reports' ? 'active' : ''}">
                <i class="bi bi-bar-chart-line"></i>
                <span>Analytical Reports</span>
            </a>
        </c:if>

        <!-- WARDEN NAVIGATION -->
        <c:if test="${sessionScope.CURRENT_USER.role == 'WARDEN'}">
            <div class="nav-section-title">Warden Operations</div>
            <a href="${pageContext.request.contextPath}/warden/dashboard" class="nav-item-link ${activePage == 'dashboard' ? 'active' : ''}">
                <i class="bi bi-speedometer2"></i>
                <span>Hostel Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/warden/leaves" class="nav-item-link ${activePage == 'leaves' ? 'active' : ''}">
                <i class="bi bi-calendar-check"></i>
                <span>Leave Approvals</span>
            </a>
            <a href="${pageContext.request.contextPath}/warden/presence" class="nav-item-link ${activePage == 'presence' ? 'active' : ''}">
                <i class="bi bi-geo-alt"></i>
                <span>Gate Checkpoint & Return</span>
            </a>
            <a href="${pageContext.request.contextPath}/warden/rooms" class="nav-item-link ${activePage == 'rooms' ? 'active' : ''}">
                <i class="bi bi-grid-3x3"></i>
                <span>Room Matrix & Beds</span>
            </a>
            <a href="${pageContext.request.contextPath}/warden/visitors" class="nav-item-link ${activePage == 'visitors' ? 'active' : ''}">
                <i class="bi bi-person-badge"></i>
                <span>Visitor Management</span>
            </a>
            <a href="${pageContext.request.contextPath}/warden/complaints" class="nav-item-link ${activePage == 'complaints' ? 'active' : ''}">
                <i class="bi bi-tools"></i>
                <span>Maintenance Tickets</span>
            </a>
        </c:if>

        <!-- STUDENT NAVIGATION -->
        <c:if test="${sessionScope.CURRENT_USER.role == 'STUDENT'}">
            <div class="nav-section-title">Resident Portal</div>
            <a href="${pageContext.request.contextPath}/student/dashboard" class="nav-item-link ${activePage == 'dashboard' ? 'active' : ''}">
                <i class="bi bi-house-door"></i>
                <span>Resident Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/leaves" class="nav-item-link ${activePage == 'leaves' ? 'active' : ''}">
                <i class="bi bi-send-plus"></i>
                <span>Holiday / Leave Request</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/complaints" class="nav-item-link ${activePage == 'complaints' ? 'active' : ''}">
                <i class="bi bi-exclamation-octagon"></i>
                <span>Register Complaint</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/fees" class="nav-item-link ${activePage == 'fees' ? 'active' : ''}">
                <i class="bi bi-credit-card-2-front"></i>
                <span>Fee Invoices & Receipts</span>
            </a>
            <a href="${pageContext.request.contextPath}/student/profile" class="nav-item-link ${activePage == 'profile' ? 'active' : ''}">
                <i class="bi bi-person-vcard"></i>
                <span>Resident Profile</span>
            </a>
        </c:if>
    </nav>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout" class="logout-link">
            <i class="bi bi-box-arrow-left"></i>
            <span>Sign Out Securely</span>
        </a>
    </div>
</aside>
