module TimeEntriesFilterable
  extend ActiveSupport::Concern

  included do
    # Override this method in the including controller if needed
    def base_time_entries_scope
      TimeEntry.includes(:user, :site, :corrected_by).order(clocked_in_at: :desc)
    end
  end

  def apply_filters(time_entries)
    # User filter
    if params[:user_id].present?
      time_entries = time_entries.where(user_id: params[:user_id])
    end
    
    # Site filter
    if params[:site_id].present?
      time_entries = time_entries.where(site_id: params[:site_id])
    end
    
    # Status filter
    if params[:status].present?
      time_entries = time_entries.where(status: params[:status])
    end
    
    # Date range filters
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      time_entries = time_entries.where('clocked_in_at >= ?', start_date.beginning_of_day)
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      time_entries = time_entries.where('clocked_in_at <= ?', end_date.end_of_day)
    end
    
    time_entries
  end

  def calculate_statistics(time_entries)
    @total_count = time_entries.count
    @completed_count = time_entries.where(status: 'completed').count
    @active_count = time_entries.where(status: 'active').count
    @anomaly_count = time_entries.where(status: 'anomaly').count
  end

  def load_filter_data
    @users = User.agents.active.order(:first_name, :last_name)
    @sites = Site.active.alphabetical
  end
end
