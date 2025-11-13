class Admin::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_report, only: [:show]
  before_action :load_demo_data
  
  def index
    # Use Report model from database
    @reports = Report.includes(:generated_by).all.recent
    
    # Filter by report type
    if params[:report_type].present?
      @reports = @reports.by_type(params[:report_type])
    end
    
    # Filter by status
    if params[:status].present?
      @reports = @reports.by_status(params[:status])
    end
    
    # Filter by date range
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      @reports = @reports.where('period_start >= ?', start_date)
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      @reports = @reports.where('period_end <= ?', end_date)
    end
    
    # Search
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @reports = @reports.where('title LIKE ? OR description LIKE ?', search_term, search_term)
    end
    
    # Paginate results (10 per page)
    @reports = @reports.page(params[:page]).per(10)
    
    # Keep all reports count for stats (before pagination)
    @all_reports_count = Report.count
    @completed_count = Report.completed.count
    @generating_count = Report.generating.count
    @pending_count = Report.pending.count
  end

  def show
    # @report is set by before_action
  end

  def monthly
    # Redirect to index with monthly filter
    redirect_to admin_reports_path(report_type: 'monthly')
  end

  def generate_monthly
    # Get parameters
    month = params[:month].to_i
    year = params[:year].to_i
    user_id = params[:user_id].presence
    site_id = params[:site_id].presence
    format = params[:format] || 'csv'
    
    # Validate parameters
    if month.zero? || year.zero?
      redirect_to admin_reports_monthly_path, alert: 'Veuillez sélectionner un mois et une année.' and return
    end
    
    # Calculate date range
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    
    # Build query
    time_entries = TimeEntry.includes(:user, :site)
                            .for_date_range(start_date, end_date)
    
    # Apply filters
    time_entries = time_entries.for_user(User.find(user_id)) if user_id.present?
    time_entries = time_entries.for_site(Site.find(site_id)) if site_id.present?
    
    # Calculate statistics
    total_hours = time_entries.sum(:duration_minutes) / 60.0
    total_agents = time_entries.select(:user_id).distinct.count
    total_sites = time_entries.select(:site_id).distinct.count
    total_entries = time_entries.count
    
    # Get anomalies if requested
    anomalies = []
    if params[:include_anomalies] == '1'
      anomalies = AnomalyLog.includes(:user)
                            .where('created_at >= ? AND created_at <= ?', start_date.beginning_of_day, end_date.end_of_day)
      anomalies = anomalies.where(user_id: user_id) if user_id.present?
    end
    
    # Generate report based on format
    case format
    when 'csv'
      send_csv_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    when 'xlsx'
      send_excel_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    when 'pdf'
      send_pdf_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    else
      redirect_to admin_reports_monthly_path, alert: 'Format non supporté.'
    end
  end

  def hr
  end

  private

  def send_csv_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    require 'csv'
    
    filename = "rapport_mensuel_#{start_date.strftime('%Y_%m')}.csv"
    
    csv_data = CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
      # Header section with summary
      csv << ['Rapport Mensuel de Pointage']
      csv << ['Période', "#{start_date.strftime('%d/%m/%Y')} - #{end_date.strftime('%d/%m/%Y')}"]
      csv << ['Généré le', Time.current.strftime('%d/%m/%Y à %H:%M')]
      csv << ['Généré par', current_user.full_name]
      csv << []
      csv << ['STATISTIQUES GÉNÉRALES']
      csv << ['Total heures travaillées', total_hours.round(2)]
      csv << ['Nombre d\'agents', total_agents]
      csv << ['Nombre de sites', total_sites]
      csv << ['Nombre de pointages', time_entries.count]
      csv << []
      
      # Time entries details
      csv << ['DÉTAIL DES POINTAGES']
      csv << ['ID', 'Agent', 'N° Employé', 'Site', 'Date', 'Arrivée', 'Départ', 'Durée (h)', 'Statut']
      
      time_entries.each do |entry|
        csv << [
          entry.id,
          entry.user.full_name,
          entry.user.employee_number,
          entry.site.name,
          entry.clocked_in_at.strftime('%d/%m/%Y'),
          entry.clocked_in_at.strftime('%H:%M'),
          entry.clocked_out_at ? entry.clocked_out_at.strftime('%H:%M') : 'En cours',
          entry.duration_minutes ? (entry.duration_minutes / 60.0).round(2) : '-',
          entry.status
        ]
      end
      
      # Hours by agent
      csv << []
      csv << ['HEURES PAR AGENT']
      csv << ['Agent', 'N° Employé', 'Total heures', 'Nombre de pointages']
      
      time_entries.group_by(&:user).each do |user, entries|
        total_minutes = entries.sum(&:duration_minutes)
        csv << [
          user.full_name,
          user.employee_number,
          (total_minutes / 60.0).round(2),
          entries.count
        ]
      end
      
      # Hours by site
      csv << []
      csv << ['HEURES PAR SITE']
      csv << ['Site', 'Code', 'Total heures', 'Nombre de pointages']
      
      time_entries.group_by(&:site).each do |site, entries|
        total_minutes = entries.sum(&:duration_minutes)
        csv << [
          site.name,
          site.code,
          (total_minutes / 60.0).round(2),
          entries.count
        ]
      end
      
      # Anomalies if included
      if anomalies.any?
        csv << []
        csv << ['ANOMALIES DÉTECTÉES']
        csv << ['Type', 'Agent', 'Description', 'Sévérité', 'Date', 'Résolu']
        
        anomalies.each do |anomaly|
          csv << [
            anomaly.anomaly_type,
            anomaly.user ? anomaly.user.full_name : '-',
            anomaly.description,
            anomaly.severity,
            anomaly.created_at.strftime('%d/%m/%Y %H:%M'),
            anomaly.resolved? ? 'Oui' : 'Non'
          ]
        end
      end
    end
    
    send_data csv_data, 
              filename: filename,
              type: 'text/csv; charset=utf-8',
              disposition: 'attachment'
  end

  def send_excel_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    # For now, send CSV with Excel MIME type (can be enhanced with a gem like 'caxlsx' for native Excel)
    require 'csv'
    
    filename = "rapport_mensuel_#{start_date.strftime('%Y_%m')}.csv"
    
    csv_data = CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
      # Same structure as CSV
      csv << ['Rapport Mensuel de Pointage']
      csv << ['Période', "#{start_date.strftime('%d/%m/%Y')} - #{end_date.strftime('%d/%m/%Y')}"]
      csv << ['Généré le', Time.current.strftime('%d/%m/%Y à %H:%M')]
      csv << ['Généré par', current_user.full_name]
      csv << []
      csv << ['STATISTIQUES GÉNÉRALES']
      csv << ['Total heures travaillées', total_hours.round(2)]
      csv << ['Nombre d\'agents', total_agents]
      csv << ['Nombre de sites', total_sites]
      csv << []
      
      csv << ['DÉTAIL DES POINTAGES']
      csv << ['ID', 'Agent', 'N° Employé', 'Site', 'Date', 'Arrivée', 'Départ', 'Durée (h)', 'Statut']
      
      time_entries.each do |entry|
        csv << [
          entry.id,
          entry.user.full_name,
          entry.user.employee_number,
          entry.site.name,
          entry.clocked_in_at.strftime('%d/%m/%Y'),
          entry.clocked_in_at.strftime('%H:%M'),
          entry.clocked_out_at ? entry.clocked_out_at.strftime('%H:%M') : 'En cours',
          entry.duration_minutes ? (entry.duration_minutes / 60.0).round(2) : '-',
          entry.status
        ]
      end
    end
    
    send_data csv_data, 
              filename: filename,
              type: 'application/vnd.ms-excel',
              disposition: 'attachment'
  end

  def send_pdf_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    # Render HTML and convert to PDF (can be enhanced with a gem like 'wicked_pdf')
    html_content = render_to_string(
      template: 'admin/reports/monthly_pdf',
      layout: false,
      locals: {
        time_entries: time_entries,
        start_date: start_date,
        end_date: end_date,
        total_hours: total_hours,
        total_agents: total_agents,
        total_sites: total_sites,
        anomalies: anomalies,
        generated_by: current_user.full_name,
        generated_at: Time.current
      }
    )
    
    filename = "rapport_mensuel_#{start_date.strftime('%Y_%m')}.html"
    
    send_data html_content,
              filename: filename,
              type: 'text/html',
              disposition: 'attachment'
  end

  def set_report
    @report = Report.find_by(id: params[:id])
    
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
