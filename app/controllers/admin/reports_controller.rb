class Admin::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_report, only: [:show, :download]
  before_action :load_demo_data
  
  def index
    # Use Report model from database
    @reports = Report.includes(:generated_by)
                 .order(created_at: :desc)
                 .recent

    
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
    # Fetch monthly reports from database
    @reports = Report.includes(:generated_by)
                     .where(period_type: 'monthly')
                     .order(created_at: :desc)
    
    # Filter by month and year
    if params[:month].present? && params[:year].present?
      month = params[:month].to_i
      year = params[:year].to_i
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      
      @reports = @reports.where('period_start >= ? AND period_start <= ?', start_date, end_date)
    end
    
    # Filter by user
    if params[:user_id].present?
      @reports = @reports.where("filters_applied LIKE ?", "%user_id\":#{params[:user_id]}%")
    end
    
    # Filter by site
    if params[:site_id].present?
      @reports = @reports.where("filters_applied LIKE ?", "%site_id\":#{params[:site_id]}%")
    end
    
    # Filter by status
    if params[:status].present?
      @reports = @reports.by_status(params[:status])
    end
    
    # Paginate results (10 per page)
    @reports = @reports.page(params[:page]).per(10)
    
    # Calculate statistics
    all_monthly_reports = Report.where(period_type: 'monthly')
    @total_monthly_reports = all_monthly_reports.count
    @reports_this_month = all_monthly_reports.where('period_start >= ?', Date.current.beginning_of_month).count
    @reports_this_year = all_monthly_reports.where('period_start >= ?', Date.current.beginning_of_year).count
    @pending_reports = all_monthly_reports.where(status: 'pending').count
    
    # Load users and sites for dropdowns
    @users = User.agents.active.order(:last_name, :first_name)
    @sites = Site.active.order(:name)
  end

  def time_tracking
    # Render time tracking report form (placeholder)
  end

  def anomalies
    # Render anomalies report form (placeholder)
  end

  def generate_monthly
    # Get parameters
    title = params[:title].presence || "Rapport #{Date.current.strftime('%B %Y')}"
    report_type = params[:report_type] || 'time_tracking'
    period_type = params[:period_type] || 'monthly'
    month = params[:month].to_i
    year = params[:year].to_i
    user_id = params[:user_id].presence
    site_id = params[:site_id].presence
    format = params[:format] || 'csv'
    
    # Validate parameters
    if month.zero? || year.zero?
      redirect_to admin_reports_path, alert: 'Veuillez sélectionner un mois et une année.' and return
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
    
    # Calculate statistics (handle nil duration_minutes for active entries)
    total_minutes = time_entries.where.not(duration_minutes: nil).sum(:duration_minutes)
    total_hours = total_minutes / 60.0
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
    
    # Generate description based on filters
    description = if user_id.present?
      user = User.find(user_id)
      "Rapport mensuel pour #{user.full_name}"
    elsif site_id.present?
      site = Site.find(site_id)
      "Rapport mensuel pour #{site.name}"
    else
      "Rapport mensuel des présences et heures travaillées pour tous les agents"
    end
    
    # Generate file content first
    file_content = case format
    when 'csv'
      generate_csv_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    when 'xlsx'
      generate_excel_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    when 'pdf'
      generate_pdf_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    end
    
    # Determine file extension and MIME type
    file_extension = case format
    when 'csv' then 'csv'
    when 'xlsx' then 'csv' # Currently using CSV for Excel
    when 'pdf' then 'html' # Currently using HTML for PDF
    end
    
    # Generate filename
    filename = "rapport_mensuel_#{start_date.strftime('%Y_%m')}.#{file_extension}"
    
    # Save file to storage
    storage_path = Rails.root.join('storage', 'reports')
    FileUtils.mkdir_p(storage_path) unless Dir.exist?(storage_path)
    
    file_path = storage_path.join(filename)
    File.write(file_path, file_content)
    
    # Calculate file size
    file_size_bytes = File.size(file_path)
    file_size = format_file_size(file_size_bytes)
    
    # Create Report record in database
    report = Report.create!(
      title: title,
      report_type: report_type,
      period_type: period_type,
      period_start: start_date,
      period_end: end_date,
      generated_at: Time.current,
      generated_by_id: current_user.id,
      status: 'completed',
      description: description,
      filters_applied: {
        all_agents: user_id.blank?,
        all_sites: site_id.blank?,
        user_id: user_id,
        site_id: site_id,
        include_anomalies: params[:include_anomalies] == '1'
      },
      file_format: format.upcase == 'XLSX' ? 'Excel' : format.upcase,
      file_size: file_size
    )
    
    # Redirect to reports index with success message
    redirect_to admin_reports_path, notice: "Rapport '#{report.title}' généré avec succès! Vous pouvez le télécharger ci-dessous."
  end

  def hr
  end

  def download
    # Reconstruct filename from report data
    file_extension = case @report[:file_format]
    when 'CSV' then 'csv'
    when 'Excel' then 'csv'
    when 'PDF', 'HTML' then 'html'
    else 'csv'
    end
    
    filename = "rapport_mensuel_#{@report[:period_start].strftime('%Y_%m')}.#{file_extension}"
    file_path = Rails.root.join('storage', 'reports', filename)
    
    if File.exist?(file_path)
      send_file file_path,
                filename: filename,
                type: get_content_type_from_format(@report[:file_format]),
                disposition: 'attachment'
    else
      redirect_to admin_reports_path, alert: 'Le fichier du rapport est introuvable.'
    end
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
        total_minutes = entries.map(&:duration_minutes).compact.sum
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
        total_minutes = entries.map(&:duration_minutes).compact.sum
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
    report_record = Report.find_by(id: params[:id])
    
    unless report_record
      redirect_to admin_reports_path, alert: 'Rapport non trouvé.'
      return
    end
    
    # Convert ActiveRecord object to hash with all calculated metrics
    @report = {
      id: report_record.id,
      title: report_record.title,
      report_type: report_record.report_type,
      period_type: report_record.period_type,
      period_start: report_record.period_start,
      period_end: report_record.period_end,
      generated_at: report_record.generated_at,
      generated_by_id: report_record.generated_by_id,
      generated_by_name: report_record.generated_by&.full_name || 'Unknown',
      status: report_record.status,
      description: report_record.description,
      filters_applied: report_record.filters_applied,
      file_format: report_record.file_format,
      file_size: report_record.file_size
    }
    
    # Add calculated metrics based on report type and REPORT_DATA_SOURCES
    case report_record.report_type
    when 'time_tracking', 'monthly', 'payroll_export'
      @report[:total_hours] = report_record.total_hours
      @report[:total_agents] = report_record.total_agents
      @report[:total_sites] = report_record.total_sites if ['time_tracking', 'monthly'].include?(report_record.report_type)
    when 'site_performance'
      @report[:total_hours] = report_record.total_hours
      @report[:total_sites] = report_record.total_sites
      @report[:site_name] = report_record.site_name
      @report[:site_code] = report_record.site_code
    when 'anomalies'
      @report[:total_anomalies] = report_record.total_anomalies
      @report[:resolved_anomalies] = report_record.resolved_anomalies
      @report[:unresolved_anomalies] = report_record.unresolved_anomalies
    when 'hr'
      @report[:total_absences] = report_record.total_absences
      @report[:absence_rate] = report_record.absence_rate
      @report[:coverage_rate] = report_record.coverage_rate
      @report[:total_agents] = report_record.total_agents
    when 'scheduling'
      @report[:total_schedules] = report_record.total_schedules
      @report[:scheduled_count] = report_record.scheduled_count
      @report[:completed_count] = report_record.completed_count
      @report[:missed_count] = report_record.missed_count
    end
  end

  def generate_csv_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    require 'csv'
    
    CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
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
        total_minutes = entries.map(&:duration_minutes).compact.sum
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
        total_minutes = entries.map(&:duration_minutes).compact.sum
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
  end

  def generate_excel_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    # For now, Excel format uses CSV (can be enhanced with a gem like 'caxlsx' for native Excel)
    generate_csv_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
  end

  def generate_pdf_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    # Render HTML (can be enhanced with a gem like 'wicked_pdf' for real PDF)
    render_to_string(
      template: 'admin/reports/monthly_pdf',
      layout: false,
      formats: [:html],
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
  end

  def get_content_type(format)
    case format
    when 'csv'
      'text/csv; charset=utf-8'
    when 'xlsx'
      'application/vnd.ms-excel'
    when 'pdf'
      'text/html' # Will be application/pdf when using real PDF generation
    else
      'application/octet-stream'
    end
  end

  def get_content_type_from_format(file_format)
    case file_format
    when 'CSV'
      'text/csv; charset=utf-8'
    when 'Excel'
      'application/vnd.ms-excel'
    when 'PDF', 'HTML'
      'text/html'
    else
      'application/octet-stream'
    end
  end

  def format_file_size(bytes)
    return '0 B' if bytes.zero?
    
    units = ['B', 'KB', 'MB', 'GB']
    exponent = (Math.log(bytes) / Math.log(1024)).floor
    size = (bytes / (1024.0 ** exponent)).round(2)
    
    "#{size} #{units[exponent]}"
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
