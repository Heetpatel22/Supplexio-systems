<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplier Management - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.22/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/animate.css@4.1.1/animate.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/supplier.css">
    <style>
        /* Any page-specific styles not in supplier.css */
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
                <div class="supplier-header-card animate__animated animate__fadeIn">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h1 class="page-title"><i class="fas fa-building text-primary mr-2"></i>Supplier Management</h1>
                            <p class="text-muted">Manage your supplier network and partnerships</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/supplier?action=new" class="btn btn-primary btn-lg shadow-sm">
                            <i class="fas fa-plus-circle mr-2"></i> Add New Supplier
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
                                    <input type="text" id="supplierSearch" class="form-control" placeholder="Search suppliers...">
                                </div>
                            </div>
                            <div class="col-md-3 mt-3 mt-md-0">
                                <select id="statusFilter" class="form-control">
                                    <option value="">All Statuses</option>
                                    <option value="ACTIVE">Active</option>
                                    <option value="INACTIVE">Inactive</option>
                                    <option value="PENDING">Pending</option>
                                </select>
                            </div>
                            <div class="col-md-3 mt-3 mt-md-0">
                                <select id="sortBy" class="form-control">
                                    <option value="name">Sort by Name</option>
                                    <option value="id">Sort by ID</option>
                                    <option value="status">Sort by Status</option>
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
        
        <!-- Suppliers table -->
        <div class="row animate__animated animate__fadeIn animate__delay-2s">
            <div class="col-12">
                <div class="card supplier-table-card">
                    <div class="card-header bg-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0"><i class="fas fa-users text-primary mr-2"></i>Supplier Directory</h5>
                            <span class="badge badge-primary badge-pill"><c:out value="${suppliers.size()}" /> Suppliers</span>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table id="suppliersTable" class="table table-borderless table-hover">
                                <thead class="thead-light">
                                    <tr>
                                        <th>ID</th>
                                        <th>Supplier</th>
                                        <th>Contact</th>
                                        <th>Phone</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="supplier" items="${suppliers}">
                                        <tr class="supplier-row">
                                            <td>
                                                <span class="badge badge-light">#${supplier.id}</span>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="supplier-avatar">
                                                        ${fn:substring(supplier.name, 0, 1)}
                                                    </div>
                                                    <div>
                                                        <div class="supplier-name">${supplier.name}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="contact-icon">
                                                        <i class="fas fa-envelope"></i>
                                                    </div>
                                                    <div class="supplier-email">${supplier.email}</div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="contact-icon">
                                                        <i class="fas fa-phone"></i>
                                                    </div>
                                                    ${supplier.phone}
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${supplier.status == 'ACTIVE'}">
                                                        <span class="badge badge-active">Active</span>
                                                    </c:when>
                                                    <c:when test="${supplier.status == 'INACTIVE'}">
                                                        <span class="badge badge-inactive">Inactive</span>
                                                    </c:when>
                                                    <c:when test="${supplier.status == 'PENDING'}">
                                                        <span class="badge badge-pending">Pending</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary">${supplier.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <a href="${pageContext.request.contextPath}/supplier?action=edit&id=${supplier.id}" class="btn btn-sm btn-outline-primary mr-1" data-toggle="tooltip" title="Edit Supplier">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="#" onclick="confirmDelete(${supplier.id});" class="btn btn-sm btn-outline-danger" data-toggle="tooltip" title="Delete Supplier">
                                                        <i class="fas fa-trash-alt"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty suppliers}">
                                        <tr>
                                            <td colspan="6" class="text-center py-5">
                                                <div class="empty-state">
                                                    <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                                    <h5>No suppliers found</h5>
                                                    <p class="text-muted">Add your first supplier to get started</p>
                                                    <a href="${pageContext.request.contextPath}/supplier?action=new" class="btn btn-primary mt-2">
                                                        <i class="fas fa-plus-circle mr-2"></i> Add New Supplier
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
                            <nav aria-label="Supplier pagination">
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
                    <p>Are you sure you want to delete this supplier? This action cannot be undone.</p>
                    <div class="alert alert-warning">
                        <i class="fas fa-info-circle mr-2"></i> Deleting this supplier will remove them from all related records and auctions.
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
            var table = $('#suppliersTable').DataTable({
                "paging": true,
                "ordering": true,
                "info": true,
                "searching": true,
                "lengthChange": false,
                "pageLength": 10,
                "language": {
                    "search": "",
                    "searchPlaceholder": "Search suppliers..."
                },
                "dom": '<"top"f>rt<"bottom"ip><"clear">'
            });
            
            // Connect search box
            $('#supplierSearch').on('keyup', function() {
                table.search(this.value).draw();
            });
            
            // Connect status filter
            $('#statusFilter').on('change', function() {
                table.column(4).search(this.value).draw();
            });
            
            // Connect sort by dropdown
            $('#sortBy').on('change', function() {
                var column = 0;
                switch($(this).val()) {
                    case 'name':
                        column = 1;
                        break;
                    case 'id':
                        column = 0;
                        break;
                    case 'status':
                        column = 4;
                        break;
                }
                table.order([column, 'asc']).draw();
            });
            
            // Connect rows per page selector
            $('#rowsPerPage').on('change', function() {
                table.page.len($(this).val()).draw();
            });
            
            // Clear filters button
            $('#clearFilters').on('click', function() {
                $('#supplierSearch').val('');
                $('#statusFilter').val('');
                $('#sortBy').val('name');
                table.search('').columns().search('').draw();
            });
            
            // Highlight row on hover
            $('#suppliersTable tbody').on('mouseenter', 'tr', function() {
                $(this).addClass('highlight');
            }).on('mouseleave', 'tr', function() {
                $(this).removeClass('highlight');
            });
            
            // Function to confirm delete
            window.confirmDelete = function(id) {
                document.getElementById('deleteLink').href = '${pageContext.request.contextPath}/supplier?action=delete&id=' + id;
                $('#deleteModal').modal('show');
            };
        });
    </script>
</body>
</html>
