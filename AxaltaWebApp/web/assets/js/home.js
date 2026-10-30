/**
 * Home Page JavaScript
 * Handles functionality for the Supplexio home page
 */

document.addEventListener('DOMContentLoaded', function() {
    // Highlight active sidebar item
    const sidebarItems = document.querySelectorAll('.sidebar-menu a');
    sidebarItems.forEach(item => {
        if (item.getAttribute('href') === '${pageContext.request.contextPath}/' || 
            item.getAttribute('href') === '${pageContext.request.contextPath}/index.jsp') {
            item.classList.add('active');
        }
    });
    
    // Add smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});
