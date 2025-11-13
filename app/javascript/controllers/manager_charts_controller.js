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

    // Team Activity Chart (Bar)
    this.createBarChart('teamActivityChart', chartData.team_activity)

    // Absences Trend Chart (Line)
    this.createLineChart('absencesTrendChart', chartData.absences_trend)
  }

  createBarChart(canvasId, data) {
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
        }
      }
    })

    this.charts.push(chart)
  }

  createLineChart(canvasId, data) {
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
        }
      }
    })

    this.charts.push(chart)
  }
}
