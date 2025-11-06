import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js"

export default class extends Controller {
  static values = {
    data: Object
  }

  connect() {
    this.initializeCharts()
  }

  initializeCharts() {
    if (!this.hasDataValue) {
      console.warn("No chart data provided")
      return
    }

    const chartData = this.dataValue

    // Time Entries Chart (Line)
    this.createLineChart('timeEntriesChart', chartData.time_entries, {
      title: 'Pointages de la Semaine',
      yAxisLabel: 'Nombre de Pointages'
    })

    // Site Occupancy Chart (Bar)
    this.createBarChart('siteOccupancyChart', chartData.site_occupancy, {
      title: 'Occupation par Site',
      yAxisLabel: 'Nombre d\'Agents'
    })

    // Absence Rate Chart (Line with Fill)
    this.createLineChart('absenceRateChart', chartData.absence_rate, {
      title: 'Taux d\'Absence',
      yAxisLabel: 'Taux (%)',
      fill: true
    })

    // Anomalies Chart (Doughnut)
    this.createDoughnutChart('anomaliesChart', chartData.anomalies, {
      title: 'Distribution des Anomalies'
    })
  }

  createLineChart(canvasId, data, options = {}) {
    const ctx = document.getElementById(canvasId)
    if (!ctx) return

    new Chart(ctx, {
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
          },
          title: {
            display: false
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
  }

  createBarChart(canvasId, data, options = {}) {
    const ctx = document.getElementById(canvasId)
    if (!ctx) return

    new Chart(ctx, {
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
          },
          title: {
            display: false
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
  }

  createDoughnutChart(canvasId, data, options = {}) {
    const ctx = document.getElementById(canvasId)
    if (!ctx) return

    new Chart(ctx, {
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
          },
          title: {
            display: false
          }
        }
      }
    })
  }
}
