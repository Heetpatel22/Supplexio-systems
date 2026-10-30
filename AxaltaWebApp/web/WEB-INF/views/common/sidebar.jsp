<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="sidebar">
    <div class="sidebar-header">
        <a href="${pageContext.request.contextPath}/home">
            <img src="${pageContext.request.contextPath}/assets/img/supplexio-logo.png" alt="Supplexio Logo" class="sidebar-logo" />
        </a>
    </div>

    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/home" class="nav-link ${pageContext.request.servletPath.contains('/home') ? 'active' : ''}">
            Dashboard
        </a>

        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link ${pageContext.request.servletPath.contains('/product') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/product">
                    <i class="fas fa-box"></i> Products
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link ${pageContext.request.servletPath.contains('/auction') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/auction">
                    <i class="fas fa-gavel"></i> Reverse Auctions
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link ${pageContext.request.servletPath.contains('/supplier') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/supplier">
                    <i class="fas fa-users"></i> Suppliers
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link ${pageContext.request.servletPath.contains('/payment') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/payment">
                    <i class="fas fa-money-bill-wave"></i> Payments
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link ${pageContext.request.servletPath.contains('/todo') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/todo">
                    <i class="fas fa-tasks"></i> To-Do List
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link ${pageContext.request.servletPath.contains('/bidding') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/bidding">
                    <i class="fas fa-hand-paper"></i> Supplier Bidding
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link ${pageContext.request.servletPath.contains('/inventory') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/inventory">
                    <i class="fas fa-warehouse"></i> Inventory Management
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link ${pageContext.request.requestURI.contains('/user-po-view') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/user-po-view">
                    <i class="fas fa-file-invoice"></i> Purchase Orders
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link ${pageContext.request.servletPath.contains('/settings') ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/settings?action=users">
                    <i class="fas fa-cog"></i> Settings
                </a>
            </li>
        </ul>
    </nav>
</div>
