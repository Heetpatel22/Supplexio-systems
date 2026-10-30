let currentChart = null;
let filteredData = [];
let allCommodities = [];

document.addEventListener('DOMContentLoaded', function() {
    initializePage();
    setupEventListeners();
});

function initializePage() {
    // Process commodities data
    if (typeof commoditiesData !== 'undefined' && commoditiesData.length > 0) {
        allCommodities = commoditiesData.map(item => ({
            ...item,
            category: getCommodityCategory(item.name),
            numericLast: parseNumericValue(item.last),
            numericHigh: parseNumericValue(item.high),
            numericLow: parseNumericValue(item.low),
            numericChange: parseNumericValue(item.change),
            numericChangePercent: parseNumericValue(item.changePercent)
        }));
    } else {
        // Fallback sample data if no server data
        allCommodities = generateSampleData();
    }
    
    filteredData = [...allCommodities];
    populateTable();
    updateLastUpdatedTime();
}

function setupEventListeners() {
    // Search functionality
    document.getElementById('commoditySearch').addEventListener('input', function() {
        filterCommodities();
    });
    
    // Category filter
    document.getElementById('categoryFilter').addEventListener('change', function() {
        filterCommodities();
    });
    
    // Clear filters
    document.getElementById('clearFilters').addEventListener('click', function() {
        document.getElementById('commoditySearch').value = '';
        document.getElementById('categoryFilter').value = '';
        filterCommodities();
    });
    
    // Time range selector
    document.getElementById('timeRange').addEventListener('change', function() {
        if (currentChart) {
            updateChartTimeRange(this.value);
        }
    });
}

function getCommodityCategory(name) {
    const lowerName = name.toLowerCase();
    if (lowerName.includes('gold') || lowerName.includes('silver') || lowerName.includes('platinum') || 
        lowerName.includes('palladium') || lowerName.includes('copper') || lowerName.includes('aluminium') || 
        lowerName.includes('zinc') || lowerName.includes('nickel')) {
        return 'metals';
    } else if (lowerName.includes('oil') || lowerName.includes('gas') || lowerName.includes('heating') || 
               lowerName.includes('gasoline') || lowerName.includes('brent')) {
        return 'energy';
    } else if (lowerName.includes('wheat') || lowerName.includes('corn') || lowerName.includes('soybean') || 
               lowerName.includes('cotton') || lowerName.includes('cocoa') || lowerName.includes('coffee') || 
               lowerName.includes('sugar') || lowerName.includes('orange') || lowerName.includes('rice') || 
               lowerName.includes('oats')) {
        return 'agriculture';
    } else if (lowerName.includes('cattle') || lowerName.includes('hogs') || lowerName.includes('feeder')) {
        return 'livestock';
    }
    return 'other';
}

