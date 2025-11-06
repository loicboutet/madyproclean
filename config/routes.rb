Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root
  root 'pages#home'
  
  # Roles overview
  get 'roles', to: 'pages#roles'
  
  # Authentication
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  # Agent Clock-in (separate domain constraint)
  constraints subdomain: 'clock' do
    get 'c/:qr_code_token', to: 'clock#show'
    post 'c/:qr_code_token/in', to: 'clock#clock_in'
    post 'c/:qr_code_token/out', to: 'clock#clock_out'
    get 'clock/auth', to: 'clock#authenticate'
    post 'clock/auth', to: 'clock#verify'
  end
  
  # Admin namespace
  namespace :admin do
    root 'dashboard#index'
    get 'dashboard', to: 'dashboard#index'
    
    resources :time_entries do
      get 'export', on: :collection
    end
    
    resources :sites do
      member do
        get 'qr_code'
      end
    end
    
    resources :users
    
    resources :schedules do
      member do
        post 'assign_replacement'
      end
      get 'export', on: :collection
    end
    
    resources :absences
    
    resources :anomalies, only: [:index, :show] do
      member do
        post 'resolve'
      end
    end
    
    resources :reports, only: [:index, :show]
    get 'reports/monthly', to: 'reports#monthly', as: 'reports_monthly'
    get 'reports/hr', to: 'reports#hr', as: 'reports_hr'
  end
  
  # Manager namespace
  namespace :manager do
    root 'dashboard#index'
    get 'dashboard', to: 'dashboard#index'
    
    resources :time_entries, only: [:index, :show]
    resources :schedules, only: [:index, :show]
    resources :absences
    resources :team, only: [:index, :show]
    
    get 'replacements', to: 'replacements#index'
    post 'replacements/assign', to: 'replacements#assign'
  end
  
  # Common dashboard
  namespace :dashboard do
    resource :profile, only: [:show, :edit, :update]
    resource :password, only: [:edit, :update]
  end
  
  # Mockups routes (kept for reference)
  get 'mockups/index'
  get 'mockups/user_dashboard'
  get 'mockups/user_profile'
  get 'mockups/user_settings'
  get 'mockups/admin_dashboard'
  get 'mockups/admin_users'
  get 'mockups/admin_analytics'
end
