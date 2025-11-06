class Manager::TimeEntriesController < ApplicationController
  layout 'manager'
  before_action :set_time_entry, only: [:show]
  before_action :load_demo_data
  
  def index
    # Apply filters to demo data (no logic, just show all)
    @time_entries = @all_time_entries.dup
    
    # Note: Filter logic intentionally not implemented as per requirements
    # Filters displayed in UI are for demonstration only
  end

  def show
    # @time_entry is set by before_action
  end

  private

  def set_time_entry
    load_demo_data
    @time_entry = @all_time_entries.find { |t| t[:id] == params[:id].to_i }
    
    unless @time_entry
      redirect_to manager_time_entries_path, alert: 'Pointage non trouvé.'
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
    
    # Demo sites
    @demo_sites = [
      { id: 1, name: 'Site Nucléaire Paris Nord', code: 'SPN-001' },
      { id: 2, name: 'Centrale de Lyon', code: 'CLY-002' },
      { id: 3, name: 'Station Marseille', code: 'SMA-003' },
      { id: 4, name: 'Centre Toulouse', code: 'CTO-004' },
      { id: 5, name: 'Unité Bordeaux', code: 'UBO-005' }
    ]
    
    # Demo time entries
    @all_time_entries = [
      {
        id: 1,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        site_id: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        clocked_in_at: Time.parse('2025-02-06 08:00:00'),
        clocked_out_at: Time.parse('2025-02-06 16:00:00'),
        duration_minutes: 480,
        status: 'completed',
        ip_address_in: '192.168.1.100',
        ip_address_out: '192.168.1.100',
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0)',
        user_agent_out: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0)',
        notes: nil,
        manually_corrected: false,
        corrected_by_id: nil,
        corrected_by_name: nil,
        corrected_at: nil,
        created_at: Time.parse('2025-02-06 08:00:00'),
        updated_at: Time.parse('2025-02-06 16:00:00')
      },
      {
        id: 2,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        site_id: 2,
        site_name: 'Centrale de Lyon',
        site_code: 'CLY-002',
        clocked_in_at: Time.parse('2025-02-06 09:00:00'),
        clocked_out_at: Time.parse('2025-02-06 17:30:00'),
        duration_minutes: 510,
        status: 'completed',
        ip_address_in: '192.168.2.50',
        ip_address_out: '192.168.2.50',
        user_agent_in: 'Mozilla/5.0 (Android 11; Mobile)',
        user_agent_out: 'Mozilla/5.0 (Android 11; Mobile)',
        notes: nil,
        manually_corrected: false,
        corrected_by_id: nil,
        corrected_by_name: nil,
        corrected_at: nil,
        created_at: Time.parse('2025-02-06 09:00:00'),
        updated_at: Time.parse('2025-02-06 17:30:00')
      },
      {
        id: 3,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        site_id: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        clocked_in_at: Time.parse('2025-02-06 07:00:00'),
        clocked_out_at: nil,
        duration_minutes: nil,
        status: 'active',
        ip_address_in: '192.168.1.102',
        ip_address_out: nil,
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0)',
        user_agent_out: nil,
        notes: nil,
        manually_corrected: false,
        corrected_by_id: nil,
        corrected_by_name: nil,
        corrected_at: nil,
        created_at: Time.parse('2025-02-06 07:00:00'),
        updated_at: Time.parse('2025-02-06 07:00:00')
      },
      {
        id: 4,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        site_id: 3,
        site_name: 'Station Marseille',
        site_code: 'SMA-003',
        clocked_in_at: Time.parse('2025-02-05 08:00:00'),
        clocked_out_at: Time.parse('2025-02-05 16:15:00'),
        duration_minutes: 495,
        status: 'completed',
        ip_address_in: '192.168.3.75',
        ip_address_out: '192.168.3.75',
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0)',
        user_agent_out: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0)',
        notes: nil,
        manually_corrected: false,
        corrected_by_id: nil,
        corrected_by_name: nil,
        corrected_at: nil,
        created_at: Time.parse('2025-02-05 08:00:00'),
        updated_at: Time.parse('2025-02-05 16:15:00')
      },
      {
        id: 5,
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'EMP004',
        site_id: 4,
        site_name: 'Centre Toulouse',
        site_code: 'CTO-004',
        clocked_in_at: Time.parse('2025-02-04 10:00:00'),
        clocked_out_at: Time.parse('2025-02-05 11:00:00'),
        duration_minutes: 1500,
        status: 'anomaly',
        ip_address_in: '192.168.4.20',
        ip_address_out: '192.168.4.20',
        user_agent_in: 'Mozilla/5.0 (Android 12; Mobile)',
        user_agent_out: 'Mozilla/5.0 (Android 12; Mobile)',
        notes: 'Pointage sortie oublié - Corrigé manuellement',
        manually_corrected: true,
        corrected_by_id: 1,
        corrected_by_name: 'Admin Principal',
        corrected_at: Time.parse('2025-02-05 11:30:00'),
        created_at: Time.parse('2025-02-04 10:00:00'),
        updated_at: Time.parse('2025-02-05 11:30:00')
      },
      {
        id: 6,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        site_id: 5,
        site_name: 'Unité Bordeaux',
        site_code: 'UBO-005',
        clocked_in_at: Time.parse('2025-02-05 09:00:00'),
        clocked_out_at: Time.parse('2025-02-05 17:00:00'),
        duration_minutes: 480,
        status: 'completed',
        ip_address_in: '192.168.5.30',
        ip_address_out: '192.168.5.30',
        user_agent_in: 'Mozilla/5.0 (Android 11; Mobile)',
        user_agent_out: 'Mozilla/5.0 (Android 11; Mobile)',
        notes: nil,
        manually_corrected: false,
        corrected_by_id: nil,
        corrected_by_name: nil,
        corrected_at: nil,
        created_at: Time.parse('2025-02-05 09:00:00'),
        updated_at: Time.parse('2025-02-05 17:00:00')
      },
      {
        id: 7,
        user_id: 5,
        user_name: 'Luc Petit',
        employee_number: 'EMP005',
        site_id: 2,
        site_name: 'Centrale de Lyon',
        site_code: 'CLY-002',
        clocked_in_at: Time.parse('2025-02-06 08:30:00'),
        clocked_out_at: Time.parse('2025-02-06 16:30:00'),
        duration_minutes: 480,
        status: 'completed',
        ip_address_in: '192.168.2.51',
        ip_address_out: '192.168.2.51',
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0)',
        user_agent_out: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0)',
        notes: nil,
        manually_corrected: false,
        corrected_by_id: nil,
        corrected_by_name: nil,
        corrected_at: nil,
        created_at: Time.parse('2025-02-06 08:30:00'),
        updated_at: Time.parse('2025-02-06 16:30:00')
      },
      {
        id: 8,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        site_id: 3,
        site_name: 'Station Marseille',
        site_code: 'SMA-003',
        clocked_in_at: Time.parse('2025-02-03 07:00:00'),
        clocked_out_at: Time.parse('2025-02-03 15:30:00'),
        duration_minutes: 510,
        status: 'completed',
        ip_address_in: '192.168.3.76',
        ip_address_out: '192.168.3.76',
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0)',
        user_agent_out: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0)',
        notes: nil,
        manually_corrected: false,
        corrected_by_id: nil,
        corrected_by_name: nil,
        corrected_at: nil,
        created_at: Time.parse('2025-02-03 07:00:00'),
        updated_at: Time.parse('2025-02-03 15:30:00')
      }
    ]
  end
end
