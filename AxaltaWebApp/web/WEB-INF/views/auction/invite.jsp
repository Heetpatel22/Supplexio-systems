<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invite Suppliers - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        :root {
            --axalta-blue: rgb(0, 51, 153);
            --axalta-red: rgb(204, 51, 51);
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
            background-color: var(--axalta-blue);
            color: white;
            font-weight: 600;
            border-radius: 10px 10px 0 0 !important;
        }
        
        .btn-primary {
            background-color: var(--axalta-blue);
            border-color: var(--axalta-blue);
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
        
        .custom-control-input:checked ~ .custom-control-label::before {
            background-color: var(--axalta-blue);
            border-color: var(--axalta-blue);
        }
        
        .supplier-list {
            max-height: 400px;
            overflow-y: auto;
            padding: 1rem;
            border: 1px solid #dee2e6;
            border-radius: 0.5rem;
        }
        
        .supplier-item {
            padding: 0.5rem;
            border-radius: 0.25rem;
            transition: background-color 0.2s;
        }
        
        .supplier-item:hover {
            background-color: var(--accent-color);
        }
        
        .supplier-item .custom-control-label {
            width: 100%;
            cursor: pointer;
        }
        
        .supplier-item .custom-control-label::before,
        .supplier-item .custom-control-label::after {
            top: 0.25rem;
        }
        
        .supplier-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-left: 2rem;
        }
        
        .supplier-name {
            font-weight: 600;
        }
        
        .supplier-email {
            color: #666;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/auction">Reverse Auction Management</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/auction?action=view&id=${auction.id}">View Auction #${auction.id}</a></li>
                <li class="breadcrumb-item active" aria-current="page">Invite Suppliers</li>
            </ol>
        </nav>
        
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Auction Details</h5>
                    </div>
                    <div class="card-body">
                        <table class="table table-borderless">
                            <tr>
                                <td><strong>Product:</strong></td>
                                <td>${auction.productName}</td>
                            </tr>
                            <tr>
                                <td><strong>Quantity:</strong></td>
                                <td>${auction.requiredQuantity} ${auction.unit}</td>
                            </tr>
                            <tr>
                                <td><strong>Starting Price:</strong></td>
                                <td><fmt:formatNumber value="${auction.startingPrice}" type="currency" currencySymbol="₹" /></td>
                            </tr>
                            <tr>
                                <td><strong>Current Price:</strong></td>
                                <td><fmt:formatNumber value="${auction.currentPrice}" type="currency" currencySymbol="₹" /></td>
                            </tr>
                            <tr>
                                <td><strong>Start Time:</strong></td>
                                <td><fmt:formatDate value="${auction.startTime}" pattern="yyyy-MM-dd HH:mm" /></td>
                            </tr>
                            <tr>
                                <td><strong>End Time:</strong></td>
                                <td><fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd HH:mm" /></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Invite Suppliers to Auction #${auction.id} - ${auction.productName}</h4>
                        <div>
                            <button type="button" class="btn btn-light btn-sm" id="selectAll">
                                <i class="fas fa-check-square"></i> Select All
                            </button>
                            <button type="button" class="btn btn-light btn-sm" id="deselectAll">
                                <i class="fas fa-square"></i> Deselect All
                            </button>
                        </div>
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
                            <input type="hidden" name="action" value="invite">
                            <input type="hidden" name="id" value="${auction.id}">
                            
                            <div class="form-group">
                                <label>Select Suppliers to Invite:</label>
                                <div class="input-group mb-3">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                                    </div>
                                    <input type="text" id="supplierSearch" class="form-control" placeholder="Search suppliers...">
                                </div>
                                
                                <div class="supplier-list">
                                    <c:forEach var="supplier" items="${suppliers}">
                                        <div class="supplier-item">
                                            <div class="custom-control custom-checkbox">
                                                <input type="checkbox" class="custom-control-input" 
                                                       id="supplier${supplier.id}" 
                                                       name="supplierIds" 
                                                       value="${supplier.id}"
                                                       ${invitedSupplierIds.contains(supplier.id) ? 'checked' : ''}>
                                                <label class="custom-control-label" for="supplier${supplier.id}">
                                                    <div class="supplier-info">
                                                        <span class="supplier-name">${supplier.name}</span>
                                                        <span class="supplier-email">${supplier.email}</span>
                                                    </div>
                                                </label>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${empty suppliers}">
                                        <p class="text-center">No active suppliers available</p>
                                    </c:if>
                                </div>
                            </div>
                            
                            <div class="form-group text-right">
                                <a href="${pageContext.request.contextPath}/auction?action=view&id=${auction.id}" class="btn btn-secondary">
                                    <i class="fas fa-times"></i> Cancel
                                </a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-paper-plane"></i> Send Invitations
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function() {
            // Filter suppliers based on search input
            $("#supplierSearch").on("keyup", function() {
                var value = $(this).val().toLowerCase();
                $(".supplier-item").filter(function() {
                    $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
                });
            });
            
            // Select all button functionality
            $("#selectAll").click(function() {
                $(".supplier-item:visible input[type='checkbox']").prop('checked', true);
            });
            
            // Deselect all button functionality
            $("#deselectAll").click(function() {
                $(".supplier-item:visible input[type='checkbox']").prop('checked', false);
            });
        });
    </script>
</body>
</html>
