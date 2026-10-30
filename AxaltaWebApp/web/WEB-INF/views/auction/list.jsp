<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reverse Auction Management - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/animate.css@4.1.1/animate.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auction.css">
    <style>
        /* Custom styles that are specific to this page and not in auction.css */
    </style>
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <!-- Page header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="auction-header-card animate__animated animate__fadeIn">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h1 class="page-title"><i class="fas fa-gavel text-primary mr-2"></i>Reverse Auction Management</h1>
                            <p class="text-muted">Create and manage reverse auctions to get the best prices from suppliers</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/auction?action=new" class="btn btn-primary btn-lg shadow-sm">
                            <i class="fas fa-plus-circle mr-2"></i> Create New Auction
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Search and filter section -->
        <div class="row mb-4 animate__animated animate__fadeIn animate__delay-1s">
            <div class="col-12">
                <div class="card filter-card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    </div>
                                    <input type="text" id="auctionSearch" class="form-control" placeholder="Search auctions...">
                                </div>
                            </div>
                            <div class="col-md-3 mt-3 mt-md-0">
                                <select id="statusFilter" class="form-control">
    <option value="">All Statuses</option>
    <option value="Active">Active</option>
    <option value="Completed">Completed</option>
    <option value="Sent To Supplier">Sent To Supplier</option>
    <option value="Payment Pending">Payment Pending</option>
    <option value="Payment Successful">Payment Successful</option>
    <option value="Delivered">Delivered</option>
    <option value="Cancelled">Cancelled</option>
