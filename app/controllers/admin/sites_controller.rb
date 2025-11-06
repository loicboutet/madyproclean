class Admin::SitesController < ApplicationController
  layout 'admin'
  before_action :set_site, only: [:show, :edit, :update, :destroy]
  before_action :load_demo_data
  
  def index
    # Apply filters to demo data
    @sites = @all_sites.dup
    
    # Filter by active status
    if params[:status].present?
      if params[:status] == 'active'
        @sites = @sites.select { |s| s[:active] == true }
      elsif params[:status] == 'inactive'
        @sites = @sites.select { |s| s[:active] == false }
      end
    end
    
    # Search by name or code
    if params[:search].present?
      search_term = params[:search].downcase
      @sites = @sites.select do |s|
        s[:name].downcase.include?(search_term) || s[:code].downcase.include?(search_term)
      end
    end
  end

  def show
    # @site is set by before_action
  end

  def new
    @site = {
      id: nil,
      name: '',
      code: '',
      address: '',
      description: '',
      active: true,
      qr_code_token: nil
    }
  end

  def create
    # Simulate creating a new site
    new_site = {
      id: @all_sites.length + 1,
      name: params[:site][:name],
      code: params[:site][:code],
      address: params[:site][:address],
      description: params[:site][:description],
      active: params[:site][:active] == '1',
      qr_code_token: generate_qr_code_token,
      created_at: Time.current,
      updated_at: Time.current
    }
    
    redirect_to admin_sites_path, notice: 'Site créé avec succès.'
  end

  def edit
    # @site is set by before_action
  end

  def update
    # Simulate updating - in a real app, you would save to database
    @site[:name] = params[:site][:name] if params[:site][:name]
    @site[:code] = params[:site][:code] if params[:site][:code]
    @site[:address] = params[:site][:address] if params[:site][:address]
    @site[:description] = params[:site][:description] if params[:site][:description]
    @site[:active] = params[:site][:active] == '1' if params[:site][:active]
    @site[:updated_at] = Time.current
    
    redirect_to admin_site_path(@site[:id]), notice: 'Site mis à jour avec succès.'
  end

  def destroy
    # Simulate soft deletion by marking as inactive
    @site[:active] = false
    redirect_to admin_sites_path, notice: 'Site désactivé avec succès.'
  end

  def qr_code
    @site = @all_sites.find { |s| s[:id] == params[:id].to_i }
    unless @site
      redirect_to admin_sites_path, alert: 'Site non trouvé.'
    end
    # Render QR code view (to be implemented)
  end

  private

  def set_site
    load_demo_data
    @site = @all_sites.find { |s| s[:id] == params[:id].to_i }
    
    unless @site
      redirect_to admin_sites_path, alert: 'Site non trouvé.'
    end
  end

  def load_demo_data
    # Demo sites
    @all_sites = [
      {
        id: 1,
        name: 'Site Nucléaire Paris Nord',
        code: 'SPN-001',
        address: '123 Rue de la République, 75001 Paris',
        description: 'Site principal de la région parisienne - Zone sécurisée niveau 3',
        active: true,
        qr_code_token: 'tk_a1b2c3d4e5f6g7h8',
        created_at: Time.parse('2025-01-15 10:00:00'),
        updated_at: Time.parse('2025-01-15 10:00:00')
      },
      {
        id: 2,
        name: 'Centrale de Lyon',
        code: 'CLY-002',
        address: '456 Avenue du Rhône, 69001 Lyon',
        description: 'Centrale de production - Accès contrôlé',
        active: true,
        qr_code_token: 'tk_b2c3d4e5f6g7h8i9',
        created_at: Time.parse('2025-01-20 14:30:00'),
        updated_at: Time.parse('2025-02-10 09:15:00')
      },
      {
        id: 3,
        name: 'Station Marseille',
        code: 'SMA-003',
        address: '789 Boulevard Maritime, 13001 Marseille',
        description: 'Station secondaire - Zone maritime',
        active: true,
        qr_code_token: 'tk_c3d4e5f6g7h8i9j0',
        created_at: Time.parse('2025-02-01 11:00:00'),
        updated_at: Time.parse('2025-02-01 11:00:00')
      },
      {
        id: 4,
        name: 'Centre Toulouse',
        code: 'CTO-004',
        address: '321 Rue Capitole, 31000 Toulouse',
        description: 'Centre de maintenance - Atelier technique',
        active: true,
        qr_code_token: 'tk_d4e5f6g7h8i9j0k1',
        created_at: Time.parse('2025-02-05 08:45:00'),
        updated_at: Time.parse('2025-02-15 16:20:00')
      },
      {
        id: 5,
        name: 'Unité Bordeaux',
        code: 'UBO-005',
        address: '654 Quai de la Garonne, 33000 Bordeaux',
        description: 'Unité de traitement - Zone industrielle',
        active: true,
        qr_code_token: 'tk_e5f6g7h8i9j0k1l2',
        created_at: Time.parse('2025-02-10 13:00:00'),
        updated_at: Time.parse('2025-02-10 13:00:00')
      },
      {
        id: 6,
        name: 'Ancien Site Lille',
        code: 'ASL-006',
        address: '987 Avenue de la Liberté, 59000 Lille',
        description: 'Site désaffecté - En cours de fermeture',
        active: false,
        qr_code_token: 'tk_f6g7h8i9j0k1l2m3',
        created_at: Time.parse('2024-12-01 10:00:00'),
        updated_at: Time.parse('2025-03-01 14:30:00')
      }
    ]
  end

  def generate_qr_code_token
    "tk_#{SecureRandom.hex(8)}"
  end
end
