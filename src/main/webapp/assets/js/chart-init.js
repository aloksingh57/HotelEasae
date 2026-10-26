/**
 * HostelEase - Chart.js Visual Analytics Engine
 */

function initOccupancyChart(canvasId, present, away, overdue, available, maintenance) {
    const ctx = document.getElementById(canvasId);
    if (!ctx) return;

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Present', 'Away (Vacant)', 'Overdue', 'Available', 'Maintenance'],
            datasets: [{
                data: [present, away, overdue, available, maintenance],
                backgroundColor: [
                    '#10b981', // Emerald
                    '#f59e0b', // Amber
                    '#ef4444', // Rose
                    '#3b82f6', // Blue
                    '#64748b'  // Slate
                ],
                borderWidth: 2,
                borderColor: '#ffffff',
                hoverOffset: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        font: { family: 'Plus Jakarta Sans', size: 12, weight: 600 },
                        padding: 16,
                        usePointStyle: true
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function (context) {
                            return ` ${context.label}: ${context.raw} beds`;
                        }
                    }
                }
            },
            cutout: '72%'
        }
    });
}

function initFinancialChart(canvasId, billed, collected, outstanding) {
    const ctx = document.getElementById(canvasId);
    if (!ctx) return;

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Billed', 'Collected', 'Outstanding'],
            datasets: [{
                label: 'Amount (Rs.)',
                data: [billed, collected, outstanding],
                backgroundColor: ['#3b82f6', '#10b981', '#f59e0b'],
                borderRadius: 8,
                barThickness: 36
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: '#f1f5f9' },
                    ticks: {
                        callback: value => 'Rs. ' + value.toLocaleString()
                    }
                },
                x: {
                    grid: { display: false }
                }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });
}
