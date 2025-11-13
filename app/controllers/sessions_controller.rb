class SessionsController < ApplicationController
  before_action :redirect_if_authenticated, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: session_params[:email])
    
    if user && user.valid_password?(session_params[:password])
      # Use Devise's sign_in method with proper scoping
      sign_in(:user, user)
      
      # Handle remember me
      user.remember_me! if session_params[:remember_me] == '1'
      
      redirect_to_dashboard
    else
      flash.now[:alert] = "Email ou mot de passe incorrect."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user
      sign_out(:user)
    end
    redirect_to root_path, notice: "Vous avez été déconnecté avec succès."
  end

  private

  def redirect_if_authenticated
    redirect_to_dashboard if current_user
  end

  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end
end
