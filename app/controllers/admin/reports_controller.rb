class Admin::ReportsController < ApplicationController
  layout 'admin'
  before_action :set_report, only: [:show]
  before_action :load_demo_data
  
  def index
    # Apply filters to demo data
    @reports = @all_reports.dup
    
    # Filter by report type
    if params[:report_type].present?
      @reports = @reports.select { |r| r[:report_type] == params[:report_type] }
    end
    
    # Filter by status
    if params[:status].present?
      @reports = @reports.select { |r| r[:status] == params[:status] }
    end
    
    # Filter by date range
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      @reports = @reports.select { |r| r[:period_start] >= start_date }
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      @reports = @reports.select { |r| r[:period_end] <= end_date }
    end
    
    # Search
    if params[:search].present?
      search_term = params[:search].downcase
      @reports = @reports.select do |r|
        r[:title].downcase.include?(search_term) ||
        (r[:description] && r[:description].downcase.include?(search_term))
      end
    end
  end

  def show
    # @report is set by before_action
  end

  def monthly
  end

  def hr
  end

  private

  def set_report
    load_demo_data
    @report = @all_reports.find { |r| r[:id] == params[:id].to_i }
    
    unless @report
      redirect_to admin_reports_path, alert: 'Rapport non trouvé.'
    end
  end

  def load_demo_data
    # Demo users for created_by
    @demo_users = [
      { id: 1, name: 'Admin Principal', role: 'admin' },
      { id: 2, name: 'Superviseur Martin', role: 'manager' },
      { id: 3, name: 'Gestionnaire RH', role: 'admin' }
    ]
    
    # Demo sites
    @demo_sites = [
      { id: 1, name: 'Site Nucléaire Paris Nord', code: 'SPN-001' },
      { id: 2, name: 'Centrale de Lyon', code: 'CLY-002' },
      { id: 3, name: 'Station Marseille', code: 'SMA-003' },
      { id: 4, name: 'Centre Toulouse', code: 'CTO-004' },
      { id: 5, name: 'Unité Bordeaux', code: 'UBO-005' }
    ]
    
    # Demo reports
    @all_reports = [
      {
        id: 1,
        title: 'Rapport Mensuel - Janvier 2025',
        report_type: 'monthly',
        period_start: Date.parse('2025-01-01'),
        period_end: Date.parse('2025-01-31'),
        generated_at: Time.parse('2025-02-01 09:00:00'),
        generated_by_id: 1,
        generated_by_name: 'Admin Principal',
        status: 'completed',
        description: 'Rapport mensuel des présences et heures travaillées pour tous les agents',
        total_hours: 4520.5,
        total_agents: 125,
        total_sites: 5,
        filters_applied: { all_agents: true, all_sites: true },
        file_format: 'PDF',
        file_size: '2.4 MB'
      },
      {
        id: 2,
        title: 'Rapport RH - Taux d\'Absence T1 2025',
        report_type: 'hr',
        period_start: Date.parse('2025-01-01'),
        period_end: Date.parse('2025-03-31'),
        generated_at: Time.parse('2025-04-01 14:30:00'),
        generated_by_id: 3,
        generated_by_name: 'Gestionnaire RH',
        status: 'completed',
        description: 'Analyse des absences et taux de couverture d\'équipe pour le premier trimestre',
        total_absences: 87,
        absence_rate: 12.5,
        coverage_rate: 87.5,
        total_agents: 125,
        filters_applied: { absence_types: ['vacation', 'sick_leave', 'other'] },
        file_format: 'Excel',
        file_size: '1.8 MB'
      },
      {
        id: 3,
        title: 'Rapport Temps Travaillé - Site Paris Nord',
        report_type: 'time_tracking',
        period_start: Date.parse('2025-02-01'),
        period_end: Date.parse('2025-02-28'),
        generated_at: Time.parse('2025-03-01 10:15:00'),
        generated_by_id: 2,
        generated_by_name: 'Superviseur Martin',
        status: 'completed',
        description: 'Détail des heures travaillées pour le site Paris Nord uniquement',
        total_hours: 1820.0,
        total_agents: 45,
        total_sites: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        filters_applied: { site_id: 1 },
        file_format: 'CSV',
        file_size: '890 KB'
      },
      {
        id: 4,
        title: 'Rapport Planification - Mars 2025',
        report_type: 'scheduling',
        period_start: Date.parse('2025-03-01'),
        period_end: Date.parse('2025-03-31'),
        generated_at: Time.parse('2025-02-25 16:00:00'),
        generated_by_id: 1,
        generated_by_name: 'Admin Principal',
        status: 'generating',
        description: 'Planification prévisionnelle des horaires pour le mois de mars',
        total_schedules: 420,
        scheduled_count: 350,
        completed_count: 0,
        missed_count: 0,
        filters_applied: { all_sites: true },
        file_format: 'PDF',
        file_size: nil
      },
      {
        id: 5,
        title: 'Rapport Anomalies - Février 2025',
        report_type: 'anomalies',
        period_start: Date.parse('2025-02-01'),
        period_end: Date.parse('2025-02-28'),
        generated_at: Time.parse('2025-03-01 11:00:00'),
        generated_by_id: 1,
        generated_by_name: 'Admin Principal',
        status: 'completed',
        description: 'Liste des anomalies détectées et leur résolution',
        total_anomalies: 23,
        resolved_anomalies: 18,
        unresolved_anomalies: 5,
        filters_applied: { severity: ['high', 'medium'] },
        file_format: 'Excel',
        file_size: '650 KB'
      },
      {
        id: 6,
        title: 'Rapport Mensuel - Février 2025',
        report_type: 'monthly',
        period_start: Date.parse('2025-02-01'),
        period_end: Date.parse('2025-02-28'),
        generated_at: Time.parse('2025-03-01 09:00:00'),
        generated_by_id: 1,
        generated_by_name: 'Admin Principal',
        status: 'completed',
        description: 'Rapport mensuel complet avec toutes les métriques',
        total_hours: 4120.0,
        total_agents: 128,
        total_sites: 5,
        filters_applied: { all_agents: true, all_sites: true },
        file_format: 'PDF',
        file_size: '2.2 MB'
      },
      {
        id: 7,
        title: 'Rapport Export Paie - Janvier 2025',
        report_type: 'payroll_export',
        period_start: Date.parse('2025-01-01'),
        period_end: Date.parse('2025-01-31'),
        generated_at: Time.parse('2025-02-01 08:30:00'),
        generated_by_id: 3,
        generated_by_name: 'Gestionnaire RH',
        status: 'completed',
        description: 'Export des données pour le traitement de la paie',
        total_hours: 4520.5,
        total_agents: 125,
        filters_applied: { active_agents: true },
        file_format: 'CSV',
        file_size: '1.1 MB'
      },
      {
        id: 8,
        title: 'Rapport Performance Sites - T1 2025',
        report_type: 'site_performance',
        period_start: Date.parse('2025-01-01'),
        period_end: Date.parse('2025-03-31'),
        generated_at: Time.current,
        generated_by_id: 1,
        generated_by_name: 'Admin Principal',
        status: 'pending',
        description: 'Analyse de performance et utilisation de tous les sites',
        total_sites: 5,
        filters_applied: { all_sites: true },
        file_format: 'PDF',
        file_size: nil
      }
    ]
  end
end
