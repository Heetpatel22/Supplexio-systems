<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List poList = (List) request.getAttribute("poList");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String successMsg = (String) request.getSession().getAttribute("success");
    String errorMsg = (String) request.getSession().getAttribute("error");
    if (successMsg != null) request.getSession().removeAttribute("success");
    if (errorMsg != null) request.getSession().removeAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Purchase Orders</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/common.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        body { background: #f5f6fa; }
        .po-header-bar {
            background: linear-gradient(135deg, #1a237e 0%, #1565c0 100%);
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.8rem;
        }
        .po-header-bar i { font-size: 1.3rem; }
        .po-header-bar span { font-size: 1.1rem; font-weight: 700; }
        .badge-sent      { background:#007bff; color:white; padding:4px 10px; border-radius:4px; }
        .badge-pending   { background:#ffc107; color:#333; padding:4px 10px; border-radius:4px; }
        .badge-confirmed { background:#28a745; color:white; padding:4px 10px; border-radius:4px; }
        .badge-delivered { background:#17a2b8; color:white; padding:4px 10px; border-radius:4px; }
        .badge-draft     { background:#6c757d; color:white; padding:4px 10px; border-radius:4px; }
    </style>
</head>
<body>

<div style="max-width:1100px; margin:2rem auto; padding:0 1rem;">

    <!-- Blue header bar -->
    <div class="po-header-bar">
        <i class="fas fa-file-invoice"></i>
        <span>My Purchase Orders</span>
    </div>

    <!-- Back to bidding portal -->
    <a href="<%= request.getContextPath() %>/bidding"
       class="btn btn-secondary btn-sm mb-3">
        <i class="fas fa-arrow-left"></i> Back to Bidding Portal
    </a>

    <!-- Success / Error alerts -->
    <% if (successMsg != null) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="fas fa-check-circle"></i> <%= successMsg %>
            <button type="button" class="close" data-dismiss="alert">&times;</button>
        </div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="fas fa-exclamation-circle"></i> <%= errorMsg %>
            <button type="button" class="close" data-dismiss="alert">&times;</button>
        </div>
    <% } %>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-striped table-bordered mb-0">
                    <thead class="thead-dark">
                        <tr>
                            <th>PO ID</th>
                            <th>PO Number</th>
                            <th>Material</th>
                            <th>Qty</th>
                            <th>Amount</th>
                            <th>GST (7.5%)</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (poList != null && !poList.isEmpty()) {
                        for (Object obj : poList) {
                            Class<?> bc = obj.getClass();
                            long   poId     = (Long)   bc.getMethod("getId").invoke(obj);
                            String material = (String) bc.getMethod("getMaterial").invoke(obj);
                            String poNumber = "";
                            try { poNumber = (String) bc.getMethod("getPoNumber").invoke(obj); } catch(Exception e) {}
                            if (poNumber == null || poNumber.isEmpty()) poNumber = "PO-" + poId;
                            double amount   = (Double) bc.getMethod("getAmount").invoke(obj);
                            int    qty      = (Integer)bc.getMethod("getQuantity").invoke(obj);
                            String status   = (String) bc.getMethod("getStatus").invoke(obj);
                            java.util.Date createdAt = (java.util.Date) bc.getMethod("getCreatedAt").invoke(obj);
                            double gst   = amount * 0.075;
                            double total = amount + gst;
                            String badgeClass = "badge-draft";
                            if ("SENT".equalsIgnoreCase(status))      badgeClass = "badge-sent";
                            if ("PAYMENT_PENDING".equalsIgnoreCase(status))   badgeClass = "badge-pending";
                            if ("PAID".equalsIgnoreCase(status)) badgeClass = "badge-confirmed";
                            if ("DELIVERED".equalsIgnoreCase(status)) badgeClass = "badge-delivered";
                    %>
                        <tr>
                            <td><%= poId %></td>
                            <td><%= poNumber %></td>
                            <td><%= material != null ? material : "N/A" %></td>
                            <td><%= qty %></td>
                            <td>₹<%= String.format("%.2f", amount) %></td>
                            <td>₹<%= String.format("%.2f", gst) %></td>
                            <td>₹<%= String.format("%.2f", total) %></td>
                            <td><span class="<%= badgeClass %>"><%= status %></span></td>
                            <td><%= createdAt != null ? sdf.format(createdAt) : "-" %></td>
                            <td>
    <% if ("PAID".equalsIgnoreCase(status) || "DELIVERED".equalsIgnoreCase(status)) { %>
        <a href="<%= request.getContextPath() %>/download-po-pdf?poId=<%= poId %>"
           class="btn btn-success btn-sm mb-1">
            <i class="fas fa-file-pdf"></i> PDF
        </a>
    <% } else { %>
        <button type="button" class="btn btn-success btn-sm mb-1" disabled>
            <i class="fas fa-file-pdf"></i> PDF
        </button>
    <% } %>

    <% if ("SENT".equalsIgnoreCase(status)) { %>
    <form method="post"
          action="<%= request.getContextPath() %>/supplier-po-view"
          style="display:inline;">
        <input type="hidden" name="poId" value="<%= poId %>"/>
        <button type="submit" class="btn btn-warning btn-sm mb-1">
            <i class="fas fa-check"></i> Confirm
        </button>
    </form>
    <% } %>
</td>

                        </tr>
                    <% } } else { %>
                        <tr>
                            <td colspan="10" class="text-center py-4 text-muted">
                                <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                                No purchase orders found.
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>