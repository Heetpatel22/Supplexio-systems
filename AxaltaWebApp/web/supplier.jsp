<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplier Management - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/supplier.css">
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
    <div class="header text-center">
        <div class="container">
            <h1>SUPPLEXIO</h1>
            <div class="divider">
                <span class="divider-text">Performance Coatings Excellence</span>
            </div>
            <p>Supplier Management</p>
        </div>
    </div>
    
    <div class="container">
        <div class="row mb-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span>Supplier List</span>
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addSupplierModal">
                            <i class="fas fa-plus"></i> Add New Supplier
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <div class="input-group">
                                    <input type="text" id="supplierSearch" class="form-control" placeholder="Search suppliers...">
                                    <div class="input-group-append">
                                        <button class="btn btn-primary" type="button" id="searchButton">
                                            <i class="fas fa-search"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group mb-0">
                                    <select id="statusFilter" class="form-control">
                                        <option value="ALL">All Statuses</option>
                                        <option value="ACTIVE">Active</option>
                                        <option value="PENDING">Pending</option>
                                        <option value="INACTIVE">Inactive</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Company</th>
                                        <th>Contact Name</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="supplierTableBody">
                                    <c:forEach items="${suppliers}" var="supplier">
                                        <tr>
                                            <td>${supplier.id}</td>
                                            <td>${supplier.company}</td>
                                            <td>${supplier.name}</td>
                                            <td>${supplier.email}</td>
                                            <td>${supplier.phone}</td>
                                            <td>
                                                <span class="badge badge-${supplier.status == 'ACTIVE' ? 'active' : supplier.status == 'PENDING' ? 'pending' : 'inactive'}">
                                                    ${supplier.status}
                                                </span>
                                            </td>
                                            <td>
                                                <button class="btn btn-sm btn-primary edit-supplier" data-id="${supplier.id}">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                                <button class="btn btn-sm btn-danger delete-supplier" data-id="${supplier.id}">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-12 text-center">
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                    <i class="fas fa-home"></i> Back to Dashboard
                </a>
            </div>
        </div>
    </div>
    
    <!-- Add Supplier Modal -->
    <div class="modal fade" id="addSupplierModal" tabindex="-1" role="dialog" aria-labelledby="addSupplierModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="addSupplierModalLabel">Add New Supplier</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form id="addSupplierForm" action="${pageContext.request.contextPath}/supplier" method="post">
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="supplierCompany">Company</label>
                            <input type="text" class="form-control" id="supplierCompany" name="company" required>
                        </div>
                        <div class="form-group">
                            <label for="supplierName">Contact Name</label>
                            <input type="text" class="form-control" id="supplierName" name="name" required>
                        </div>
                        <div class="form-group">
                            <label for="supplierEmail">Email</label>
                            <input type="email" class="form-control" id="supplierEmail" name="email" required>
                        </div>
                        <div class="form-group">
                            <label for="supplierPhone">Phone</label>
                            <input type="text" class="form-control" id="supplierPhone" name="phone" required>
                        </div>
                        <div class="form-group">
                            <label for="supplierStatus">Status</label>
                            <select class="form-control" id="supplierStatus" name="status" required>
                                <option value="ACTIVE">Active</option>
                                <option value="PENDING">Pending</option>
                                <option value="INACTIVE">Inactive</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save Supplier</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Edit Supplier Modal -->
    <div class="modal fade" id="editSupplierModal" tabindex="-1" role="dialog" aria-labelledby="editSupplierModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="editSupplierModalLabel">Edit Supplier</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form id="editSupplierForm" action="${pageContext.request.contextPath}/supplier" method="post">
                    <input type="hidden" id="editSupplierId" name="id">
                    <input type="hidden" name="action" value="update">
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="editSupplierCompany">Company</label>
                            <input type="text" class="form-control" id="editSupplierCompany" name="company" required>
                        </div>
                        <div class="form-group">
                            <label for="editSupplierName">Contact Name</label>
                            <input type="text" class="form-control" id="editSupplierName" name="name" required>
                        </div>
                        <div class="form-group">
                            <label for="editSupplierEmail">Email</label>
                            <input type="email" class="form-control" id="editSupplierEmail" name="email" required>
                        </div>
                        <div class="form-group">
                            <label for="editSupplierPhone">Phone</label>
                            <input type="text" class="form-control" id="editSupplierPhone" name="phone" required>
                        </div>
                        <div class="form-group">
                            <label for="editSupplierStatus">Status</label>
                            <select class="form-control" id="editSupplierStatus" name="status" required>
                                <option value="ACTIVE">Active</option>
                                <option value="PENDING">Pending</option>
                                <option value="INACTIVE">Inactive</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update Supplier</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteSupplierModal" tabindex="-1" role="dialog" aria-labelledby="deleteSupplierModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title" id="deleteSupplierModalLabel">Confirm Delete</h5>
                    <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this supplier? This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <form id="deleteSupplierForm" action="${pageContext.request.contextPath}/supplier" method="post">
                        <input type="hidden" id="deleteSupplierId" name="id">
                        <input type="hidden" name="action" value="delete">
                        <button type="submit" class="btn btn-danger">Delete</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    </div> <!-- End of main-content -->
    
    <footer class="footer text-center">
        <div class="container">
            <p>&copy; <%= java.time.Year.now().getValue() %> Supplexio. All rights reserved.</p>
        </div>
    </footer>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function() {
            // Edit supplier button click
            $('.edit-supplier').click(function() {
                var supplierId = $(this).data('id');
                // AJAX call to get supplier details
                $.ajax({
                    url: '${pageContext.request.contextPath}/supplier',
                    type: 'GET',
                    data: {
                        id: supplierId,
                        action: 'get'
                    },
                    success: function(response) {
                        var supplier = JSON.parse(response);
                        $('#editSupplierId').val(supplier.id);
                        $('#editSupplierCompany').val(supplier.company);
                        $('#editSupplierName').val(supplier.name);
                        $('#editSupplierEmail').val(supplier.email);
                        $('#editSupplierPhone').val(supplier.phone);
                        $('#editSupplierStatus').val(supplier.status);
                        $('#editSupplierModal').modal('show');
                    },
                    error: function(xhr, status, error) {
                        alert('Error fetching supplier details: ' + error);
                    }
                });
            });
            
            // Delete supplier button click
            $('.delete-supplier').click(function() {
                var supplierId = $(this).data('id');
                $('#deleteSupplierId').val(supplierId);
                $('#deleteSupplierModal').modal('show');
            });
            
            // Filter suppliers by status
            $('#statusFilter').change(function() {
                var status = $(this).val();
                filterSuppliers(status);
            });
            
            // Search suppliers
            $('#searchButton').click(function() {
                var searchTerm = $('#supplierSearch').val().toLowerCase();
                searchSuppliers(searchTerm);
            });
            
            // Enter key in search box
            $('#supplierSearch').keypress(function(e) {
                if (e.which == 13) {
                    var searchTerm = $(this).val().toLowerCase();
                    searchSuppliers(searchTerm);
                    e.preventDefault();
                }
            });
            
            function filterSuppliers(status) {
                if (status === 'ALL') {
                    $('#supplierTableBody tr').show();
                } else {
                    $('#supplierTableBody tr').hide();
                    $('#supplierTableBody tr').each(function() {
                        var rowStatus = $(this).find('td:eq(5) span').text().trim();
                        if (rowStatus === status) {
                            $(this).show();
                        }
                    });
                }
            }
            
            function searchSuppliers(term) {
                $('#supplierTableBody tr').hide();
                $('#supplierTableBody tr').each(function() {
                    var company = $(this).find('td:eq(1)').text().toLowerCase();
                    var name = $(this).find('td:eq(2)').text().toLowerCase();
                    var email = $(this).find('td:eq(3)').text().toLowerCase();
                    
                    if (company.includes(term) || name.includes(term) || email.includes(term)) {
                        $(this).show();
                    }
                });
            }
        });
    </script>
</body>
</html>
