# frozen_string_literal: true

# ReportsGeneration concern
# Shared report generation logic for Admin and Manager namespaces
module ReportsGeneration
  extend ActiveSupport::Concern
  
  included do
    before_action :set_report, only: [:show, :download]
  end
  
  # These methods must be implemented by the including controller
  def reports_index_path
    raise NotImplementedError, "#{self.class.name} must implement #reports_index_path"
  end
  
  def reports_monthly_path
    raise NotImplementedError, "#{self.class.name} must implement #reports_monthly_path"
  end
  
  def monthly_pdf_template_path
    raise NotImplementedError, "#{self.class.name} must implement #monthly_pdf_template_path"
  end
  
  # Shared action: Generate monthly report
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
      redirect_to reports_monthly_path, alert: 'Veuillez sélectionner un mois et une année.' and return
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
    # Use binary mode to handle PDF and other binary formats
    File.binwrite(file_path, file_content)
    
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
    redirect_to reports_index_path, notice: "Rapport '#{report.title}' généré avec succès! Vous pouvez le télécharger ci-dessous."
  end
  
  # Shared action: Download report
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
    when 'HTML'
      send_html_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, @report_record)
    else
      redirect_to reports_index_path, alert: 'Format de rapport non supporté.'
    end
  end
  
  private
  
  # Send CSV report
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
  
  # Send Excel report
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
  
  # Send PDF report
  def send_pdf_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, report)
    # Generate real PDF using WickedPDF
    html_string = render_to_string(
      template: monthly_pdf_template_path,
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
  
  # Send HTML report
  def send_html_report(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies, report)
    # Send HTML report
    html_content = render_to_string(
      template: monthly_pdf_template_path,
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
    
    filename = report.filename
    
    send_data html_content,
              filename: filename,
              type: 'text/html',
              disposition: 'attachment'
  end
  
  # Set report for show and download actions
  def set_report
    @report_record = Report.find_by(id: params[:id])
    
    unless @report_record
      redirect_to reports_index_path, alert: 'Rapport non trouvé.'
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
    when 'site_performance'
      @report[:total_hours] = @report_record.total_hours
      @report[:total_sites] = @report_record.total_sites
      @report[:site_name] = @report_record.site_name
      @report[:site_code] = @report_record.site_code
    when 'anomalies'
      @report[:total_anomalies] = @report_record.total_anomalies
      @report[:resolved_anomalies] = @report_record.resolved_anomalies
      @report[:unresolved_anomalies] = @report_record.unresolved_anomalies
    when 'hr'
      @report[:total_absences] = @report_record.total_absences
      @report[:absence_rate] = @report_record.absence_rate
      @report[:coverage_rate] = @report_record.coverage_rate
      @report[:total_agents] = @report_record.total_agents
    when 'scheduling'
      @report[:total_schedules] = @report_record.total_schedules
      @report[:scheduled_count] = @report_record.scheduled_count
      @report[:completed_count] = @report_record.completed_count
      @report[:missed_count] = @report_record.missed_count
    end
  end
  
  # Generate CSV content
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
  
  # Generate Excel content
  def generate_excel_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    # For now, Excel format uses CSV
    generate_csv_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
  end
  
  # Generate PDF content
  def generate_pdf_content(time_entries, start_date, end_date, total_hours, total_agents, total_sites, anomalies)
    # Generate real PDF using WickedPDF
    html_string = render_to_string(
      template: monthly_pdf_template_path,
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
  
  # Format file size in human-readable format
  def format_file_size(bytes)
    return '0 B' if bytes.zero?
    
    units = ['B', 'KB', 'MB', 'GB']
    exponent = (Math.log(bytes) / Math.log(1024)).floor
    size = (bytes / (1024.0 ** exponent)).round(2)
    
    "#{size} #{units[exponent]}"
  end
end
