<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Details - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        :root {
            --supplexio-primary: rgb(0, 123, 255);
            --supplexio-secondary: rgb(108, 117, 125);
            --background-color: rgb(245, 245, 250);
            --accent-color: rgb(230, 230, 235);
        }
        
        body {
            background-color: var(--background-color);
            font-family: 'Segoe UI', Arial, sans-serif;
            padding-top: 20px;
        }
        
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        
        .card-header {
            background-color: var(--supplexio-primary);
            color: white;
            font-weight: 600;
            border-radius: 10px 10px 0 0 !important;
        }
        
        .btn-primary {
            background-color: var(--supplexio-primary);
            border-color: var(--supplexio-primary);
        }
        
        .btn-primary:hover {
            background-color: #0056b3;
            border-color: #0056b3;
        }
        
        .btn-success {
            background-color: #28a745;
            border-color: #28a745;
        }
        
        .btn-success:hover {
            background-color: #218838;
            border-color: #1e7e34;
        }
        
        .btn-warning {
            background-color: #ffc107;
            border-color: #ffc107;
        }
        
        .btn-warning:hover {
            background-color: #e0a800;
            border-color: #d39e00;
        }
        
        .badge-completed {
            background-color: #28a745;
        }
        
        .badge-pending {
            background-color: #ffc107;
            color: #212529;
        }
        
        .badge-failed {
            background-color: #dc3545;
        }
        
        .payment-detail-label {
            font-weight: 600;
            color: #495057;
        }
        
        .payment-detail-value {
            color: #212529;
        }
        
        .payment-history {
            max-height: 300px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/payment">Payment Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">Payment Details</li>
            </ol>
        </nav>
        
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
        
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h4 class="mb-0">Payment #${payment.id} Details</h4>
                <div>
                    <c:if test="${payment.status == 'PENDING'}">
                        <a href="${pageContext.request.contextPath}/payment?action=markCompleted&id=${payment.id}" 
                           class="btn btn-success btn-sm" onclick="return confirm('Mark this payment as completed?')">
                            <i class="fas fa-check"></i> Mark as Completed
                        </a>
                    </c:if>
                    <c:if test="${payment.status == 'PENDING'}">
                        <a href="${pageContext.request.contextPath}/payment?action=edit&id=${payment.id}" class="btn btn-primary btn-sm">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/payment?action=generateReceipt&id=${payment.id}" 
                       class="btn btn-warning btn-sm" target="_blank">
                        <i class="fas fa-file-pdf"></i> Generate Receipt
                    </a>
                </div>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <h5 class="mb-3">Payment Information</h5>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Payment ID:</div>
                            <div class="col-7 payment-detail-value">${payment.id}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Amount:</div>
                            <div class="col-7 payment-detail-value">
                                <fmt:formatNumber value="${payment.amount}" type="currency" currencySymbol="₹" />
                            </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Payment Method:</div>
                            <div class="col-7 payment-detail-value">${payment.paymentMethod}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Transaction ID:</div>
                            <div class="col-7 payment-detail-value">
                                ${not empty payment.transactionId ? payment.transactionId : '<span class="text-muted">N/A</span>'}
                            </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Payment Date:</div>
                            <div class="col-7 payment-detail-value">
                                <fmt:formatDate value="${payment.paymentDate}" pattern="yyyy-MM-dd" />
                            </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Due Date:</div>
                            <div class="col-7 payment-detail-value">
                                <c:choose>
                                    <c:when test="${not empty payment.dueDate}">
                                        <fmt:formatDate value="${payment.dueDate}" pattern="yyyy-MM-dd" />
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">N/A</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Status:</div>
                            <div class="col-7 payment-detail-value">
                                <c:choose>
                                    <c:when test="${payment.status == 'COMPLETED'}">
                                        <span class="badge badge-completed">Completed</span>
                                    </c:when>
                                    <c:when test="${payment.status == 'PENDING'}">
                                        <span class="badge badge-pending">Pending</span>
                                    </c:when>
                                    <c:when test="${payment.status == 'FAILED'}">
                                        <span class="badge badge-failed">Failed</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary">${payment.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <h5 class="mb-3">Related Information</h5>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Supplier:</div>
                            <div class="col-7 payment-detail-value">${supplierName}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Supplier Email:</div>
                            <div class="col-7 payment-detail-value">${supplierEmail}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Supplier Phone:</div>
                            <div class="col-7 payment-detail-value">${supplierPhone}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Auction:</div>
                            <div class="col-7 payment-detail-value">
                                <a href="${pageContext.request.contextPath}/auction?action=view&id=${auction.id}">
                                    ${auction.title}
                                </a>
                            </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Product:</div>
                            <div class="col-7 payment-detail-value">${auction.productName}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-5 payment-detail-label">Winning Bid:</div>
                            <div class="col-7 payment-detail-value">
                                <fmt:formatNumber value="${winningBid.bidAmount}" type="currency" currencySymbol="₹" />
                            </div>
                        </div>
                    </div>
                </div>
                
                <hr>
                
                <div class="row mt-3">
                    <div class="col-12">
                        <h5>Notes</h5>
                        <p class="mb-4">
                            ${not empty payment.notes ? payment.notes : '<span class="text-muted">No notes available</span>'}
                        </p>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-12">
                        <h5>Payment History</h5>
                        <div class="payment-history">
                            <table class="table table-sm table-striped">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Action</th>
                                        <th>Details</th>
                                        <th>User</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="history" items="${paymentHistory}">
                                        <tr>
                                            <td><fmt:formatDate value="${history.timestamp}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                                            <td>${history.action}</td>
                                            <td>${history.details}</td>
                                            <td>${history.user}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty paymentHistory}">
                                        <tr>
                                            <td colspan="4" class="text-center">No history available</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
