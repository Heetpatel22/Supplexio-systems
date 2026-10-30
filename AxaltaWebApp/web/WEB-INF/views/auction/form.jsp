<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty auction ? 'Create New' : 'Edit'} Auction - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        :root {
            --supplexio-blue: rgb(0, 51, 153);
            --supplexio-red: rgb(204, 51, 51);
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
            background-color: var(--supplexio-blue);
            color: white;
            font-weight: 600;
            border-radius: 10px 10px 0 0 !important;
        }
        
        .btn-primary {
            background-color: var(--supplexio-blue);
            border-color: var(--supplexio-blue);
        }
        
        .btn-primary:hover {
            background-color: #00307a;
            border-color: #00307a;
        }
        
        .btn-secondary {
            background-color: var(--accent-color);
            border-color: var(--accent-color);
            color: #333;
        }
        
        .btn-secondary:hover {
            background-color: #c8c8d0;
            border-color: #c8c8d0;
            color: #333;
        }
        
        .form-control:focus {
            border-color: var(--axalta-blue);
            box-shadow: 0 0 0 0.2rem rgba(0, 51, 153, 0.25);
        }
        
        .alert {
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/auction">Reverse Auction Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">${empty auction ? 'Create New' : 'Edit'} Auction</li>
            </ol>
        </nav>
        
        <div class="card">
            <div class="card-header">
                <h4 class="mb-0">${empty auction ? 'Create New' : 'Edit'} Reverse Auction</h4>
            </div>
            <div class="card-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${error}
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>
                
                <form method="post" action="${pageContext.request.contextPath}/auction">
                    <input type="hidden" name="action" value="${empty auction ? 'create' : 'update'}">
                    <c:if test="${not empty auction}">
                        <input type="hidden" name="id" value="${auction.id}">
                    </c:if>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="productId">Product</label>
                                <select class="form-control" id="productId" name="productId" required>
                                    <option value="">Select a product</option>
                                    <c:forEach items="${products}" var="product">
                                        <option value="${product.id}" 
                                                data-price="${product.unitPrice}"
                                                data-unit="${product.unit}"
                                                data-inventory-qty="${product.inventoryQuantity}"
                                                data-min-threshold="${product.minThreshold}"
                                                data-max-threshold="${product.maxThreshold}"
                                                data-kanban-status="${product.kanbanStatus}"
                                                data-needs-auction="${product.needsAuction}"
                                                ${auction.productId eq product.id ? 'selected' : ''}>
                                            ${product.name} - ${product.category} 
                                            <c:if test="${not empty product.kanbanStatus}">
                                                [${product.kanbanStatus} Stock: ${product.inventoryQuantity}/${product.minThreshold}]
                                            </c:if>
                                            (₹${product.unitPrice} per ${product.unit})
                                        </option>
                                    </c:forEach>
                                </select>
                                <small class="form-text text-muted">Products with low inventory are prioritized</small>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="quantity">Required Quantity (in <span id="unitLabel">units</span>)</label>
                                <input type="number" class="form-control" id="quantity" name="quantity" 
                                       value="${auction.requiredQuantity}" min="1" required>
                                <small class="form-text text-muted">
                                    <span id="quantityRecommendation">Select a product to see recommended quantity</span>
                                </small>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Inventory Status Card -->
                    <div class="row" id="inventoryStatusCard" style="display: none;">
                        <div class="col-12">
                            <div class="card bg-light mb-3">
                                <div class="card-header">
                                    <h6 class="mb-0"><i class="fas fa-warehouse mr-2"></i>Inventory Status</h6>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-3">
                                            <div class="text-center">
                                                <h5 class="mb-1" id="currentStock">-</h5>
                                                <small class="text-muted">Current Stock</small>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="text-center">
                                                <h5 class="mb-1" id="minThreshold">-</h5>
                                                <small class="text-muted">Min Threshold</small>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="text-center">
                                                <h5 class="mb-1" id="maxThreshold">-</h5>
                                                <small class="text-muted">Max Threshold</small>
                                            </div>
                                        </div>
                                        <div class="col-md-3">
                                            <div class="text-center">
                                                <span class="badge badge-pill" id="kanbanStatus">-</span>
                                                <br><small class="text-muted">Status</small>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mt-3">
                                        <div class="progress" style="height: 20px;">
                                            <div class="progress-bar" id="stockProgress" role="progressbar" style="width: 0%"></div>
                                        </div>
                                        <div class="d-flex justify-content-between mt-1">
                                            <small class="text-muted">0</small>
                                            <small class="text-muted" id="maxProgressLabel">Max</small>
                                        </div>
                                    </div>
                                    <div class="mt-2" id="auctionAlert" style="display: none;">
                                        <div class="alert alert-warning alert-sm mb-0">
                                            <i class="fas fa-exclamation-triangle mr-2"></i>
                                            <strong>Auction Needed:</strong> This item has low inventory and requires restocking.
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="startingPrice">Starting Price</label>
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">₹</span>
                                    </div>
                                    <input type="number" class="form-control" id="startingPrice" name="startingPrice" 
                                           value="${auction.startingPrice}" min="0" step="0.01" required>
                                </div>
                                <small class="form-text text-muted">Suggested: <span id="suggestedPrice">0.00</span></small>
                            </div>
                        </div>
                        <c:if test="${not empty auction}">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="status">Status <span class="text-danger">*</span></label>
                                    <select class="form-control" id="status" name="status" required>
                                        <option value="ACTIVE" ${auction.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                                        <option value="COMPLETED" ${auction.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                        <option value="CANCELLED" ${auction.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                                    </select>
                                </div>
                            </div>
                        </c:if>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="startTime">Start Time <span class="text-danger">*</span></label>
                                <input type="datetime-local" class="form-control" id="startTime" name="startTime" 
                                       value="<fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd'T'HH:mm" />" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="endTime">End Time <span class="text-danger">*</span></label>
                                <input type="datetime-local" class="form-control" id="endTime" name="endTime" 
                                       value="<fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd'T'HH:mm" />" required>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group text-right">
                        <a href="${pageContext.request.contextPath}/auction" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${empty auction ? 'Create' : 'Update'} Auction
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function() {
            function updateProductInfo() {
                var selectedOption = $('#productId option:selected');
                var quantity = $('#quantity').val() || 1;
                var unitPrice = selectedOption.data('price') || 0;
                var unit = selectedOption.data('unit') || 'units';
                var inventoryQty = selectedOption.data('inventory-qty');
                var minThreshold = selectedOption.data('min-threshold');
                var maxThreshold = selectedOption.data('max-threshold');
                var kanbanStatus = selectedOption.data('kanban-status');
                var needsAuction = selectedOption.data('needs-auction');
                
                // Update unit label and suggested price
                $('#unitLabel').text(unit);
                $('#suggestedPrice').text((quantity * unitPrice).toFixed(2));
                
                // Show/hide inventory status card
                if (selectedOption.val() && inventoryQty !== undefined) {
                    $('#inventoryStatusCard').show();
                    
                    // Update inventory information
                    $('#currentStock').text(inventoryQty + ' ' + unit);
                    $('#minThreshold').text(minThreshold + ' ' + unit);
                    $('#maxThreshold').text(maxThreshold + ' ' + unit);
                    $('#maxProgressLabel').text(maxThreshold);
                    
                    // Update kanban status badge
                    var statusBadge = $('#kanbanStatus');
                    statusBadge.removeClass('badge-success badge-warning badge-danger');
                    statusBadge.text(kanbanStatus);
                    
                    switch(kanbanStatus) {
                        case 'High':
                            statusBadge.addClass('badge-success');
                            break;
                        case 'Medium':
                            statusBadge.addClass('badge-warning');
                            break;
                        case 'Low':
                            statusBadge.addClass('badge-danger');
                            break;
                        default:
                            statusBadge.addClass('badge-secondary');
                    }
                    
                    // Update progress bar
                    var progressPercent = Math.min(100, (inventoryQty / maxThreshold) * 100);
                    var progressBar = $('#stockProgress');
                    progressBar.css('width', progressPercent + '%');
                    progressBar.removeClass('bg-success bg-warning bg-danger');
                    
                    if (inventoryQty <= minThreshold) {
                        progressBar.addClass('bg-danger');
                    } else if (inventoryQty < maxThreshold * 0.7) {
                        progressBar.addClass('bg-warning');
                    } else {
                        progressBar.addClass('bg-success');
                    }
                    
                    // Show/hide auction alert
                    if (needsAuction === true || needsAuction === 'true') {
                        $('#auctionAlert').show();
                    } else {
                        $('#auctionAlert').hide();
                    }
                    
                    // Calculate and show recommended quantity
                    var recommendedQty = Math.max(1, maxThreshold - inventoryQty);
                    if (inventoryQty <= minThreshold) {
                        $('#quantityRecommendation').html(
                            '<strong>Recommended:</strong> ' + recommendedQty + ' ' + unit + 
                            ' <button type="button" class="btn btn-sm btn-outline-primary ml-2" onclick="setRecommendedQuantity(' + recommendedQty + ')">Use Recommended</button>'
                        );
                    } else {
                        $('#quantityRecommendation').text('Current stock level is adequate');
                    }
                } else {
                    $('#inventoryStatusCard').hide();
                    $('#quantityRecommendation').text('Select a product to see recommended quantity');
                }
            }
            
            // Function to set recommended quantity
            window.setRecommendedQuantity = function(qty) {
                $('#quantity').val(qty);
                updateProductInfo(); // Refresh the suggested price
            };
            
            // Sort products by priority (low inventory first)
            function sortProductOptions() {
                var select = $('#productId');
                var options = select.find('option:not(:first)').toArray();
                
                options.sort(function(a, b) {
                    var aNeedsAuction = $(a).data('needs-auction');
                    var bNeedsAuction = $(b).data('needs-auction');
                    var aKanban = $(a).data('kanban-status');
                    var bKanban = $(b).data('kanban-status');
                    
                    // Priority: needs auction first, then by kanban status (Low > Medium > High)
                    if (aNeedsAuction && !bNeedsAuction) return -1;
                    if (!aNeedsAuction && bNeedsAuction) return 1;
                    
                    var statusPriority = {'Low': 3, 'Medium': 2, 'High': 1};
                    var aPriority = statusPriority[aKanban] || 0;
                    var bPriority = statusPriority[bKanban] || 0;
                    
                    if (aPriority !== bPriority) return bPriority - aPriority;
                    
                    // If same priority, sort alphabetically
                    return $(a).text().localeCompare($(b).text());
                });
                
                select.find('option:not(:first)').remove();
                $.each(options, function(i, option) {
                    select.append(option);
                });
            }
            
            // Initialize
            sortProductOptions();
            $('#productId, #quantity').on('change input', updateProductInfo);
            updateProductInfo();
            
            // Set default start time to now and end time to 7 days from now
            if (!$('#startTime').val()) {
                var now = new Date();
                var startTime = new Date(now.getTime() + (60 * 60 * 1000)); // 1 hour from now
                var endTime = new Date(now.getTime() + (7 * 24 * 60 * 60 * 1000)); // 7 days from now
                
                $('#startTime').val(startTime.toISOString().slice(0, 16));
                $('#endTime').val(endTime.toISOString().slice(0, 16));
            }
        });
    </script>
</body>
</html>
