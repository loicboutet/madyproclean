class Manager::TimeEntriesController < ApplicationController
  include TimeEntriesFilterable
  
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'
  before_action :set_time_entry, only: [:show]
  
  def index
    # Get base scope
    @time_entries = base_time_entries_scope
    
    # Apply filters
    @time_entries = apply_filters(@time_entries)
    
    # Calculate statistics before pagination
    calculate_statistics(@time_entries)
    
    # Paginate results (20 per page)
    @time_entries = @time_entries.page(params[:page]).per(20)
    
    # Load users and sites for filters
    load_filter_data
    
    # For backward compatibility with view that references @all_time_entries
    @all_time_entries = @time_entries
  end

  def show
    # @time_entry is set by before_action
  end

  private

  def set_time_entry
    @time_entry = TimeEntry.includes(:user, :site, :corrected_by).find_by(id: params[:id])
    
    unless @time_entry
      redirect_to manager_time_entries_path, alert: 'Pointage non trouvé.'
    end
  end
end
