class Manager::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'
  
  def index
    @chart_data = {
      team_activity: team_activity_chart_data,
      absences_trend: absences_trend_chart_data
    }
  end

  private

  def team_activity_chart_data
    {
      labels: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'],
      datasets: [
        {
          label: 'Agents Actifs',
          data: [10, 12, 11, 10, 9, 5, 0],
          backgroundColor: 'rgba(0, 212, 255, 0.6)',
          borderColor: 'rgba(0, 212, 255, 1)',
          borderWidth: 2
        },
        {
          label: 'Heures Travaillées',
          data: [85, 102, 95, 87, 78, 42, 0],
          backgroundColor: 'rgba(0, 255, 224, 0.6)',
          borderColor: 'rgba(0, 255, 224, 1)',
          borderWidth: 2
        }
      ]
    }
  end

  def absences_trend_chart_data
    {
      labels: ['Oct', 'Sem 1 Nov', 'Sem 2 Nov', 'Sem 3 Nov', 'Sem 4 Nov', 'Sem 5 Nov'],
      datasets: [
        {
          label: 'Congés',
          data: [1, 2, 3, 2, 1, 2],
          borderColor: 'rgba(0, 255, 224, 1)',
          backgroundColor: 'rgba(0, 255, 224, 0.1)',
          tension: 0.4,
          fill: true
        },
        {
          label: 'Maladie',
          data: [0, 1, 1, 0, 2, 1],
          borderColor: 'rgba(255, 193, 7, 1)',
          backgroundColor: 'rgba(255, 193, 7, 0.1)',
          tension: 0.4,
          fill: true
        },
        {
          label: 'Formation',
          data: [2, 0, 1, 1, 0, 1],
          borderColor: 'rgba(0, 212, 255, 1)',
          backgroundColor: 'rgba(0, 212, 255, 0.1)',
          tension: 0.4,
          fill: true
        }
      ]
    }
  end
end
