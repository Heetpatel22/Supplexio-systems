<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplexio Web App - Debug Page</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="resources/css/style.css">
</head>
<body>
    <div class="container mt-5">
        <h1>Supplexio Web App - Debug Information</h1>
        <hr>
        
        <div class="card mb-4">
            <div class="card-header">Application Information</div>
            <div class="card-body">
                <p><strong>Context Path:</strong> <%= request.getContextPath() %></p>
                <p><strong>Servlet Path:</strong> <%= request.getServletPath() %></p>
                <p><strong>Request URI:</strong> <%= request.getRequestURI() %></p>
                <p><strong>Server Info:</strong> <%= application.getServerInfo() %></p>
                <p><strong>Servlet API Version:</strong> <%= application.getMajorVersion() %>.<%= application.getMinorVersion() %></p>
                <p><strong>Java Version:</strong> <%= System.getProperty("java.version") %></p>
            </div>
        </div>
        
        <div class="card mb-4">
            <div class="card-header">Servlet Mapping Test</div>
            <div class="card-body">
                <p>Click the links below to test if the servlets are properly mapped:</p>
                <ul>
                    <li><a href="product" target="_blank">Product Servlet</a></li>
                    <li><a href="supplier" target="_blank">Supplier Servlet</a></li>
                    <li><a href="auction" target="_blank">Auction Servlet</a></li>
                    <li><a href="bidding" target="_blank">Bidding Servlet</a></li>
                    <li><a href="payment" target="_blank">Payment Servlet</a></li>
                    <li><a href="statistics" target="_blank">Statistics Servlet</a></li>
                    <li><a href="test-connection" target="_blank">Test Connection Servlet</a></li>
                </ul>
            </div>
        </div>
        
        <div class="card mb-4">
            <div class="card-header">Database Connection Test</div>
            <div class="card-body">
                <p>Test the database connection:</p>
                <a href="test-connection" class="btn btn-primary">Test Database Connection</a>
            </div>
        </div>
        
        <div class="card mb-4">
            <div class="card-header">Initialize Database</div>
            <div class="card-body">
                <p>Initialize the database tables:</p>
                <a href="test-connection?init=true" class="btn btn-warning">Initialize Database Tables</a>
                <p class="mt-2 text-muted">Note: This will create the necessary tables if they don't exist.</p>
            </div>
        </div>
        
        <div class="mt-4">
            <a href="index.jsp" class="btn btn-secondary">Back to Home</a>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
