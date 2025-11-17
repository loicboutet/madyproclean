import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    data: Object
  }

  connect() {
    this.charts = []
    this.initializeCharts()
  }

  disconnect() {
    // Destroy all charts when controller disconnects (Turbo navigation)
    this.charts.forEach(chart => chart.destroy())
    this.charts = []
  }

  initializeCharts() {
    if (!this.hasDataValue) {
      console.warn("No chart data provided")
      return
    }

    const chartData = this.dataValue

    // Time Entries Chart (Line)
    this.createLineChart('timeEntriesChart', chartData.time_entries)

    // Site Occupancy Chart (Bar)
    this.createBarChart('siteOccupancyChart', chartData.site_occupancy)

    // Absence Rate Chart (Line with Fill)
    this.createLineChart('absenceRateChart', chartData.absence_rate, { fill: true })

    // Anomalies Chart (Doughnut)
    this.createDoughnutChart('anomaliesChart', chartData.anomalies)
  }

  createLineChart(canvasId, data, options = {}) {
    const ctx = document.getElementById(canvasId)
    if (!ctx) {
      console.warn(`Canvas element ${canvasId} not found`)
      return
    }

    const chart = new Chart(ctx, {
      type: 'line',
      data: data,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            labels: {
              color: '#FFFFFF',
              font: { size: 12 }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: {
              color: 'rgba(0, 212, 255, 0.1)'
            },
            ticks: {
              color: '#FFFFFF'
            }
          },
          x: {
            grid: {
              color: 'rgba(0, 212, 255, 0.1)'
            },
            ticks: {
              color: '#FFFFFF'
            }
          }
        },
        ...options
      }
    })

    this.charts.push(chart)
  }

  createBarChart(canvasId, data, options = {}) {
    const ctx = document.getElementById(canvasId)
    if (!ctx) {
      console.warn(`Canvas element ${canvasId} not found`)
      return
    }

    const chart = new Chart(ctx, {
      type: 'bar',
      data: data,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            labels: {
              color: '#FFFFFF',
              font: { size: 12 }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: {
              color: 'rgba(0, 212, 255, 0.1)'
            },
            ticks: {
              color: '#FFFFFF'
            }
          },
          x: {
            grid: {
              color: 'rgba(0, 212, 255, 0.1)'
            },
            ticks: {
              color: '#FFFFFF'
            }
          }
        },
        ...options
      }
    })

    this.charts.push(chart)
  }

  createDoughnutChart(canvasId, data, options = {}) {
    const ctx = document.getElementById(canvasId)
    if (!ctx) {
      console.warn(`Canvas element ${canvasId} not found`)
      return
    }

    const chart = new Chart(ctx, {
      type: 'doughnut',
      data: data,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            position: 'bottom',
            labels: {
              color: '#FFFFFF',
              font: { size: 12 },
              padding: 15
            }
          }
        },
        ...options
      }
    })

    this.charts.push(chart)
  }
}
