<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Task - Supplexio</title>
    
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
        
        .detail-label {
            font-weight: bold;
            color: #555;
        }
        
        .detail-value {
            margin-bottom: 15px;
        }
        
        .detail-description {
            background-color: white;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid var(--axalta-blue);
        }
    </style>
</head>
<body>
    <!-- Include sidebar -->
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />
    
    <!-- Main content -->
    <div class="main-content">
        <div class="container">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">Home</a></li>
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/todo">To-Do List</a></li>
                    <li class="breadcrumb-item active" aria-current="page">View Task #${todo.id}</li>
                </ol>
            </nav>
            
            <c:if test="${empty todo}">
                <div class="alert alert-danger">
                    Task not found.
                </div>
            </c:if>
            
            <c:if test="${not empty todo}">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">Task Details</h4>
                        <div>
                            <a href="${pageContext.request.contextPath}/todo?action=edit&id=${todo.id}" class="btn btn-light btn-sm">
                                <i class="fas fa-edit"></i> Edit
                            </a>
                            <c:if test="${todo.status != 'COMPLETED'}">
                                <form action="${pageContext.request.contextPath}/todo" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="complete">
                                    <input type="hidden" name="id" value="${todo.id}">
                                    <button type="submit" class="btn btn-success btn-sm">
                                        <i class="fas fa-check"></i> Mark as Completed
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <p>
                                    <span class="detail-label">Title:</span><br>
                                    <span class="detail-value">${todo.title}</span>
                                </p>
                                
                                <p>
                                    <span class="detail-label">Priority:</span><br>
                                    <span class="detail-value">
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
                                    </span>
                                </p>
                                
                                <p>
                                    <span class="detail-label">Status:</span><br>
                                    <span class="detail-value">
                                        <c:choose>
                                            <c:when test="${todo.status == 'COMPLETED'}">
                                                <span class="badge badge-completed">Completed</span>
                                            </c:when>
                                            <c:when test="${todo.status == 'PENDING'}">
                                                <span class="badge badge-pending">Pending</span>
                                            </c:when>
                                        </c:choose>
                                    </span>
                                </p>
                            </div>
                            
                            <div class="col-md-6">
                                <p>
                                    <span class="detail-label">Due Date:</span><br>
                                    <span class="detail-value">
                                        <c:choose>
                                            <c:when test="${empty todo.dueDate}">No due date</c:when>
                                            <c:otherwise>
                                                <fmt:formatDate value="${todo.dueDate}" pattern="yyyy-MM-dd" />
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </p>
                                
                                <p>
                                    <span class="detail-label">Created:</span><br>
                                    <span class="detail-value">
                                        <fmt:formatDate value="${todo.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                                    </span>
                                </p>
                                
                                <p>
                                    <span class="detail-label">Last Updated:</span><br>
                                    <span class="detail-value">
                                        <fmt:formatDate value="${todo.updatedAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                                    </span>
                                </p>
                            </div>
                        </div>
                        
                        <div class="row mt-3">
                            <div class="col-md-12">
                                <span class="detail-label">Description:</span>
                                <div class="detail-description mt-2">
                                    <c:choose>
                                        <c:when test="${empty todo.description}">
                                            <em>No description provided</em>
                                        </c:when>
                                        <c:otherwise>
                                            ${todo.description}
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <a href="${pageContext.request.contextPath}/todo" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to List
                        </a>
                        <a href="${pageContext.request.contextPath}/todo?action=delete&id=${todo.id}" 
                           class="btn btn-danger float-right" 
                           onclick="return confirm('Are you sure you want to delete this task?')">
                            <i class="fas fa-trash"></i> Delete
                        </a>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
