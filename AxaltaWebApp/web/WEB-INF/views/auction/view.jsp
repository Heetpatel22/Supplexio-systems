<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Auction - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
    body {
        background-color: rgb(245, 245, 250);
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
        background-color: rgb(0, 51, 153);
        color: white;
        font-weight: 600;
        border-radius: 10px 10px 0 0 !important;
    }

    .btn-primary {
        background-color: rgb(0, 51, 153);
        border-color: rgb(0, 51, 153);
    }

    .btn-primary:hover {
        background-color: #00307a;
        border-color: #00307a;
    }

    .btn-success {
        background-color: #28a745;
        border-color: #28a745;
    }

    .btn-success:hover {
        background-color: #218838;
        border-color: #1e7e34;
    }

    .table th {
        background-color: rgb(230, 230, 235);
    }

    .alert {
        border-radius: 10px;
    }

    .badge-active {
        background-color: #28a745;
        color: white;
    }

    .badge-completed {
        background-color: #6c757d;
        color: white;
    }

    .badge-cancelled {
        background-color: #dc3545;
        color: white;
    }

    .badge-warning {
        color: #212529;
    }

    .detail-label {
        font-weight: bold;
        color: #555;
    }

    .lowest-bid {
        background-color: rgba(40, 167, 69, 0.1);
    }

    .list-group-item {
        font-size: 1rem;
    }

    .table td,
    .table th {
        vertical-align: middle;
    }
</style>

</head>
<body>
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/auction">Reverse Auction Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">View Auction #${auction.id}</li>
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
        
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Auction Details</h4>
                        <div>
                            <a href="${pageContext.request.contextPath}/auction?action=edit&id=${auction.id}" class="btn btn-light btn-sm">
                                <i class="fas fa-edit"></i> Edit
                            </a>
                            <a href="${pageContext.request.contextPath}/auction?action=invite&id=${auction.id}" class="btn btn-light btn-sm">
                                <i class="fas fa-user-plus"></i> Invite Suppliers
                            </a>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <table>
                                    <tr>
                                        <td class="detail-label">Product:</td>
                                        <td>${auction.productName}</td>
                                    </tr>
                                    <tr>
                                        <td class="detail-label">Quantity:</td>
                                        <td>${auction.requiredQuantity} ${auction.unit}</td>
                                    </tr>
                                    <tr>
                                        <td class="detail-label">Starting Price:</td>
                                        <td><fmt:formatNumber value="${auction.startingPrice}" type="currency" currencySymbol="₹" /></td>
                                    </tr>
                                    <tr>
                                        <td class="detail-label">Current Price:</td>
                                        <td><fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="₹" /></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <p>
                                    <span class="detail-label">Status:</span>
                                    <c:choose>
                                        <c:when test="${auction.status == 'ACTIVE'}">
                                            <span class="badge badge-active">Active</span>
                                        </c:when>
                                        <c:when test="${auction.status == 'COMPLETED'}">
                                            <span class="badge badge-completed">Completed</span>
                                        </c:when>
                                        <c:when test="${auction.status == 'CANCELLED'}">
                                            <span class="badge badge-cancelled">Cancelled</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-secondary">${auction.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <p><span class="detail-label">Start Time:</span> <fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd HH:mm" /></p>
                                <p><span class="detail-label">End Time:</span> <fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm" /></p>
                                <p><span class="detail-label">Created:</span> <fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd" /></p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Bids</h4>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Supplier</th>
                                        <th>Bid Amount</th>
                                        <th>Bid Time</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="bidInfo" items="${bids}" varStatus="status">
                                        <c:set var="bid" value="${bidInfo[0]}" />
<c:set var="supplierName" value="${bidInfo[1]}" />
<c:set var="supplierEmail" value="${bidInfo[2]}" />
<tr class="${status.index == 0 ? 'lowest-bid' : ''}">
    <td>${supplierName} (${supplierEmail})</td>
    <td>&#8377;<fmt:formatNumber value="${bid.amount}" minFractionDigits="2" maxFractionDigits="2" /></td>
    <td><fmt:formatDate value="${bid.bidTime}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
    <td>
        <c:if test="${status.index == 0}">
            <span class="badge badge-success">Lowest Bid</span>
        </c:if>
    </td>
</tr>

                                    </c:forEach>
                                    <c:if test="${empty bids}">
                                        <tr>
                                            <td colspan="4" class="text-center">No bids have been placed yet</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Invited Suppliers</h4>
                        <a href="${pageContext.request.contextPath}/auction?action=invite&id=${auction.id}" class="btn btn-light btn-sm">
                            <i class="fas fa-user-plus"></i> Manage
                        </a>
                    </div>
                    <div class="card-body">
                        <ul class="list-group">
                            <c:forEach var="supplier" items="${invitedSuppliers}">
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    ${supplier.name} (${supplier.email})
                                    <span class="badge badge-primary badge-pill">
                                        <i class="fas fa-envelope"></i>
                                    </span>
                                </li>
                            </c:forEach>
                            <c:if test="${empty invitedSuppliers}">
                                <li class="list-group-item text-center">No suppliers have been invited yet</li>
                            </c:if>
                        </ul>
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
