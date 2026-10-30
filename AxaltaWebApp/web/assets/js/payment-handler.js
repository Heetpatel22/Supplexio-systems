/**
 * payment-handler.js  — FIXED
 *
 * ROOT CAUSE (original bug):
 *   The old version called checkForJsonResponse() which:
 *     1. Read document.body.textContent
 *     2. If it started with '{' → JSON.parse()
 *     3. On success: document.body.innerHTML = ''  ← WIPES the whole JSP page
 *
 * This happened because PaymentServlet returns JSON for some action= calls
 * on the SAME /payment URL.  When JSP renders the page (which contains any
 * curly brace in JS or CSS), the check could trigger and replace the fully
 * rendered HTML with a blank "Success/Error" card.
 *
 * FIX: Remove the DOM-wipe entirely.
 * All rendering is now exclusively JSP server-side.
 * This file now contains only safe, additive utilities.
 */

(function () {
    'use strict';

    // Helper: format currency
    window.PaymentHandler = {
        formatCurrency: function (amount) {
            return '$' + parseFloat(amount).toLocaleString('en-US', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        },

        // Highlight a table row by payment ID (useful after redirect with ?highlight=N)
        highlightRow: function (paymentId) {
            var row = document.querySelector('tr[data-id="' + paymentId + '"]');
            if (row) {
                row.classList.add('table-info');
                row.scrollIntoView({ behavior: 'smooth', block: 'center' });
                setTimeout(function () { row.classList.remove('table-info'); }, 3000);
            }
        }
    };

    // Auto-highlight if URL contains ?highlight=N
    document.addEventListener('DOMContentLoaded', function () {
        var params = new URLSearchParams(window.location.search);
        var highlight = params.get('highlight');
        if (highlight) {
            window.PaymentHandler.highlightRow(highlight);
        }
    });
}());
