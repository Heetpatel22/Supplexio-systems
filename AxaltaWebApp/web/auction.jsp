<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reverse Auction Management - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auction.css">
    <!-- Chart.js for bid trend charts -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
    <div class="header text-center">
        <div class="container">
            <h1>SUPPLEXIO</h1>
            <div class="divider">
                <span class="divider-text">Procurement Excellence</span>
            </div>
            <p>Reverse Auction Management</p>
        </div>
    </div>
    
    <div class="container">
        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span>Reverse Auctions</span>
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addAuctionModal">
                            <i class="fas fa-plus"></i> Create New Auction
                        </button>
                    </div>
                    <div class="card-body">
                        <ul class="nav nav-tabs mb-3" id="auctionTabs" role="tablist">
                            <li class="nav-item">
                                <a class="nav-link active" id="active-tab" data-toggle="tab" href="#active" role="tab">Active</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="completed-tab" data-toggle="tab" href="#completed" role="tab">Completed</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="cancelled-tab" data-toggle="tab" href="#cancelled" role="tab">Cancelled</a>
                            </li>
                        </ul>
                        
                        <div class="tab-content" id="auctionTabContent">
                            <div class="tab-pane fade show active" id="active" role="tabpanel">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Product</th>
                                                <th>Quantity</th>
                                                <th>Starting Price</th>
                                                <th>Current Price</th>
                                                <th>Start Time</th>
                                                <th>End Time</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${activeAuctions}" var="auction">
                                                <tr>
                                                    <td>${auction.id}</td>
                                                    <td>${auction.productName}</td>
                                                    <td>${auction.requiredQuantity}</td>
                                                    <td>$<fmt:formatNumber value="${auction.startingPrice}" pattern="#,##0.00"/></td>
                                                    <td>$<fmt:formatNumber value="${auction.currentPrice}" pattern="#,##0.00"/></td>
                                                    <td><fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                                    <td><fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                                    <td>
                                                        <button class="btn btn-sm btn-primary view-auction" data-id="${auction.id}">
                                                            <i class="fas fa-eye"></i>
                                                        </button>
                                                        <button class="btn btn-sm btn-danger cancel-auction" data-id="${auction.id}">
                                                            <i class="fas fa-times"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <div class="tab-pane fade" id="completed" role="tabpanel">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Product</th>
                                                <th>Quantity</th>
                                                <th>Starting Price</th>
                                                <th>Final Price</th>
                                                <th>End Time</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${completedAuctions}" var="auction">
                                                <tr>
                                                    <td>${auction.id}</td>
                                                    <td>${auction.productName}</td>
                                                    <td>${auction.requiredQuantity}</td>
                                                    <td>$<fmt:formatNumber value="${auction.startingPrice}" pattern="#,##0.00"/></td>
                                                    <td>$<fmt:formatNumber value="${auction.currentPrice}" pattern="#,##0.00"/></td>
                                                    <td><fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                                    <td>
                                                        <button class="btn btn-sm btn-primary view-auction" data-id="${auction.id}">
                                                            <i class="fas fa-eye"></i>
                                                        </button>
                                                        <button class="btn btn-sm btn-success create-payment" data-id="${auction.id}">
                                                            <i class="fas fa-dollar-sign"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <div class="tab-pane fade" id="cancelled" role="tabpanel">
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Product</th>
                                                <th>Quantity</th>
                                                <th>Starting Price</th>
                                                <th>Cancel Time</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${cancelledAuctions}" var="auction">
                                                <tr>
                                                    <td>${auction.id}</td>
                                                    <td>${auction.productName}</td>
                                                    <td>${auction.requiredQuantity}</td>
                                                    <td>$<fmt:formatNumber value="${auction.startingPrice}" pattern="#,##0.00"/></td>
                                                    <td><fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                                    <td>
                                                        <button class="btn btn-sm btn-primary view-auction" data-id="${auction.id}">
                                                            <i class="fas fa-eye"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-12 text-center">
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                    <i class="fas fa-home"></i> Back to Dashboard
                </a>
            </div>
        </div>
    </div>
    
    <!-- Create Auction Modal -->
    <div class="modal fade" id="addAuctionModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Create New Reverse Auction</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form id="addAuctionForm" action="${pageContext.request.contextPath}/auction" method="post">
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="productId">Product</label>
                            <select class="form-control" id="productId" name="productId" required>
                                <option value="">Select Product</option>
                                <c:forEach items="${products}" var="product">
                                    <option value="${product.id}">${product.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="quantity">Quantity Required</label>
                            <input type="number" class="form-control" id="quantity" name="quantity" min="1" required>
                        </div>
                        <div class="form-group">
                            <label for="startingPrice">Starting Price</label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">$</span>
                                </div>
                                <input type="number" class="form-control" id="startingPrice" name="startingPrice" step="0.01" min="0" required>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="startDate">Start Date</label>
                                    <input type="date" class="form-control" id="startDate" name="startDate" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="startTime">Start Time</label>
                                    <input type="time" class="form-control" id="startTime" name="startTime" required>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="endDate">End Date</label>
                                    <input type="date" class="form-control" id="endDate" name="endDate" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="endTime">End Time</label>
                                    <input type="time" class="form-control" id="endTime" name="endTime" required>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Invite Suppliers</label>
                            <div class="supplier-list">
                                <c:forEach items="${suppliers}" var="supplier">
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="supplier${supplier.id}" name="supplierIds" value="${supplier.id}">
                                        <label class="custom-control-label" for="supplier${supplier.id}">${supplier.company} - ${supplier.name}</label>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Create Auction</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- View Auction Details Modal -->
    <div class="modal fade" id="viewAuctionModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Auction Details</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <!-- Debug info to check if chart data is available -->
                    <div id="chart-debug" class="alert alert-info mb-3" style="display:none;"></div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <h6>Auction Information</h6>
                            <table class="table table-sm">
                                <tr>
                                    <th>ID:</th>
                                    <td id="auction-id"></td>
                                </tr>
                                <tr>
                                    <th>Product:</th>
                                    <td id="auction-product"></td>
                                </tr>
                                <tr>
                                    <th>Quantity:</th>
                                    <td id="auction-quantity"></td>
                                </tr>
                                <tr>
                                    <th>Starting Price:</th>
                                    <td id="auction-starting-price"></td>
                                </tr>
                                <tr>
                                    <th>Current Price:</th>
                                    <td id="auction-current-price"></td>
                                </tr>
                                <tr>
                                    <th>Status:</th>
                                    <td id="auction-status"></td>
                                </tr>
                                <tr>
                                    <th>Start Time:</th>
                                    <td id="auction-start-time"></td>
                                </tr>
                                <tr>
                                    <th>End Time:</th>
                                    <td id="auction-end-time"></td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6">
                            <h6>Bid History</h6>
                            <div class="table-responsive">
                                <table class="table table-sm table-striped" id="bid-history-table">
                                    <thead>
                                        <tr>
                                            <th>Supplier</th>
                                            <th>Amount</th>
                                            <th>Time</th>
                                        </tr>
                                    </thead>
                                    <tbody id="bid-history-body">
                                        <!-- Bid history will be loaded here -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="row mt-4">
                        <div class="col-md-12">
                            <h6>Bid Trend Chart</h6>
                            <div class="chart-container" style="position: relative; height:300px;">
                                <canvas id="bidTrendChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Cancel Auction Modal -->
    <div class="modal fade" id="cancelAuctionModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">Cancel Auction</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to cancel this auction? This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">No, Keep Auction</button>
                    <form id="cancelAuctionForm" action="${pageContext.request.contextPath}/auction" method="post">
                        <input type="hidden" id="cancelAuctionId" name="id">
                        <input type="hidden" name="action" value="cancel">
                        <button type="submit" class="btn btn-danger">Yes, Cancel Auction</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    </div> <!-- End of main-content -->
    
    <footer class="footer text-center">
        <div class="container">
            <p>&copy; <%= java.time.Year.now().getValue() %> Supplexio. All rights reserved.</p>
        </div>
    </footer>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        // Global variable to store chart instance
        let bidTrendChart = null;
        
        // Function to render the bid trend chart
        function renderBidTrendChart(chartData) {
            // Sort data by time
            chartData.sort((a, b) => a.bidTime - b.bidTime);
            
            // Prepare data for chart
            const labels = chartData.map(item => new Date(item.bidTime).toLocaleTimeString());
            const amounts = chartData.map(item => item.bidAmount);
            
            // Create dataset with supplier colors
            const supplierIds = [...new Set(chartData.map(item => item.supplierId))];
            const supplierNames = [...new Set(chartData.map(item => item.supplierName))];
            
            // Generate supplier datasets with different colors
            const datasets = [];
            const colors = ['#4e73df', '#1cc88a', '#36b9cc', '#f6c23e', '#e74a3b', '#6f42c1', '#5a5c69'];
            
            // Create a map of bidTime to index for positioning data points
            const timeMap = {};
            chartData.forEach((item, index) => {
                if (!timeMap[item.bidTime]) {
                    timeMap[item.bidTime] = index;
                }
            });
            
            // Create datasets for each supplier
            supplierIds.forEach((supplierId, index) => {
                const supplierData = chartData.filter(item => item.supplierId === supplierId);
                const dataPoints = Array(labels.length).fill(null);
                
                // Place supplier bids at correct positions
                supplierData.forEach(item => {
                    const position = timeMap[item.bidTime];
                    if (position !== undefined) {
                        dataPoints[position] = item.bidAmount;
                    }
                });
                
                datasets.push({
                    label: supplierNames[supplierIds.indexOf(supplierId)],
                    data: dataPoints,
                    borderColor: colors[index % colors.length],
                    backgroundColor: colors[index % colors.length] + '20',  // Add transparency
                    pointBackgroundColor: colors[index % colors.length],
                    pointRadius: 5,
                    pointHoverRadius: 7,
                    fill: false,
                    tension: 0.1
                });
            });
            
            // Destroy existing chart if it exists
            if (bidTrendChart) {
                bidTrendChart.destroy();
            }
            
            // Get the canvas element
            const ctx = document.getElementById('bidTrendChart').getContext('2d');
            
            // Create the chart
            bidTrendChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: datasets
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: 'Bid Trend Over Time',
                            font: {
                                size: 16
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return context.dataset.label + ': $' + context.parsed.y.toFixed(2);
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            title: {
                                display: true,
                                text: 'Time'
                            }
                        },
                        y: {
                            title: {
                                display: true,
                                text: 'Bid Amount ($)'
                            },
                            ticks: {
                                callback: function(value) {
                                    return '$' + value.toFixed(2);
                                }
                            }
                        }
                    }
                }
            });
        }
        
        $(document).ready(function() {
            // View auction details
            $('.view-auction').click(function() {
                var auctionId = $(this).data('id');
                $.ajax({
                    url: '${pageContext.request.contextPath}/auction',
                    type: 'GET',
                    data: {
                        id: auctionId,
                        action: 'get'
                    },
                    success: function(response) {
                        var data = JSON.parse(response);
                        $('#auction-id').text(data.auction.id);
                        $('#auction-product').text(data.auction.productName);
                        $('#auction-quantity').text(data.auction.requiredQuantity);
                        $('#auction-starting-price').text('$' + data.auction.startingPrice.toFixed(2));
                        $('#auction-current-price').text('$' + data.auction.currentPrice.toFixed(2));
                        $('#auction-status').text(data.auction.status);
                        $('#auction-start-time').text(new Date(data.auction.startTime).toLocaleString());
                        $('#auction-end-time').text(new Date(data.auction.endTime).toLocaleString());
                        
                        // Load bid history
                        $('#bid-history-body').empty();
                        if (data.bids && data.bids.length > 0) {
                            data.bids.forEach(function(bid) {
                                $('#bid-history-body').append(
                                    '<tr>' +
                                    '<td>' + bid.supplierName + '</td>' +
                                    '<td>$' + bid.amount.toFixed(2) + '</td>' +
                                    '<td>' + new Date(bid.bidTime).toLocaleString() + '</td>' +
                                    '</tr>'
                                );
                            });
                        } else {
                            $('#bid-history-body').append('<tr><td colspan="3" class="text-center">No bids yet</td></tr>');
                        }
                        
                        // Debug chart data
                        $('#chart-debug').show().html('Chart data count: ' + (data.chartData ? data.chartData.length : 0));
                        
                        // Render bid trend chart
                        if (data.chartData && data.chartData.length > 0) {
                            renderBidTrendChart(data.chartData);
                            $('.chart-container').show();
                        } else {
                            // Display a message if no chart data is available
                            $('.chart-container').hide();
                            $('#bidTrendChart').parent().before('<div class="alert alert-info">No bid data available for chart visualization</div>');
                        }
                        
                        $('#viewAuctionModal').modal('show');
                    },
                    error: function(xhr, status, error) {
                        alert('Error fetching auction details: ' + error);
                    }
                });
            });
            
            // Cancel auction
            $('.cancel-auction').click(function() {
                var auctionId = $(this).data('id');
                $('#cancelAuctionId').val(auctionId);
                $('#cancelAuctionModal').modal('show');
            });
            
            // Create payment for completed auction
            $('.create-payment').click(function() {
                var auctionId = $(this).data('id');
                window.location.href = '${pageContext.request.contextPath}/payment?auctionId=' + auctionId;
            });
            
            // Set min date for date inputs
            var today = new Date().toISOString().split('T')[0];
            $('#startDate').attr('min', today);
            $('#endDate').attr('min', today);
            
            // Ensure end date is after start date
            $('#startDate, #startTime').change(function() {
                var startDate = $('#startDate').val();
                var startTime = $('#startTime').val();
                
                if (startDate) {
                    $('#endDate').attr('min', startDate);
                    
                    // If end date is before start date, update it
                    if ($('#endDate').val() < startDate) {
                        $('#endDate').val(startDate);
                    }
                }
            });
        });
    </script>
</body>
</html>
