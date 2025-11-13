class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :employee_number, :phone_number, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :employee_number, :phone_number])
  end

  # Authentication helper
  def authenticate_user!
    unless current_user
      redirect_to login_path, alert: 'Vous devez vous connecter pour accéder à cette page.'
    end
  end

  # Redirect to role-specific dashboard
  def redirect_to_dashboard
    return unless current_user
    
    if current_user.admin?
      redirect_to admin_dashboard_path
    elsif current_user.manager?
      redirect_to manager_dashboard_path
    else
      # Agents don't have a dedicated dashboard, send them to home
      redirect_to home_path
    end
  end

  # Authorization helpers
  def authorize_admin!
    return unless current_user # authenticate_user! will handle redirect
    unless current_user.admin?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  def authorize_manager!
    return unless current_user # authenticate_user! will handle redirect
    unless current_user.manager? || current_user.admin?
      redirect_to root_path, alert: 'Access denied. Manager or Admin privileges required.'
    end
  end

  def authorize_admin_or_manager!
    authorize_manager!
  end
end
