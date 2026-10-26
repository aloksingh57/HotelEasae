<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Fee Invoices & Payments" scope="request" />
<c:set var="pageSubtitle" value="Track hostel residency charges, download fee receipts, and pay online through secure gateway" scope="request" />
<c:set var="activePage" value="fees" scope="request" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fee Portal — HostelEase</title>
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
                <c:if test="${param.msg == 'payment_simulated_success'}">
                    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-patch-check-fill fs-5 me-2"></i>
                        <div><strong>Payment Successful!</strong> Transaction processed and official electronic receipt issued.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${param.error == 'payment_simulation_failed'}">
                    <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4" role="alert">
                        <i class="bi bi-exclamation-triangle-fill fs-5 me-2"></i>
                        <div><strong>Payment Failed:</strong> Gateway simulation could not complete. Please retry.</div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Fee Metrics Calculation -->
                <c:set var="studentTotalBilled" value="0" />
                <c:set var="studentTotalPaid" value="0" />
                <c:set var="studentTotalBalance" value="0" />
                <c:forEach var="inv" items="${invoices}">
                    <c:set var="studentTotalBilled" value="${studentTotalBilled + inv.totalAmount}" />
                    <c:set var="studentTotalPaid" value="${studentTotalPaid + inv.paidAmount}" />
                    <c:set var="studentTotalBalance" value="${studentTotalBalance + inv.balanceAmount}" />
                </c:forEach>

                <div class="stat-grid mb-4">
                    <div class="stat-card">
                        <div class="stat-icon icon-primary"><i class="bi bi-receipt"></i></div>
                        <div>
                            <div class="stat-value">₹<fmt:formatNumber value="${studentTotalBilled}" pattern="#,##0" /></div>
                            <div class="stat-label">Total Invoiced Fees</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-success"><i class="bi bi-check2-circle"></i></div>
                        <div>
                            <div class="stat-value text-success">₹<fmt:formatNumber value="${studentTotalPaid}" pattern="#,##0" /></div>
                            <div class="stat-label">Total Paid Amount</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon icon-warning"><i class="bi bi-hourglass-split"></i></div>
                        <div>
                            <div class="stat-value ${studentTotalBalance > 0 ? 'text-danger' : 'text-success'}">
                                ₹<fmt:formatNumber value="${studentTotalBalance}" pattern="#,##0" />
                            </div>
                            <div class="stat-label">Outstanding Dues</div>
                        </div>
                    </div>
                </div>

                <!-- Fee Invoices Section -->
                <div class="panel-card mb-4">
                    <div class="panel-header d-flex justify-content-between align-items-center">
                        <div class="panel-title">
                            <i class="bi bi-wallet2 text-primary"></i> Hostel Fee Invoices (${invoices.size()})
                        </div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Invoice #</th>
                                        <th>Term / Session</th>
                                        <th>Description</th>
                                        <th>Total Bill</th>
                                        <th>Paid</th>
                                        <th>Balance Due</th>
                                        <th>Due Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty invoices}">
                                            <tr>
                                                <td colspan="9" class="text-center py-5 text-secondary">
                                                    No fee invoices generated for your account.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="inv" items="${invoices}">
                                                <tr>
                                                    <td>
                                                        <span class="badge bg-light text-dark font-monospace border px-2 py-1">${inv.invoiceNumber}</span>
                                                    </td>
                                                    <td class="fw-semibold">${inv.sessionName != null ? inv.sessionName : '2026-27'}</td>
                                                    <td>
                                                        <div class="fw-semibold">${inv.title != null ? inv.title : 'Hostel & Mess Fee'}</div>
                                                    </td>
                                                    <td class="fw-bold">₹<fmt:formatNumber value="${inv.totalAmount}" pattern="#,##0.00" /></td>
                                                    <td class="fw-bold text-success">₹<fmt:formatNumber value="${inv.paidAmount}" pattern="#,##0.00" /></td>
                                                    <td class="fw-bold ${inv.balanceAmount > 0 ? 'text-danger' : 'text-success'}">
                                                        ₹<fmt:formatNumber value="${inv.balanceAmount}" pattern="#,##0.00" />
                                                    </td>
                                                    <td>
                                                        <span class="small ${inv.balanceAmount > 0 && inv.status == 'OVERDUE' ? 'text-danger fw-bold' : 'text-secondary'}">
                                                            ${inv.dueDate}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${inv.status == 'PAID'}">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle">Paid</span>
                                                            </c:when>
                                                            <c:when test="${inv.status == 'PARTIALLY_PAID'}">
                                                                <span class="badge bg-info-subtle text-info border border-info-subtle">Partial</span>
                                                            </c:when>
                                                            <c:when test="${inv.status == 'OVERDUE'}">
                                                                <span class="badge bg-danger-subtle text-danger border border-danger-subtle animate-pulse">Overdue</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-warning-subtle text-warning border border-warning-subtle">Pending</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${inv.balanceAmount > 0}">
                                                            <button type="button" class="btn btn-primary-custom btn-sm fw-bold"
                                                                    onclick="openStudentPaymentModal(${inv.id}, '${inv.invoiceNumber}', ${inv.balanceAmount})">
                                                                <i class="bi bi-credit-card me-1"></i>Pay Online
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

                <!-- Past Payment Receipts -->
                <div class="panel-card">
                    <div class="panel-header">
                        <div class="panel-title"><i class="bi bi-receipt text-primary"></i> Payment Receipts & History (${payments.size()})</div>
                    </div>
                    <div class="panel-body p-0">
                        <div class="table-responsive">
                            <table class="table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Receipt #</th>
                                        <th>Date & Time</th>
                                        <th>Amount Paid</th>
                                        <th>Payment Mode</th>
                                        <th>Transaction Ref</th>
                                        <th>Status</th>
                                        <th>Print</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty payments}">
                                            <tr>
                                                <td colspan="7" class="text-center py-4 text-secondary">
                                                    No past payments recorded on this account.
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="p" items="${payments}">
                                                <tr>
                                                    <td><span class="badge bg-light text-dark font-monospace border px-2 py-1">${p.receiptNumber}</span></td>
                                                    <td class="small text-secondary">${p.paymentDate != null ? p.paymentDate.toString().substring(0, 16) : 'N/A'}</td>
                                                    <td class="fw-bold text-success">₹<fmt:formatNumber value="${p.amount}" pattern="#,##0.00" /></td>
                                                    <td><span class="badge bg-light text-dark border">${p.paymentMode}</span></td>
                                                    <td class="font-monospace small">${p.transactionReference}</td>
                                                    <td><span class="badge bg-success-subtle text-success">Successful</span></td>
                                                    <td>
                                                        <button type="button" class="btn btn-outline-secondary btn-sm" onclick="window.print()">
                                                            <i class="bi bi-printer"></i>
                                                        </button>
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

    <!-- Student Payment Modal -->
    <div class="modal fade" id="studentPayModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="bi bi-shield-check me-2"></i>Instant Online Payment Gateway</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/student/fees" method="post">
                    <input type="hidden" name="action" value="simulatePayment">
                    <input type="hidden" name="invoiceId" id="modalStudentInvoiceId">
                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">

                    <div class="modal-body p-4">
                        <div class="p-3 bg-light rounded border mb-3">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="text-secondary small">Invoice Number:</span>
                                <strong class="font-monospace" id="modalStudentInvoiceNum"></strong>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-secondary small">Payable Balance:</span>
                                <span class="fw-bold fs-5 text-danger" id="modalStudentBalanceDisplay"></span>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Payment Amount (₹) <span class="text-danger">*</span></label>
                            <input type="number" step="0.01" min="1" name="amount" id="modalStudentAmount" class="form-control form-control-lg fw-bold" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Choose Payment Method <span class="text-danger">*</span></label>
                            <select name="paymentMethod" class="form-select" required>
                                <option value="UPI">UPI Instant (Google Pay / PhonePe / Paytm)</option>
                                <option value="ONLINE_CARD">Debit / Credit Card</option>
                                <option value="BANK_TRANSFER">Net Banking (All Indian Banks)</option>
                            </select>
                        </div>

                        <div class="p-2 bg-success-subtle border border-success-subtle rounded small text-success text-center">
                            <i class="bi bi-lock-fill me-1"></i>256-Bit SSL Encrypted End-to-End Simulation
                        </div>
                    </div>

                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success btn-sm fw-bold">
                            <i class="bi bi-check-circle me-1"></i>Authorize & Pay Now
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
        function openStudentPaymentModal(invoiceId, invoiceNum, balance) {
            document.getElementById('modalStudentInvoiceId').value = invoiceId;
            document.getElementById('modalStudentInvoiceNum').textContent = invoiceNum;
            document.getElementById('modalStudentBalanceDisplay').textContent = '₹' + Number(balance).toLocaleString('en-IN', {minimumFractionDigits: 2});
            document.getElementById('modalStudentAmount').value = balance;
            document.getElementById('modalStudentAmount').max = balance;

            new bootstrap.Modal(document.getElementById('studentPayModal')).show();
        }
    </script>
</body>
</html>
