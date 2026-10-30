<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Management - Supplexio</title>
    
    <!-- Common CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/animate.css@4.1.1/animate.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/product.css">
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <div class="container-fluid">
            <!-- Page header -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="page-header-card animate__animated animate__fadeIn">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h1 class="page-title"><i class="fas fa-boxes text-primary mr-2"></i>Product Management</h1>
                                <p class="text-muted">Manage your product inventory and catalog</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/product?action=new" class="btn btn-primary btn-lg shadow-sm">
                                <i class="fas fa-plus-circle mr-2"></i> Add New Product
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
                                <div class="col-md-8">
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                                        </div>
                                        <input type="text" id="productSearch" class="form-control" placeholder="Search products...">
                                    </div>
                                </div>
                                <div class="col-md-4 mt-3 mt-md-0">
                                    <select id="categoryFilter" class="form-control">
                                        <option value="">All Categories</option>
                                        <option value="Paints">Paints</option>
                                        <option value="Coatings">Coatings</option>
                                        <option value="Primers">Primers</option>
                                        <option value="Sealants">Sealants</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Alerts section -->
            <div class="row mb-4">
                <div class="col-12">
                    <c:if test="${not empty success}">
                        <div class="alert alert-success alert-dismissible fade show animate__animated animate__fadeIn" role="alert">
                            <i class="fas fa-check-circle mr-2"></i> ${success}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show animate__animated animate__fadeIn" role="alert">
                            <i class="fas fa-exclamation-circle mr-2"></i> ${error}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </c:if>
                </div>
            </div>
            
            <!-- Products table -->
            <div class="row animate__animated animate__fadeIn animate__delay-2s">
                <div class="col-12">
                    <div class="card product-table-card">
                        <div class="card-header bg-white">
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-table text-primary mr-2"></i>Product Inventory</h5>
                                <span class="badge badge-primary badge-pill"><c:out value="${products.size()}" /> Products</span>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table id="productsTable" class="table table-borderless table-hover">
                                    <thead class="thead-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>Inventory ID</th>
                                            <th>Name</th>
                                            <th>Description</th>
                                            <th>Unit</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="product" items="${products}">
                                            <tr class="product-row">
                                                <td>
                                                    <span class="badge badge-light">#${product.id}</span>
                                                </td>
                                                <td>
                                                    <span class="badge badge-secondary">#${product.inventoryId}</span>
                                                </td>
                                                <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="product-color-dot mr-2" style="background-color: var(--supplexio-primary);"></div>
                                                    <strong>${product.name}</strong>
                                                </div>
                                                </td>
                                                <td>
                                                    <div class="product-description">${product.description}</div>
                                                </td>
                                                <td>
                                                    <span class="badge badge-info">${product.unit}</span>
                                                </td>
                                                <td>
                                                    <span class="badge badge-success">Active</span>
                                                </td>
                                                <td>
                                                    <div class="action-buttons">
                                                        <a href="${pageContext.request.contextPath}/product?action=edit&id=${product.id}" class="btn btn-sm btn-outline-primary mr-1" data-toggle="tooltip" title="Edit Product">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <a href="#" onclick="confirmDelete('${product.id}')" class="btn btn-sm btn-outline-danger" data-toggle="tooltip" title="Delete Product">
                                                            <i class="fas fa-trash-alt"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty products}">
                                            <tr>
                                                <td colspan="7" class="text-center py-5">
                                                    <div class="empty-state">
                                                        <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                                                        <h5>No products found</h5>
                                                        <p class="text-muted">Add your first product to get started</p>
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
                                <nav aria-label="Product pagination">
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
                        <p>Are you sure you want to delete this product? This action cannot be undone.</p>
                        <div class="alert alert-warning">
                            <i class="fas fa-info-circle mr-2"></i> Deleting this product will remove it from all related records and auctions.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-dismiss="modal">
                            <i class="fas fa-times mr-1"></i> Cancel
                        </button>
                        <a id="deleteLink" href="#" class="btn btn-danger">
                            <i class="fas fa-trash-alt mr-1"></i> Delete
                        </a>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- JavaScript -->
        <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
        <script src="https://cdn.datatables.net/1.10.22/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.datatables.net/1.10.22/js/dataTables.bootstrap4.min.js"></script>
        
        <script>
            $(document).ready(function() {
                // Initialize tooltips
                $('[data-toggle="tooltip"]').tooltip();
                
                // Initialize DataTable
                var table = $('#productsTable').DataTable({
                    "paging": true,
                    "ordering": true,
                    "info": true,
                    "searching": true,
                    "lengthChange": false,
                    "pageLength": 10,
                    "language": {
                        "search": "",
                        "searchPlaceholder": "Search products..."
                    },
                    "dom": '<"top"f>rt<"bottom"ip><"clear">'
                });
                
                // Connect search box
                $('#productSearch').on('keyup', function() {
                    table.search(this.value).draw();
                });
                
                // Connect category filter
                $('#categoryFilter').on('change', function() {
                    table.column(1).search(this.value).draw();
                });
                
                // Connect rows per page selector
                $('#rowsPerPage').on('change', function() {
                    table.page.len($(this).val()).draw();
                });
                
                // Highlight row on hover
                $('#productsTable tbody').on('mouseenter', 'tr', function() {
                    $(this).addClass('highlight');
                }).on('mouseleave', 'tr', function() {
                    $(this).removeClass('highlight');
                });
                
                // Function to confirm delete
                window.confirmDelete = function(id) {
                    document.getElementById('deleteLink').href = '${pageContext.request.contextPath}/product?action=delete&id=' + id;
                    $('#deleteModal').modal('show');
                };
            });
        </script>
    </div>
</body>
</html>
