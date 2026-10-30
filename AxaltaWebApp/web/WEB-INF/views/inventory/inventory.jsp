<!-- filepath: c:\Users\vaibh\CascadeProjects\AxaltaWebApp\web\WEB-INF\views\inventory\inventory.jsp -->
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Inventory Management</title>
    <link href="${pageContext.request.contextPath}/assets/css/common.css" rel="stylesheet" type="text/css"/>
    <style>
        .crud-form input[type="text"], .crud-form input[type="number"] { width: 120px; }
        .crud-form { margin-bottom: 2rem; }
        .crud-btn { padding: 0.2rem 0.7rem; border-radius: 4px; border: none; cursor: pointer; }
        .crud-btn.add { background: #2ecc71; color: #fff; }
        .crud-btn.update { background: #3498db; color: #fff; }
        .crud-btn.delete { background: #e74c3c; color: #fff; }
    </style>
</head>
<body>
    <div class="sidebar">
        <%@ include file="../common/sidebar.jsp" %>
    </div>
    <div class="main-content">
        <div class="page-header" style="margin-bottom: 2rem;">
            <h1>Inventory Management</h1>
            <p>Manage your inventory items below.</p>
        </div>
        <!-- Add Item Form -->
        <form class="crud-form" method="post" action="${pageContext.request.contextPath}/inventory">
            <input type="hidden" name="action" value="add"/>
            <input type="text" name="itemName" placeholder="Item Name" required/>
            <input type="number" name="quantity" placeholder="Quantity" min="0" required/>
            <input type="number" name="threshold" placeholder="Threshold" min="0" required/>
            <button type="submit" class="crud-btn add">Add Item</button>
        </form>
        <!-- Inventory Table -->
        <div class="card commodities-table">
            <div class="card-body">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Item Name</th>
                            <th>Quantity</th>
                            <th>Threshold</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="inv" items="${inventoryList}">
                            <tr>
                                <form method="post" action="${pageContext.request.contextPath}/inventory">
                                    <td>${inv.id}<input type="hidden" name="id" value="${inv.id}"/></td>
                                    <td><input type="text" name="itemName" value="${inv.itemName}" required/></td>
                                    <td><input type="number" name="quantity" value="${inv.quantity}" min="0" required/></td>
                                    <td><input type="number" name="threshold" value="${inv.threshold}" min="0" required/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${inv.quantity < inv.threshold}">
                                                <span style="color:#e74c3c;">To Order</span>
                                            </c:when>
                                            <c:when test="${inv.quantity == inv.threshold}">
                                                <span style="color:#f1c40f;">At Threshold</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:#2ecc71;">In Stock</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <button type="submit" name="action" value="update" class="crud-btn update">Update</button>
                                        <button type="submit" name="action" value="delete" class="crud-btn delete" onclick="return confirm('Delete this item?');">Delete</button>
                                    </td>
                                </form>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>