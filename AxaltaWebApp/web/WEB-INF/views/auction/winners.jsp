<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Auction Winners - Axalta Coating Systems</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <style>
        .payment-created {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp" />
    
    <div class="container mt-4">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Auction Winners</h5>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>AUCTION ID</th>
                                <th>PRODUCT</th>
                                <th>WINNING SUPPLIER</th>
                                <th>WINNING AMOUNT</th>
                                <th>PAYMENT STATUS</th>
                                <th>ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${auctionWinners}" var="winner">
                                <tr>
                                    <td>${winner.auctionId}</td>
                                    <td>${winner.product}</td>
                                    <td>${winner.supplier}</td>
                                    <td>₹${winner.amount}</td>
                                    <td>
                                        <span class="badge badge-${winner.paymentStatus eq 'PAYMENT_CREATED' ? 'success' : 'warning'}">
                                            ${winner.paymentStatus}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${winner.paymentStatus eq 'PAYMENT_CREATED'}">
                                                <button class="btn btn-secondary btn-sm" disabled>
                                                    <i class="fas fa-check"></i> Payment Created
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-primary btn-sm create-payment" 
                                                        data-auction-id="${winner.auctionId}"
                                                        data-product="${winner.product}"
                                                        data-supplier="${winner.supplier}"
                                                        data-amount="${winner.amount}">
                                                    <i class="fas fa-credit-card"></i> Create Payment
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Payment Modal -->
    <div class="modal fade" id="paymentModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Create Payment</h5>
                    <button type="button" class="close text-white" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id="paymentForm">
                        <input type="hidden" id="auctionId" name="auctionId">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Product</label>
                                    <input type="text" class="form-control" id="product" readonly>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Supplier</label>
                                    <input type="text" class="form-control" id="supplier" readonly>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Amount</label>
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <span class="input-group-text">₹</span>
                                        </div>
                                        <input type="text" class="form-control" id="amount" readonly>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Payment Method</label>
                                    <select class="form-control" id="paymentMethod" name="paymentMethod" required>
                                        <option value="">Select Payment Method</option>
                                        <option value="CREDIT_CARD">Credit Card</option>
                                        <option value="DEBIT_CARD">Debit Card</option>
                                        <option value="NET_BANKING">Net Banking</option>
                                        <option value="UPI">UPI</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div id="paymentDetails">
                            <!-- Dynamic payment fields will be loaded here based on payment method -->
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="processPayment">
                        <i class="fas fa-credit-card"></i> Process Payment
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.4/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function() {
            // Handle Create Payment button click
            $('.create-payment').click(function() {
                const button = $(this);
                const auctionId = button.data('auction-id');
                const product = button.data('product');
                const supplier = button.data('supplier');
                const amount = button.data('amount');

                // Populate modal fields
                $('#auctionId').val(auctionId);
                $('#product').val(product);
                $('#supplier').val(supplier);
                $('#amount').val(amount);

                // Show modal
                $('#paymentModal').modal('show');
            });

            // Handle payment method change
            $('#paymentMethod').change(function() {
                const method = $(this).val();
                let fields = '';

                switch(method) {
                    case 'CREDIT_CARD':
                    case 'DEBIT_CARD':
                        fields = `
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>Card Number</label>
                                        <input type="text" class="form-control" name="cardNumber" required>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Expiry Month</label>
                                        <input type="text" class="form-control" name="expiryMonth" placeholder="MM" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>Expiry Year</label>
                                        <input type="text" class="form-control" name="expiryYear" placeholder="YYYY" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>CVV</label>
                                        <input type="password" class="form-control" name="cvv" required>
                                    </div>
                                </div>
                            </div>`;
                        break;
                    case 'NET_BANKING':
                        fields = `
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>Select Bank</label>
                                        <select class="form-control" name="bank" required>
                                            <option value="">Choose your bank</option>
                                            <option value="SBI">State Bank of India</option>
                                            <option value="HDFC">HDFC Bank</option>
                                            <option value="ICICI">ICICI Bank</option>
                                            <option value="AXIS">Axis Bank</option>
                                        </select>
                                    </div>
                                </div>
                            </div>`;
                        break;
                    case 'UPI':
                        fields = `
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>UPI ID</label>
                                        <input type="text" class="form-control" name="upiId" placeholder="example@upi" required>
                                    </div>
                                </div>
                            </div>`;
                        break;
                }

                $('#paymentDetails').html(fields);
            });

            // Handle payment processing
            $('#processPayment').click(function() {
                const form = $('#paymentForm');
                if (!form[0].checkValidity()) {
                    form[0].reportValidity();
                    return;
                }

                // Show loading state
                const button = $(this);
                button.prop('disabled', true);
                button.html('<i class="fas fa-spinner fa-spin"></i> Processing...');

                // Collect form data
                const formData = {
                    auctionId: $('#auctionId').val(),
                    paymentMethod: $('#paymentMethod').val(),
                    amount: $('#amount').val(),
                    // Add other form fields based on payment method
                };

                // Send payment request
                $.ajax({
                    url: '${pageContext.request.contextPath}/payment/process',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(formData),
                    success: function(response) {
                        // Close modal
                        $('#paymentModal').modal('hide');

                        // Show success message
                        alert('Payment processed successfully!');

                        // Reload page to update status
                        location.reload();
                    },
                    error: function(xhr, status, error) {
                        alert('Payment processing failed: ' + error);
                        button.prop('disabled', false);
                        button.html('<i class="fas fa-credit-card"></i> Process Payment');
                    }
                });
            });
        });
    </script>
</body>
</html>
