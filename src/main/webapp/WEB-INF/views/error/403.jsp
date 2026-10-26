<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>403 Forbidden — HostelEase</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="d-flex align-items-center justify-content-center min-vh-100 bg-light p-4">
    <div class="text-center p-5 bg-white rounded-4 border shadow-sm" style="max-width: 500px;">
        <div class="text-danger mb-3" style="font-size: 64px;">
            <i class="bi bi-shield-x"></i>
        </div>
        <h1 class="h3 fw-bold text-dark mb-2">Access Forbidden (403)</h1>
        <p class="text-secondary small mb-4">You do not have the required role privileges to access this protected resource.</p>
        <a href="${pageContext.request.contextPath}/" class="btn btn-primary px-4 fw-bold">Return to Safe Harbor</a>
    </div>
</body>
</html>
