class MockupsController < ApplicationController
  # Set the layout based on the action
  layout :resolve_layout
  
  def index
    # Main index page that will list all mockup journeys
  end
  
  # User journey pages
  def user_dashboard
    # User dashboard mockup
  end
  
  def user_profile
    # User profile mockup
  end
  
  def user_settings
    # User settings mockup
  end
  
  # Admin journey pages
  def admin_dashboard
    # Admin dashboard mockup
  end
  
  def admin_users
    # Admin users management mockup
  end
  
  def admin_analytics
    # Admin analytics mockup
  end
  
  private
  
  # Determine which layout to use based on the action name
  def resolve_layout
    if action_name == 'index'
      'application'
    elsif action_name.start_with?('user_')
      'mockup_user'
    elsif action_name.start_with?('admin_')
      'mockup_admin'
    else
      'application'
    end
  end
end