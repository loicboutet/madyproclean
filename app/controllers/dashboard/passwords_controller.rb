class Dashboard::PasswordsController < ApplicationController
  layout 'manager'
  
  def edit
    # Demo user data (no real model relation)
    @user = {
      id: 1,
      first_name: 'Jean',
      last_name: 'Dupont',
      email: 'jean.dupont@madyproclean.fr',
      employee_number: 'EMP-2023-001',
      role: 'manager',
      last_password_changed: 3.months.ago,
      password_expires_in: 90.days
    }

    # Demo password history
    @password_history = [
      { changed_at: 3.months.ago, method: 'Manual' },
      { changed_at: 6.months.ago, method: 'Admin Reset' },
      { changed_at: 9.months.ago, method: 'Manual' }
    ]

    # Demo security settings
    @security_settings = {
      two_factor_enabled: false,
      login_notifications: true,
      session_timeout: 30,
      max_login_attempts: 5
    }
  end

  def update
    # Dummy implementation - just redirect with success message
    redirect_to edit_dashboard_password_path, notice: 'Mot de passe mis à jour avec succès!'
  end
end
