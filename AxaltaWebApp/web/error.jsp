<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<%@page import="java.util.logging.Logger"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f5f5fa;
            font-family: 'Segoe UI', Arial, sans-serif;
            padding: 20px;
        }
        .error-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-top: 50px;
        }
        .error-header {
            color: #cc3333;
            border-bottom: 1px solid #eee;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .error-details {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
        }
        .stack-trace {
            font-family: monospace;
            font-size: 12px;
            white-space: pre-wrap;
            overflow-x: auto;
            max-height: 400px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <%
        Logger logger = Logger.getLogger("error.jsp");
        logger.severe("An error occurred: " + (exception != null ? exception.getMessage() : "Unknown error"));
    %>
    <div class="container">
        <div class="row">
            <div class="col-md-12">
                <div class="error-container">
                    <h2 class="error-header">Application Error</h2>
                    <p>We apologize, but an error occurred while processing your request. Our team has been notified and is working to resolve the issue.</p>
                    
                    <div class="error-details">
                        <h4>Error Details:</h4>
                        <% 
                            String errorType = exception != null ? exception.getClass().getName() : "Unknown";
                            String errorMessage = exception != null ? exception.getMessage() : "No message available";
                        %>
                        <p><strong>Error Type:</strong> <%= errorType %></p>
                        <p><strong>Message:</strong> <%= errorMessage %></p>
                        
                        <% if (errorType.contains("SQL") || errorMessage.toLowerCase().contains("database")) { %>
                            <div class="alert alert-warning">
                                <strong>Database Issue Detected:</strong> There might be a problem with our database connection. Please check the <a href="${pageContext.request.contextPath}/dbstatus">database status</a> for more information.
                            </div>
                        <% } %>
                        
                        <% if (exception != null) { %>
                            <h4>Technical Details:</h4>
                            <div class="stack-trace">
                                <% 
                                    java.io.StringWriter sw = new java.io.StringWriter();
                                    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
                                    exception.printStackTrace(pw);
                                    out.println(sw.toString());
                                %>
                            </div>
                        <% } %>
                    </div>
                    
                    <div class="mt-4">
                        <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Return to Home</a>
                        <a href="${pageContext.request.contextPath}/dbstatus" class="btn btn-info ml-2">Check Database Status</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
