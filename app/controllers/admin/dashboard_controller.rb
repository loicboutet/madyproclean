class Admin::DashboardController < ApplicationController
  layout 'admin'
  
  def index
    # Sample data for charts - Replace with real database queries later
    @chart_data = {
      time_entries: time_entries_chart_data,
      site_occupancy: site_occupancy_chart_data,
      absence_rate: absence_rate_chart_data,
      anomalies: anomalies_chart_data
    }
  end

  private

  def time_entries_chart_data
    # Sample: Clock-ins over the past 7 days
    # TODO: Replace with: TimeEntry.group_by_day(:created_at, last: 7).count
    {
      labels: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
      datasets: [
        {
          label: 'Pointages',
          data: [78, 85, 82, 90, 88, 45, 32],
          borderColor: '#00D4FF',
          backgroundColor: 'rgba(0, 212, 255, 0.1)',
          tension: 0.4
        }
      ]
    }
  end

  def site_occupancy_chart_data
    # Sample: Current agents per site
    # TODO: Replace with real site data
    {
      labels: ['Site A', 'Site B', 'Site C', 'Site D', 'Site E', 'Site F'],
      datasets: [
        {
          label: 'Agents Actifs',
          data: [12, 19, 8, 15, 10, 7],
          backgroundColor: [
            'rgba(0, 212, 255, 0.8)',
            'rgba(0, 255, 224, 0.8)',
            'rgba(102, 227, 255, 0.8)',
            'rgba(0, 212, 255, 0.6)',
            'rgba(0, 255, 224, 0.6)',
            'rgba(102, 227, 255, 0.6)'
          ],
          borderColor: '#00D4FF',
          borderWidth: 1
        }
      ]
    }
  end

  def absence_rate_chart_data
    # Sample: Absence rate over last 6 months
    # TODO: Replace with: Absence.calculate_monthly_rate
    {
      labels: ['Juin', 'Juillet', 'Août', 'Sept', 'Oct', 'Nov'],
      datasets: [
        {
          label: 'Taux d\'Absence (%)',
          data: [3.2, 2.8, 4.1, 3.5, 2.9, 3.7],
          borderColor: '#00FFE0',
          backgroundColor: 'rgba(0, 255, 224, 0.1)',
          tension: 0.4,
          fill: true
        }
      ]
    }
  end

  def anomalies_chart_data
    # Sample: Distribution of anomaly types
    # TODO: Replace with: Anomaly.group(:type).count
    {
      labels: ['Pointage Manqué', 'Pointage >24h', 'Site Invalide', 'Autres'],
      datasets: [
        {
          label: 'Anomalies',
          data: [45, 12, 8, 5],
          backgroundColor: [
            'rgba(255, 99, 132, 0.8)',
            'rgba(255, 159, 64, 0.8)',
            'rgba(255, 205, 86, 0.8)',
            'rgba(201, 203, 207, 0.8)'
          ],
          borderColor: '#00D4FF',
          borderWidth: 2
        }
      ]
    }
  end
end
