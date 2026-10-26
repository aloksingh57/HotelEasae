<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In — HostelEase Smart Hostel Management</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@500;600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Custom Style -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: radial-gradient(circle at 10% 20%, rgba(37, 99, 235, 0.12) 0%, transparent 45%),
                        radial-gradient(circle at 90% 80%, rgba(99, 102, 241, 0.12) 0%, transparent 45%),
                        linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            padding: 20px;
        }
        .login-card {
            width: 100%;
            max-width: 480px;
            background: rgba(255, 255, 255, 0.96);
            backdrop-filter: blur(16px);
            border-radius: var(--radius-lg);
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4);
            padding: 40px;
            animation: fadeInEntrance 0.4s ease-out;
        }
        .demo-pill-btn {
            font-size: 11px;
            font-weight: 700;
            padding: 6px 12px;
            border-radius: var(--radius-full);
            border: 1px solid var(--slate-300);
            background: #ffffff;
            color: var(--navy-700);
            cursor: pointer;
            transition: var(--transition-fast);
        }
        .demo-pill-btn:hover {
            background: var(--blue-600);
            color: #ffffff;
            border-color: var(--blue-600);
            transform: translateY(-1px);
        }
    </style>
</head>
<body>

    <div class="login-card">
        <div class="text-center mb-4">
            <a href="${pageContext.request.contextPath}/" class="text-decoration-none d-inline-flex align-items-center gap-2 mb-2">
                <div class="brand-icon" style="width: 44px; height: 44px; font-size: 22px;">
                    <i class="bi bi-buildings"></i>
                </div>
                <span class="fs-3 fw-bold text-dark">Hostel<span class="text-primary">Ease</span></span>
            </a>
            <h2 class="fs-4 fw-bold text-dark mb-1">Welcome Back</h2>
            <p class="text-secondary small">Sign in to access your administrative, warden, or resident dashboard</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger py-2 px-3 small d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-exclamation-circle-fill fs-5"></i>
                <div>${errorMessage}</div>
            </div>
        </c:if>

        <c:if test="${param.msg == 'session_expired'}">
            <div class="alert alert-warning py-2 px-3 small d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-clock-history fs-5"></i>
                <div>Your session has expired. Please sign in again.</div>
            </div>
        </c:if>

        <c:if test="${param.msg == 'logged_out'}">
            <div class="alert alert-success py-2 px-3 small d-flex align-items-center gap-2 mb-4" role="alert">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <div>You have been signed out safely.</div>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm">
            <input type="hidden" name="redirect" value="<c:out value='${param.redirect}'/>">

            <div class="mb-3">
                <label for="usernameInput" class="form-label small fw-bold text-secondary text-uppercase">Username or Email</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-person"></i></span>
                    <input type="text" class="form-control border-start-0 ps-0" id="usernameInput" name="username" value="${enteredUsername != null ? enteredUsername : ''}" placeholder="e.g. admin or student1@hostelease.com" required autocomplete="username">
                </div>
            </div>

            <div class="mb-4">
                <label for="passwordInput" class="form-label small fw-bold text-secondary text-uppercase">Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                    <input type="password" class="form-control border-start-0 ps-0" id="passwordInput" name="password" placeholder="Enter password" required autocomplete="current-password">
                    <button class="btn btn-outline-secondary border-start-0" type="button" id="togglePassword">
                        <i class="bi bi-eye"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-3 shadow-sm mb-4">
                <i class="bi bi-box-arrow-in-right me-2"></i>Sign In to Portal
            </button>
        </form>

        <!-- Quick Demo Fill Section -->
        <div class="pt-3 border-top">
            <div class="small fw-bold text-secondary text-uppercase mb-2 text-center">Quick Demo Login Pre-fills</div>
            <div class="d-flex flex-wrap justify-content-center gap-2">
                <button type="button" class="demo-pill-btn" onclick="fillDemo('admin', 'Admin@123')">
                    <i class="bi bi-shield-fill text-primary me-1"></i>Admin
                </button>
                <button type="button" class="demo-pill-btn" onclick="fillDemo('warden.boys', 'Warden@123')">
                    <i class="bi bi-person-badge-fill text-success me-1"></i>Warden Boys
                </button>
                <button type="button" class="demo-pill-btn" onclick="fillDemo('warden.girls', 'Warden@123')">
                    <i class="bi bi-person-badge-fill text-info me-1"></i>Warden Girls
                </button>
                <button type="button" class="demo-pill-btn" onclick="fillDemo('student1@hostelease.com', 'Student@123')">
                    <i class="bi bi-person-fill text-dark me-1"></i>Resident (Present)
                </button>
                <button type="button" class="demo-pill-btn" onclick="fillDemo('student2@hostelease.com', 'Student@123')">
                    <i class="bi bi-airplane-fill text-warning me-1"></i>Resident (Away)
                </button>
                <button type="button" class="demo-pill-btn" onclick="fillDemo('student3@hostelease.com', 'Student@123')">
                    <i class="bi bi-clock-fill text-danger me-1"></i>Resident (Overdue)
                </button>
            </div>
        </div>

        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/" class="text-secondary small text-decoration-none">
                &larr; Back to Public Overview
            </a>
        </div>
    </div>

    <script>
        function fillDemo(username, password) {
            document.getElementById('usernameInput').value = username;
            document.getElementById('passwordInput').value = password;
        }

        document.getElementById('togglePassword').addEventListener('click', function () {
            const pwdInput = document.getElementById('passwordInput');
            const icon = this.querySelector('i');
            if (pwdInput.type === 'password') {
                pwdInput.type = 'text';
                icon.classList.replace('bi-eye', 'bi-eye-slash');
            } else {
                pwdInput.type = 'password';
                icon.classList.replace('bi-eye-slash', 'bi-eye');
            }
        });
    </script>
</body>
</html>
