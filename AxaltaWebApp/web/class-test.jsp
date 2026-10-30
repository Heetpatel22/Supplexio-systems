<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class Loading Test - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f5f5fa;
            font-family: 'Segoe UI', Arial, sans-serif;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-top: 50px;
        }
        .success {
            color: green;
            font-weight: bold;
        }
        .error {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Class Loading Test</h1>
        <p>This page tests if critical classes are properly loaded in the application.</p>
        
        <h2>MySQL JDBC Driver</h2>
        <% 
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                out.println("<p class='success'>✓ MySQL JDBC Driver loaded successfully</p>");
            } catch (ClassNotFoundException e) {
                out.println("<p class='error'>✗ MySQL JDBC Driver not found: " + e.getMessage() + "</p>");
            }
        %>
        
        <h2>JSON Simple Library</h2>
        <% 
            try {
                Class.forName("org.json.simple.JSONObject");
                out.println("<p class='success'>✓ JSON Simple library loaded successfully</p>");
            } catch (ClassNotFoundException e) {
                out.println("<p class='error'>✗ JSON Simple library not found: " + e.getMessage() + "</p>");
            }
        %>
        
        <h2>Database Connection</h2>
        <% 
            try {
                Class.forName("com.axaltacoating.util.DatabaseConnection");
                out.println("<p class='success'>✓ DatabaseConnection class loaded successfully</p>");
            } catch (ClassNotFoundException e) {
                out.println("<p class='error'>✗ DatabaseConnection class not found: " + e.getMessage() + "</p>");
            }
        %>
        
        <h2>Servlet Classes</h2>
        <% 
            String[] servletClasses = {
                "com.axaltacoating.servlet.ProductServlet",
                "com.axaltacoating.servlet.SupplierServlet",
                "com.axaltacoating.servlet.AuctionServlet",
                "com.axaltacoating.servlet.PaymentServlet",
                "com.axaltacoating.servlet.BiddingServlet",
                "com.axaltacoating.servlet.StatisticsServlet"
            };
            
            for (String className : servletClasses) {
                try {
                    Class.forName(className);
                    out.println("<p class='success'>✓ " + className + " loaded successfully</p>");
                } catch (ClassNotFoundException e) {
                    out.println("<p class='error'>✗ " + className + " not found: " + e.getMessage() + "</p>");
                }
            }
        %>
        
        <h2>Library Path Information</h2>
        <p>The following shows the Java library path:</p>
        <pre><%= System.getProperty("java.library.path") %></pre>
        
        <h2>Classpath Information</h2>
        <p>The following shows the Java classpath:</p>
        <pre><%= System.getProperty("java.class.path") %></pre>
        
        <div class="mt-4">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Return to Home</a>
        </div>
    </div>
</body>
</html>
