<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Receipt - Supplexio</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
        }
        
        .receipt-container {
            max-width: 800px;
            margin: 0 auto;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            padding: 30px;
            position: relative;
        }
        
        .receipt-header {
            border-bottom: 2px solid #007bff;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        
        .receipt-logo {
            max-height: 60px;
        }
        
        .receipt-title {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
            margin-top: 10px;
        }
        
        .receipt-subtitle {
            color: #666;
            font-size: 14px;
        }
        
        .receipt-id {
            font-size: 18px;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 5px;
        }
        
        .receipt-date {
            color: #666;
            margin-bottom: 20px;
        }
        
        .receipt-section {
            margin-bottom: 30px;
        }
        
        .receipt-section-title {
            font-weight: bold;
            color: #007bff;
            border-bottom: 1px solid #eee;
            padding-bottom: 5px;
            margin-bottom: 15px;
        }
        
        .receipt-row {
            display: flex;
            margin-bottom: 8px;
        }
        
        .receipt-label {
            flex: 0 0 40%;
            font-weight: 600;
            color: #555;
        }
        
        .receipt-value {
            flex: 0 0 60%;
        }
        
        .receipt-total {
            background-color: #f8f9fa;
            border-top: 2px solid #007bff;
            padding: 15px;
            margin-top: 20px;
            font-size: 18px;
            font-weight: bold;
        }
        
        .receipt-footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #666;
            text-align: center;
        }
        
        .receipt-watermark {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-45deg);
            font-size: 100px;
            color: rgba(0, 123, 255, 0.05);
            z-index: 0;
            pointer-events: none;
        }
        
        .receipt-content {
            position: relative;
            z-index: 1;
        }
        
        .receipt-status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 4px;
            font-weight: bold;
            text-transform: uppercase;
            font-size: 12px;
        }
        
        .receipt-status-completed {
            background-color: #d4edda;
            color: #155724;
        }
        
        .receipt-status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .receipt-status-failed {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .print-button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 20px;
        }
        
        .print-button:hover {
            background-color: #0056b3;
        }
        
        @media print {
            body {
                background-color: #fff;
                padding: 0;
            }
            
            .receipt-container {
                box-shadow: none;
                padding: 0;
            }
            
            .no-print {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="text-center mb-4 no-print">
            <button onclick="window.print()" class="print-button">
                <i class="fas fa-print"></i> Print Receipt
            </button>
            <a href="${pageContext.request.contextPath}/payment?action=view&id=${payment.id}" class="btn btn-secondary">
                Back to Payment Details
            </a>
        </div>
        
        <div class="receipt-container">
            <div class="receipt-watermark">
                <c:choose>
                    <c:when test="${payment.status == 'COMPLETED'}">PAID</c:when>
                    <c:when test="${payment.status == 'PENDING'}">PENDING</c:when>
                    <c:when test="${payment.status == 'FAILED'}">CANCELLED</c:when>
                </c:choose>
            </div>
            
            <div class="receipt-content">
                <div class="receipt-header">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="receipt-title">SUPPLEXIO</div>
                            <div class="receipt-subtitle">Supply Chain Excellence</div>
                        </div>
                        <div class="col-md-6 text-right">
                            <div class="receipt-id">Receipt #${payment.id}</div>
                            <div class="receipt-date">
                                Issue Date: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy-MM-dd" />
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="receipt-section">
                    <div class="receipt-section-title">Payment Information</div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="receipt-row">
                                <div class="receipt-label">Payment ID:</div>
                                <div class="receipt-value">${payment.id}</div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Payment Date:</div>
                                <div class="receipt-value">
                                    <fmt:formatDate value="${payment.paymentDate}" pattern="yyyy-MM-dd" />
                                </div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Payment Method:</div>
                                <div class="receipt-value">${payment.paymentMethod}</div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Transaction ID:</div>
                                <div class="receipt-value">
                                    ${not empty payment.transactionId ? payment.transactionId : 'N/A'}
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="receipt-row">
                                <div class="receipt-label">Status:</div>
                                <div class="receipt-value">
                                    <c:choose>
                                        <c:when test="${payment.status == 'COMPLETED'}">
                                            <span class="receipt-status receipt-status-completed">Completed</span>
                                        </c:when>
                                        <c:when test="${payment.status == 'PENDING'}">
                                            <span class="receipt-status receipt-status-pending">Pending</span>
                                        </c:when>
                                        <c:when test="${payment.status == 'FAILED'}">
                                            <span class="receipt-status receipt-status-failed">Failed</span>
                                        </c:when>
                                        <c:otherwise>
                                            ${payment.status}
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Due Date:</div>
                                <div class="receipt-value">
                                    <c:choose>
                                        <c:when test="${not empty payment.dueDate}">
                                            <fmt:formatDate value="${payment.dueDate}" pattern="yyyy-MM-dd" />
                                        </c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="receipt-section">
                    <div class="receipt-section-title">Supplier Information</div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="receipt-row">
                                <div class="receipt-label">Company Name:</div>
                                <div class="receipt-value">${supplier.companyName}</div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Contact Person:</div>
                                <div class="receipt-value">${supplier.contactName}</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="receipt-row">
                                <div class="receipt-label">Email:</div>
                                <div class="receipt-value">${supplier.email}</div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Phone:</div>
                                <div class="receipt-value">${supplier.phone}</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="receipt-section">
                    <div class="receipt-section-title">Auction Details</div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="receipt-row">
                                <div class="receipt-label">Auction ID:</div>
                                <div class="receipt-value">${auction.id}</div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Title:</div>
                                <div class="receipt-value">${auction.title}</div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Product:</div>
                                <div class="receipt-value">${auction.productName}</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="receipt-row">
                                <div class="receipt-label">Quantity:</div>
                                <div class="receipt-value">${auction.requiredQuantity}</div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Winning Bid:</div>
                                <div class="receipt-value">
                                    <fmt:formatNumber value="${winningBid.bidAmount}" type="currency" currencySymbol="₹" />
                                </div>
                            </div>
                            <div class="receipt-row">
                                <div class="receipt-label">Auction End Date:</div>
                                <div class="receipt-value">
                                    <fmt:formatDate value="${auction.endTime}" pattern="yyyy-MM-dd" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="receipt-total">
                    <div class="row">
                        <div class="col-md-6">
                            Total Amount:
                        </div>
                        <div class="col-md-6 text-right">
                            <fmt:formatNumber value="${payment.amount}" type="currency" currencySymbol="₹" />
                        </div>
                    </div>
                </div>
                
                <c:if test="${not empty payment.notes}">
                    <div class="receipt-section">
                        <div class="receipt-section-title">Notes</div>
                        <p>${payment.notes}</p>
                    </div>
                </c:if>
                
                <div class="receipt-footer">
                    <p>This is a computer-generated receipt and does not require a signature.</p>
                    <p>&copy; 2025 Supplexio. All rights reserved.</p>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
