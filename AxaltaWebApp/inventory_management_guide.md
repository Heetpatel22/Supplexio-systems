# Kanban-based Inventory Management System User Guide

## Overview

This guide explains the new Kanban-based inventory management system implemented in our application. The system uses the Kanban method to efficiently manage inventory levels and automatically trigger auctions when stock levels are low.

## Kanban Method

The Kanban method is used to categorize inventory items into three status levels:

1. **Low**: Quantity is at or below the minimum threshold. Replenishment is needed, and an auction may be triggered.
2. **Medium**: Quantity is between the minimum and maximum thresholds. Inventory level is optimal.
3. **High**: Quantity is at or above the maximum threshold. Stock levels are sufficient.

## Key Features

### Inventory List View

- The main inventory page displays all items with their current status, quantity, and thresholds.
- A color-coded progress bar visually represents the current stock level for each item.
- Items are categorized by their Kanban status (Low, Medium, High).
- The page includes a summary of items in each Kanban status and items needing auctions.

### Notifications

- A warning notification appears at the top of the inventory list when there are items needing auctions.
- Individual items that need auctions are clearly marked in the list.

### Filtering and Searching

- Use the search bar to quickly find specific items.
- Filter items by their Kanban status using the dropdown menu.

### Auction Management

- For items with "Low" status that need replenishment, you can start an auction directly from the inventory list.
- Click the "Start Auction" button next to an eligible item to initiate the auction process.

### Automatic Updates

- The system periodically checks and updates the Kanban status of all items.
- Auctions are automatically triggered for items that reach the "Low" status.

## Best Practices

1. Regularly review the inventory list, paying special attention to items with "Low" status.
2. Promptly start auctions for items that need replenishment to maintain optimal stock levels.
3. Adjust minimum and maximum thresholds as needed to fine-tune the Kanban system for your specific needs.
4. Use the filtering and search features to focus on items that require immediate attention.

## Support

For any questions or issues regarding the inventory management system, please contact the IT support team.