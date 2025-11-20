class ClockController < ApplicationController
  before_action :find_site, only: [:show, :clock_in, :clock_out]
  before_action :ensure_authenticated, only: [:clock_in, :clock_out]
  
  layout 'clock'
  
  # GET /c/:qr_code_token
  def show
    @site = Site.find_by!(qr_code_token: params[:qr_code_token])
    
    if user_signed_in?
      @active_entry = current_user.time_entries.active.first
      @can_clock_in = @active_entry.nil?
      @can_clock_out = @active_entry.present? && @active_entry.site_id == @site.id
    else
      # Redirect to authentication page
      redirect_to clock_auth_path(qr_code_token: params[:qr_code_token])
    end
  end
  
  # POST /c/:qr_code_token/in
  def clock_in
    # Check if already clocked in
    active_entry = current_user.time_entries.active.first
    if active_entry.present?
      @error = "Vous êtes déjà pointé sur un autre site : #{active_entry.site.name}"
      render :error and return
    end
    
    # Create time entry
    @time_entry = current_user.time_entries.create!(
      site: @site,
      clocked_in_at: Time.current,
      ip_address_in: request.remote_ip,
      user_agent_in: request.user_agent,
      status: 'active'
    )
    
    @message = "✅ Pointage d'entrée validé"
    @site_name = @site.name
    render :success
  rescue ActiveRecord::RecordInvalid => e
    @error = "Erreur: #{e.message}"
    render :error
  end
  
  # POST /c/:qr_code_token/out
  def clock_out
    # Find active entry for this user at this site
    @time_entry = current_user.time_entries.active.find_by(site: @site)
    
    if @time_entry.nil?
      @error = "Aucun pointage actif trouvé pour ce site"
      render :error and return
    end
    
    # Clock out
    @time_entry.update!(
      clocked_out_at: Time.current,
      ip_address_out: request.remote_ip,
      user_agent_out: request.user_agent,
      status: 'completed'
    )
    @time_entry.calculate_duration
    @time_entry.save!
    
    @message = "✅ Pointage de sortie validé"
    @site_name = @site.name
    render :success
  rescue => e
    @error = "Erreur: #{e.message}"
    render :error
  end
  
  # GET /clock/auth
  def authenticate
    @qr_code_token = params[:qr_code_token]
  end
  
  # POST /clock/auth
  def verify
    user = User.find_by(email: params[:email])
    
    if user && user.valid_password?(params[:password])
      sign_in(user)
      redirect_to clock_show_path(qr_code_token: params[:qr_code_token])
    else
      flash.now[:alert] = "Email ou mot de passe incorrect"
      @qr_code_token = params[:qr_code_token]
      render :authenticate
    end
  end
  
  private
  
  def find_site
    @site = Site.active.find_by!(qr_code_token: params[:qr_code_token])
  rescue ActiveRecord::RecordNotFound
    render plain: "QR Code invalide", status: :not_found
  end
  
  def ensure_authenticated
    unless user_signed_in?
      redirect_to clock_auth_path(qr_code_token: params[:qr_code_token]), alert: "Veuillez vous authentifier"
    end
  end
end
