<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Management - Supplexio</title>
    
    <!-- Common CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/payment.css">
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>Payment Management</h2>
                <!-- Statistics button removed as requested -->
            </div>
            
            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${success}
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${error}
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </c:if>
            
            <div class="filter-panel">
                <form method="get" action="${pageContext.request.contextPath}/payment" class="form-row align-items-end">
                    <input type="hidden" name="action" value="filter">
                    
                    <div class="col-md-3 mb-2">
                        <label for="startDate">Start Date</label>
                        <input type="date" class="form-control" id="startDate" name="startDate" value="${startDate}">
                    </div>
                    
                    <div class="col-md-3 mb-2">
                        <label for="endDate">End Date</label>
                        <input type="date" class="form-control" id="endDate" name="endDate" value="${endDate}">
                    </div>
                    
                    <div class="col-md-2 mb-2">
                        <label for="status">Status</label>
                        <select class="form-control" id="status" name="status">
                            <option value="">All</option>
                            <option value="COMPLETED" ${statusFilter == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                            <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>Pending</option>
                            <option value="FAILED" ${statusFilter == 'FAILED' ? 'selected' : ''}>Failed</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2 mb-2">
                        <label for="paymentMethod">Payment Method</label>
                        <select class="form-control" id="paymentMethod" name="paymentMethod">
                            <option value="">All</option>
                            <option value="BANK_TRANSFER" ${paymentMethodFilter == 'BANK_TRANSFER' ? 'selected' : ''}>Bank Transfer</option>
                            <option value="CREDIT_CARD" ${paymentMethodFilter == 'CREDIT_CARD' ? 'selected' : ''}>Credit Card</option>
                            <option value="CHEQUE" ${paymentMethodFilter == 'CHEQUE' ? 'selected' : ''}>Cheque</option>
                            <option value="CASH" ${paymentMethodFilter == 'CASH' ? 'selected' : ''}>Cash</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2 mb-2">
                        <button type="submit" class="btn btn-primary btn-block">
                            <i class="fas fa-filter"></i> Filter
                        </button>
                    </div>
                </form>
            </div>
            
            <!-- Auction Winners Section -->
            <div class="card mb-4">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">Auction Winners</h4>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Auction ID</th>
                                    <th>Product</th>
                                    <th>Winning Supplier</th>
                                    <th>Winning Amount</th>
                                    <th>Payment Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
    <c:when test="${empty auctionWinners}">
        <tr>
            <td colspan="6" class="text-center">No payments pending</td>
        </tr>
    </c:when>
    <c:otherwise>
        <c:forEach var="winner" items="${auctionWinners}">
            <tr>
                <td>${winner.auctionId}</td>
                <td>${winner.productName}</td>
                <td>${winner.supplierName}</td>
                <td>&#8377;<fmt:formatNumber value="${winner.amount}" minFractionDigits="2" maxFractionDigits="2" /></td>
                <td><span class="badge badge-warning">Payment Pending</span></td>
                <td>
                    <a href="${pageContext.request.contextPath}/payment?action=new&auctionId=${winner.auctionId}&supplierId=${winner.supplierId}"
                       class="btn btn-sm btn-success">
                        <i class="fas fa-money-bill-wave"></i> Make Payment
                    </a>
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
            
            <!-- Payment List Section -->
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0"><i class="fas fa-history mr-2"></i>Payment History</h4>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Supplier</th>
                                    <th>Product</th>
                                    <th>Amount</th>
                                    <th>Payment Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty paymentHistory}">
                                        <tr>
                                            <td colspan="5" class="text-center">No payments found</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="payment" items="${paymentHistory}">
                                            <tr>
                                                <td>${payment.id}</td>
                                                <td>${payment.supplierName}</td>
                                                <td>${payment.productName}</td>
                                                <td><fmt:formatNumber value="${payment.amount}" type="currency" currencySymbol="₹" /></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${empty payment.paymentDate}">-</c:when>
                                                        <c:otherwise>
                                                            <fmt:formatDate value="${payment.paymentDate}" pattern="yyyy-MM-dd HH:mm:ss" />
                                                        </c:otherwise>
                                                    </c:choose>
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
    </div>
    
    <!-- Common JavaScript -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/payment.js"></script>
    <c:if test="${not empty sessionScope.success}">
<script>
    window.addEventListener('load', function () {
        alert('${sessionScope.success}');
    });
</script>
</c:if>

</body>
</html>
