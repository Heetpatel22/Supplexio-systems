<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Management - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/animate.css@4.1.1/animate.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <style>
        .progress {
            height: 20px;
        }

        .summary-card {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .summary-card h5 {
            margin-bottom: 15px;
            color: #495057;
        }

        .summary-item {
            display: inline-block;
            margin-right: 20px;
            margin-bottom: 10px;
        }
        
        .progress-bar-custom {
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: bold;
        }
        
        .filter-card {
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border: none;
            border-radius: 10px;
        }
        
        .inventory-table-card {
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border: none;
            border-radius: 10px;
        }
        
        .page-title {
            color: #495057;
            font-weight: 600;
        }
        
        .table th {
            background-color: #f8f9fa;
            border-top: none;
            font-weight: 600;
            color: #495057;
        }
        
        .table td {
            vertical-align: middle;
        }
        
        .action-buttons .btn {
            margin-right: 5px;
        }
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
                <div class="card animate__animated animate__fadeIn">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h1 class="page-title"><i class="fas fa-warehouse text-primary mr-2"></i>Inventory Management</h1>
                                <p class="text-muted">Monitor stock levels and manage inventory with Kanban system</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Summary Cards -->
        <div class="row mb-4 animate__animated animate__fadeIn animate__delay-1s">
            <div class="col-12">
                <div class="summary-card">
                    <h5><i class="fas fa-chart-bar text-primary mr-2"></i>Inventory Summary</h5>
                    <div class="row">
                        <div class="col-md-3">
                            <div class="summary-item">
                                <span class="badge badge-danger badge-lg">Low: <span id="lowCount">0</span></span>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="summary-item">
                                <span class="badge badge-warning badge-lg">Medium: <span id="mediumCount">0</span></span>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="summary-item">
                                <span class="badge badge-success badge-lg">High: <span id="highCount">0</span></span>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="summary-item">
                                <span class="badge badge-danger badge-lg">Auction Needed: <span id="auctionNeededCount">0</span></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search and filter section -->
        <div class="row mb-4 animate__animated animate__fadeIn animate__delay-2s">
            <div class="col-12">
                <div class="card filter-card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    </div>
                                    <input type="text" id="inventorySearch" class="form-control" placeholder="Search inventory items...">
                                </div>
                            </div>
                            <div class="col-md-3 mt-3 mt-md-0">
                                <select id="kanbanFilter" class="form-control">
                                    <option value="">All Statuses</option>
                                    <option value="Low">Low Stock</option>
                                    <option value="Medium">Medium Stock</option>
                                    <option value="High">High Stock</option>
                                </select>
                            </div>
                            <div class="col-md-3 mt-3 mt-md-0">
                                <select id="auctionFilter" class="form-control">
                                    <option value="">All Items</option>
                                    <option value="needed">Auction Needed</option>
                                    <option value="started">Auction Started</option>
                                    <option value="none">No Auction</option>
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

        <!-- Inventory table -->
        <div class="row animate__animated animate__fadeIn animate__delay-3s">
            <div class="col-12">
                <div class="card inventory-table-card">
                    <div class="card-header bg-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fas fa-list text-primary mr-2"></i>Inventory Items</h5>
                            <span class="badge badge-primary badge-pill" id="itemCount">0 Items</span>
                        </div>
                    </div>
                    <div class="card-body">
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
                
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Quantity</th>
                            <th>Min Threshold</th>
                            <th>Max Threshold</th>
                            <th>Inventory Level</th>
                            <th>Kanban Status</th>
                            <th>Auction Need</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="inventoryTableBody">
                        <c:forEach var="item" items="${inventory}">
                            <tr data-kanban-status="${item.kanbanStatus}">
                                <td>${item.id}</td>
                                <td>${item.itemName}</td>
                                <td>${item.quantity}</td>
                                <td data-toggle="tooltip" title="Minimum stock level before replenishment is needed">${item.minThreshold}</td>
                                <td data-toggle="tooltip" title="Maximum stock level to maintain optimal inventory">${item.maxThreshold}</td>
                                <td>
                                    <div class="progress">
                                        <div class="progress-bar progress-bar-custom bg-${item.kanbanStatus == 'Low' ? 'danger' : item.kanbanStatus == 'Medium' ? 'warning' : 'success'}" 
                                             role="progressbar" 
                                             data-quantity="${item.quantity}"
                                             data-min="${item.minThreshold}"
                                             data-max="${item.maxThreshold}"
                                             aria-valuenow="${item.quantity}" 
                                             aria-valuemin="${item.minThreshold}" 
                                             aria-valuemax="${item.maxThreshold}">
                                            ${item.quantity}
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge badge-${item.kanbanStatus == 'Low' ? 'danger' : item.kanbanStatus == 'Medium' ? 'warning' : 'success'}" 
                                          data-toggle="tooltip" title="Low: Needs replenishment, Medium: Monitor closely, High: Sufficient stock">
                                        ${item.kanbanStatus}
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.needsAuction}">
                                            <span class="badge badge-danger">Auction Needed</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-success">Not Needed</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/inventory?action=edit&id=${item.id}" class="btn btn-sm btn-primary">
                                        <i class="fas fa-edit"></i> Edit
                                    </a>
                                    <c:if test="${item.needsAuction && !item.auctionStarted}">
                                        <button data-id="${item.id}" data-name="${item.itemName}" class="btn btn-sm btn-danger start-auction" 
                                                data-toggle="tooltip" title="Create auction for this low stock item">
                                            <i class="fas fa-gavel"></i> Create Auction
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <!-- Auction Popup Modal -->
    <div class="modal fade" id="auctionModal" tabindex="-1" role="dialog" aria-labelledby="auctionModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="auctionModalLabel">Create Auction</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to create an auction for <span id="auctionItemName"></span>?</p>
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle mr-2"></i>
                        This will create a reverse auction to get the best price from suppliers for restocking this low inventory item.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="confirmStartAuction">Create Auction</button>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <div class="pagination-container mt-3"></div>

    <script>
        $(document).ready(function() {
            var currentAuctionItemId = null;
            var currentAuctionItemName = null;
            var currentPage = 1;
            var totalPages = ${totalPages};
            var searchTerm = '';
            var kanbanFilter = '';
            var auctionFilter = '';

            $('[data-toggle="tooltip"]').tooltip();

            function loadInventoryData(page) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/inventory',
                    method: 'GET',
                    data: {
                        action: 'ajaxList',
                        page: page,
                        search: searchTerm,
                        filter: kanbanFilter,
                        auctionFilter: auctionFilter
                    },
                    success: function(response) {
                        updateInventoryTable(response.inventory);
                        updatePagination(response.currentPage, response.totalPages);
                        updateSummary(response);
                        updateItemCount(response.inventory.length);
                        setProgressBarWidths();
                    },
                    error: function(xhr, status, error) {
                        console.error('Error loading inventory data:', error);
                        alert('Failed to load inventory data. Please try again.');
                    }
                });
            }
            function updateInventoryTable(inventory) {
                var tableBody = $('#inventoryTableBody');
                tableBody.empty();
                inventory.forEach(function(item) {
                    tableBody.append(createInventoryRow(item));
                });
            }

            function createInventoryRow(item) {
                var kanbanBadgeClass = item.kanbanStatus == 'Low' ? 'danger' : (item.kanbanStatus == 'Medium' ? 'warning' : 'success');
                var auctionBadgeClass = item.needsAuction ? 'danger' : 'success';
                var auctionText = item.needsAuction ? 'Auction Needed' : 'Not Needed';
                
                var auctionButton = '';
                if (item.needsAuction && !item.auctionStarted) {
                    auctionButton = '<button data-id="' + item.id + '" data-name="' + item.itemName + '" class="btn btn-sm btn-danger start-auction" ' +
                                   'data-toggle="tooltip" title="Create auction for this low stock item">' +
                                   '<i class="fas fa-gavel"></i> Create Auction</button>';
                }
                
                return '<tr data-kanban-status="' + item.kanbanStatus + '">' +
                        '<td>' + item.id + '</td>' +
                        '<td>' + item.itemName + '</td>' +
                        '<td>' + item.quantity + '</td>' +
                        '<td data-toggle="tooltip" title="Minimum stock level before replenishment is needed">' + item.minThreshold + '</td>' +
                        '<td data-toggle="tooltip" title="Maximum stock level to maintain optimal inventory">' + item.maxThreshold + '</td>' +
                        '<td>' +
                            '<div class="progress">' +
                                '<div class="progress-bar progress-bar-custom bg-' + kanbanBadgeClass + '" ' +
                                     'role="progressbar" ' +
                                     'data-quantity="' + item.quantity + '" ' +
                                     'data-min="' + item.minThreshold + '" ' +
                                     'data-max="' + item.maxThreshold + '" ' +
                                     'aria-valuenow="' + item.quantity + '" ' +
                                     'aria-valuemin="' + item.minThreshold + '" ' +
                                     'aria-valuemax="' + item.maxThreshold + '">' +
                                    item.quantity +
                                '</div>' +
                            '</div>' +
                        '</td>' +
                        '<td>' +
                            '<span class="badge badge-' + kanbanBadgeClass + '" ' +
                                  'data-toggle="tooltip" title="Low: Needs replenishment, Medium: Monitor closely, High: Sufficient stock">' +
                                item.kanbanStatus +
                            '</span>' +
                        '</td>' +
                        '<td>' +
                            '<span class="badge badge-' + auctionBadgeClass + '">' +
                                auctionText +
                            '</span>' +
                        '</td>' +
                        '<td>' +
                            '<a href="${pageContext.request.contextPath}/inventory?action=edit&id=' + item.id + '" class="btn btn-sm btn-primary">' +
                                '<i class="fas fa-edit"></i> Edit' +
                            '</a> ' +
                            auctionButton +
                        '</td>' +
                    '</tr>';
            }

            function updatePagination(currentPage, totalPages) {
                var paginationHtml = '<nav><ul class="pagination justify-content-center">';
                for (var i = 1; i <= totalPages; i++) {
                    var activeClass = (i === currentPage) ? 'active' : '';
                    paginationHtml += '<li class="page-item ' + activeClass + '"><a class="page-link" href="#" data-page="' + i + '">' + i + '</a></li>';
                }
                paginationHtml += '</ul></nav>';
                $('.pagination-container').html(paginationHtml);
            }

            function updateSummary(data) {
                $('#lowCount').text(data.lowCount);
                $('#mediumCount').text(data.mediumCount);
                $('#highCount').text(data.highCount);
                $('#auctionNeededCount').text(data.auctionNeededCount);
            }

            function updateItemCount(count) {
                $('#itemCount').text(count + ' Items');
            }

            $(document).on('click', '.start-auction', function() {
                currentAuctionItemId = $(this).data('id');
                currentAuctionItemName = $(this).data('name');
                $('#auctionItemName').text(currentAuctionItemName);
                $('#auctionModal').modal('show');
            });

            $('#confirmStartAuction').on('click', function() {
                if (currentAuctionItemId) {
                    // First get the product ID associated with this inventory item
                    $.ajax({
                        url: '${pageContext.request.contextPath}/inventory',
                        method: 'GET',
                        data: {
                            action: 'getProductId',
                            itemId: currentAuctionItemId
                        },
                        success: function(productResponse) {
                            if (productResponse.success && productResponse.productId) {
                                // Now create the auction using the product ID
                                $.ajax({
                                    url: '${pageContext.request.contextPath}/auction',
                                    method: 'POST',
                                    data: {
                                        action: 'createAutomatic',
                                        productId: productResponse.productId
                                    },
                                    success: function(auctionResponse) {
                                        if (auctionResponse.success) {
                                            alert('Success: ' + auctionResponse.message);
                                            $('#auctionModal').modal('hide');
                                            loadInventoryData(currentPage);
                                        } else {
                                            alert('Error: ' + auctionResponse.message);
                                        }
                                    },
                                    error: function(xhr, status, error) {
                                        console.error('Error creating auction:', error);
                                        alert('Failed to create auction. Please try again.');
                                    }
                                });
                            } else {
                                alert('Error: Could not find associated product for this inventory item.');
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('Error getting product ID:', error);
                            // Fallback to the old method
                            $.ajax({
                                url: '${pageContext.request.contextPath}/inventory',
                                method: 'POST',
                                data: {
                                    action: 'startAuction',
                                    itemId: currentAuctionItemId
                                },
                                success: function(response) {
                                    console.log('Auction started successfully for item ID:', currentAuctionItemId);
                                    $('#auctionModal').modal('hide');
                                    loadInventoryData(currentPage);
                                },
                                error: function(xhr, status, error) {
                                    console.error('Error starting auction:', error);
                                    alert('Failed to start auction. Please try again.');
                                }
                            });
                        }
                    });
                }
            });

            $('#inventorySearch').on('keyup', function() {
                searchTerm = $(this).val().toLowerCase();
                currentPage = 1;
                loadInventoryData(currentPage);
            });

            $('#kanbanFilter').on('change', function() {
                kanbanFilter = $(this).val();
                currentPage = 1;
                loadInventoryData(currentPage);
            });

            $('#auctionFilter').on('change', function() {
                auctionFilter = $(this).val();
                currentPage = 1;
                loadInventoryData(currentPage);
            });

            $('#clearFilters').on('click', function() {
                $('#inventorySearch').val('');
                $('#kanbanFilter').val('');
                $('#auctionFilter').val('');
                searchTerm = '';
                kanbanFilter = '';
                auctionFilter = '';
                currentPage = 1;
                loadInventoryData(currentPage);
            });

            function setProgressBarWidths() {
                $('.progress-bar').each(function() {
                    var $this = $(this);
                    var quantity = parseFloat($this.data('quantity'));
                    var min = parseFloat($this.data('min'));
                    var max = parseFloat($this.data('max'));
                    var width = 0;

                    if (!isNaN(quantity) && !isNaN(min) && !isNaN(max) && max > min) {
                        width = Math.max(0, Math.min(100, ((quantity - min) / (max - min)) * 100));
                    }

                    $this.css('width', width + '%');
                });
            }

            $(document).on('click', '.pagination a', function(e) {
                e.preventDefault();
                currentPage = parseInt($(this).data('page'));
                loadInventoryData(currentPage);
            });

            // Initial load
            loadInventoryData(currentPage);
        });
    </script>
</body>
</html>