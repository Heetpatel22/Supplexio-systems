<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>To-Do List - Supplexio</title>
    
    <!-- Common CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    
    <style>
        
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
        
        .btn-success {
            background-color: #28a745;
            border-color: #28a745;
        }
        
        .btn-success:hover {
            background-color: #218838;
            border-color: #1e7e34;
        }
        
        .table th {
            background-color: var(--accent-color);
        }
        
        .alert {
            border-radius: 10px;
        }
        
        .badge-high {
            background-color: #dc3545;
        }
        
        .badge-medium {
            background-color: #ffc107;
            color: #212529;
        }
        
        .badge-low {
            background-color: #17a2b8;
        }
        
        .badge-completed {
            background-color: #28a745;
        }
        
        .badge-pending {
            background-color: #6c757d;
        }
        
        .todo-completed {
            text-decoration: line-through;
            color: #6c757d;
        }
        
        .filter-form {
            background-color: white;
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <div class="container">
            <h1 class="mt-4 mb-4">To-Do List</h1>
            
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
            
            <div class="row mb-4">
                <div class="col-md-12">
                    <div class="filter-form">
                        <form action="${pageContext.request.contextPath}/todo" method="get" class="row align-items-end">
                            <div class="col-md-4 form-group">
                                <label for="statusFilter">Status:</label>
                                <select name="status" id="statusFilter" class="form-control">
                                    <option value="ALL" ${statusFilter == 'ALL' || empty statusFilter ? 'selected' : ''}>All</option>
                                    <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>Pending</option>
                                    <option value="COMPLETED" ${statusFilter == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                </select>
                            </div>
                            <div class="col-md-4 form-group">
                                <label for="priorityFilter">Priority:</label>
                                <select name="priority" id="priorityFilter" class="form-control">
                                    <option value="ALL" ${priorityFilter == 'ALL' || empty priorityFilter ? 'selected' : ''}>All</option>
                                    <option value="HIGH" ${priorityFilter == 'HIGH' ? 'selected' : ''}>High</option>
                                    <option value="MEDIUM" ${priorityFilter == 'MEDIUM' ? 'selected' : ''}>Medium</option>
                                    <option value="LOW" ${priorityFilter == 'LOW' ? 'selected' : ''}>Low</option>
                                </select>
                            </div>
                            <div class="col-md-4 form-group">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-filter"></i> Filter
                                </button>
                                <a href="${pageContext.request.contextPath}/todo" class="btn btn-secondary ml-2">
                                    <i class="fas fa-redo"></i> Reset
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h4 class="mb-0">Tasks</h4>
                    <a href="${pageContext.request.contextPath}/todo?action=new" class="btn btn-light">
                        <i class="fas fa-plus"></i> Add New Task
                    </a>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Due Date</th>
                                    <th>Priority</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty todos}">
                                        <tr>
                                            <td colspan="5" class="text-center">No tasks found</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="todo" items="${todos}">
                                            <tr>
                                                <td class="${todo.status == 'COMPLETED' ? 'todo-completed' : ''}">
                                                    ${todo.title}
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${empty todo.dueDate}">No due date</c:when>
                                                        <c:otherwise>
                                                            <fmt:formatDate value="${todo.dueDate}" pattern="yyyy-MM-dd" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${todo.priority == 'HIGH'}">
                                                            <span class="badge badge-high">High</span>
                                                        </c:when>
                                                        <c:when test="${todo.priority == 'MEDIUM'}">
                                                            <span class="badge badge-medium">Medium</span>
                                                        </c:when>
                                                        <c:when test="${todo.priority == 'LOW'}">
                                                            <span class="badge badge-low">Low</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${todo.status == 'COMPLETED'}">
                                                            <span class="badge badge-completed">Completed</span>
                                                        </c:when>
                                                        <c:when test="${todo.status == 'PENDING'}">
                                                            <span class="badge badge-pending">Pending</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <div class="btn-group" role="group">
                                                        <a href="${pageContext.request.contextPath}/todo?action=view&id=${todo.id}" 
                                                           class="btn btn-sm btn-info" title="View">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/todo?action=edit&id=${todo.id}" 
                                                           class="btn btn-sm btn-primary" title="Edit">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <c:if test="${todo.status != 'COMPLETED'}">
                                                            <form action="${pageContext.request.contextPath}/todo" method="post" class="d-inline">
                                                                <input type="hidden" name="action" value="complete">
                                                                <input type="hidden" name="id" value="${todo.id}">
                                                                <button type="submit" class="btn btn-sm btn-success" title="Mark as Completed">
                                                                    <i class="fas fa-check"></i>
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                        <a href="${pageContext.request.contextPath}/todo?action=delete&id=${todo.id}" 
                                                           class="btn btn-sm btn-danger" 
                                                           onclick="return confirm('Are you sure you want to delete this task?')" title="Delete">
                                                            <i class="fas fa-trash"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
