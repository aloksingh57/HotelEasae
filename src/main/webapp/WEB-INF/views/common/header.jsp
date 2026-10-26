<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="app-header">
    <div class="d-flex align-items-center gap-3">
        <button id="sidebarToggle" class="btn btn-sm btn-light d-lg-none" type="button">
            <i class="bi bi-list fs-5"></i>
        </button>
        <div class="header-title-wrap">
            <h1>${pageTitle != null ? pageTitle : 'Dashboard'}</h1>
            <p>${pageSubtitle != null ? pageSubtitle : 'Smart Hostel Management System'}</p>
        </div>
    </div>

    <div class="header-actions">
        <!-- Quick Notification Bell -->
        <div class="dropdown">
            <button class="btn btn-light rounded-circle p-2 position-relative" type="button" title="System Status: Normal">
                <i class="bi bi-bell text-secondary"></i>
                <span class="position-absolute top-0 start-100 translate-middle p-1 bg-success border border-light rounded-circle"></span>
            </button>
        </div>

        <!-- User Profile Pill -->
        <div class="d-flex align-items-center gap-2 bg-light px-3 py-2 rounded-pill border">
            <div class="user-avatar" style="width: 28px; height: 28px; font-size: 11px;">
                ${sessionScope.CURRENT_USER != null ? sessionScope.CURRENT_USER.firstName.substring(0, 1) : 'U'}
            </div>
            <span class="small fw-bold text-dark d-none d-md-inline">
                ${sessionScope.CURRENT_USER != null ? sessionScope.CURRENT_USER.fullName : 'Guest'}
            </span>
            <span class="user-role-badge">
                ${sessionScope.CURRENT_USER != null ? sessionScope.CURRENT_USER.role : 'USER'}
            </span>
        </div>
    </div>
</header>
