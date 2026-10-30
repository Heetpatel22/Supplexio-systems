<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Place Bid - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script>
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

    .btn-secondary {
        background-color: rgb(230, 230, 235);
        border-color: rgb(230, 230, 235);
        color: #333;
    }

    .btn-secondary:hover {
        background-color: #c8c8d0;
        border-color: #c8c8d0;
        color: #333;
    }

    .form-control:focus {
        border-color: rgb(0, 51, 153);
        box-shadow: 0 0 0 0.2rem rgba(0, 51, 153, 0.25);
    }

    .alert {
        border-radius: 10px;
    }

    .detail-label {
        font-weight: bold;
        color: #555;
    }

    .countdown {
        font-weight: bold;
        color: rgb(204, 51, 51);
    }

    .bid-form {
        background-color: #f8f9fa;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 20px;
    }

    .table th {
        background-color: rgb(230, 230, 235);
    }

    .lowest-bid {
        background-color: rgba(40, 167, 69, 0.1);
    }

    .your-bid {
        background-color: rgba(0, 51, 153, 0.1);
    }

    .table td,
    .table th {
        vertical-align: middle;
    }

    .chart-container {
        background: white;
        border-radius: 8px;
    }
</style>

</head>
<body>
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/bidding">Supplier Bidding Portal</a></li>
                <li class="breadcrumb-item active" aria-current="page">Place Bid</li>
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
                    <div class="card-header">
                        <h4 class="mb-0">Auction Details</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <p><span class="detail-label">Product:</span> ${auction.productName}</p>
                                <p><span class="detail-label">Quantity:</span> ${auction.requiredQuantity}</p>
                                <p><span class="detail-label">Starting Price:</span> <fmt:formatNumber value="${auction.startingPrice}" type="currency" currencySymbol="₹" /></p>
                                <p><span class="detail-label">Current Price:</span> <fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="₹" /></p>
                            </div>
                            <div class="col-md-6">
                                <p><span class="detail-label">Start Time:</span> <fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd HH:mm" /></p>
                                <p><span class="detail-label">End Time:</span> <fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm" /></p>
                                <p><span class="detail-label">Time Left:</span> <span class="countdown" data-end="${auction.endTime.time}">Loading...</span></p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Place Your Bid</h4>
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${isAuctionActive}">
                                <form method="post" action="${pageContext.request.contextPath}/bidding" class="mb-4">
                                    <input type="hidden" name="action" value="bid">
                                    <input type="hidden" name="auctionId" value="${auction.id}">
                                    
                                    <div class="form-group">
                                        <label for="amount">Your Bid Amount (₹)</label>
                                        <input type="number" step="0.01" min="0" class="form-control" id="amount" name="amount" required>
                                    </div>
                                    
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-gavel"></i> Place Bid
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-info">
                                    <c:choose>
                                        <c:when test="${currentTimeMillis < auction.startTime.time}">
                                            <i class="fas fa-clock"></i> This auction has not started yet. It will begin on 
                                            <fmt:formatDate value="${auction.startTime}" pattern="MMM dd, yyyy HH:mm:ss" />
                                        </c:when>
                                        <c:when test="${currentTimeMillis > auction.endTime.time || auction.status == 'COMPLETED'}">
                                            <i class="fas fa-flag-checkered"></i> This auction has ended on 
                                            <fmt:formatDate value="${auction.endTime}" pattern="MMM dd, yyyy HH:mm:ss" />
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-exclamation-circle"></i> This auction is not active
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Bid Price Trend</h4>
                    </div>
                    <div class="card-body">
                        <div class="chart-container" style="position: relative; height:300px; width:100%">
                            <canvas id="bidChart"></canvas>
                        </div>
                        <div class="text-center mt-3 mb-2">
                            <small class="text-muted">Showing bid price trend over time</small>
                        </div>
                    </div>
                </div>
                
                <div class="card">
    <div class="card-header">
        <h4 class="mb-0">All Bids</h4>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Supplier</th>
                        <th>Bid Amount</th>
                        <th>Bid Time</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="bidInfo" items="${allBids}" varStatus="status">
                        <c:set var="bid" value="${bidInfo[0]}" />
                        <c:set var="supplierName" value="${bidInfo[1]}" />
                        <tr class="${status.index == 0 ? 'lowest-bid' : ''}">
                            <td>${supplierName}</td>
                            <td>&#8377;<fmt:formatNumber value="${bid.amount}" minFractionDigits="2" maxFractionDigits="2" /></td>
                            <td><fmt:formatDate value="${bid.bidTime}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                            <td>
                                <c:choose>
                                    <c:when test="${status.index == 0}">
                                        <span class="badge badge-success">Lowest Bid</span>
                                    </c:when>
                                    <c:when test="${bid.supplierId == sessionScope.supplier.id}">
                                        <span class="badge badge-primary">Your Bid</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary">Competing Bid</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty allBids}">
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
                    <div class="card-header">
                        <h4 class="mb-0">Your Bids</h4>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Amount</th>
                                        <th>Time</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="bid" items="${supplierBids}">
                                        <tr>
                                            <td><fmt:formatNumber value="${bid.amount}" type="currency" currencySymbol="₹" /></td>
                                            <td><fmt:formatDate value="${bid.bidTime}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty supplierBids}">
                                        <tr>
                                            <td colspan="2" class="text-center">You haven't placed any bids yet</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Bidding Tips</h4>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item">
                                <i class="fas fa-info-circle text-primary"></i> Your bid must be lower than the current price.
                            </li>
                            <li class="list-group-item">
                                <i class="fas fa-info-circle text-primary"></i> The lowest bid wins the auction.
                            </li>
                            <li class="list-group-item">
                                <i class="fas fa-info-circle text-primary"></i> You can place multiple bids until the auction ends.
                            </li>
                            <li class="list-group-item">
                                <i class="fas fa-info-circle text-primary"></i> All bids are binding and cannot be withdrawn.
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        // Current time is already set by the servlet
        // Do not try to set JSP variables from JavaScript
        
        // Update countdown timer
        function updateCountdown() {
            const now = new Date().getTime();
            const element = document.querySelector('.countdown');
            const endTime = parseInt(element.getAttribute('data-end'));
            const timeLeft = endTime - now;
            
            if (timeLeft <= 0) {
                element.innerHTML = 'Auction ended';
                element.classList.add('text-danger');
                
                // Disable the bid form if auction has ended
                const bidForm = document.querySelector('.bid-form');
                if (bidForm) {
                    const submitButton = bidForm.querySelector('button[type="submit"]');
                    if (submitButton) {
                        submitButton.disabled = true;
                        submitButton.innerHTML = '<i class="fas fa-times"></i> Auction Ended';
                    }
                }
            } else {
                const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
                const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);
                
                let countdownText = '';
                if (days > 0) countdownText += days + 'd ';
                countdownText += hours + 'h ' + minutes + 'm ' + seconds + 's';
                
                element.innerHTML = countdownText;
            }
        }
        
        // Initial update and set interval
        updateCountdown();
        setInterval(updateCountdown, 1000);
        
        // Initialize bid chart
        document.addEventListener('DOMContentLoaded', function() {
            const ctx = document.getElementById('bidChart').getContext('2d');
            
            // Fetch bid data for the chart
            const auctionId = '${auction.id}';
            
            console.log('Fetching bid data for auction ID:', auctionId);
            $.ajax({
                url: '${pageContext.request.contextPath}/api/bids/chart',
                type: 'GET',
                data: { auctionId: auctionId },
                dataType: 'json',
                success: function(data) {
                    console.log('Received bid data:', data);
                    if (data && data.length > 0) {
                        renderBidChart(ctx, data);
                    } else {
                        console.log('No bid data available');
                        // No data available, show a message
                        document.querySelector('.chart-container').innerHTML = 
                            '<div class="alert alert-info text-center">No bid data available to display chart</div>';
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error loading bid data:', status, error);
                    console.log('Response:', xhr.responseText);
                    // Error handling
                    document.querySelector('.chart-container').innerHTML = 
                        '<div class="alert alert-danger text-center">Failed to load bid chart data</div>';
                }
            });
        });
        
        function renderBidChart(ctx, data) {
            // Process the data for the chart
            const labels = data.map(item => {
                const date = new Date(item.bidTime);
                return date.toLocaleString();
            });
            
            const amounts = data.map(item => item.bidAmount);
            
            // Create the chart
            const bidChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Bid Amounts',
                        data: amounts,
                        backgroundColor: 'rgba(0, 51, 153, 0.2)',
                        borderColor: 'rgba(0, 51, 153, 1)',
                        borderWidth: 2,
                        pointBackgroundColor: 'rgba(0, 51, 153, 1)',
                        pointRadius: 4,
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: false,
                            title: {
                                display: true,
                                text: 'Bid Amount (₹)'
                            },
                            ticks: {
                                callback: function(value) {
                                    return '₹' + value;
                                }
                            }
                        },
                        x: {
                            title: {
                                display: true,
                                text: 'Bid Time'
                            }
                        }
                    },
                    plugins: {
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return 'Bid Amount: ₹' + context.parsed.y;
                                }
                            }
                        },
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    }
                }
            });
        }
    </script>
</body>
</html>
