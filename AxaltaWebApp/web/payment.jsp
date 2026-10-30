<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Management - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/payment.css">
    <!-- jsPDF for client-side PDF download -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.25/jspdf.plugin.autotable.min.js"></script>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <div class="main-content">
        <div class="header text-center">
            <div class="container">
                <h1>SUPPLEXIO</h1>
                <div class="divider"><span class="divider-text">Supply Chain Excellence</span></div>
                <p>Payment Management</p>
            </div>
        </div>

        <div class="container">

            <%-- ── Flash messages ───────────────────────────────────────── --%>
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle mr-2"></i>${sessionScope.success}
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <c:remove var="success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle mr-2"></i>${sessionScope.error}
                    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>
            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-danger">${requestScope.error}</div>
            </c:if>

            <%-- ═══════════════════════════════════════════════════════════
                 NEW-PAYMENT FORM  (only shown when auctionId param present)
                 This is driven by the servlet forwarding to this page with
                 "auction" and "supplier" request attributes set.
            ═══════════════════════════════════════════════════════════════ --%>
            <c:if test="${not empty auction}">
                <div class="row mb-4">
                    <div class="col-md-12">
                        <div class="card">
                            <div class="card-header">
                                <span><i class="fas fa-file-invoice-dollar"></i>
                                    Create Payment — Auction #${auction.id} &nbsp;|&nbsp; ${auction.product_name}
                                </span>
                                <a href="${pageContext.request.contextPath}/payment"
                                   class="btn btn-sm btn-outline-primary float-right">
                                    <i class="fas fa-arrow-left"></i> Back
                                </a>
                            </div>
                            <div class="card-body">
                                <%-- POST to /payment, action=create --%>
                                <form id="createPaymentForm"
                                      action="${pageContext.request.contextPath}/payment"
                                      method="post">
                                    <input type="hidden" name="action"     value="create">
                                    <input type="hidden" name="auctionId"  value="${auction.id}">
                                    <input type="hidden" name="supplierId" value="${supplier.id}">

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label><i class="fas fa-building text-primary mr-1"></i> Winning Supplier</label>
                                                <input type="text" class="form-control"
                                                       value="${not empty supplier ? supplier.name : 'Unknown'}" readonly>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label><i class="fas fa-dollar-sign text-success mr-1"></i> Amount</label>
                                                <div class="input-group">
                                                    <div class="input-group-prepend">
                                                        <span class="input-group-text">$</span>
                                                    </div>
                                                    <input type="number" class="form-control" name="amount"
                                                           value="${auction.winning_amount}" step="0.01" min="0" required>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label><i class="fas fa-credit-card text-primary mr-1"></i> Payment Method</label>
                                                <select class="form-control" name="paymentMethod" required>
                                                    <option value="">Select Method</option>
                                                    <option value="BANK_TRANSFER">Bank Transfer</option>
                                                    <option value="CREDIT_CARD">Credit Card</option>
                                                    <option value="CHECK">Check</option>
                                                    <option value="CASH">Cash</option>
                                                    <option value="PAYPAL">PayPal</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label><i class="fas fa-hashtag text-primary mr-1"></i> Transaction ID</label>
                                                <input type="text" class="form-control" name="transactionId"
                                                       placeholder="e.g. TXN-20250401-001">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label><i class="far fa-calendar-alt text-primary mr-1"></i> Payment Date</label>
                                                <input type="date" class="form-control" name="paymentDate"
                                                       value="${pageContext.response.encodeURL('')}" required
                                                       id="paymentDateInput">
                                                <script>
                                                    document.getElementById('paymentDateInput').valueAsDate = new Date();
                                                </script>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label><i class="fas fa-info-circle text-primary mr-1"></i> Status</label>
                                                <select class="form-control" name="status">
                                                    <option value="COMPLETED" selected>Completed</option>
                                                    <option value="PENDING">Pending</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label><i class="fas fa-comment-alt text-primary mr-1"></i> Remarks</label>
                                        <textarea class="form-control" name="remarks" rows="2"
                                                  placeholder="Optional notes..."></textarea>
                                    </div>

                                    <div class="d-flex justify-content-between mt-3">
                                        <a href="${pageContext.request.contextPath}/payment"
                                           class="btn btn-outline-secondary">
                                            <i class="fas fa-times mr-1"></i> Cancel
                                        </a>
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save mr-1"></i> Create Payment
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <%-- ═══════════════════════════════════════════════════════════
                 PAYMENT LIST  (shown when no auction form is active)
            ═══════════════════════════════════════════════════════════════ --%>
            <c:if test="${empty auction}">

                <%-- Statistics row --%>
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card text-center shadow-sm">
                            <div class="card-body">
                                <h2 class="text-success">${completedPaymentsCount}</h2>
                                <p class="mb-0 text-muted">Completed Payments</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center shadow-sm">
                            <div class="card-body">
                                <h2 class="text-warning">${pendingPaymentsCount}</h2>
                                <p class="mb-0 text-muted">Pending Payments</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center shadow-sm">
                            <div class="card-body">
                                <h2 class="text-primary">${totalPaymentsCount}</h2>
                                <p class="mb-0 text-muted">Total Payments</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center shadow-sm">
                            <div class="card-body">
                                <h2 class="text-info">
                                    $<fmt:formatNumber value="${totalPaymentAmount != null ? totalPaymentAmount : 0}"
                                                       pattern="#,##0.00"/>
                                </h2>
                                <p class="mb-0 text-muted">Total Amount</p>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Auctions awaiting payment --%>
                <c:if test="${not empty auctionWinners}">
                    <div class="card mb-4 border-warning">
                        <div class="card-header bg-warning text-white">
                            <i class="fas fa-exclamation-triangle mr-1"></i>
                            Completed Auctions Awaiting Payment (${fn:length(auctionWinners)})
                        </div>
                        <div class="card-body p-2">
                            <div class="table-responsive">
                                <table class="table table-sm mb-0">
                                    <thead>
                                        <tr>
                                            <th>Auction ID</th><th>Product</th>
                                            <th>Supplier</th><th>Winning Bid</th>
                                            <th>Ended</th><th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${auctionWinners}" var="w">
                                            <tr>
                                                <td>#${w.auctionId}</td>
                                                <td>${w.productName}</td>
                                                <td>${w.supplierName}</td>
                                                <td>$<fmt:formatNumber value="${w.winningAmount}" pattern="#,##0.00"/></td>
                                                <td><fmt:formatDate value="${w.endTime}" pattern="MMM dd, yyyy"/></td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/payment?action=new&auctionId=${w.auctionId}"
                                                       class="btn btn-sm btn-success">
                                                        <i class="fas fa-plus"></i> Create Payment
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </c:if>

                <%-- ── FILTER FORM ─────────────────────────────────────────────
                     FIX: method="get", param names match what servlet reads:
                          dateFrom, dateTo, status, method
                ─────────────────────────────────────────────────────────────── --%>
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="fas fa-filter mr-1"></i> Filter Payments
                    </div>
                    <div class="card-body">
                        <form id="filterForm"
                              action="${pageContext.request.contextPath}/payment"
                              method="get">

                            <div class="form-row align-items-end">
                                <div class="form-group col-md-2">
                                    <label for="filterStatus">Status</label>
                                    <select class="form-control" id="filterStatus" name="status">
                                        <option value="">All Statuses</option>
                                        <option value="COMPLETED"
                                            ${filterStatus == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                        <option value="PENDING"
                                            ${filterStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                                        <option value="FAILED"
                                            ${filterStatus == 'FAILED' ? 'selected' : ''}>Failed</option>
                                    </select>
                                </div>

                                <div class="form-group col-md-2">
                                    <label for="filterMethod">Payment Method</label>
                                    <select class="form-control" id="filterMethod" name="method">
                                        <option value="">All Methods</option>
                                        <option value="BANK_TRANSFER"
                                            ${filterMethod == 'BANK_TRANSFER' ? 'selected' : ''}>Bank Transfer</option>
                                        <option value="CREDIT_CARD"
                                            ${filterMethod == 'CREDIT_CARD' ? 'selected' : ''}>Credit Card</option>
                                        <option value="CHECK"
                                            ${filterMethod == 'CHECK' ? 'selected' : ''}>Check</option>
                                        <option value="CASH"
                                            ${filterMethod == 'CASH' ? 'selected' : ''}>Cash</option>
                                        <option value="PAYPAL"
                                            ${filterMethod == 'PAYPAL' ? 'selected' : ''}>PayPal</option>
                                    </select>
                                </div>

                                <%-- FIX: name="dateFrom" and name="dateTo" match servlet --%>
                                <div class="form-group col-md-2">
                                    <label for="filterDateFrom">Date From</label>
                                    <input type="date" class="form-control" id="filterDateFrom"
                                           name="dateFrom" value="${filterDateFrom}">
                                </div>

                                <div class="form-group col-md-2">
                                    <label for="filterDateTo">Date To</label>
                                    <input type="date" class="form-control" id="filterDateTo"
                                           name="dateTo" value="${filterDateTo}">
                                </div>

                                <div class="form-group col-md-2">
                                    <button type="submit" class="btn btn-primary btn-block">
                                        <i class="fas fa-search mr-1"></i> Apply
                                    </button>
                                </div>
                                <div class="form-group col-md-2">
                                    <a href="${pageContext.request.contextPath}/payment"
                                       class="btn btn-outline-secondary btn-block">
                                        <i class="fas fa-times mr-1"></i> Clear
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <%-- ── PAYMENT TABLE ──────────────────────────────────────── --%>
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="fas fa-list mr-1"></i> Payment Records
                            (${totalPaymentsCount} found)</span>
                        <c:if test="${not empty payments}">
                            <button id="exportPdfBtn" class="btn btn-sm btn-danger">
                                <i class="fas fa-file-pdf mr-1"></i> Export PDF
                            </button>
                        </c:if>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table id="paymentsTable" class="table table-hover mb-0">
                                <thead class="thead-light">
                                    <tr>
                                        <th>ID</th>
                                        <th>Auction</th>
                                        <th>Product</th>
                                        <th>Supplier</th>
                                        <th>Amount</th>
                                        <th>Method</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty payments}">
                                            <c:forEach items="${payments}" var="payment">
                                                <tr>
                                                    <td>#${payment.id}</td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/auction?action=view&id=${payment.auctionId}"
                                                           class="text-primary">
                                                            <i class="fas fa-gavel mr-1"></i>#${payment.auctionId}
                                                        </a>
                                                    </td>
                                                    <td>${payment.productName}</td>
                                                    <td>${payment.supplierName}</td>
                                                    <td class="font-weight-bold">
                                                        $<fmt:formatNumber value="${payment.amount}" pattern="#,##0.00"/>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${payment.paymentMethod == 'CREDIT_CARD'}">
                                                                <i class="fas fa-credit-card text-info mr-1"></i>Credit Card
                                                            </c:when>
                                                            <c:when test="${payment.paymentMethod == 'BANK_TRANSFER'}">
                                                                <i class="fas fa-university text-primary mr-1"></i>Bank Transfer
                                                            </c:when>
                                                            <c:when test="${payment.paymentMethod == 'CHECK'}">
                                                                <i class="fas fa-money-check text-success mr-1"></i>Check
                                                            </c:when>
                                                            <c:when test="${payment.paymentMethod == 'CASH'}">
                                                                <i class="fas fa-money-bill-wave text-success mr-1"></i>Cash
                                                            </c:when>
                                                            <c:when test="${payment.paymentMethod == 'PAYPAL'}">
                                                                <i class="fab fa-paypal text-info mr-1"></i>PayPal
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fas fa-money-bill-alt text-secondary mr-1"></i>${payment.paymentMethod}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${payment.paymentDate}"
                                                                        pattern="MMM dd, yyyy"/>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${payment.status == 'COMPLETED'}">
                                                                <span class="badge badge-success">
                                                                    <i class="fas fa-check mr-1"></i>Completed
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${payment.status == 'PENDING'}">
                                                                <span class="badge badge-warning text-dark">
                                                                    <i class="fas fa-clock mr-1"></i>Pending
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-danger">
                                                                    <i class="fas fa-times mr-1"></i>${payment.status}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div class="btn-group btn-group-sm">
                                                            <%-- View detail button (opens modal via JS) --%>
                                                            <button class="btn btn-info view-payment"
                                                                    data-id="${payment.id}"
                                                                    data-auction="${payment.auctionId}"
                                                                    data-supplier="${payment.supplierName}"
                                                                    data-product="${payment.productName}"
                                                                    data-amount="${payment.amount}"
                                                                    data-method="${payment.paymentMethod}"
                                                                    data-status="${payment.status}"
                                                                    data-txn="${payment.transactionId}"
                                                                    title="View Details">
                                                                <i class="fas fa-eye"></i>
                                                            </button>

                                                            <%-- FIX: Download Payment Slip button --%>
                                                            <button class="btn btn-secondary download-slip"
                                                                    title="Download Payment Slip"
                                                                    data-id="${payment.id}"
                                                                    data-auction="${payment.auctionId}"
                                                                    data-product="${payment.productName}"
                                                                    data-supplier="${payment.supplierName}"
                                                                    data-amount="${payment.amount}"
                                                                    data-method="${payment.paymentMethod}"
                                                                    data-status="${payment.status}"
                                                                    data-txn="${payment.transactionId}"
                                                                    data-date="<fmt:formatDate value="${payment.paymentDate}" pattern="MMM dd, yyyy"/>">
                                                                <i class="fas fa-download"></i>
                                                            </button>

                                                            <%-- Mark as completed (only for PENDING) --%>
                                                            <c:if test="${payment.status == 'PENDING'}">
                                                                <a href="${pageContext.request.contextPath}/payment?action=new&auctionId=${payment.auctionId}"
                                                                   class="btn btn-success"
                                                                   title="Mark as Completed">
                                                                    <i class="fas fa-check"></i>
                                                                </a>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="9" class="text-center py-5">
                                                    <div class="text-muted">
                                                        <i class="fas fa-inbox fa-3x mb-3"></i>
                                                        <p class="mb-1">No payments found</p>
                                                        <small>Try adjusting your filters or
                                                            <a href="${pageContext.request.contextPath}/payment">clear all filters</a>.
                                                        </small>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:if> <%-- end empty auction --%>

        </div><%-- container --%>
    </div><%-- main-content --%>

    <%-- ── View-detail modal ──────────────────────────────────────────────── --%>
    <div class="modal fade" id="paymentDetailModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-file-invoice-dollar mr-2"></i>Payment Details</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <table class="table table-sm">
                        <tr><th>Payment ID</th>    <td id="mdId"></td></tr>
                        <tr><th>Auction ID</th>    <td id="mdAuction"></td></tr>
                        <tr><th>Product</th>       <td id="mdProduct"></td></tr>
                        <tr><th>Supplier</th>      <td id="mdSupplier"></td></tr>
                        <tr><th>Amount</th>        <td id="mdAmount"></td></tr>
                        <tr><th>Method</th>        <td id="mdMethod"></td></tr>
                        <tr><th>Transaction ID</th><td id="mdTxn"></td></tr>
                        <tr><th>Status</th>        <td id="mdStatus"></td></tr>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>

    <%-- BUG-FIX #3 — payment-handler.js is NO LONGER included here.
         It was scanning document.body for JSON and wiping the entire page.
         All rendering is now done exclusively by JSP (server-side). --%>
    <script src="${pageContext.request.contextPath}/assets/js/payment.js"></script>

    <script>
    // ── DataTable init ────────────────────────────────────────────────────────
    $(function () {
        if ($('#paymentsTable tbody tr').length > 1 ||
            ($('#paymentsTable tbody tr').length === 1 &&
             $('#paymentsTable tbody tr td').length > 1)) {
            $('#paymentsTable').DataTable({
                order: [[0, 'desc']],
                pageLength: 25,
                language: { search: 'Search payments:' }
            });
        }

        // ── View-detail modal ─────────────────────────────────────────────────
        $(document).on('click', '.view-payment', function () {
            var btn = $(this);
            $('#mdId').text('#' + btn.data('id'));
            $('#mdAuction').text('#' + btn.data('auction'));
            $('#mdProduct').text(btn.data('product'));
            $('#mdSupplier').text(btn.data('supplier'));
            $('#mdAmount').text('$' + parseFloat(btn.data('amount')).toFixed(2));
            $('#mdMethod').text(btn.data('method'));
            $('#mdTxn').text(btn.data('txn') || '—');
            $('#mdStatus').text(btn.data('status'));
            $('#paymentDetailModal').modal('show');
        });

        // ── Per-row PDF slip (jsPDF) ──────────────────────────────────────────
        $(document).on('click', '.download-slip', function () {
            var btn   = $(this);
            var { jsPDF } = window.jspdf;
            var doc   = new jsPDF({ unit: 'mm', format: 'a5', orientation: 'portrait' });

            // Header
            doc.setFillColor(30, 136, 229);
            doc.rect(0, 0, 148, 30, 'F');
            doc.setTextColor(255, 255, 255);
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('SUPPLEXIO', 74, 14, { align: 'center' });
            doc.setFontSize(9);
            doc.setFont('helvetica', 'normal');
            doc.text('Payment Slip', 74, 22, { align: 'center' });

            // Body
            doc.setTextColor(50, 50, 50);
            var rows = [
                ['Payment ID',   '#' + btn.data('id')],
                ['Auction ID',   '#' + btn.data('auction')],
                ['Product',      btn.data('product')],
                ['Supplier',     btn.data('supplier')],
                ['Amount',       '$' + parseFloat(btn.data('amount')).toFixed(2)],
                ['Method',       btn.data('method')],
                ['Transaction',  btn.data('txn') || '—'],
                ['Date',         btn.data('date')],
                ['Status',       btn.data('status')]
            ];

            doc.autoTable({
                startY: 35,
                head: [['Field', 'Value']],
                body: rows,
                styles: { fontSize: 10, cellPadding: 4 },
                headStyles: { fillColor: [30, 136, 229] },
                alternateRowStyles: { fillColor: [245, 250, 255] },
                margin: { left: 10, right: 10 }
            });

            // Footer
            var pageH = doc.internal.pageSize.getHeight();
            doc.setFontSize(7);
            doc.setTextColor(150);
            doc.text('Generated by Supplexio — ' + new Date().toLocaleString(),
                     74, pageH - 5, { align: 'center' });

            doc.save('payment-slip-' + btn.data('id') + '.pdf');
        });

        // ── Full-list PDF export ──────────────────────────────────────────────
        $('#exportPdfBtn').on('click', function () {
            var { jsPDF } = window.jspdf;
            var doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });

            doc.setFillColor(30, 136, 229);
            doc.rect(0, 0, 297, 20, 'F');
            doc.setTextColor(255, 255, 255);
            doc.setFontSize(14);
            doc.text('SUPPLEXIO — Payment Report', 148, 13, { align: 'center' });

            var headers = ['ID','Auction','Product','Supplier','Amount','Method','Date','Status'];
            var rows = [];
            $('#paymentsTable tbody tr').each(function () {
                var cells = $(this).find('td');
                if (cells.length > 1) {
                    rows.push([
                        cells.eq(0).text().trim(),
                        cells.eq(1).text().trim(),
                        cells.eq(2).text().trim(),
                        cells.eq(3).text().trim(),
                        cells.eq(4).text().trim(),
                        cells.eq(5).text().trim(),
                        cells.eq(6).text().trim(),
                        cells.eq(7).text().trim()
                    ]);
                }
            });

            doc.autoTable({
                startY: 25,
                head: [headers],
                body: rows,
                styles: { fontSize: 8, cellPadding: 2 },
                headStyles: { fillColor: [30, 136, 229] }
            });

            doc.save('payments-export-' + new Date().toISOString().slice(0, 10) + '.pdf');
        });

        // ── Date validation on filter form ────────────────────────────────────
        $('#filterForm').on('submit', function (e) {
            var from = $('#filterDateFrom').val();
            var to   = $('#filterDateTo').val();
            if (from && to && from > to) {
                e.preventDefault();
                alert('Date From cannot be after Date To');
            }
        });
    });
    </script>
</body>
</html>
