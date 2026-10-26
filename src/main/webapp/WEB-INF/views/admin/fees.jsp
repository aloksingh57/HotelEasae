<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Financial & Fee Management" scope="request" />
<c:set var="pageSubtitle" value="Track hostel fee invoices, record offline and gateway receipts, and audit collection status" scope="request" />
<c:set var="activePage" value="fees" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fee Management — HostelEase</title>
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
                <!-- Notifications from redirects -->
                <c:if test="${param.msg == 'payment_recorded'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-check-circle-fill fs-5 me-2"></i>
                        <div><strong>Payment Recorded!</strong> The transaction was posted and an official digital receipt has been generated.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'payment_failed'}">
                    <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill fs-5 me-2"></i>
                        <div><strong>Payment Failed:</strong> Unable to process the payment. Please verify the amount and student record.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Financial Stats Cards -->
                <div class="stat-grid mb-4">
                    <div class="stat-card">
                        <div class="stat-icon icon-primary"><i class="bi bi-receipt-cutoff"></i></div>
                        <div>
                            <div class="stat-value">₹<fmt:formatNumber value="${summary.totalBilled}" pattern="#,##0" /></div>
                            <div class="stat-label">Total Invoiced Amount</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-success"><i class="bi bi-cash-stack"></i></div>
                        <div>
                            <div class="stat-value text-success">₹<fmt:formatNumber value="${summary.totalCollected}" pattern="#,##0" /></div>
                            <div class="stat-label">Total Collected Revenue</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-warning"><i class="bi bi-hourglass-split"></i></div>
                        <div>
                            <div class="stat-value text-warning">₹<fmt:formatNumber value="${summary.totalPending}" pattern="#,##0" /></div>
                            <div class="stat-label">Pending / Unpaid Dues</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-danger"><i class="bi bi-exclamation-circle-fill"></i></div>
                        <div>
                            <div class="stat-value text-danger">₹<fmt:formatNumber value="${summary.totalOverdue}" pattern="#,##0" /></div>
                            <div class="stat-label">Overdue Outstanding</div>
                        </div>
                    </div>
                </div>

                <!-- Filter Toolbar -->
                <div class="filter-toolbar mb-4">
                    <form action="${pageContext.request.contextPath}/admin/fees" method="get" class="d-flex flex-wrap align-items-center gap-3 flex-grow-1">
                        <div class="d-flex align-items-center gap-2">
                            <label class="small fw-bold text-secondary text-uppercase mb-0">Hostel:</label>
                            <select name="hostelId" class="form-select-custom">
                                <option value="">All Hostels</option>
                                <c:forEach var="h" items="${hostels}">
                                    <option value="${h.id}" ${selectedHostelId == h.id ? 'selected' : ''}>${h.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="d-flex align-items-center gap-2">
                            <label class="small fw-bold text-secondary text-uppercase mb-0">Status:</label>
                            <select name="status" class="form-select-custom">
                                <option value="">All Invoices</option>
                                <option value="PENDING" ${selectedStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                                <option value="PARTIALLY_PAID" ${selectedStatus == 'PARTIALLY_PAID' ? 'selected' : ''}>Partially Paid</option>
                                <option value="PAID" ${selectedStatus == 'PAID' ? 'selected' : ''}>Fully Paid</option>
                                <option value="OVERDUE" ${selectedStatus == 'OVERDUE' ? 'selected' : ''}>Overdue</option>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-primary-custom btn-sm">
                            <i class="bi bi-filter me-1"></i>Apply Filter
                        </button>

                        <c:if test="${not empty selectedHostelId || not empty selectedStatus}">
                            <a href="${pageContext.request.contextPath}/admin/fees" class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-x-circle me-1"></i>Reset
                            </a>
                        </c:if>
                    </form>

                    <div class="d-flex align-items-center gap-2">
                        <input type="text" id="quickFeeFilter" class="form-control form-control-sm" style="width: 220px;" placeholder="Search student or invoice...">
                        <button type="button" class="btn btn-primary-custom btn-sm fw-bold" data-bs-toggle="modal" data-bs-target="#generateInvoiceModal">
                            <i class="bi bi-file-earmark-plus-fill me-1"></i>Generate Invoice
                        </button>
                    </div>
                </div>

                <!-- Invoices Table Card -->
                <div class="panel-card">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-wallet2 text-primary"></i> Fee Invoices & Payment Ledger (${invoices.size()})
                        </div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0" id="invoicesTable">
                                <thead>
                                    <tr>
                                        <th>Invoice #</th>
                                        <th>Resident Student</th>
                                        <th>Hostel & Room</th>
                                        <th>Billing Details</th>
                                        <th>Amount</th>
                                        <th>Balance</th>
                                        <th>Due Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty invoices}">
                                            <tr>
                                                <td colspan="9" class="text-center py-5">
                                                    <div class="empty-state">
                                                        <i class="bi bi-receipt display-4 text-secondary mb-3 d-block"></i>
                                                        <h5 class="fw-bold">No Invoices Found</h5>
                                                        <p class="text-secondary small">No billing records matched your filter criteria.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="inv" items="${invoices}">
                                                <tr>
                                                    <td>
                                                        <span class="badge bg-light text-dark font-monospace border px-2 py-1">${inv.invoiceNumber}</span>
                                                        <div class="small text-secondary mt-1">Issued: ${inv.createdAt != null ? inv.createdAt.toString().substring(0, 10) : 'N/A'}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold">${inv.studentName}</div>
                                                        <div class="small text-secondary font-monospace">${inv.studentRegistrationNumber}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold text-primary">${inv.hostelName}</div>
                                                        <div class="small text-secondary">Room ${inv.roomNumber}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold">${inv.title != null ? inv.title : 'Hostel & Mess Fee'}</div>
                                                        <div class="small text-secondary">Term: ${inv.sessionName != null ? inv.sessionName : '2026-27'}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold">₹<fmt:formatNumber value="${inv.totalAmount}" pattern="#,##0.00" /></div>
                                                        <div class="small text-success">Paid: ₹<fmt:formatNumber value="${inv.paidAmount}" pattern="#,##0.00" /></div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold ${inv.balanceAmount > 0 ? 'text-danger' : 'text-success'}">
                                                            ₹<fmt:formatNumber value="${inv.balanceAmount}" pattern="#,##0.00" />
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <span class="small ${inv.balanceAmount > 0 && inv.status == 'OVERDUE' ? 'text-danger fw-bold' : 'text-secondary'}">
                                                            ${inv.dueDate}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${inv.status == 'PAID'}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                                                    <i class="bi bi-check-circle-fill me-1"></i>Paid
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${inv.status == 'PARTIALLY_PAID'}">
                                                                <span class="badge bg-info-subtle text-info border border-info-subtle px-2 py-1">
                                                                    <i class="bi bi-clock-history me-1"></i>Partial
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${inv.status == 'OVERDUE'}">
                                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1 animate-pulse">
                                                                    <i class="bi bi-exclamation-circle-fill me-1"></i>Overdue
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1">
                                                                    <i class="bi bi-hourglass-split me-1"></i>Pending
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${inv.balanceAmount > 0}">
                                                            <button type="button" class="btn btn-outline-success btn-sm fw-bold"
                                                                    onclick="openPaymentModal(${inv.id}, ${inv.studentId}, '${inv.studentName}', '${inv.invoiceNumber}', ${inv.balanceAmount})">
                                                                <i class="bi bi-credit-card me-1"></i>Pay
                                                            </button>
                                                        </c:if>
                                                        <c:if test="${inv.balanceAmount <= 0}">
                                                            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">
                                                                <i class="bi bi-printer"></i>
                                                            </button>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <jsp:include page="../common/footer.jsp" />
        </main>
    </div>

    <!-- Record Payment Modal -->
    <div class="modal fade" id="recordPaymentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title fw-bold"><i class="bi bi-cash-coin me-2"></i>Record Offline Payment</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/admin/fees" method="post">
                    <input type="hidden" name="action" value="recordPayment">
                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                    <input type="hidden" name="invoiceId" id="payModalInvoiceId">
                    <input type="hidden" name="studentId" id="payModalStudentId">

                    <div class="modal-body p-4">
                        <div class="bg-light p-3 rounded mb-3 border">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="text-secondary small">Resident:</span>
                                <strong id="payModalStudentName"></strong>
                            </div>
                            <div class="d-flex justify-content-between mb-1">
                                <span class="text-secondary small">Invoice Ref:</span>
                                <span class="font-monospace fw-bold" id="payModalInvoiceNum"></span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-secondary small">Outstanding Due:</span>
                                <span class="fw-bold text-danger fs-6" id="payModalBalanceDisplay"></span>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Payment Amount (₹) <span class="text-danger">*</span></label>
                            <input type="number" step="0.01" min="1" name="amount" id="payModalAmount" class="form-control form-control-lg fw-bold" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Payment Mode <span class="text-danger">*</span></label>
                            <select name="paymentMethod" class="form-select" required>
                                <option value="UPI">UPI / QR Code</option>
                                <option value="BANK_TRANSFER">NEFT / RTGS Bank Transfer</option>
                                <option value="CASH">Cash Deposit at Warden Office</option>
                                <option value="CHEQUE">Bank Cheque / DD</option>
                                <option value="ONLINE_CARD">Debit / Credit Card</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Transaction / UTR Reference <span class="text-danger">*</span></label>
                            <input type="text" name="transactionReference" class="form-control" placeholder="e.g. UTR8912389123 or REC-CASH-001" required>
                        </div>
                    </div>

                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success btn-sm fw-bold">
                            <i class="bi bi-check-circle me-1"></i>Confirm & Generate Receipt
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Generate Invoice Modal -->
    <div class="modal fade" id="generateInvoiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="bi bi-file-earmark-plus-fill me-2"></i>Generate Student Fee Invoice</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/admin/fees" method="post">
                    <input type="hidden" name="action" value="createInvoice">
                    <input type="hidden" name="csrfToken" value="${csrfToken != null ? csrfToken : sessionScope.CSRF_TOKEN}">

                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-semibold small text-uppercase">Select Resident Student <span class="text-danger">*</span></label>
                            <select name="studentId" class="form-select" required>
                                <option value="">-- Choose Student --</option>
                                <c:forEach var="st" items="${students}">
                                    <option value="${st.id}">${st.fullName} (${st.registrationNumber}) — ${st.currentHostelName != null ? st.currentHostelName : 'Unallocated'}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold small text-uppercase">Fee Invoice Amount (₹) <span class="text-danger">*</span></label>
                            <input type="number" step="0.01" min="1" name="amount" class="form-control form-control-lg fw-bold" placeholder="e.g. 25000" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold small text-uppercase">Payment Due Date <span class="text-danger">*</span></label>
                            <input type="date" name="dueDate" class="form-control" value="2026-11-15" required>
                        </div>

                        <div class="small text-muted">
                            <i class="bi bi-info-circle me-1"></i>An official email and SMS notification will be automatically dispatched to both the student and the hostel warden upon generation.
                        </div>
                    </div>

                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary-custom btn-sm fw-bold">
                            <i class="bi bi-send-check me-1"></i>Issue Invoice & Notify
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script>
        document.getElementById('quickFeeFilter')?.addEventListener('keyup', function() {
            const query = this.value.toLowerCase();
            document.querySelectorAll('#invoicesTable tbody tr').forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(query) ? '' : 'none';
            });
        });

        function openPaymentModal(invoiceId, studentId, studentName, invoiceNum, balance) {
            document.getElementById('payModalInvoiceId').value = invoiceId;
            document.getElementById('payModalStudentId').value = studentId;
            document.getElementById('payModalStudentName').textContent = studentName;
            document.getElementById('payModalInvoiceNum').textContent = invoiceNum;
            document.getElementById('payModalBalanceDisplay').textContent = '₹' + Number(balance).toLocaleString('en-IN', {minimumFractionDigits: 2});
            document.getElementById('payModalAmount').value = balance;
            document.getElementById('payModalAmount').max = balance;

            new bootstrap.Modal(document.getElementById('recordPaymentModal')).show();
        }
    </script>
</body>
</html>
