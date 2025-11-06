class Admin::AbsencesController < ApplicationController
  layout 'admin'
  before_action :set_absence, only: [:show, :edit, :update, :destroy]
  before_action :load_demo_data
  
  def index
    # Apply filters to demo data
    @absences = @all_absences.dup
    
    # Filter by absence type
    if params[:absence_type].present?
      @absences = @absences.select { |a| a[:absence_type] == params[:absence_type] }
    end
    
    # Filter by user
    if params[:user_id].present?
      @absences = @absences.select { |a| a[:user_id] == params[:user_id].to_i }
    end
    
    # Filter by date range
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      @absences = @absences.select { |a| a[:end_date] >= start_date }
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      @absences = @absences.select { |a| a[:start_date] <= end_date }
    end
    
    # Search by reason or notes
    if params[:search].present?
      search_term = params[:search].downcase
      @absences = @absences.select do |a|
        (a[:reason] && a[:reason].downcase.include?(search_term)) ||
        (a[:notes] && a[:notes].downcase.include?(search_term)) ||
        a[:user_name].downcase.include?(search_term)
      end
    end
  end

  def show
    # @absence is set by before_action
  end

  def new
    @absence = {
      id: nil,
      user_id: nil,
      absence_type: 'vacation',
      start_date: Date.today,
      end_date: Date.today,
      reason: '',
      declared_by_id: 1,
      notes: ''
    }
  end

  def create
    # Simulate creating a new absence
    new_absence = {
      id: @all_absences.length + 1,
      user_id: params[:absence][:user_id].to_i,
      absence_type: params[:absence][:absence_type],
      start_date: Date.parse(params[:absence][:start_date]),
      end_date: Date.parse(params[:absence][:end_date]),
      reason: params[:absence][:reason],
      declared_by_id: 1,
      notes: params[:absence][:notes],
      created_at: Time.current,
      updated_at: Time.current
    }
    
    redirect_to admin_absences_path, notice: 'Absence créée avec succès.'
  end

  def edit
    # @absence is set by before_action
  end

  def update
    # Simulate updating
    @absence[:user_id] = params[:absence][:user_id].to_i if params[:absence][:user_id]
    @absence[:absence_type] = params[:absence][:absence_type] if params[:absence][:absence_type]
    @absence[:start_date] = Date.parse(params[:absence][:start_date]) if params[:absence][:start_date]
    @absence[:end_date] = Date.parse(params[:absence][:end_date]) if params[:absence][:end_date]
    @absence[:reason] = params[:absence][:reason] if params[:absence][:reason]
    @absence[:notes] = params[:absence][:notes] if params[:absence][:notes]
    @absence[:updated_at] = Time.current
    
    redirect_to admin_absence_path(@absence[:id]), notice: 'Absence mise à jour avec succès.'
  end

  def destroy
    # Simulate deletion
    redirect_to admin_absences_path, notice: 'Absence supprimée avec succès.'
  end

  private

  def set_absence
    load_demo_data
    @absence = @all_absences.find { |a| a[:id] == params[:id].to_i }
    
    unless @absence
      redirect_to admin_absences_path, alert: 'Absence non trouvée.'
    end
  end

  def load_demo_data
    # Demo users
    @demo_users = [
      { id: 1, name: 'Jean Dupont', employee_number: 'EMP001', role: 'agent' },
      { id: 2, name: 'Marie Martin', employee_number: 'EMP002', role: 'agent' },
      { id: 3, name: 'Pierre Durand', employee_number: 'EMP003', role: 'agent' },
      { id: 4, name: 'Sophie Bernard', employee_number: 'EMP004', role: 'agent' },
      { id: 5, name: 'Luc Petit', employee_number: 'EMP005', role: 'agent' }
    ]
    
    # Demo managers/admins
    @demo_managers = [
      { id: 10, name: 'Admin Principal', role: 'admin' },
      { id: 11, name: 'Superviseur Nord', role: 'manager' },
      { id: 12, name: 'Superviseur Sud', role: 'manager' }
    ]
    
    # Demo absences
    @all_absences = [
      {
        id: 1,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        absence_type: 'vacation',
        absence_type_label: 'Congés payés',
        start_date: Date.today + 5,
        end_date: Date.today + 10,
        reason: 'Vacances annuelles planifiées',
        declared_by_id: 10,
        declared_by_name: 'Admin Principal',
        notes: 'Congés validés par la direction',
        created_at: Time.parse('2025-01-15 10:00:00'),
        updated_at: Time.parse('2025-01-15 10:00:00')
      },
      {
        id: 2,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        absence_type: 'sick_leave',
        absence_type_label: 'Congé maladie',
        start_date: Date.today - 2,
        end_date: Date.today,
        reason: 'Arrêt maladie - certificat médical fourni',
        declared_by_id: 11,
        declared_by_name: 'Superviseur Nord',
        notes: 'Certificat médical reçu le ' + (Date.today - 2).strftime('%d/%m/%Y'),
        created_at: Time.parse('2025-02-01 08:30:00'),
        updated_at: Time.parse('2025-02-01 08:30:00')
      },
      {
        id: 3,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        absence_type: 'training',
        absence_type_label: 'Formation',
        start_date: Date.today + 15,
        end_date: Date.today + 17,
        reason: 'Formation habilitation nucléaire - mise à jour',
        declared_by_id: 10,
        declared_by_name: 'Admin Principal',
        notes: 'Formation obligatoire - Centre de Lyon',
        created_at: Time.parse('2025-01-20 14:00:00'),
        updated_at: Time.parse('2025-01-20 14:00:00')
      },
      {
        id: 4,
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'EMP004',
        absence_type: 'unpaid_leave',
        absence_type_label: 'Congé sans solde',
        start_date: Date.today + 30,
        end_date: Date.today + 44,
        reason: 'Congé sans solde pour raisons personnelles',
        declared_by_id: 11,
        declared_by_name: 'Superviseur Nord',
        notes: 'Demande acceptée - remplacement prévu',
        created_at: Time.parse('2025-01-25 11:00:00'),
        updated_at: Time.parse('2025-01-25 11:00:00')
      },
      {
        id: 5,
        user_id: 5,
        user_name: 'Luc Petit',
        employee_number: 'EMP005',
        absence_type: 'other',
        absence_type_label: 'Autre',
        start_date: Date.today + 7,
        end_date: Date.today + 7,
        reason: 'Rendez-vous médical obligatoire',
        declared_by_id: 12,
        declared_by_name: 'Superviseur Sud',
        notes: 'Absence d\'une journée - visite médicale du travail',
        created_at: Time.parse('2025-02-03 09:00:00'),
        updated_at: Time.parse('2025-02-03 09:00:00')
      },
      {
        id: 6,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        absence_type: 'sick_leave',
        absence_type_label: 'Congé maladie',
        start_date: Date.today - 15,
        end_date: Date.today - 13,
        reason: 'Grippe saisonnière',
        declared_by_id: 10,
        declared_by_name: 'Admin Principal',
        notes: 'Retour au travail confirmé',
        created_at: Time.parse('2025-01-10 16:00:00'),
        updated_at: Time.parse('2025-01-12 10:00:00')
      },
      {
        id: 7,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        absence_type: 'vacation',
        absence_type_label: 'Congés payés',
        start_date: Date.today + 20,
        end_date: Date.today + 27,
        reason: 'Congés d\'été',
        declared_by_id: 11,
        declared_by_name: 'Superviseur Nord',
        notes: 'Période de forte demande - planning ajusté',
        created_at: Time.parse('2025-02-05 13:30:00'),
        updated_at: Time.parse('2025-02-05 13:30:00')
      },
      {
        id: 8,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        absence_type: 'training',
        absence_type_label: 'Formation',
        start_date: Date.today - 5,
        end_date: Date.today - 3,
        reason: 'Formation sécurité incendie',
        declared_by_id: 10,
        declared_by_name: 'Admin Principal',
        notes: 'Formation terminée avec succès - certification obtenue',
        created_at: Time.parse('2025-01-28 10:00:00'),
        updated_at: Time.parse('2025-02-01 15:00:00')
      }
    ]
  end
end
