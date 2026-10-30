<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Please Wait - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: Arial, sans-serif;
        }
        .container {
            max-width: 600px;
            margin-top: 100px;
        }
        .spinner-border {
            width: 3rem;
            height: 3rem;
        }
        .error-message {
            color: #dc3545;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container text-center">
        <h1 class="mb-4">Please Wait</h1>
        <p class="lead">The system is initializing. This process may take a few moments.</p>
        <div class="spinner-border text-primary mt-4" role="status">
            <span class="sr-only">Loading...</span>
        </div>
        <p id="status" class="mt-4">Checking system status...</p>
        <p id="error-message" class="error-message mt-3"></p>
    </div>

    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const error = urlParams.get('error');
        const errorMessageElement = document.getElementById('error-message');
        const statusElement = document.getElementById('status');

        function displayError(message) {
            errorMessageElement.textContent = message;
            statusElement.style.display = 'none';
            document.querySelector('.spinner-border').style.display = 'none';
        }

        if (error) {
            switch(error) {
                case 'db_timeout':
                    displayError('Database initialization timed out. Please try again later.');
                    break;
                case 'interrupted':
                    displayError('The initialization process was interrupted. Please refresh the page.');
                    break;
                case 'db_not_ready':
                    displayError('The database is not ready. Our team has been notified. Please try again later.');
                    break;
                default:
                    displayError('An unexpected error occurred. Please try again later.');
            }
        } else {
            function checkStatus() {
                fetch('${pageContext.request.contextPath}/dbstatus')
                    .then(response => response.text())
                    .then(html => {
                        const parser = new DOMParser();
                        const doc = parser.parseFromString(html, 'text/html');
                        const statusElement = doc.querySelector('p');
                        if (statusElement) {
                            document.getElementById('status').innerHTML = statusElement.innerHTML;
                            if (statusElement.innerHTML.includes('Success')) {
                                setTimeout(() => window.location.href = '${pageContext.request.contextPath}/home', 2000);
                            } else {
                                setTimeout(checkStatus, 5000);
                            }
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        displayError('Error checking status. Please refresh the page.');
                    });
            }

            checkStatus();
        }
    </script>
</body>
</html>