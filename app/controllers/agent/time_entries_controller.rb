class Agent::TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_agent_role
  layout 'agent'

  def index
    @time_entries = current_user.time_entries
                                .includes(:site)
                                .order(clocked_in_at: :desc)
                                .page(params[:page])
                                .per(20)
  end

  def show
    @time_entry = current_user.time_entries.find(params[:id])
  end

  private

  def ensure_agent_role
    unless current_user.agent?
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end
end
