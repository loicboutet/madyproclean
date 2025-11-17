# frozen_string_literal: true

# SitesManagement Concern
# Shared logic for Sites controllers across Admin and Manager namespaces
# Following DRY principle to avoid code duplication
#
# Usage:
#   include SitesManagement in Admin::SitesController and Manager::SitesController
#
# Required methods to be implemented by including controllers:
#   - sites_index_path: Returns namespace-specific index path
#   - sites_show_path(site): Returns namespace-specific show path
#   - qr_code_path(site): Returns namespace-specific QR code path
#   - has_crud_permissions?: Returns true if controller has CRUD permissions
module SitesManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_site, only: [:show, :qr_code]
  end

  # GET /sites
  # Displays list of sites with filtering and pagination
  def index
    @sites = Site.all
    
    apply_site_filters
    
    # Order alphabetically and paginate
    @sites = @sites.alphabetical.page(params[:page]).per(15)
  end

  # GET /sites/:id
  # Display site details with statistics
  def show
    # @site is set by before_action
    load_site_statistics
  end

  # GET /sites/:id/qr_code
  # Display QR code for site
  def qr_code
    # @site is set by before_action
    # Render QR code view
  end

  private

  # Set site from params
  def set_site
    @site = Site.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to sites_index_path, alert: 'Site non trouvé.'
  end

  # Apply filtering logic based on params
  def apply_site_filters
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
  end

  # Load common statistics for site show page
  def load_site_statistics
    @current_time_entries = @site.current_time_entries
    @total_time_entries = @site.time_entries.count
    @current_agents_count = @site.current_agent_count
    @schedules_count = @site.schedules.count
  end

  # Abstract methods - must be implemented by including controllers
  def sites_index_path
    raise NotImplementedError, "#{self.class} must implement #sites_index_path"
  end

  def sites_show_path(site)
    raise NotImplementedError, "#{self.class} must implement #sites_show_path"
  end

  def qr_code_path(site)
    raise NotImplementedError, "#{self.class} must implement #qr_code_path"
  end

  def has_crud_permissions?
    raise NotImplementedError, "#{self.class} must implement #has_crud_permissions?"
  end
end
