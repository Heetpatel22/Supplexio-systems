/**
 * Product Management JavaScript
 * Handles functionality for product list and form pages
 */

document.addEventListener('DOMContentLoaded', function() {
    // Highlight active sidebar item
    const sidebarItems = document.querySelectorAll('.sidebar-menu a');
    sidebarItems.forEach(item => {
        if (item.getAttribute('href').includes('/product')) {
            item.classList.add('active');
        }
    });
    
    // Initialize product search functionality
    const searchInput = document.getElementById('productSearch');
    if (searchInput) {
        searchInput.addEventListener('keyup', function() {
            const searchTerm = this.value.toLowerCase();
            const productItems = document.querySelectorAll('.product-item');
            
            productItems.forEach(item => {
                const productName = item.querySelector('.product-name').textContent.toLowerCase();
                const productDesc = item.querySelector('.product-description').textContent.toLowerCase();
                const productCategory = item.querySelector('.product-category').textContent.toLowerCase();
                
                if (productName.includes(searchTerm) || 
                    productDesc.includes(searchTerm) || 
                    productCategory.includes(searchTerm)) {
                    item.style.display = '';
                } else {
                    item.style.display = 'none';
                }
            });
        });
    }
    
    // Product form validation
    const productForm = document.getElementById('productForm');
    if (productForm) {
        productForm.addEventListener('submit', function(event) {
            let isValid = true;
            
            // Validate product name
            const nameInput = document.getElementById('name');
            if (nameInput && nameInput.value.trim() === '') {
                isValid = false;
                nameInput.classList.add('is-invalid');
            } else if (nameInput) {
                nameInput.classList.remove('is-invalid');
            }
            
            // Validate unit price
            const priceInput = document.getElementById('unitPrice');
            if (priceInput && (priceInput.value.trim() === '' || isNaN(priceInput.value) || parseFloat(priceInput.value) <= 0)) {
                isValid = false;
                priceInput.classList.add('is-invalid');
            } else if (priceInput) {
                priceInput.classList.remove('is-invalid');
            }
            
            if (!isValid) {
                event.preventDefault();
            }
        });
    }
});
