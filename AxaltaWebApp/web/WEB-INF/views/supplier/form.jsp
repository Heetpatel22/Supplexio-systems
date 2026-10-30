<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty supplier ? 'Add New' : 'Edit'} Supplier - Supplexio</title>
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
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/supplier">Supplier Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">${empty supplier ? 'Add New' : 'Edit'} Supplier</li>
            </ol>
        </nav>
        
        <div class="card">
            <div class="card-header">
                <h4 class="mb-0">${empty supplier ? 'Add New' : 'Edit'} Supplier</h4>
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
                
                <form method="post" action="${pageContext.request.contextPath}/supplier">
                    <input type="hidden" name="action" value="${empty supplier ? 'create' : 'update'}">
                    <c:if test="${not empty supplier}">
                        <input type="hidden" name="id" value="${supplier.id}">
                    </c:if>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="name">Name <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="name" name="name" value="${supplier.name}" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="email">Email <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" id="email" name="email" value="${supplier.email}" required>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="phone">Phone <span class="text-danger">*</span></label>
                                <input type="tel" class="form-control" id="phone" name="phone" value="${supplier.phone}" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="status">Status</label>
                                <select class="form-control" id="status" name="status">
                                    <option value="ACTIVE" ${supplier.status == 'ACTIVE' || empty supplier.status ? 'selected' : ''}>Active</option>
                                    <option value="INACTIVE" ${supplier.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                                    <option value="PENDING" ${supplier.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="address">Address</label>
                        <textarea class="form-control" id="address" name="address" rows="3">${supplier.address}</textarea>
                    </div>
                    
                    <div class="form-group text-right">
                        <a href="${pageContext.request.contextPath}/supplier" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${empty supplier ? 'Create' : 'Update'} Supplier
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
