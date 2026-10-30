<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<header>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/">
                <div class="logo-container">
                    <img src="${pageContext.request.contextPath}/assets/images/supplexio-logo.png" alt="Supplexio Logo" class="logo-img">
                </div>
            </a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item">
                        <a class="nav-link ${pageContext.request.servletPath eq '/index.jsp' ? 'active' : ''}" href="${pageContext.request.contextPath}/">
                            <i class="fas fa-home"></i> Home
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${pageContext.request.servletPath eq '/product.jsp' ? 'active' : ''}" href="${pageContext.request.contextPath}/product">
                            <i class="fas fa-box"></i> Products
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${pageContext.request.servletPath eq '/auction.jsp' ? 'active' : ''}" href="${pageContext.request.contextPath}/auction">
                            <i class="fas fa-gavel"></i> Reverse Auctions
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${pageContext.request.servletPath eq '/supplier.jsp' ? 'active' : ''}" href="${pageContext.request.contextPath}/supplier">
                            <i class="fas fa-truck"></i> Suppliers
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${pageContext.request.servletPath eq '/payment.jsp' ? 'active' : ''}" href="${pageContext.request.contextPath}/payment">
                            <i class="fas fa-credit-card"></i> Payments
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${pageContext.request.servletPath eq '/todo.jsp' ? 'active' : ''}" href="${pageContext.request.contextPath}/todo">
                            <i class="fas fa-tasks"></i> To-Do List
                        </a>
                    </li>
                    <c:if test="${sessionScope.userRole eq 'SUPPLIER'}">
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.servletPath eq '/bidding.jsp' ? 'active' : ''}" href="${pageContext.request.contextPath}/bidding">
                                <i class="fas fa-hand-paper"></i> Supplier Bidding
                            </a>
                        </li>
                    </c:if>
                    <c:if test="${sessionScope.userRole eq 'ADMIN'}">
                        <li class="nav-item">
                            <a class="nav-link ${pageContext.request.servletPath eq '/WEB-INF/views/settings/users.jsp' ? 'active' : ''}" href="${pageContext.request.contextPath}/settings?action=users">
                                <i class="fas fa-cog"></i> Settings
                            </a>
                        </li>
                    </c:if>
                </ul>
                <div class="navbar-nav ml-auto">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <div class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <i class="fas fa-user-circle"></i> ${sessionScope.user.username}
                                </a>
                                <div class="dropdown-menu dropdown-menu-right" aria-labelledby="navbarDropdown">
                                    <div class="dropdown-item text-muted">
                                        <small>Role: ${sessionScope.userRole}</small>
                                    </div>
                                    <div class="dropdown-divider"></div>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/auth?action=logout">
                                        <i class="fas fa-sign-out-alt"></i> Logout
                                    </a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <a class="nav-link" href="${pageContext.request.contextPath}/login.jsp">
                                <i class="fas fa-sign-in-alt"></i> Login
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </nav>
    <div class="tagline bg-light text-center py-1">
        <small>EMPOWERING SUPPLY CHAIN EXCELLENCE</small>
    </div>
</header>
