<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List poList = (List) request.getAttribute("poList");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <title>All Purchase Orders</title>
    <link rel="stylesheet" href="assets/css/common.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        body {
            padding-left: 250px;
        }
        .main-content {
            margin-left: 0;
            padding: 2rem;
            width: 100%;
        }
        .table-responsive {
            width: 100%;
            margin: 0;
        }
        @media (max-width: 991px) {
            body {
                padding-left: 0;
            }
            .sidebar {
                display: none;
            }
            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>
<jsp:include page="WEB-INF/views/common/sidebar.jsp" />

<div class="main-content">
    <div style="background: white; padding: 2rem; border-radius: 10px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); margin-bottom: 2rem;">
        <h1 style="margin: 0; display: flex; align-items: center; font-size: 2.5rem; color: #333;">
            <i class="fas fa-file-invoice" style="color: #007bff; margin-right: 1rem;"></i>
            All Purchase Orders
        </h1>
        <p style="margin: 0.5rem 0 0 0; color: #666; font-size: 1.1rem;">Track all purchase orders, view details, and manage supplier communications</p>
    </div>

    <div class="table-responsive">
        <table class="table table-striped table-bordered align-middle">
            <thead class="table-dark">
                <tr>
                    <th>PO ID</th>
                    <th>Supplier Name</th>
                    <th>Material</th>
                    <th>Amount</th>
                    <th>GST (7.5%)</th>
                    <th>Total (incl. GST)</th>
                    <th>Status</th>
                    <th>Created At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (poList != null && !poList.isEmpty()) {
                for (Object obj : poList) {
                    Class<?> beanClass = obj.getClass();
                    double amount = Double.parseDouble(beanClass.getMethod("getAmount").invoke(obj).toString());
                    double gst = amount * 0.075;
                    double total = amount * 1.075;
                    String status = String.valueOf(beanClass.getMethod("getStatus").invoke(obj));
            %>
                <tr>
                    <td><%= beanClass.getMethod("getId").invoke(obj) %></td>
                    <td><%= beanClass.getMethod("getCompanyName").invoke(obj) %></td>
                    <td><%= beanClass.getMethod("getMaterial").invoke(obj) %></td>
                    <td>&#8377;<%= String.format("%.2f", amount) %></td>
                    <td>&#8377;<%= String.format("%.2f", gst) %></td>
                    <td>&#8377;<%= String.format("%.2f", total) %></td>
                    <td>
    <% if ("COMPLETED".equalsIgnoreCase(status)) { %>
        <span class="badge bg-secondary">COMPLETED</span>
    <% } else if ("SENT".equalsIgnoreCase(status)) { %>
        <span class="badge bg-primary">SENT</span>
    <% } else if ("PAYMENT_PENDING".equalsIgnoreCase(status)) { %>
        <span class="badge bg-warning text-dark">PAYMENT PENDING</span>
    <% } else if ("PAID".equalsIgnoreCase(status)) { %>
        <span class="badge bg-info">PAYMENT SUCCESSFUL</span>
    <% } else if ("DELIVERED".equalsIgnoreCase(status)) { %>
        <span class="badge bg-success">DELIVERED</span>
    <% } else { %>
        <span class="badge bg-dark"><%= status %></span>
    <% } %>
</td>

                    <td><%= sdf.format(beanClass.getMethod("getCreatedAt").invoke(obj)) %></td>
                    <td>
    <% if ("COMPLETED".equalsIgnoreCase(status)) { %>
        <form method="post" action="send-po-to-supplier" style="display:inline;">
            <input type="hidden" name="poId" value="<%= beanClass.getMethod("getId").invoke(obj) %>" />
            <button type="submit" class="btn btn-sm btn-primary">Send PO to Supplier</button>
        </form>
    <% } else if ("PAYMENT_PENDING".equalsIgnoreCase(status)) { %>
        <button type="button" class="btn btn-sm btn-warning" disabled>Payment Pending</button>
    <% } %>

    <% if ("PAID".equalsIgnoreCase(status) || "DELIVERED".equalsIgnoreCase(status)) { %>
        <form method="get" action="download-po-pdf" style="display:inline;">
            <input type="hidden" name="poId" value="<%= beanClass.getMethod("getId").invoke(obj) %>" />
            <button type="submit" class="btn btn-sm btn-success">Download as PDF</button>
        </form>
    <% } else { %>
        <button type="button" class="btn btn-sm btn-success" disabled>Download as PDF</button>
    <% } %>
</td>

                </tr>
            <%  }
            } else { %>
                <tr>
                    <td colspan="9" class="text-center">No purchase orders found.</td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="WEB-INF/views/includes/footer.jsp" />
</body>
</html>
