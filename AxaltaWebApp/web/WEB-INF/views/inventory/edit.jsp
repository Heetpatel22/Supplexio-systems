<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Inventory - Supplexio</title>
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
            border-color: var(--supplexio-primary);
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        }
    </style>
</head>
<body>
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/inventory">Inventory Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">Edit Inventory</li>
            </ol>
        </nav>
        
        <div class="card">
            <div class="card-header">
                <h4 class="mb-0">Edit Inventory - ${product.name}</h4>
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
                
                <form method="post" action="${pageContext.request.contextPath}/inventory">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="${item.id}">
                    
                    <div class="form-group">
                        <label for="itemName">Item Name</label>
                        <input type="text" class="form-control" id="itemName" value="${item.itemName}" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="quantity">Quantity <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="quantity" name="quantity" value="${item.quantity}" min="0" required>
                        <small class="form-text text-muted">Enter the new quantity. Must be a non-negative integer.</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="minThreshold">Minimum Threshold <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="minThreshold" name="minThreshold" value="${item.minThreshold}" min="0" required>
                        <small class="form-text text-muted">Enter the minimum threshold for Kanban "Low" status. Must be less than the maximum threshold.</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="maxThreshold">Maximum Threshold <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="maxThreshold" name="maxThreshold" value="${item.maxThreshold}" min="0" required>
                        <small class="form-text text-muted">Enter the maximum threshold for Kanban "High" status. Must be greater than the minimum threshold.</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="kanbanStatus">Current Kanban Status</label>
                        <input type="text" class="form-control ${item.kanbanStatus == 'Low' ? 'bg-danger text-white' : item.kanbanStatus == 'Medium' ? 'bg-warning' : 'bg-success text-white'}" id="kanbanStatus" value="${item.kanbanStatus}" readonly>
                        <small class="form-text text-muted">This status is automatically updated based on the quantity and thresholds.</small>
                    </div>
                    
                    <div class="alert alert-info" role="alert">
                        <h5 class="alert-heading">Kanban Method Explanation</h5>
                        <p>The Kanban method helps manage inventory levels efficiently:</p>
                        <ul>
                            <li><strong>Low:</strong> Quantity is at or below the minimum threshold. Needs replenishment, an auction may be needed.</li>
                            <li><strong>Medium:</strong> Quantity is between the minimum and maximum thresholds. Monitor closely, inventory level is optimal.</li>
                            <li><strong>High:</strong> Quantity is at or above the maximum threshold. Sufficient stock, consider reducing if necessary.</li>
                        </ul>
                    </div>
                    
                    <div id="auctionWarning" class="alert alert-warning d-none" role="alert">
                        <strong>Warning:</strong> The current quantity is below the minimum threshold. An auction may be needed.
                    </div>
                    
                    <div class="form-group text-right">
                        <a href="${pageContext.request.contextPath}/inventory" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Update Inventory
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
            function validateThresholds() {
                var minThreshold = parseInt($('#minThreshold').val());
                var maxThreshold = parseInt($('#maxThreshold').val());
                var quantity = parseInt($('#quantity').val());
                
                if (minThreshold >= maxThreshold) {
                    alert('Minimum threshold must be less than maximum threshold.');
                    return false;
                }
                
                if (quantity < minThreshold) {
                    $('#auctionWarning').removeClass('d-none');
                } else {
                    $('#auctionWarning').addClass('d-none');
                }
                
                return true;
            }
            
            $('form').on('submit', function(e) {
                if (!validateThresholds()) {
                    e.preventDefault();
                }
            });
            
            $('#quantity, #minThreshold, #maxThreshold').on('change', validateThresholds);
        });
    </script>
</body>
</html>