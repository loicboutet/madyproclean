class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :employee_number, :phone_number, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :employee_number, :phone_number])
  end

  # Authorization helpers
  def authorize_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  def authorize_manager!
    unless current_user&.manager? || current_user&.admin?
      redirect_to root_path, alert: 'Access denied. Manager or Admin privileges required.'
    end
  end

  def authorize_admin_or_manager!
    authorize_manager!
  end
end
