<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio - Procurement Portal</title>
    
    <!-- Common CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <!-- Chart.js for graphs -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>

</head>
<body>
        <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <section class="main-hero">
            <div class="container">
                <h1 class="main-title">SUPPLEXIO</h1>
                <p class="main-subtitle">Next-Generation Procurement and Reverse Auction Platform</p>
            </div>
        </section>
        
        <!-- Dashboard Graphs Section -->
        <div class="container mt-5">
            <!-- Row 1: Active Auctions Over Time & Supplier Performance -->
            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-hourglass-half"></i> Active Auctions Over Time</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="auctionsOverTimeChart"></canvas>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-award"></i> Top Supplier Performance</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="supplierPerformanceChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Row 2: Payment Status & Inventory Status -->
            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="card compact-chart-card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-credit-card"></i> Payment Status Distribution</h5>
                        </div>
                        <div class="card-body payment-chart-card">
                            <div class="chart-frame chart-frame-compact">
                                <canvas id="paymentStatusChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="card compact-chart-card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-warehouse"></i> Inventory Status</h5>
                        </div>
                        <div class="card-body payment-chart-card">
                            <div class="chart-frame chart-frame-compact">
                                <canvas id="inventoryStatusChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Row 3: Top Products & Spend by Category -->
            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-box"></i> Top Products by Auction Frequency</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="topProductsChart"></canvas>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-dollar-sign"></i> Spend by Category of Product</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="spendByCategoryChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-3">
                <div class="card h-100 ${hasLowStockAlert ? 'border-warning' : ''}">
                    <div class="card-header ${hasLowStockAlert ? 'bg-warning text-dark' : ''}">
                        <i class="fas fa-warehouse"></i>
                        Inventory Management
                        <c:if test="${hasLowStockAlert}">
                            <span class="badge badge-danger ml-2">Alert!</span>
                        </c:if>
                    </div>
                    <div class="card-body d-flex flex-column">
                        <c:choose>
                            <c:when test="${hasLowStockAlert}">
                                <p class="text-warning"><strong>⚠️ Low stock items detected!</strong></p>
                                <p>Monitor stock levels and manage inventory with Kanban system. Some items need immediate attention.</p>
                                <a href="inventory" class="btn btn-warning mt-auto">
                                    <i class="fas fa-exclamation-triangle"></i> Manage Inventory
                                </a>
                            </c:when>
                            <c:otherwise>
                                <p>Monitor stock levels and manage inventory with Kanban system. All items are well-stocked.</p>
                                <a href="inventory" class="btn btn-primary mt-auto">
                                    <i class="fas fa-arrow-right"></i> Manage Inventory
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            
            <div class="col-md-9">
                <div class="card h-100">
                    <div class="card-header">
                        <i class="fas fa-chart-line"></i>
                        System Status & Quick Actions
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>Quick Actions</h6>
                                <a href="auction?action=new" class="quick-action-btn">
                                    <i class="fas fa-plus-circle"></i>
                                    Create New Auction
                                </a>
                                <a href="supplier?action=new" class="quick-action-btn">
                                    <i class="fas fa-user-plus"></i>
                                    Add New Supplier
                                </a>
                                <a href="product?action=new" class="quick-action-btn">
                                    <i class="fas fa-cube"></i>
                                    Add New Product
                                </a>
                            </div>
                            <div class="col-md-6">
                                <h6>System Overview</h6>
                                <c:if test="${hasLowStockAlert}">
                                    <div class="alert alert-warning alert-sm">
                                        <i class="fas fa-exclamation-triangle"></i>
                                        <strong>${fn:length(lowStockItems)}</strong> items need attention
                                    </div>
                                </c:if>
                                <a href="auction?action=active" class="quick-action-btn">
                                    <i class="fas fa-clock"></i>
                                    View Active Auctions
                                </a>
                                <a href="payment?action=statistics" class="quick-action-btn">
                                    <i class="fas fa-chart-bar"></i>
                                    View Payment Statistics
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row mt-4">
            <div class="col-md-12">
                <div class="card h-100">
                    <div class="card-header">
                        <i class="fas fa-sign-in-alt"></i>
                        Supplier Portal
                    </div>
                    <div class="card-body text-center">
                        <p class="mb-4">Access the supplier bidding portal to participate in active reverse auctions.</p>
                        <a href="bidding" class="btn btn-danger btn-lg">
                            <i class="fas fa-external-link-alt"></i> Enter Bidding Portal
                        </a>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </div>
    
    <!-- Footer -->
    <footer class="footer mt-5">
        <div class="container">
            <div class="row">
                <div class="col-md-4">
                    <h5>SUPPLEXIO</h5>
                    <p><i class="fas fa-map-marker-alt"></i> Supplexio Systems India<br>HITEC City, Madhapur<br>Hyderabad, Telangana 500081</p>
                </div>
                <div class="col-md-4">
                    <h5>Quick Links</h5>
                    <ul class="footer-links">
                        <li><a href="product"><i class="fas fa-box"></i> Products</a></li>
                        <li><a href="supplier"><i class="fas fa-users"></i> Suppliers</a></li>
                        <li><a href="auction"><i class="fas fa-gavel"></i> Reverse Auctions</a></li>
                        <li><a href="payment"><i class="fas fa-money-check-alt"></i> Payments</a></li>
                    </ul>
                </div>
                <div class="col-md-4">
                    <h5>Contact Us</h5>
                    <p><i class="fas fa-phone"></i> +91 98765 43210</p>
                    <p><i class="fas fa-envelope"></i> procurement@supplexio.com</p>
                    <div class="social-icons">
                        <a href="#" class="social-icon"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-linkedin-in"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-youtube"></i></a>
                    </div>
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-md-12 text-center">
                    <p class="copyright">© <%= java.time.Year.now().getValue() %> Supplexio. All Rights Reserved.</p>
                </div>
            </div>
        </div>
    </footer>
    
    <!-- Common JavaScript -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/home.js"></script>
    
    <!-- Dashboard Graphs Script -->
    <script>
        // Initialize charts when page loads
        document.addEventListener('DOMContentLoaded', function() {
            loadDashboardCharts();
        });
        
        function loadDashboardCharts() {
            // 1. Active Auctions Over Time Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/auctions-over-time')
                .then(response => response.json())
                .then(data => {
                    const ctx = document.getElementById('auctionsOverTimeChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                label: 'Active Auctions',
                                data: data.values,
                                borderColor: '#007bff',
                                backgroundColor: 'rgba(0, 123, 255, 0.1)',
                                borderWidth: 2,
                                fill: true,
                                tension: 0.4
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: {
                                    position: 'top'
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true
                                }
                            }
                        }
                    });
                });
            
            // 2. Supplier Performance Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/supplier-performance')
                .then(response => response.json())
                .then(data => {
                    const ctx = document.getElementById('supplierPerformanceChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                label: 'Number of Wins',
                                data: data.values,
                                backgroundColor: '#28a745'
                            }]
                        },
                        options: {
                            responsive: true,
                            indexAxis: 'y',
                            plugins: {
                                legend: {
                                    position: 'top'
                                }
                            },
                            scales: {
                                x: {
                                    beginAtZero: true
                                }
                            }
                        }
                    });
                });
            
            // 3. Payment Status Distribution Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/payment-status')
                .then(response => response.json())
                .then(data => {
                    const ctx = document.getElementById('paymentStatusChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'doughnut',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                data: data.values,
                                backgroundColor: ['#1E3A8A', '#2DD4BF', '#60A5FA'],
                                borderColor: '#ffffff',
                                borderWidth: 4,
                                hoverOffset: 10,
                                radius: '84%'
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '66%',
                            layout: {
                                padding: {
                                    top: 8,
                                    bottom: 8
                                }
                            },
                            plugins: {
                                legend: {
                                    position: 'bottom',
                                    labels: {
                                        usePointStyle: true,
                                        pointStyle: 'circle',
                                        boxWidth: 10,
                                        boxHeight: 10,
                                        padding: 16,
                                        color: '#1F2937',
                                        font: {
                                            size: 12,
                                            weight: '600'
                                        }
                                    }
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function(context) {
                                            return context.label + ': ' + context.parsed;
                                        }
                                    }
                                }
                            }
                        }
                    });
                });
            
            // 4. Inventory Status Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/inventory-status')
                .then(response => response.json())
                .then(data => {
                    const ctx = document.getElementById('inventoryStatusChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'doughnut',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                data: data.values,
                                backgroundColor: ['#1E3A8A', '#2DD4BF', '#60A5FA'],
                                borderColor: '#ffffff',
                                borderWidth: 4,
                                hoverOffset: 10,
                                radius: '84%'
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '66%',
                            layout: {
                                padding: {
                                    top: 8,
                                    bottom: 8
                                }
                            },
                            plugins: {
                                legend: {
                                    position: 'bottom',
                                    labels: {
                                        usePointStyle: true,
                                        pointStyle: 'circle',
                                        boxWidth: 10,
                                        boxHeight: 10,
                                        padding: 16,
                                        color: '#1F2937',
                                        font: {
                                            size: 12,
                                            weight: '600'
                                        }
                                    }
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function(context) {
                                            return context.label + ': ' + context.parsed;
                                        }
                                    }
                                }
                            }
                        }
                    });
                });
            
            // 5. Top Products by Auction Frequency Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/top-products')
                .then(response => response.json())
                .then(data => {
                    const ctx = document.getElementById('topProductsChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                label: 'Auction Frequency',
                                data: data.values,
                                backgroundColor: '#17a2b8'
                            }]
                        },
                        options: {
                            responsive: true,
                            indexAxis: 'y',
                            plugins: {
                                legend: {
                                    position: 'top'
                                }
                            },
                            scales: {
                                x: {
                                    beginAtZero: true
                                }
                            }
                        }
                    });
                });
            
            // 6. Spend by Category Chart
            fetch('${pageContext.request.contextPath}/api/dashboard/spend-by-category')
                .then(response => response.json())
                .then(data => {
                    const ctx = document.getElementById('spendByCategoryChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: data.labels,
                            datasets: [{
                                label: 'Total Spend (₹)',
                                data: data.values,
                                backgroundColor: '#6f42c1'
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: {
                                    position: 'top'
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true
                                }
                            }
                        }
                    });
                });
        }
    </script>

</body>
</html>
