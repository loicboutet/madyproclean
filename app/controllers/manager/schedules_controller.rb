class Manager::SchedulesController < ApplicationController
  include SchedulesManagement
  
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'user'
  before_action :set_schedule, only: [:show]
  
  def index
    # Managers can view all schedules (no filtering implemented as per requirements)
    # Filters displayed in UI are for demonstration only
    @schedules = @all_schedules.dup
  end

  def show
    # @schedule is set by before_action from concern
  end

  private

  # Implement required abstract methods from SchedulesManagement concern
  def schedules_index_path
    manager_schedules_path
  end

  def schedule_path(id)
    manager_schedule_path(id)
  end

  def schedule_not_found_message
    'Planning non trouvé.'
  end
end
