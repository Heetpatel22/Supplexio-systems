<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty product ? 'Add New' : 'Edit'} Product - Supplexio</title>
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
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/product">Product Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">${empty product ? 'Add New' : 'Edit'} Product</li>
            </ol>
        </nav>
        
        <div class="card">
            <div class="card-header">
                <h4 class="mb-0">${empty product ? 'Add New' : 'Edit'} Product</h4>
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
                
                <form method="post" action="${pageContext.request.contextPath}/product">
                    <input type="hidden" name="action" value="${empty product ? 'create' : 'update'}">
                    <c:if test="${not empty product}">
                        <input type="hidden" name="id" value="${product.id}">
                    </c:if>
                    
                    <div class="form-group">
                        <label for="name">Product Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" value="${product.name}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="inventoryId">Inventory ID</label>
                        <input type="number" class="form-control" id="inventoryId" name="inventoryId" value="${product.inventoryId}">
                        <small class="form-text text-muted">Optional. Leave blank if not applicable. If provided, must be a positive integer.</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="inventoryQuantity">Inventory Quantity <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="inventoryQuantity" name="inventoryQuantity" value="${product.inventoryQuantity}" min="0" required>
                        <small class="form-text text-muted">Current stock quantity. Must be a non-negative integer.</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3">${product.description}</textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="unit">Unit <span class="text-danger">*</span></label>
                        <select class="form-control" id="unit" name="unit" required>
                            <option value="" disabled ${empty product.unit ? 'selected' : ''}>Select a unit</option>
                            <option value="KG" ${product.unit == 'KG' ? 'selected' : ''}>Kilogram (KG)</option>
                            <option value="L" ${product.unit == 'L' ? 'selected' : ''}>Liter (L)</option>
                            <option value="PCS" ${product.unit == 'PCS' ? 'selected' : ''}>Pieces (PCS)</option>
                            <option value="BOX" ${product.unit == 'BOX' ? 'selected' : ''}>Box (BOX)</option>
                            <option value="DRUM" ${product.unit == 'DRUM' ? 'selected' : ''}>Drum (DRUM)</option>
                            <option value="TON" ${product.unit == 'TON' ? 'selected' : ''}>Ton (TON)</option>
                            <option value="GAL" ${product.unit == 'GAL' ? 'selected' : ''}>Gallon (GAL)</option>
                        </select>
                    </div>
                    
                    <div class="form-group text-right">
                        <a href="${pageContext.request.contextPath}/product" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${empty product ? 'Create' : 'Update'} Product
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
