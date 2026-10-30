/**
 * Payment Management JavaScript
 * Handles functionality for payment list and statistics pages
 */

document.addEventListener('DOMContentLoaded', function() {
    // Initialize date pickers with default values if needed
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');
    
    if (startDateInput && !startDateInput.value) {
        // Set default start date to first day of current month
        const today = new Date();
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        startDateInput.valueAsDate = firstDay;
    }
    
    if (endDateInput && !endDateInput.value) {
        // Set default end date to today
        const today = new Date();
        endDateInput.valueAsDate = today;
    }
    
    // Add event listener for filter form submission
    const filterForm = document.querySelector('form[action*="/payment"]');
    if (filterForm) {
        filterForm.addEventListener('submit', function(event) {
            // Validate date range if both dates are provided
            if (startDateInput && endDateInput && 
                startDateInput.value && endDateInput.value) {
                const startDate = new Date(startDateInput.value);
                const endDate = new Date(endDateInput.value);
                
                if (startDate > endDate) {
                    event.preventDefault();
                    alert('Start date cannot be after end date');
                    return false;
                }
            }
        });
    }
    
    // Highlight active sidebar item
    const sidebarItems = document.querySelectorAll('.sidebar-menu a');
    sidebarItems.forEach(item => {
        if (item.getAttribute('href').includes('/payment')) {
            item.classList.add('active');
        }
    });
});
