class Admin::SitesController < ApplicationController
  include SitesManagement
  
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_site, only: [:show, :edit, :update, :destroy, :qr_code]
  
  # index, show, qr_code inherited from SitesManagement concern

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

  private

  def site_params
    params.require(:site).permit(:name, :code, :address, :description, :active)
  end

  # Required by SitesManagement concern
  def sites_index_path
    admin_sites_path
  end

  def sites_show_path(site)
    admin_site_path(site)
  end

  def qr_code_path(site)
    qr_code_admin_site_path(site)
  end

  def has_crud_permissions?
    true
  end
end
