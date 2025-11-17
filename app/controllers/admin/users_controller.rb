class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :load_demo_data
  
  def index
    # Apply filters to demo data
    @users = @all_users.dup
    
    # Filter by role
    if params[:role].present? && params[:role] != 'all'
      @users = @users.select { |u| u[:role] == params[:role] }
    end
    
    # Filter by active status
    if params[:status].present?
      if params[:status] == 'active'
        @users = @users.select { |u| u[:active] == true }
      elsif params[:status] == 'inactive'
        @users = @users.select { |u| u[:active] == false }
      end
    end
    
    # Search by name, email, or employee number
    if params[:search].present?
      search_term = params[:search].downcase
      @users = @users.select do |u|
        u[:first_name].downcase.include?(search_term) ||
        u[:last_name].downcase.include?(search_term) ||
        u[:email].downcase.include?(search_term) ||
        (u[:employee_number] && u[:employee_number].downcase.include?(search_term))
      end
    end
  end

  def show
    # @user is set by before_action
    if @user[:manager_id]
      @manager = @all_users.find { |u| u[:id] == @user[:manager_id] }
    end
  end

  def new
    @user = {
      id: nil,
      email: '',
      first_name: '',
      last_name: '',
      employee_number: '',
      role: 'agent',
      active: true,
      phone_number: '',
      manager_id: nil
    }
    @managers = @all_users.select { |u| u[:role] == 'manager' && u[:active] }
  end

  def create
    # Simulate creating a new user
    new_user = {
      id: @all_users.length + 1,
      email: params[:user][:email],
      first_name: params[:user][:first_name],
      last_name: params[:user][:last_name],
      employee_number: params[:user][:employee_number],
      role: params[:user][:role],
      active: params[:user][:active] == '1',
      phone_number: params[:user][:phone_number],
      manager_id: params[:user][:manager_id].present? ? params[:user][:manager_id].to_i : nil,
      created_at: Time.current,
      updated_at: Time.current
    }
    
    redirect_to admin_users_path, notice: 'Utilisateur créé avec succès.'
  end

  def edit
    # @user is set by before_action
    @managers = @all_users.select { |u| u[:role] == 'manager' && u[:active] }
  end

  def update
    # Simulate updating - in a real app, you would save to database
    @user[:email] = params[:user][:email] if params[:user][:email]
    @user[:first_name] = params[:user][:first_name] if params[:user][:first_name]
    @user[:last_name] = params[:user][:last_name] if params[:user][:last_name]
    @user[:employee_number] = params[:user][:employee_number] if params[:user][:employee_number]
    @user[:role] = params[:user][:role] if params[:user][:role]
    @user[:active] = params[:user][:active] == '1' if params[:user][:active]
    @user[:phone_number] = params[:user][:phone_number] if params[:user][:phone_number]
    @user[:manager_id] = params[:user][:manager_id].present? ? params[:user][:manager_id].to_i : nil if params[:user][:manager_id]
    @user[:updated_at] = Time.current
    
    redirect_to admin_user_path(@user[:id]), notice: 'Utilisateur mis à jour avec succès.'
  end

  def destroy
    # Simulate soft deletion by marking as inactive
    @user[:active] = false
    redirect_to admin_users_path, notice: 'Utilisateur désactivé avec succès.'
  end

  private

  def set_user
    load_demo_data
    @user = @all_users.find { |u| u[:id] == params[:id].to_i }
    
    unless @user
      redirect_to admin_users_path, alert: 'Utilisateur non trouvé.'
    end
  end

  def load_demo_data
    # Demo users - mix of admins, managers, and agents
    @all_users = [
      # Admins (Direction)
      {
        id: 1,
        email: 'marie.dubois@madyproclean.fr',
        first_name: 'Marie',
        last_name: 'Dubois',
        employee_number: 'ADM-001',
        role: 'admin',
        active: true,
        phone_number: '+33 6 12 34 56 01',
        manager_id: nil,
        created_at: Time.parse('2024-11-01 09:00:00'),
        updated_at: Time.parse('2024-11-01 09:00:00')
      },
      {
        id: 2,
        email: 'jean.martin@madyproclean.fr',
        first_name: 'Jean',
        last_name: 'Martin',
        employee_number: 'ADM-002',
        role: 'admin',
        active: true,
        phone_number: '+33 6 12 34 56 02',
        manager_id: nil,
        created_at: Time.parse('2024-11-05 10:30:00'),
        updated_at: Time.parse('2025-01-15 14:20:00')
      },
      {
        id: 3,
        email: 'sophie.bernard@madyproclean.fr',
        first_name: 'Sophie',
        last_name: 'Bernard',
        employee_number: 'ADM-003',
        role: 'admin',
        active: true,
        phone_number: '+33 6 12 34 56 03',
        manager_id: nil,
        created_at: Time.parse('2024-11-10 11:00:00'),
        updated_at: Time.parse('2024-11-10 11:00:00')
      },
      
      # Managers (Supervisors)
      {
        id: 4,
        email: 'pierre.laurent@madyproclean.fr',
        first_name: 'Pierre',
        last_name: 'Laurent',
        employee_number: 'MGR-001',
        role: 'manager',
        active: true,
        phone_number: '+33 6 23 45 67 01',
        manager_id: nil,
        created_at: Time.parse('2024-11-15 08:30:00'),
        updated_at: Time.parse('2025-02-10 09:15:00')
      },
      {
        id: 5,
        email: 'claire.moreau@madyproclean.fr',
        first_name: 'Claire',
        last_name: 'Moreau',
        employee_number: 'MGR-002',
        role: 'manager',
        active: true,
        phone_number: '+33 6 23 45 67 02',
        manager_id: nil,
        created_at: Time.parse('2024-11-20 09:00:00'),
        updated_at: Time.parse('2024-11-20 09:00:00')
      },
      {
        id: 6,
        email: 'laurent.petit@madyproclean.fr',
        first_name: 'Laurent',
        last_name: 'Petit',
        employee_number: 'MGR-003',
        role: 'manager',
        active: true,
        phone_number: '+33 6 23 45 67 03',
        manager_id: nil,
        created_at: Time.parse('2024-12-01 10:00:00'),
        updated_at: Time.parse('2025-01-20 16:30:00')
      },
      
      # Agents (Field Workers)
      {
        id: 7,
        email: 'luc.roux@madyproclean.fr',
        first_name: 'Luc',
        last_name: 'Roux',
        employee_number: 'AGT-001',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 01',
        manager_id: 4,
        created_at: Time.parse('2024-12-05 08:00:00'),
        updated_at: Time.parse('2024-12-05 08:00:00')
      },
      {
        id: 8,
        email: 'amelie.simon@madyproclean.fr',
        first_name: 'Amélie',
        last_name: 'Simon',
        employee_number: 'AGT-002',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 02',
        manager_id: 4,
        created_at: Time.parse('2024-12-10 09:30:00'),
        updated_at: Time.parse('2025-02-01 11:20:00')
      },
      {
        id: 9,
        email: 'thomas.michel@madyproclean.fr',
        first_name: 'Thomas',
        last_name: 'Michel',
        employee_number: 'AGT-003',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 03',
        manager_id: 4,
        created_at: Time.parse('2024-12-15 10:00:00'),
        updated_at: Time.parse('2024-12-15 10:00:00')
      },
      {
        id: 10,
        email: 'isabelle.fontaine@madyproclean.fr',
        first_name: 'Isabelle',
        last_name: 'Fontaine',
        employee_number: 'AGT-004',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 04',
        manager_id: 5,
        created_at: Time.parse('2025-01-05 08:30:00'),
        updated_at: Time.parse('2025-01-05 08:30:00')
      },
      {
        id: 11,
        email: 'nicolas.andre@madyproclean.fr',
        first_name: 'Nicolas',
        last_name: 'André',
        employee_number: 'AGT-005',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 05',
        manager_id: 5,
        created_at: Time.parse('2025-01-10 09:00:00'),
        updated_at: Time.parse('2025-02-15 14:10:00')
      },
      {
        id: 12,
        email: 'julie.leroy@madyproclean.fr',
        first_name: 'Julie',
        last_name: 'Leroy',
        employee_number: 'AGT-006',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 06',
        manager_id: 5,
        created_at: Time.parse('2025-01-15 10:30:00'),
        updated_at: Time.parse('2025-01-15 10:30:00')
      },
      {
        id: 13,
        email: 'david.blanc@madyproclean.fr',
        first_name: 'David',
        last_name: 'Blanc',
        employee_number: 'AGT-007',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 07',
        manager_id: 6,
        created_at: Time.parse('2025-01-20 08:00:00'),
        updated_at: Time.parse('2025-01-20 08:00:00')
      },
      {
        id: 14,
        email: 'sandrine.garnier@madyproclean.fr',
        first_name: 'Sandrine',
        last_name: 'Garnier',
        employee_number: 'AGT-008',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 08',
        manager_id: 6,
        created_at: Time.parse('2025-01-25 09:30:00'),
        updated_at: Time.parse('2025-02-20 16:45:00')
      },
      {
        id: 15,
        email: 'francois.rousseau@madyproclean.fr',
        first_name: 'François',
        last_name: 'Rousseau',
        employee_number: 'AGT-009',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 09',
        manager_id: 6,
        created_at: Time.parse('2025-02-01 10:00:00'),
        updated_at: Time.parse('2025-02-01 10:00:00')
      },
      {
        id: 16,
        email: 'valerie.girard@madyproclean.fr',
        first_name: 'Valérie',
        last_name: 'Girard',
        employee_number: 'AGT-010',
        role: 'agent',
        active: false,
        phone_number: '+33 6 34 56 78 10',
        manager_id: 4,
        created_at: Time.parse('2024-10-01 08:00:00'),
        updated_at: Time.parse('2025-02-15 12:00:00')
      },
      {
        id: 17,
        email: 'marc.bonnet@madyproclean.fr',
        first_name: 'Marc',
        last_name: 'Bonnet',
        employee_number: 'AGT-011',
        role: 'agent',
        active: false,
        phone_number: '+33 6 34 56 78 11',
        manager_id: 5,
        created_at: Time.parse('2024-09-15 09:00:00'),
        updated_at: Time.parse('2025-01-30 10:30:00')
      },
      {
        id: 18,
        email: 'christine.lambert@madyproclean.fr',
        first_name: 'Christine',
        last_name: 'Lambert',
        employee_number: 'AGT-012',
        role: 'agent',
        active: true,
        phone_number: '+33 6 34 56 78 12',
        manager_id: 4,
        created_at: Time.parse('2025-02-05 08:30:00'),
        updated_at: Time.parse('2025-02-05 08:30:00')
      }
    ]
  end
end
