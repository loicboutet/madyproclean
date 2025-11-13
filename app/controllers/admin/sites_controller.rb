class Admin::SitesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_site, only: [:show, :edit, :update, :destroy, :qr_code]
  
  def index
    # Use real Site model with filters
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
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(site_params)
    
    if @site.save
      redirect_to admin_sites_path, notice: 'Site créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @site is set by before_action
  end

  def update
    if @site.update(site_params)
      redirect_to admin_site_path(@site), notice: 'Site mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Soft delete by marking as inactive
    @site.update(active: false)
    redirect_to admin_sites_path, notice: 'Site désactivé avec succès.'
  end

  def qr_code
    # @site is set by before_action
    # Render QR code view
  end

  private

  def set_site
    @site = Site.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_sites_path, alert: 'Site non trouvé.'
  end

  def site_params
    params.require(:site).permit(:name, :code, :address, :description, :active)
  end
end