</select>


                            </div>
                            <div class="col-md-3 mt-3 mt-md-0">
                                <select id="productFilter" class="form-control">
                                    <option value="">All Products</option>
                                    <c:forEach var="product" items="${products}">
                                        <option value="${product.name}">${product.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-2 mt-3 mt-md-0">
                                <button id="clearFilters" class="btn btn-outline-secondary btn-block">
                                    <i class="fas fa-undo mr-1"></i> Clear
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Products needing auctions alert -->
        <c:if test="${not empty productsNeedingAuctions}">
        <div class="row mb-4 animate__animated animate__fadeIn animate__delay-1s">
            <div class="col-12">
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="alert-heading mb-2"><i class="fas fa-exclamation-triangle mr-2"></i>Items Need Auctions</h5>
                            <p class="mb-2">The following products have low inventory and need auctions:</p>
                            <div class="row">
                                <c:forEach var="product" items="${productsNeedingAuctions}" varStatus="status">
                                    <div class="col-md-6 col-lg-4 mb-2">
                                        <div class="d-flex justify-content-between align-items-center p-2 bg-light rounded">
                                            <div>
                                                <strong>${product.name}</strong>
                                                <br><small class="text-muted">Current: ${product.inventoryQuantity} ${product.unit} | Min: ${product.minThreshold}</small>
                                                <br><span class="badge badge-danger">${product.kanbanStatus}</span>
                                            </div>
                                            <button class="btn btn-sm btn-primary create-auction-btn" 
                                                    data-product-id="${product.id}"
                                                    data-product-name="${product.name}">
                                                <i class="fas fa-gavel"></i> Create Auction
                                            </button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
        </c:if>

        <!-- Auctions table -->
        <div class="row animate__animated animate__fadeIn animate__delay-2s">
            <div class="col-12">
                <div class="card auction-table-card">
                    <div class="card-header bg-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fas fa-list text-primary mr-2"></i>Active Auctions</h5>
                            <span class="badge badge-primary badge-pill"><c:out value="${auctions.size()}" /> Auctions</span>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table id="auctionsTable" class="table table-borderless table-hover">
                                <thead class="thead-light">
                                    <tr>
                                        <th>ID</th>
                                        <th>Product</th>
                                        <th>Quantity</th>
                                        <th>Start Price</th>
                                        <th>Current Price</th>
                                        <th>Start Time</th>
                                        <th>End Time</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="auction" items="${auctions}">
                                        <tr class="auction-row">
                                            <td>
                                                <span class="badge badge-light">#${auction.id}</span>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="product-color-dot mr-2" style="background-color: #003399;"></div>

                                                    <strong>${auction.productName}</strong>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="badge badge-info">${auction.requiredQuantity} ${auction.unit}</span>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${auction.startingPrice}" type="currency" currencySymbol="₹" />
                                            </td>
                                            <td>
                                                <strong class="text-success">
                                                    <fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="₹" />
                                                </strong>
                                            </td>
                                            <td>
                                                <small class="text-muted">
                                                    <i class="far fa-calendar-alt mr-1"></i>
                                                    <fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd HH:mm" />
                                                </small>
                                            </td>
                                            <td>
                                                <small>
                                                    <i class="far fa-clock mr-1"></i>
                                                    <fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm" />
                                                </small>
                                            </td>
                                            <td>
                                                <c:choose>
    <c:when test="${auction.status == 'ACTIVE'}">
        <span class="badge badge-active">Active</span>
    </c:when>
    <c:when test="${auction.status == 'COMPLETED'}">
        <span class="badge badge-completed">Completed</span>
    </c:when>
    <c:when test="${auction.status == 'SENT'}">
        <span class="badge badge-warning">Sent To Supplier</span>
    </c:when>
    <c:when test="${auction.status == 'PAYMENT_PENDING'}">
        <span class="badge badge-warning">Payment Pending</span>
    </c:when>
    <c:when test="${auction.status == 'PAID'}">
        <span class="badge badge-info">Payment Successful</span>
    </c:when>
    <c:when test="${auction.status == 'DELIVERED'}">
        <span class="badge badge-success">Delivered</span>
    </c:when>
    <c:when test="${auction.status == 'CANCELLED'}">
        <span class="badge badge-cancelled">Cancelled</span>
    </c:when>
    <c:otherwise>
        <span class="badge badge-secondary">${auction.status}</span>
    </c:otherwise>
</c:choose>


                                                <c:if test="${not empty auction.supplierName}">
                                                    <br><small class="text-muted">Winner: ${auction.supplierName}</small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <a href="${pageContext.request.contextPath}/auction?action=view&id=${auction.id}" 
                                                       class="btn btn-sm btn-outline-info mr-1" data-toggle="tooltip" title="View Details">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <c:if test="${auction.status != 'DELIVERED' && auction.status != 'CANCELLED'}">
                                                        <a href="${pageContext.request.contextPath}/auction?action=edit&id=${auction.id}" 
                                                           class="btn btn-sm btn-outline-primary mr-1" data-toggle="tooltip" title="Edit Auction">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${auction.status == 'ACTIVE' || auction.status == 'SCHEDULED'}">
                                                        <a href="${pageContext.request.contextPath}/auction?action=invite&id=${auction.id}"
                                                           class="btn btn-sm btn-outline-success mr-1" data-toggle="tooltip" title="Invite Suppliers">
                                                            <i class="fas fa-user-plus"></i>
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${auction.status == 'PAID'}">

                                                        <button type="button" 
                                                                class="btn btn-sm btn-outline-success mr-1" 
                                                                data-toggle="tooltip"
                                                                title="Mark as Delivered"
                                                                onclick="markDelivered('${auction.id}', '${auction.productName}', ${auction.requiredQuantity})">
                                                            <i class="fas fa-truck"></i>
                                                        </button>
                                                    </c:if>
                                                    <c:if test="${auction.status == 'ACTIVE'}">
                                                        <button type="button" 
                                                                class="btn btn-sm btn-outline-warning mr-1" 
                                                                data-toggle="tooltip"
                                                                title="Complete Auction"
                                                                onclick="completeAuction('${auction.id}')">
                                                            <i class="fas fa-check"></i>
                                                        </button>
                                                    </c:if>
                                                    <c:if test="${auction.status != 'DELIVERED'}">
                                                        <button type="button" 
                                                                class="btn btn-sm btn-outline-danger" 
                                                                data-toggle="tooltip"
                                                                title="Delete Auction"
                                                                onclick="confirmDelete('${auction.id}')">
                                                            <i class="fas fa-trash-alt"></i>
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty auctions}">
                                        <tr>
                                            <td colspan="9" class="text-center py-5">
                                                <div class="empty-state">
                                                    <i class="fas fa-gavel fa-3x text-muted mb-3"></i>
                                                    <h5>No auctions found</h5>
                                                    <p class="text-muted">Create your first auction to get started</p>
                                                    <a href="${pageContext.request.contextPath}/auction?action=new" class="btn btn-primary mt-2">
                                                        <i class="fas fa-plus-circle mr-2"></i> Create New Auction
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <div>
                                <select class="form-control form-control-sm" id="rowsPerPage">
                                    <option value="10">10 rows</option>
                                    <option value="25">25 rows</option>
                                    <option value="50">50 rows</option>
                                    <option value="100">100 rows</option>
                                </select>
                            </div>
                            <nav aria-label="Auction pagination">
                                <ul class="pagination pagination-sm">
                                    <li class="page-item disabled">
                                        <a class="page-link" href="#" tabindex="-1" aria-disabled="true">Previous</a>
                                    </li>
                                    <li class="page-item active"><a class="page-link" href="#">1</a></li>
                                    <li class="page-item"><a class="page-link" href="#">2</a></li>
                                    <li class="page-item"><a class="page-link" href="#">3</a></li>
                                    <li class="page-item">
                                        <a class="page-link" href="#">Next</a>
                                    </li>
                                </ul>
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1" role="dialog" aria-labelledby="deleteModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title" id="deleteModalLabel"><i class="fas fa-exclamation-triangle mr-2"></i>Confirm Delete</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this auction? This action cannot be undone.</p>
                    <div class="alert alert-warning">
                        <i class="fas fa-info-circle mr-2"></i> Deleting this auction will remove all associated bids and supplier invitations.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-dismiss="modal">
                        <i class="fas fa-times mr-1"></i> Cancel
                    </button>
                    <form id="deleteForm" action="${pageContext.request.contextPath}/auction" method="post" style="display: inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" id="deleteAuctionId">
                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-trash-alt mr-1"></i> Delete
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Required JavaScript -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>
    
    <script>
        $(document).ready(function() {
            console.log('Auction page loaded - setting up Create Auction button handlers');
            
            // Create Auction button click handler
            $('.create-auction-btn').on('click', function(e) {
                console.log('=== CREATE AUCTION BUTTON CLICKED ===');
                console.log('Button element:', this);
                console.log('Button data:', $(this).data());
                
                var productId = $(this).data('product-id');
                var productName = $(this).data('product-name');
                
                console.log('Extracted productId:', productId);
                console.log('Extracted productName:', productName);
                
                // Prevent default behavior
                e.preventDefault();
                e.stopPropagation();
                
                // Call the auction creation function
                createAutomaticAuctionHandler(productId, productName, $(this));
            });
            
            // Function to handle auction creation - redirect to form
            function createAutomaticAuctionHandler(productId, productName, buttonElement) {
                console.log('=== NAVIGATING TO AUCTION CREATION FORM ===');
                console.log('Product ID:', productId);
                console.log('Product Name:', productName);
                
                if (!productId || !productName) {
                    alert('Error: Missing product information');
                    return;
                }
                
                // Navigate to auction creation form with pre-selected product
                var createUrl = '${pageContext.request.contextPath}/auction?action=new&productId=' + productId;
                console.log('Redirecting to:', createUrl);
                
                // Show loading indicator briefly
                var originalText = buttonElement.html();
                buttonElement.html('<i class="fas fa-spinner fa-spin"></i> Loading...').prop('disabled', true);
                
                // Redirect to auction creation form
                window.location.href = createUrl;
            }
            
            // Initialize tooltips
            $('[data-toggle="tooltip"]').tooltip();
            
            // Initialize DataTable
            var table = $('#auctionsTable').DataTable({
                "paging": true,
                "ordering": true,
                "info": true,
                "searching": true,
                "lengthChange": false,
                "pageLength": 10,
                "language": {
                    "search": "",
                    "searchPlaceholder": "Search auctions..."
                },
                "dom": '<"top"f>rt<"bottom"ip><"clear">'
            });
            
            // Connect search box
            $('#auctionSearch').on('keyup', function() {
                table.search(this.value).draw();
            });
            
            // Connect status filter
            $('#statusFilter').on('change', function() {
    var value = this.value;
    if (value) {
        table.column(7).search(value, false, false).draw();
    } else {
        table.column(7).search('').draw();
    }
});

            
            // Connect product filter
            $('#productFilter').on('change', function() {
                table.column(1).search(this.value).draw();
            });
            
            // Connect rows per page selector
            $('#rowsPerPage').on('change', function() {
                table.page.len($(this).val()).draw();
            });
            
            // Clear filters button
            $('#clearFilters').on('click', function() {
                $('#auctionSearch').val('');
                $('#statusFilter').val('');
                $('#productFilter').val('');
                table.search('').columns().search('').draw();
            });
            
            // Highlight row on hover
            $('#auctionsTable tbody').on('mouseenter', 'tr', function() {
                $(this).addClass('highlight');
            }).on('mouseleave', 'tr', function() {
                $(this).removeClass('highlight');
            });
            
            // Function to confirm delete
            window.confirmDelete = function(auctionId) {
                $('#deleteAuctionId').val(auctionId);
                $('#deleteModal').modal('show');
            };
            
                        
            // Function to complete an auction manually
            window.completeAuction = function(auctionId) {
                if (confirm('Complete this auction? This will determine the winning bid and close the auction.')) {
                    $.ajax({
                        url: '${pageContext.request.contextPath}/auction-completion',
                        method: 'POST',
                        data: {
                            action: 'completeAuction',
                            auctionId: auctionId
                        },
                        dataType: 'json',
                        success: function(response) {
                            if (response.success) {
                                alert('Success: ' + response.message);
                                location.reload(); // Refresh to show updated status
                            } else {
                                alert('Error: ' + response.message);
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('AJAX Error:', xhr.responseText);
                            try {
                                var response = JSON.parse(xhr.responseText);
                                alert('Error: ' + response.message);
                            } catch (e) {
                                alert('Error completing auction: ' + error);
                            }
                        }
                    });
                }
            };
            
            // Function to mark auction delivery as completed
            window.markDelivered = function(auctionId, productName, quantity) {
                var deliveredQuantity = prompt('Enter the quantity delivered for ' + productName + ':', quantity);
                if (deliveredQuantity !== null && deliveredQuantity !== '') {
                    var qty = parseInt(deliveredQuantity);
                    if (isNaN(qty) || qty <= 0) {
                        alert('Please enter a valid quantity.');
                        return;
                    }
                    
                    if (confirm('Mark ' + qty + ' units of ' + productName + ' as delivered? This will update the inventory.')) {
                        $.ajax({
                            url: '${pageContext.request.contextPath}/auction-completion',
                            method: 'POST',
                            data: {
                                action: 'markDelivered',
                                auctionId: auctionId,
                                quantity: qty
                            },
                            dataType: 'json',
                            success: function(response) {
                                if (response.success) {
                                    alert('Success: ' + response.message);
                                    location.reload(); // Refresh to show updated status
                                } else {
                                    alert('Error: ' + response.message);
                                }
                            },
                            error: function(xhr, status, error) {
                                console.error('AJAX Error:', xhr.responseText);
                                try {
                                    var response = JSON.parse(xhr.responseText);
                                    alert('Error: ' + response.message);
                                } catch (e) {
                                    alert('Error marking delivery: ' + error);
                                }
                            }
                        });
                    }
                }
            };
        });
    </script>
    
    </div> <!-- End of main-content -->
</body>
</html>
