class Manager::SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager_or_admin!
  layout 'manager'
  before_action :set_site, only: [:show]
  
  def index
    # Show all sites - managers can view all sites (read-only)
    @sites = Site.all
    
    # Filter by active status
    if params[:status].present?
      if params[:status] == 'active'
        @sites = @sites.active
      elsif params[:status] == 'inactive'
        @sites = @sites.where(active: false)
      end
    end
    
    # Search by name or code
    if params[:search].present?
      search_term = params[:search]
      @sites = @sites.where('name LIKE ? OR code LIKE ?', "%#{search_term}%", "%#{search_term}%")
    end
    
    # Order alphabetically and paginate
    @sites = @sites.alphabetical.page(params[:page]).per(15)
  end

  def show
    # @site is set by before_action
    # Load current agents for this site
    @current_time_entries = @site.current_time_entries
    
    # Load statistics
    @total_time_entries = @site.time_entries.count
    @current_agents_count = @site.current_agent_count
    @schedules_count = @site.schedules.count
    
    # Recent time entries for this site (last 10)
    @recent_time_entries = @site.time_entries.includes(:user)
                                .order(created_at: :desc)
                                .limit(10)
  end

  private

  def set_site
    @site = Site.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to manager_sites_path, alert: 'Site non trouvé.'
  end
  
  def authorize_manager_or_admin!
    unless current_user.manager? || current_user.admin?
      redirect_to root_path, alert: 'Accès non autorisé.'
    end
  end
end
