class Manager::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager!
  layout 'manager'
  
  def index
  end
end
