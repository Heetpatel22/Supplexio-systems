<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty todo ? 'Add New Task' : 'Edit Task'} - Supplexio</title>
    
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
        
        .alert {
            border-radius: 10px;
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
                    <li class="breadcrumb-item active" aria-current="page">${empty todo ? 'Add New Task' : 'Edit Task'}</li>
                </ol>
            </nav>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${error}
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </c:if>
            
            <div class="card">
                <div class="card-header">
                    <h4 class="mb-0">${empty todo ? 'Add New Task' : 'Edit Task'}</h4>
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/todo" method="post">
                        <input type="hidden" name="action" value="${empty todo ? 'create' : 'update'}">
                        <c:if test="${not empty todo}">
                            <input type="hidden" name="id" value="${todo.id}">
                        </c:if>
                        
                        <div class="form-group">
                            <label for="title">Title <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="title" name="title" 
                                   value="${todo.title}" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea class="form-control" id="description" name="description" 
                                      rows="4">${todo.description}</textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="dueDate">Due Date</label>
                            <input type="date" class="form-control" id="dueDate" name="dueDate" 
                                   value="<fmt:formatDate value="${todo.dueDate}" pattern="yyyy-MM-dd" />">
                        </div>
                        
                        <div class="form-group">
                            <label for="priority">Priority</label>
                            <select class="form-control" id="priority" name="priority">
                                <option value="HIGH" ${todo.priority == 'HIGH' ? 'selected' : ''}>High</option>
                                <option value="MEDIUM" ${todo.priority == 'MEDIUM' || empty todo.priority ? 'selected' : ''}>Medium</option>
                                <option value="LOW" ${todo.priority == 'LOW' ? 'selected' : ''}>Low</option>
                            </select>
                        </div>
                        
                        <c:if test="${not empty todo}">
                            <div class="form-group">
                                <label for="status">Status</label>
                                <select class="form-control" id="status" name="status">
                                    <option value="PENDING" ${todo.status == 'PENDING' || empty todo.status ? 'selected' : ''}>Pending</option>
                                    <option value="COMPLETED" ${todo.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                </select>
                            </div>
                        </c:if>
                        
                        <div class="form-group mt-4">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> ${empty todo ? 'Create Task' : 'Update Task'}
                            </button>
                            <a href="${pageContext.request.contextPath}/todo" class="btn btn-secondary ml-2">
                                <i class="fas fa-times"></i> Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
