<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplier Bidding Portal - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
    <style>
        .fixed-header-supplier {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            background: #003399;
            color: #fff;
            z-index: 9999; /* Increased for visibility */
            height: 64px;
            display: flex;
            align-items: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            border-bottom: 3px solid #ffeb3b; /* Debug: yellow border */
        }
        .fixed-header-supplier .header-content {
            width: 100%;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            height: 100%;
            padding-right: 32px;
        }
        .fixed-header-supplier .btn-po {
            font-weight: 700;
            min-width: 220px;
            font-size: 1.1rem;
            background: #ffeb3b !important; /* Debug: yellow background */
            color: #003399 !important;
            border: 2px solid #003399;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.04);
            transition: background 0.2s;
        }
        .fixed-header-supplier .btn-po:hover {
            background: #fff176 !important;
            color: #003399 !important;
        }
        .main-content-supplier {
            padding-top: 80px;
        }
        .main-header {
            background: #003399;
            color: #fff;
            padding: 2rem 0 1rem 0;
            text-align: center;
        }
        .main-header h1 {
            font-weight: 800;
            letter-spacing: 2px;
        }
        .main-header .subtitle {
            font-size: 1.2rem;
            font-weight: 400;
            color: #e0e0e0;
        }
        .po-btn-top {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: #f8f9fa;
            padding: 1rem 0 0.5rem 0;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid #e0e0e0;
        }
        .welcome-bar {
            background: #e9f7ef;
            border-left: 5px solid #17a2b8;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }
        .card-header {
            font-weight: 600;
        }
        .countdown {
            font-size: 1.1rem;
            font-weight: 600;
            color: #dc3545;
        }
        .current-price {
            font-size: 1.5rem;
            font-weight: 700;
            color: #003399;
        }
        .bid-form {
            background: #f1f8ff;
            padding: 1rem;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Supplier Bidding Portal</h2>
            <div>
                <a href="${pageContext.request.contextPath}/supplier-po-view" class="btn btn-warning font-weight-bold mr-2">
                    <i class="fas fa-file-invoice"></i> My Purchase Orders
                </a>
                <a href="${pageContext.request.contextPath}/bidding?action=logout" class="btn btn-outline-danger">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
        <c:if test="${supplier == null}">
            <!-- Login Form -->
            <div class="row justify-content-center mt-5">
                <div class="col-md-6">
                    <div class="card shadow">
                        <div class="card-header bg-primary text-white">Supplier Login</div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/bidding" method="post">
                                <input type="hidden" name="action" value="login">
                                <div class="form-group">
                                    <label for="email">Email</label>
                                    <input type="email" class="form-control" id="email" name="email" required>
                                </div>
                                <div class="form-group">
                                    <label for="company">Company Name</label>
                                    <input type="text" class="form-control" id="company" name="company" required>
                                </div>
                                <button type="submit" class="btn btn-primary btn-block">Login</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>
        <c:if test="${supplier != null}">
            <!-- Welcome Bar -->
            <div class="alert alert-info d-flex justify-content-between align-items-center mb-4">
                <div>
                    <strong>Welcome, ${supplier.name} (${supplier.company})</strong>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/bidding?action=logout" class="btn btn-outline-secondary btn-sm">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </div>
            <c:if test="${param.auctionId != null}">
                <!-- Auction Bidding Page -->
                <div class="row">
                    <div class="col-md-8 mb-4">
                        <div class="card shadow">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <span>Auction Details</span>
                                <span class="countdown" id="countdown" data-end="${auction.endTime}"></span>
                            </div>
                            <div class="card-body">
                                <h5>${auction.productName}</h5>
                                <table class="table table-sm mb-3">
                                    <tr><th>Auction ID:</th><td>${auction.id}</td></tr>
                                    <tr><th>Quantity Required:</th><td>${auction.requiredQuantity}</td></tr>
                                    <tr><th>Starting Price:</th><td>$<fmt:formatNumber value="${auction.startingPrice}" pattern="#.00"/></td></tr>
                                    <tr><th>Current Price:</th><td class="current-price">$<fmt:formatNumber value="${auction.currentPrice}" pattern="#.00"/></td></tr>
                                    <tr><th>Start Time:</th><td><fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd HH:mm"/></td></tr>
                                    <tr><th>End Time:</th><td><fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/></td></tr>
                                    <tr><th>Status:</th><td><span class="badge badge-${auction.status == 'ACTIVE' ? 'success' : 'secondary'}">${auction.status}</span></td></tr>
                                    <tr><th>Your Lowest Bid:</th><td><c:if test="${lowestBid != null}">$<fmt:formatNumber value="${lowestBid}" pattern="#.00"/></c:if><c:if test="${lowestBid == null}">No bids yet</c:if></td></tr>
                                </table>
                                <div class="bid-form mt-3">
                                    <h5>Place Your Bid</h5>
                                    <form id="bidForm" action="${pageContext.request.contextPath}/bidding" method="post">
                                        <input type="hidden" name="action" value="bid">
                                        <input type="hidden" name="auctionId" value="${auction.id}">
                                        <input type="hidden" name="supplierId" value="${supplier.id}">
                                        <div class="form-group">
                                            <label for="bidAmount">Your Bid Amount</label>
                                            <div class="input-group">
                                                <div class="input-group-prepend">
                                                    <span class="input-group-text">$</span>
                                                </div>
                                                <input type="number" class="form-control" id="bidAmount" name="amount" step="0.01" min="0" max="${auction.currentPrice}" required>
                                                <div class="input-group-append">
                                                    <button type="submit" class="btn btn-danger" id="bidButton">Place Bid</button>
                                                </div>
                                            </div>
                                            <small class="form-text text-muted">Your bid must be lower than the current price of $<fmt:formatNumber value="${auction.currentPrice}" pattern="#.00"/></small>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 mb-4">
                        <div class="card shadow mb-4">
                            <div class="card-header">Bid History</div>
                            <div class="card-body p-0">
                                <div class="bid-history" style="max-height:250px;overflow-y:auto;">
                                    <table class="table table-sm table-striped mb-0">
                                        <thead><tr><th>Supplier</th><th>Amount</th><th>Time</th></tr></thead>
                                        <tbody>
                                            <c:forEach items="${bids}" var="bid">
                                                <tr class="${bid.supplierId == supplier.id ? 'table-primary' : ''}">
                                                    <td><c:if test="${bid.supplierId == supplier.id}"><strong>You</strong></c:if><c:if test="${bid.supplierId != supplier.id}">Supplier #${bid.supplierId}</c:if></td>
                                                    <td>$<fmt:formatNumber value="${bid.amount}" pattern="#.00"/></td>
                                                    <td><fmt:formatDate value="${bid.bidTime}" pattern="HH:mm:ss"/></td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty bids}"><tr><td colspan="3" class="text-center">No bids yet</td></tr></c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="card shadow">
                            <div class="card-header">Bidding Rules</div>
                            <div class="card-body">
                                <ul class="mb-0">
                                    <li>Your bid must be lower than the current price</li>
                                    <li>Once placed, bids cannot be withdrawn</li>
                                    <li>The lowest bid at auction end wins</li>
                                    <li>Auction may be extended if bids are placed in the last 5 minutes</li>
                                    <li>All prices are in USD</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row mb-4">
                    <div class="col-md-12 text-center">
                        <a href="${pageContext.request.contextPath}/bidding" class="btn btn-primary">
                            <i class="fas fa-arrow-left"></i> Back to Auction List
                        </a>
                    </div>
                </div>
            </c:if>
            <c:if test="${param.auctionId == null}">
                <!-- Auction List -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <div class="card shadow">
                            <div class="card-header">Available Auctions</div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead><tr><th>ID</th><th>Product</th><th>Quantity</th><th>Current Price</th><th>End Time</th><th>Your Bid</th><th>Actions</th></tr></thead>
                                        <tbody>
                                            <c:forEach items="${auctions}" var="auction">
                                                <tr>
                                                    <td>${auction.id}</td>
                                                    <td>${auction.productName}</td>
                                                    <td>${auction.requiredQuantity}</td>
                                                    <td>$<fmt:formatNumber value="${auction.currentPrice}" pattern="#.00"/></td>
                                                    <td><fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/><c:if test="${auction.endingSoon}"><span class="badge badge-danger ml-2">Ending Soon</span></c:if></td>
                                                    <td><c:if test="${auction.yourBid != null}">$<fmt:formatNumber value="${auction.yourBid}" pattern="#.00"/><c:if test="${auction.yourBidWinning}"><span class="badge badge-success ml-1">Lowest</span></c:if></c:if><c:if test="${auction.yourBid == null}">No bid</c:if></td>
                                                    <td><a href="${pageContext.request.contextPath}/bidding?auctionId=${auction.id}" class="btn btn-sm btn-danger"><i class="fas fa-gavel"></i> Bid Now</a></td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty auctions}"><tr><td colspan="7" class="text-center">No active auctions available for your company</td></tr></c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Bidding History -->
                <div class="row mb-4">
                    <div class="col-md-12">
                        <div class="card shadow">
                            <div class="card-header">Your Bidding History</div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead><tr><th>Auction ID</th><th>Product</th><th>Your Lowest Bid</th><th>Winning Bid</th><th>Status</th><th>Result</th></tr></thead>
                                        <tbody>
                                            <c:forEach items="${biddingHistory}" var="history">
                                                <tr>
                                                    <td>${history.auctionId}</td>
                                                    <td>${history.productName}</td>
                                                    <td>$<fmt:formatNumber value="${history.yourBid}" pattern="#.00"/></td>
                                                    <td>$<fmt:formatNumber value="${history.winningBid}" pattern="#.00"/></td>
                                                    <td><span class="badge badge-${history.status == 'ACTIVE' ? 'success' : history.status == 'COMPLETED' ? 'secondary' : 'danger'}">${history.status}</span></td>
                                                    <td><c:if test="${history.status == 'COMPLETED'}"><c:if test="${history.yourBid == history.winningBid}"><span class="badge badge-success">Won</span></c:if><c:if test="${history.yourBid != history.winningBid}"><span class="badge badge-secondary">Lost</span></c:if></c:if><c:if test="${history.status != 'COMPLETED'}">-</c:if></td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty biddingHistory}"><tr><td colspan="6" class="text-center">No bidding history available</td></tr></c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </c:if>
        <div class="row mb-4">
            <div class="col-md-12 text-center">
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                    <i class="fas fa-home"></i> Back to Dashboard
                </a>
            </div>
        </div>
    </div>
    <footer class="footer text-center mt-4">
        <div class="container">
            <p>&copy; 2025 Supplexio. All rights reserved.</p>
        </div>
    </footer>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function() {
            // Countdown timer for auction
            function updateCountdown() {
                var countdownElement = document.getElementById('countdown');
                if (!countdownElement) return;
                var endTime = new Date(countdownElement.getAttribute('data-end')).getTime();
                var now = new Date().getTime();
                var distance = endTime - now;
                if (distance <= 0) {
                    countdownElement.innerHTML = "AUCTION ENDED";
                    if(document.getElementById('bidButton')) document.getElementById('bidButton').disabled = true;
                    if(document.getElementById('bidAmount')) document.getElementById('bidAmount').disabled = true;
                    return;
                }
                var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                var countdownText = "";
                if (days > 0) countdownText += days + "d ";
                countdownText += hours.toString().padStart(2, '0') + ":" + minutes.toString().padStart(2, '0') + ":" + seconds.toString().padStart(2, '0');
                countdownElement.innerHTML = "Time Remaining: " + countdownText;
                if (distance < 5 * 60 * 1000) {
                    countdownElement.style.color = '#dc3545';
                    countdownElement.style.fontWeight = '700';
                }
            }
            if (document.getElementById('countdown')) {
                updateCountdown();
                setInterval(updateCountdown, 1000);
            }
            // Form validation for bid
            $('#bidForm').submit(function(e) {
                var bidAmount = parseFloat($('#bidAmount').val());
                var currentPrice = parseFloat('${auction.currentPrice}');
                if (bidAmount >= currentPrice) {
                    alert('Your bid must be lower than the current price of $' + currentPrice.toFixed(2));
                    e.preventDefault();
                    return false;
                }
                return true;
            });
            // Auto-refresh bid history every 30 seconds
            function refreshBidHistory() {
                if (window.location.href.includes('auctionId')) {
                    $.ajax({
                        url: '${pageContext.request.contextPath}/bidding',
                        type: 'GET',
                        data: { action: 'refreshBids', auctionId: '${param.auctionId}' },
                        success: function(response) {
                            if (response && response.html) {
                                $('.bid-history').html(response.html);
                                if (response.currentPrice) {
                                    $('.current-price').text('$' + parseFloat(response.currentPrice).toFixed(2));
                                    $('#bidAmount').attr('max', response.currentPrice);
                                }
                            }
                        }
                    });
                }
            }
            if (window.location.href.includes('auctionId')) {
                setInterval(refreshBidHistory, 30000);
            }
        });
    </script>
</body>
</html>
