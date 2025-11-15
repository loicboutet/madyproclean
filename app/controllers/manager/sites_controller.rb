class Manager::SitesController < ApplicationController
  include SitesManagement
  
  before_action :authenticate_user!
  before_action :authorize_manager_or_admin!
  layout 'user'
  
  # index, show, qr_code inherited from SitesManagement concern
  
  # Override show to add recent time entries for managers
  def show
    super # Call the concern's show method to load common statistics
    
    # Additional data for manager view
    @recent_time_entries = @site.time_entries.includes(:user)
                                .order(created_at: :desc)
                                .limit(10)
  end

  private
  def authorize_manager_or_admin!
    unless current_user.manager? || current_user.admin?
      redirect_to root_path, alert: 'Accès non autorisé.'
    end
  end

  # Required by SitesManagement concern
  def sites_index_path
    manager_sites_path
  end

  def sites_show_path(site)
    manager_site_path(site)
  end

  def qr_code_path(site)
    qr_code_manager_site_path(site)
  end

  def has_crud_permissions?
    false
  end
end
