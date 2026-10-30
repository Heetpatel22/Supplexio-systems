<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplier Bidding Portal - Axalta Coating Systems</title>
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
            transition: transform 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
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

        .btn-danger {
            background-color: rgb(204, 51, 51);
            border-color: rgb(204, 51, 51);
        }

        .btn-danger:hover {
            background-color: #b32e2e;
            border-color: #b32e2e;
        }

        .alert {
            border-radius: 10px;
        }

        .supplier-info {
            background-color: rgb(230, 230, 235);
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        .supplier-name {
            font-weight: 600;
            color: rgb(0, 51, 153);
        }

        .countdown {
            font-weight: bold;
            color: rgb(204, 51, 51);
        }

        .no-auctions {
            text-align: center;
            padding: 50px 0;
            color: #666;
        }

        .no-auctions i {
            font-size: 3rem;
            color: rgb(230, 230, 235);
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Supplier Bidding Portal</h2>
            <div>
                <button id="showPOBtn" type="button" class="btn btn-warning font-weight-bold mr-2">
                    <i class="fas fa-file-invoice"></i> My Purchase Orders
                </button>
                <a href="${pageContext.request.contextPath}/bidding?action=logout" class="btn btn-outline-danger">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>

        <div id="purchaseOrdersSection" style="display:none; width:100%; max-width:1100px;">
            <c:if test="${not empty purchaseOrders}">
                <div class="card mb-4">
                    <div class="card-header bg-warning text-dark d-flex justify-content-between align-items-center">
                        <span><i class="fas fa-file-invoice"></i> My Purchase Orders</span>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-striped mb-0">
                                <thead>
                                    <tr>
                                        <th>PO Number</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Quantity</th>
                                        <th>Amount</th>
                                        <th>GST (7.5%)</th>
                                        <th>Total (incl. GST)</th>
                                        <th>Supplier Name</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="po" items="${purchaseOrders}">
                                        <tr>
                                            <td>${po.poNumber}</td>
                                            <td><fmt:formatDate value="${po.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${po.status eq 'CONFIRMED'}">
                                                        <span class="badge badge-success">CONFIRMED</span>
                                                    </c:when>
                                                    <c:when test="${po.status eq 'SENT'}">
                                                        <span class="badge badge-primary">SENT</span>
                                                    </c:when>
                                                    <c:when test="${po.status eq 'DELIVERED'}">
                                                        <span class="badge badge-info">DELIVERED</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-warning">${po.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${po.quantity}</td>
                                            <td>&#8377;<fmt:formatNumber value="${po.amount}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                            <td>&#8377;<fmt:formatNumber value="${po.amount * 0.075}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                            <td>&#8377;<fmt:formatNumber value="${po.amount * 1.075}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                            <td>${po.supplierName}</td>
                                            <td>
                                                <c:if test="${po.status eq 'PENDING' or po.status eq 'SENT'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/supplier-po-view" style="display:inline;">
                                                        <input type="hidden" name="poId" value="${po.id}">
                                                        <button type="submit" class="btn btn-success btn-sm">Confirm Order</button>
                                                    </form>
                                                </c:if>

                                                <a href="${pageContext.request.contextPath}/download-po-pdf?poId=${po.id}" class="btn btn-outline-primary btn-sm ml-1">
                                                    <i class="fas fa-download"></i> PDF
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

            <c:if test="${empty purchaseOrders}">
                <div class="alert alert-info text-center">
                    <i class="fas fa-info-circle"></i> You have no purchase orders yet.
                </div>
            </c:if>
        </div>

        <div class="supplier-info">
            <div class="row">
                <div class="col-md-6">
                    <p class="mb-1">Welcome, <span class="supplier-name">${supplier.name}</span></p>
                    <p class="mb-1"><strong>Address:</strong> ${supplier.address}</p>
                </div>
                <div class="col-md-6 text-md-right">
                    <p class="mb-1"><strong>Email:</strong> ${supplier.email}</p>
                    <p class="mb-1"><strong>Phone:</strong> ${supplier.phone}</p>
                </div>
            </div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>

        <h4 class="mb-3">Active Auctions</h4>

        <div class="row">
            <c:forEach var="auction" items="${auctions}">
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100">
                        <div class="card-header">
                            <h5 class="mb-0">${auction.productName}</h5>
                        </div>
                        <div class="card-body d-flex flex-column">
                            <p><strong>Quantity:</strong> ${auction.requiredQuantity}</p>
                            <p><strong>Current Price:</strong> &#8377;<fmt:formatNumber value="${auction.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/></p>
                            <p><strong>End Time:</strong> <fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/></p>
                            <p><strong>Time Left:</strong> <span class="countdown" data-end="${auction.endTime.time}">Loading...</span></p>

                            <a href="${pageContext.request.contextPath}/bidding?action=view&id=${auction.id}" class="btn btn-primary mt-auto">
                                <i class="fas fa-gavel"></i> Place Bid
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <c:if test="${empty auctions}">
                <div class="col-12">
                    <div class="no-auctions">
                        <i class="fas fa-search"></i>
                        <h4>No Active Auctions</h4>
                        <p>You don't have any active auctions to participate in at the moment.</p>
                        <p>Please check back later or contact Axalta Coating Systems if you believe this is an error.</p>
                    </div>
                </div>
            </c:if>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        function updateCountdowns() {
            var now = new Date().getTime();

            document.querySelectorAll('.countdown').forEach(function(element) {
                var endTime = parseInt(element.getAttribute('data-end'));
                var timeLeft = endTime - now;

                if (timeLeft <= 0) {
                    element.innerHTML = 'Auction ended';
                    element.classList.add('text-danger');
                } else {
                    var days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
                    var hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    var minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);

                    var countdownText = '';
                    if (days > 0) {
                        countdownText += days + 'd ';
                    }
                    countdownText += hours + 'h ' + minutes + 'm ' + seconds + 's';

                    element.innerHTML = countdownText;
                }
            });
        }

        updateCountdowns();
        setInterval(updateCountdowns, 1000);

        document.getElementById('showPOBtn').addEventListener('click', function() {
            var section = document.getElementById('purchaseOrdersSection');
            if (section.style.display === 'none' || section.style.display === '') {
                section.style.display = 'block';
                this.classList.add('active');
            } else {
                section.style.display = 'none';
                this.classList.remove('active');
            }
        });
    </script>
</body>
</html>
