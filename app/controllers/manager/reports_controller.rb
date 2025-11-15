class Manager::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'
  before_action :set_report, only: [:show, :download]
  
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
    
    # Load users and sites for dropdowns (only agents for managers)
    @users = User.agents.active.order(:last_name, :first_name)
    @sites = Site.active.order(:name)
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
      redirect_to manager_reports_monthly_path, alert: 'Veuillez sélectionner un mois et une année.' and return
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
      "Rapport mensuel des présences et heures travaillées"
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
    
    # Create Report record in database first to generate proper filename
    report = Report.new(
      title: title,
      report_type: report_type,
      period_type: period_type,
      file_format: format.upcase == 'XLSX' ? 'Excel' : format.upcase
    )
    
    # Generate filename using the report's filename method
    filename = report.filename
    
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
    redirect_to manager_reports_path, notice: "Rapport '#{report.title}' généré avec succès! Vous pouvez le télécharger ci-dessous."
  end

  def download
    # Generate report on-the-fly based on stored metadata
    start_date = @report[:period_start]
    end_date = @report[:period_end]
    filters = @report[:filters_applied] || {}
    
    # Build query based on stored filters
    time_entries = TimeEntry.includes(:user, :site)
                            .for_date_range(start_date, end_date)
    
    # Apply filters
    time_entries = time_entries.for_user(User.find(filters['user_id'])) if filters['user_id'].present?
    time_entries = time_entries.for_site(Site.find(filters['site_id'])) if filters['site_id'].present?
    
    # Calculate statistics
    total_minutes = time_entries.where.not(duration_minutes: nil).sum(:duration_minutes)
    total_hours = total_minutes / 60.0
    total_agents = time_entries.select(:user_id).distinct.count
    total_sites = time_entries.select(:site_id).distinct.count
    
    # Get anomalies if they were included
    anomalies = []
    if filters['include_anomalies']
      anomalies = AnomalyLog.includes(:user)
                            .where('created_at >= ? AND created_at <= ?', start_date.beginning_of_day, end_date.end_of_day)
      anomalies = anomalies.where(user_id: filters['user_id']) if filters['user_id'].present?
    end
    
    # Generate and send the file based on format
    case @report[:file_format]
    when 'CSV'
      send_csv_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, @report_record)
    when 'Excel'
      send_excel_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, @report_record)
    when 'PDF'
      send_pdf_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, @report_record)
    else
      redirect_to manager_reports_path, alert: 'Format de rapport non supporté.'
    end
  end

  private

  def send_csv_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, report)
    require 'csv'
    
    filename = report.filename
    
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

  def send_excel_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, report)
    # For now, send CSV with Excel MIME type
    require 'csv'
    
    filename = report.filename
    
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

  def send_pdf_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, report)
    # Generate real PDF using WickedPDF
    html_string = render_to_string(
      template: 'manager/reports/monthly_pdf',
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
    
    pdf_content = WickedPdf.new.pdf_from_string(
      html_string,
      page_size: 'A4',
      margin: {
        top: 15,
        bottom: 15,
        left: 10,
        right: 10
      },
      encoding: 'UTF-8'
    )
    
    filename = report.filename
    
    send_data pdf_content,
              filename: filename,
              type: 'application/pdf',
              disposition: 'attachment'
  end

  def set_report
    @report_record = Report.find_by(id: params[:id])
    
    unless @report_record
      redirect_to manager_reports_path, alert: 'Rapport non trouvé.'
      return
    end
    
    # Convert ActiveRecord object to hash with all calculated metrics
    @report = {
      id: @report_record.id,
      title: @report_record.title,
      report_type: @report_record.report_type,
      period_type: @report_record.period_type,
      period_start: @report_record.period_start,
      period_end: @report_record.period_end,
      generated_at: @report_record.generated_at,
      generated_by_id: @report_record.generated_by_id,
      generated_by_name: @report_record.generated_by&.full_name || 'Unknown',
      status: @report_record.status,
      description: @report_record.description,
      filters_applied: @report_record.filters_applied,
      file_format: @report_record.file_format,
      file_size: @report_record.file_size
    }
    
    # Add calculated metrics based on report type
    case @report_record.report_type
    when 'time_tracking', 'monthly', 'payroll_export'
      @report[:total_hours] = @report_record.total_hours
      @report[:total_agents] = @report_record.total_agents
      @report[:total_sites] = @report_record.total_sites if ['time_tracking', 'monthly'].include?(@report_record.report_type)
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
    # For now, Excel format uses CSV
    generate_csv_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
  end

  def generate_pdf_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    # Generate real PDF using WickedPDF
    html_string = render_to_string(
      template: 'manager/reports/monthly_pdf',
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
    
    WickedPdf.new.pdf_from_string(
      html_string,
      page_size: 'A4',
      margin: {
        top: 15,
        bottom: 15,
        left: 10,
        right: 10
      },
      encoding: 'UTF-8'
    )
  end

  def format_file_size(bytes)
    return '0 B' if bytes.zero?
    
    units = ['B', 'KB', 'MB', 'GB']
    exponent = (Math.log(bytes) / Math.log(1024)).floor
    size = (bytes / (1024.0 ** exponent)).round(2)
    
    "#{size} #{units[exponent]}"
  end
end
