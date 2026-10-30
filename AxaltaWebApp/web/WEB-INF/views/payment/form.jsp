<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Make Payment - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        body {
            background-color: #f5f6fa;
            font-family: 'Segoe UI', Arial, sans-serif;
            padding-top: 20px;
        }

        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }

        .card-header {
            background-color: #007bff;
            color: white;
            font-weight: 600;
            border-radius: 10px 10px 0 0 !important;
        }

        .btn-primary {
            background-color: #007bff;
            border-color: #007bff;
        }

        .btn-primary:hover {
            background-color: #0056b3;
            border-color: #0056b3;
        }

        .btn-secondary {
            background-color: #6c757d;
            border-color: #6c757d;
        }

        .btn-secondary:hover {
            background-color: #5a6268;
            border-color: #545b62;
        }

        .form-control:focus {
            border-color: #007bff;
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        }

        .required-field::after {
            content: " *";
            color: #dc3545;
        }

        .readonly-box {
            background: #e9ecef;
        }
    </style>
</head>
<body>
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/payment">Payment Management</a></li>
                <li class="breadcrumb-item active" aria-current="page">Make Payment</li>
            </ol>
        </nav>

        <div class="card">
            <div class="card-header">
                <h4 class="mb-0">Make Payment</h4>
            </div>
            <div class="card-body">
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${error}
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/payment" id="paymentForm">
                    <input type="hidden" name="auctionId" value="${auction.id}">
                    <input type="hidden" name="supplierId" value="${supplier.id}">
                    <input type="hidden" name="status" value="COMPLETED">

                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label class="required-field">Auction</label>
                            <input type="text" class="form-control readonly-box"
                                   value="${auction.product_name} (ID: ${auction.id})" readonly>
                        </div>

                        <div class="form-group col-md-6">
                            <label class="required-field">Supplier</label>
                            <input type="text" class="form-control readonly-box"
                                   value="${supplier.name} (ID: ${supplier.id})" readonly>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="amount" class="required-field">Amount (₹)</label>
                            <input type="number" class="form-control readonly-box" id="amount" name="amount"
                                   value="${auction.winning_amount}" step="0.01" min="0" required readonly>
                        </div>

                        <div class="form-group col-md-6">
                            <label for="paymentMethod" class="required-field">Payment Method</label>
                            <select class="form-control" id="paymentMethod" name="paymentMethod" required>
                                <option value="">-- Select Payment Method --</option>
                                <option value="BANK_TRANSFER">Bank Transfer</option>
                                <option value="CREDIT_CARD">Credit Card</option>
                                <option value="CHEQUE">Cheque</option>
                                <option value="CASH">Cash</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="transactionId">Transaction ID</label>
                            <input type="text" class="form-control" id="transactionId" name="transactionId"
                                   value="TXN-${auction.id}-${supplier.id}-${pageContext.session.id}" maxlength="100">
                            <small class="form-text text-muted">Auto-filled. You can edit if needed.</small>
                        </div>

                        <div class="form-group col-md-6">
                            <label for="paymentDate" class="required-field">Payment Date</label>
                            <input type="date" class="form-control" id="paymentDate" name="paymentDate" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="remarks">Notes</label>
                        <textarea class="form-control" id="remarks" name="remarks" rows="3"
                                  placeholder="Optional payment note">Payment against confirmed supplier PO for auction #${auction.id}</textarea>
                    </div>

                    <div class="form-group text-right">
                        <a href="${pageContext.request.contextPath}/payment" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-money-bill-wave"></i> Make Payment
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var paymentDate = document.getElementById('paymentDate');
            if (paymentDate) {
                var today = new Date();
                var yyyy = today.getFullYear();
                var mm = String(today.getMonth() + 1).padStart(2, '0');
                var dd = String(today.getDate()).padStart(2, '0');
                paymentDate.value = yyyy + '-' + mm + '-' + dd;
            }

            var paymentMethod = document.getElementById('paymentMethod');
            var transactionId = document.getElementById('transactionId');

            if (paymentMethod && transactionId) {
                paymentMethod.addEventListener('change', function () {
                    if (this.value === 'CASH') {
                        transactionId.value = '';
                        transactionId.setAttribute('readonly', 'readonly');
                    } else {
                        transactionId.removeAttribute('readonly');
                        if (!transactionId.value) {
                            transactionId.value = 'TXN-${auction.id}-${supplier.id}-${pageContext.session.id}';
                        }
                    }
                });
            }
        });
    </script>
</body>
</html>
