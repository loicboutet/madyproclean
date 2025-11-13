class SessionsController < ApplicationController
  before_action :redirect_if_authenticated, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user && user.valid_password?(params[:password])
      sign_in(user)
      redirect_to_dashboard
    else
      flash.now[:alert] = "Email ou mot de passe incorrect."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out(current_user) if current_user
    redirect_to root_path, notice: "Vous avez été déconnecté avec succès."
  end

  private

  def redirect_if_authenticated
    redirect_to_dashboard if current_user
  end
end
