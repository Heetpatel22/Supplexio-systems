<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - Supplexio</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/supplexio-theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        body {
            padding-left: 250px;
            background: #f5f6fa;
        }
        .main-content {
            margin-left: 0;
            padding: 2rem;
        }
        @media (max-width: 991px) {
            body {
                padding-left: 0;
            }
            .main-content {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/sidebar.jsp" />

    <div class="main-content">
        <div class="page-header">
            <h1 class="page-title">Edit User: ${user.username}</h1>
            <a href="${pageContext.request.contextPath}/settings?action=users" class="btn-supplexio">
                <i class="fas fa-arrow-left"></i> Back to Users
            </a>
        </div>

        <div class="form-container">
            <c:if test="${not empty errors}">
                <div class="alert alert-danger">
                    <strong>Please fix the following errors:</strong>
                    <ul class="error-list">
                        <c:forEach items="${errors}" var="error">
                            <li>${error}</li>
                        </c:forEach>
                    </ul>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/settings" method="post">
                <input type="hidden" name="action" value="updateUser">
                <input type="hidden" name="id" value="${user.id}">

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="username">Username <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="username" name="username" value="${user.username}" required>
                            <small class="form-text text-muted">Username must be between 3 and 50 characters.</small>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="email">Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="email" name="email" value="${user.email}" required>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="role">Role <span class="text-danger">*</span></label>
                            <select class="form-control" id="role" name="role" required>
                                <option value="">Select Role</option>
                                <option value="ADMIN" ${user.role eq 'ADMIN' ? 'selected' : ''}>Admin</option>
                                <option value="USER" ${user.role eq 'USER' ? 'selected' : ''}>User</option>
                                <option value="SUPPLIER" ${user.role eq 'SUPPLIER' ? 'selected' : ''}>Supplier</option>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="status">Status <span class="text-danger">*</span></label>
                            <select class="form-control" id="status" name="status" required>
                                <option value="">Select Status</option>
                                <option value="ACTIVE" ${user.status eq 'ACTIVE' ? 'selected' : ''}>Active</option>
                                <option value="INACTIVE" ${user.status eq 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                                <option value="BLOCKED" ${user.status eq 'BLOCKED' ? 'selected' : ''}>Blocked</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="password-section">
                    <h5>Change Password</h5>
                    <p class="text-muted">Leave blank to keep current password</p>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="password">New Password</label>
                                <input type="password" class="form-control" id="password" name="password">
                                <small class="form-text text-muted">Password must be at least 6 characters.</small>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="confirmPassword">Confirm New Password</label>
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-supplexio">
                        <i class="fas fa-save"></i> Update User
                    </button>
                    <a href="${pageContext.request.contextPath}/settings?action=users" class="btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </form>
        </div>

        <div class="footer-text">
            <p>Global leader in coatings providing customers with innovative, colorful, beautiful and sustainable solutions.</p>
            <p>&copy; ${java.time.Year.now().getValue()} Supplexio. All rights reserved.</p>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>
</body>
</html>