function parseNumericValue(value) {
    if (!value) return 0;
    // Remove commas, quotes, and other non-numeric characters except decimal point and minus sign
    const cleaned = value.toString().replace(/[,"]/g, '').replace(/[^\d.-]/g, '');
    return parseFloat(cleaned) || 0;
}

function filterCommodities() {
    const searchTerm = document.getElementById('commoditySearch').value.toLowerCase();
    const categoryFilter = document.getElementById('categoryFilter').value;
    
    filteredData = allCommodities.filter(commodity => {
        const matchesSearch = commodity.name.toLowerCase().includes(searchTerm);
        const matchesCategory = !categoryFilter || commodity.category === categoryFilter;
        return matchesSearch && matchesCategory;
    });
    
    populateTable();
}

function populateTable() {
    const tbody = document.getElementById('commoditiesTableBody');
    tbody.innerHTML = '';
    
    if (filteredData.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="8" class="text-center py-4">
                    <i class="fas fa-search fa-2x text-muted mb-2"></i>
                    <p class="text-muted">No commodities found matching your criteria</p>
                </td>
            </tr>
        `;
        return;
    }
    
    filteredData.forEach((commodity, index) => {
        const row = createTableRow(commodity, index);
        tbody.appendChild(row);
    });
}

function createTableRow(commodity, index) {
    const row = document.createElement('tr');
    row.className = 'commodity-row';
    row.onclick = () => showCommodityChart(commodity);
    
    const isPositiveChange = commodity.numericChange >= 0;
    const changeClass = isPositiveChange ? 'price-positive' : 'price-negative';
    const trendIcon = isPositiveChange ? '↗' : '↘';
    
    row.innerHTML = `
        <td>
            <div class="d-flex align-items-center">
                <strong>${commodity.name}</strong>
                <span class="badge badge-secondary category-badge ml-2">${commodity.category}</span>
            </div>
        </td>
        <td><strong>${commodity.last}</strong></td>
        <td>${commodity.high}</td>
        <td>${commodity.low}</td>
        <td class="${changeClass}">
            <span class="trend-icon">${trendIcon}</span>
            ${commodity.change}
        </td>
        <td class="${changeClass}">
            <strong>${commodity.changePercent}</strong>
        </td>
        <td><small class="text-muted">${commodity.time}</small></td>
        <td>
            <button class="btn btn-sm btn-primary" onclick="event.stopPropagation(); showCommodityChart(commoditiesData[${index}])">
                <i class="fas fa-chart-line"></i> View Chart
            </button>
        </td>
    `;
    
    return row;
}

function showCommodityChart(commodity) {
    document.getElementById('selectedCommodityName').textContent = `${commodity.name} - Price Trend`;
    document.getElementById('chartSection').style.display = 'block';
    
    // Scroll to chart
    document.getElementById('chartSection').scrollIntoView({ behavior: 'smooth' });
    
    // Generate sample historical data for the selected commodity
    const historicalData = generateHistoricalData(commodity);
    
    createChart(historicalData);
}

function hideChart() {
    document.getElementById('chartSection').style.display = 'none';
    if (currentChart) {
        currentChart.destroy();
        currentChart = null;
    }
}

function generateHistoricalData(commodity) {
    const days = parseInt(document.getElementById('timeRange').value);
    const labels = [];
    const data = [];
    const basePrice = commodity.numericLast;
    
    // Generate dates
    for (let i = days - 1; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        labels.push(date.toLocaleDateString());
    }
    
    // Generate price data with some realistic variation
    let currentPrice = basePrice * 0.95; // Start slightly lower
    for (let i = 0; i < days; i++) {
        // Add some random variation (±2%)
        const variation = (Math.random() - 0.5) * 0.04;
        currentPrice = currentPrice * (1 + variation);
        
        // Trend towards the current price
        const trendFactor = 0.1;
        currentPrice = currentPrice + (basePrice - currentPrice) * trendFactor;
        
        data.push(parseFloat(currentPrice.toFixed(2)));
    }
    
    return { labels, data };
}

function createChart(historicalData) {
    const ctx = document.getElementById('priceChart').getContext('2d');
    
    if (currentChart) {
        currentChart.destroy();
    }
    
    const gradient = ctx.createLinearGradient(0, 0, 0, 400);
    gradient.addColorStop(0, 'rgba(54, 162, 235, 0.2)');
    gradient.addColorStop(1, 'rgba(54, 162, 235, 0.02)');
    
    currentChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: historicalData.labels,
            datasets: [{
                label: 'Price',
                data: historicalData.data,
                borderColor: '#36a2eb',
                backgroundColor: gradient,
                borderWidth: 2,
                fill: true,
                tension: 0.4,
                pointBackgroundColor: '#36a2eb',
                pointBorderColor: '#ffffff',
                pointBorderWidth: 2,
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    mode: 'index',
                    intersect: false,
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleColor: '#ffffff',
                    bodyColor: '#ffffff',
                    borderColor: '#36a2eb',
                    borderWidth: 1
                }
            },
            scales: {
                x: {
                    display: true,
                    grid: {
                        display: false
                    },
                    ticks: {
                        maxTicksLimit: 10
                    }
                },
                y: {
                    display: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.1)'
                    },
                    ticks: {
                        callback: function(value) {
                            return '$' + value.toFixed(2);
                        }
                    }
                }
            },
            interaction: {
                mode: 'nearest',
                axis: 'x',
                intersect: false
            }
        }
    });
}

function updateChartTimeRange(days) {
    const selectedCommodity = filteredData.find(c => 
        document.getElementById('selectedCommodityName').textContent.includes(c.name)
    );
    
    if (selectedCommodity) {
        const historicalData = generateHistoricalData(selectedCommodity);
        
        if (currentChart) {
            currentChart.data.labels = historicalData.labels;
            currentChart.data.datasets[0].data = historicalData.data;
            currentChart.update('active');
        }
    }
}

function updateLastUpdatedTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString();
    document.getElementById('lastUpdated').textContent = `Updated: ${timeString}`;
}

function generateSampleData() {
    return [
        {
            name: 'Gold derived',
            month: 'Aug 25',
            last: '3,403.30',
            high: '3,411.55',
            low: '3,362.17',
            change: '+17.60',
            changePercent: '+0.52%',
            time: '11:14:44',
            category: 'metals',
            numericLast: 3403.30,
            numericHigh: 3411.55,
            numericLow: 3362.17,
            numericChange: 17.60,
            numericChangePercent: 0.52
        },
        {
            name: 'Silver derived',
            month: 'Jul 25',
            last: '36.288',
            high: '36.305',
            low: '35.793',
            change: '+0.270',
            changePercent: '+0.75%',
            time: '11:14:40',
            category: 'metals',
            numericLast: 36.288,
            numericHigh: 36.305,
            numericLow: 35.793,
            numericChange: 0.270,
            numericChangePercent: 0.75
        },
        {
            name: 'Copper derived',
            month: 'Jul 25',
            last: '4.8445',
            high: '4.8513',
            low: '4.7705',
            change: '+0.0110',
            changePercent: '+0.23%',
            time: '11:14:24',
            category: 'metals',
            numericLast: 4.8445,
            numericHigh: 4.8513,
            numericLow: 4.7705,
            numericChange: 0.0110,
            numericChangePercent: 0.23
        },
        {
            name: 'Crude Oil WTI derived',
            month: 'Aug 25',
            last: '72.94',
            high: '77.13',
            low: '72.61',
            change: '-0.90',
            changePercent: '-1.22%',
            time: '11:14:39',
            category: 'energy',
            numericLast: 72.94,
            numericHigh: 77.13,
            numericLow: 72.61,
            numericChange: -0.90,
            numericChangePercent: -1.22
        }
    ];
}

// Auto-refresh data every 30 seconds
setInterval(function() {
    updateLastUpdatedTime();
    // In a real application, you would fetch new data from the server here
}, 30000);