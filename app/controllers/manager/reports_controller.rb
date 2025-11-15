class Manager::ReportsController < ApplicationController
  include ReportsGeneration
  
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'user'
  
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
    # @report is set by before_action from ReportsGeneration concern
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

  # generate_monthly and download are provided by ReportsGeneration concern

  private
  
  # Required by ReportsGeneration concern
  def reports_index_path
    manager_reports_path
  end
  
  def reports_monthly_path
    manager_reports_monthly_path
  end
  
  def monthly_pdf_template_path
    'manager/reports/monthly_pdf'
  end
end
