class Admin::AnomaliesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  
  def index
    # Demo data - no real model relations
    @demo_users = [
      { id: 1, name: 'Jean Dupont', employee_number: 'AG-001' },
      { id: 2, name: 'Marie Martin', employee_number: 'AG-002' },
      { id: 3, name: 'Pierre Dubois', employee_number: 'AG-003' },
      { id: 4, name: 'Sophie Bernard', employee_number: 'AG-004' },
      { id: 5, name: 'Luc Thomas', employee_number: 'AG-005' }
    ]

    @demo_sites = [
      { id: 1, name: 'Site Central Paris', code: 'SCP-001' },
      { id: 2, name: 'Site Lyon Nord', code: 'SLN-002' },
      { id: 3, name: 'Site Marseille', code: 'SM-003' }
    ]

    # All anomalies for demo
    @all_anomalies = [
      {
        id: 1,
        anomaly_type: 'missed_clock_out',
        severity: 'high',
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'AG-001',
        time_entry_id: 15,
        schedule_id: nil,
        description: 'Agent n\'a pas enregistré sa sortie du site Central Paris le 05/01/2025',
        resolved: false,
        resolved_by_id: nil,
        resolved_by_name: nil,
        resolved_at: nil,
        resolution_notes: nil,
        created_at: Time.new(2025, 1, 6, 8, 30),
        updated_at: Time.new(2025, 1, 6, 8, 30)
      },
      {
        id: 2,
        anomaly_type: 'over_24h',
        severity: 'high',
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'AG-002',
        time_entry_id: 23,
        schedule_id: nil,
        description: 'Pointage actif depuis plus de 24 heures (28h15) sur le site Lyon Nord',
        resolved: true,
        resolved_by_id: 8,
        resolved_by_name: 'Admin Principal',
        resolved_at: Time.new(2025, 1, 5, 14, 20),
        resolution_notes: 'Correction manuelle effectuée - oubli de pointage de sortie',
        created_at: Time.new(2025, 1, 5, 10, 0),
        updated_at: Time.new(2025, 1, 5, 14, 20)
      },
      {
        id: 3,
        anomaly_type: 'schedule_mismatch',
        severity: 'medium',
        user_id: 3,
        user_name: 'Pierre Dubois',
        employee_number: 'AG-003',
        time_entry_id: nil,
        schedule_id: 42,
        description: 'Agent n\'a pas pointé alors qu\'il était planifié sur le site Marseille le 04/01/2025',
        resolved: false,
        resolved_by_id: nil,
        resolved_by_name: nil,
        resolved_at: nil,
        resolution_notes: nil,
        created_at: Time.new(2025, 1, 5, 18, 0),
        updated_at: Time.new(2025, 1, 5, 18, 0)
      },
      {
        id: 4,
        anomaly_type: 'multiple_active',
        severity: 'high',
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'AG-004',
        time_entry_id: 31,
        schedule_id: nil,
        description: 'Détection de plusieurs pointages actifs simultanés depuis des adresses IP différentes',
        resolved: true,
        resolved_by_id: 8,
        resolved_by_name: 'Admin Principal',
        resolved_at: Time.new(2025, 1, 4, 16, 45),
        resolution_notes: 'Anomalie confirmée - doublon supprimé, agent contacté',
        created_at: Time.new(2025, 1, 4, 15, 30),
        updated_at: Time.new(2025, 1, 4, 16, 45)
      },
      {
        id: 5,
        anomaly_type: 'missed_clock_in',
        severity: 'low',
        user_id: 5,
        user_name: 'Luc Thomas',
        employee_number: 'AG-005',
        time_entry_id: nil,
        schedule_id: 38,
        description: 'Aucun pointage d\'entrée enregistré pour l\'horaire planifié du 03/01/2025',
        resolved: true,
        resolved_by_id: 7,
        resolved_by_name: 'Manager Dupuis',
        resolved_at: Time.new(2025, 1, 4, 9, 15),
        resolution_notes: 'Agent en absence maladie non déclarée - absence ajoutée rétroactivement',
        created_at: Time.new(2025, 1, 3, 20, 0),
        updated_at: Time.new(2025, 1, 4, 9, 15)
      },
      {
        id: 6,
        anomaly_type: 'missed_clock_out',
        severity: 'medium',
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'AG-001',
        time_entry_id: 45,
        schedule_id: nil,
        description: 'Sortie non enregistrée sur le site Central Paris le 02/01/2025',
        resolved: false,
        resolved_by_id: nil,
        resolved_by_name: nil,
        resolved_at: nil,
        resolution_notes: nil,
        created_at: Time.new(2025, 1, 3, 22, 0),
        updated_at: Time.new(2025, 1, 3, 22, 0)
      }
    ]

    # No filters logic applied - showing all demo data
    @anomalies = @all_anomalies
  end

  def show
    # Demo data - find anomaly by ID
    @anomaly = {
      id: params[:id].to_i,
      anomaly_type: 'missed_clock_out',
      severity: 'high',
      user_id: 1,
      user_name: 'Jean Dupont',
      employee_number: 'AG-001',
      time_entry_id: 15,
      schedule_id: nil,
      description: 'Agent n\'a pas enregistré sa sortie du site Central Paris le 05/01/2025',
      resolved: false,
      resolved_by_id: nil,
      resolved_by_name: nil,
      resolved_at: nil,
      resolution_notes: nil,
      created_at: Time.new(2025, 1, 6, 8, 30),
      updated_at: Time.new(2025, 1, 6, 8, 30),
      site_name: 'Site Central Paris',
      site_code: 'SCP-001'
    }

    # Vary the details based on ID for demo purposes
    case params[:id].to_i
    when 2
      @anomaly.merge!({
        anomaly_type: 'over_24h',
        severity: 'high',
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'AG-002',
        time_entry_id: 23,
        description: 'Pointage actif depuis plus de 24 heures (28h15) sur le site Lyon Nord',
        resolved: true,
        resolved_by_id: 8,
        resolved_by_name: 'Admin Principal',
        resolved_at: Time.new(2025, 1, 5, 14, 20),
        resolution_notes: 'Correction manuelle effectuée - oubli de pointage de sortie',
        created_at: Time.new(2025, 1, 5, 10, 0),
        updated_at: Time.new(2025, 1, 5, 14, 20),
        site_name: 'Site Lyon Nord',
        site_code: 'SLN-002'
      })
    when 3
      @anomaly.merge!({
        anomaly_type: 'schedule_mismatch',
        severity: 'medium',
        user_id: 3,
        user_name: 'Pierre Dubois',
        employee_number: 'AG-003',
        time_entry_id: nil,
        schedule_id: 42,
        description: 'Agent n\'a pas pointé alors qu\'il était planifié sur le site Marseille le 04/01/2025',
        resolved: false,
        resolved_by_id: nil,
        resolved_by_name: nil,
        resolved_at: nil,
        resolution_notes: nil,
        created_at: Time.new(2025, 1, 5, 18, 0),
        updated_at: Time.new(2025, 1, 5, 18, 0),
        site_name: 'Site Marseille',
        site_code: 'SM-003'
      })
    end
  end

  def resolve
    # Demo action - no real processing
    redirect_to admin_anomalies_path, notice: 'Anomalie marquée comme résolue'
  end
end
