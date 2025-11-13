class Admin::TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  layout 'admin'
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy]
  before_action :load_demo_data
  
  def index
    # Apply filters to demo data
    @time_entries = @all_time_entries.dup
    
    if params[:user_id].present?
      @time_entries = @time_entries.select { |e| e[:user][:id] == params[:user_id].to_i }
    end
    
    if params[:site_id].present?
      @time_entries = @time_entries.select { |e| e[:site][:id] == params[:site_id].to_i }
    end
    
    if params[:status].present?
      @time_entries = @time_entries.select { |e| e[:status] == params[:status] }
    end
    
    # Date range filter
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      @time_entries = @time_entries.select { |e| e[:clocked_in_at].to_date >= start_date }
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      @time_entries = @time_entries.select { |e| e[:clocked_in_at].to_date <= end_date }
    end
  end

  def show
    # @time_entry is set by before_action
  end

  def new
    @time_entry = {
      id: nil,
      user: { id: nil },
      site: { id: nil },
      clocked_in_at: Time.current,
      clocked_out_at: nil,
      status: 'active',
      notes: '',
      manually_corrected: false
    }
  end

  def create
    # Simulate creating a new time entry
    new_entry = {
      id: @all_time_entries.length + 1,
      user: @sample_users.find { |u| u[:id] == params[:time_entry][:user_id].to_i },
      site: @sample_sites.find { |s| s[:id] == params[:time_entry][:site_id].to_i },
      clocked_in_at: params[:time_entry][:clocked_in_at].present? ? Time.parse(params[:time_entry][:clocked_in_at]) : Time.current,
      clocked_out_at: params[:time_entry][:clocked_out_at].present? ? Time.parse(params[:time_entry][:clocked_out_at]) : nil,
      status: params[:time_entry][:status] || 'active',
      ip_address_in: '192.168.1.100',
      ip_address_out: params[:time_entry][:clocked_out_at].present? ? '192.168.1.100' : nil,
      user_agent_in: request.user_agent,
      user_agent_out: params[:time_entry][:clocked_out_at].present? ? request.user_agent : nil,
      notes: params[:time_entry][:notes] || '',
      manually_corrected: true,
      corrected_by: { id: 1, first_name: 'Admin', last_name: 'User' },
      corrected_at: Time.current,
      duration_minutes: calculate_duration(
        params[:time_entry][:clocked_in_at].present? ? Time.parse(params[:time_entry][:clocked_in_at]) : Time.current,
        params[:time_entry][:clocked_out_at].present? ? Time.parse(params[:time_entry][:clocked_out_at]) : nil
      )
    }
    
    redirect_to admin_time_entries_path, notice: 'Pointage créé avec succès.'
  end

  def edit
    # @time_entry is set by before_action
  end

  def update
    # Simulate updating - in a real app, you would save to database
    @time_entry[:user] = @sample_users.find { |u| u[:id] == params[:time_entry][:user_id].to_i } if params[:time_entry][:user_id]
    @time_entry[:site] = @sample_sites.find { |s| s[:id] == params[:time_entry][:site_id].to_i } if params[:time_entry][:site_id]
    @time_entry[:clocked_in_at] = Time.parse(params[:time_entry][:clocked_in_at]) if params[:time_entry][:clocked_in_at].present?
    @time_entry[:clocked_out_at] = Time.parse(params[:time_entry][:clocked_out_at]) if params[:time_entry][:clocked_out_at].present?
    @time_entry[:status] = params[:time_entry][:status] if params[:time_entry][:status]
    @time_entry[:notes] = params[:time_entry][:notes] if params[:time_entry][:notes]
    @time_entry[:manually_corrected] = true
    @time_entry[:corrected_at] = Time.current
    
    # Recalculate duration
    @time_entry[:duration_minutes] = calculate_duration(@time_entry[:clocked_in_at], @time_entry[:clocked_out_at])
    
    redirect_to admin_time_entry_path(@time_entry[:id]), notice: 'Pointage mis à jour avec succès.'
  end

  def destroy
    # Simulate deletion
    redirect_to admin_time_entries_path, notice: 'Pointage supprimé avec succès.'
  end

  def export
    # Apply same filters as index
    @time_entries = @all_time_entries.dup
    
    if params[:user_id].present?
      @time_entries = @time_entries.select { |e| e[:user][:id] == params[:user_id].to_i }
    end
    
    if params[:site_id].present?
      @time_entries = @time_entries.select { |e| e[:site][:id] == params[:site_id].to_i }
    end
    
    if params[:status].present?
      @time_entries = @time_entries.select { |e| e[:status] == params[:status] }
    end
    
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      @time_entries = @time_entries.select { |e| e[:clocked_in_at].to_date >= start_date }
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      @time_entries = @time_entries.select { |e| e[:clocked_in_at].to_date <= end_date }
    end
    
    respond_to do |format|
      format.csv do
        send_data generate_csv(@time_entries), filename: "pointages-#{Date.today}.csv"
      end
    end
  end

  private

  def set_time_entry
    load_demo_data
    @time_entry = @all_time_entries.find { |e| e[:id] == params[:id].to_i }
    
    unless @time_entry
      redirect_to admin_time_entries_path, alert: 'Pointage non trouvé.'
    end
  end

  def load_demo_data
    # Demo users (agents)
    @sample_users = [
      { id: 1, first_name: 'Jean', last_name: 'Dupont', employee_number: 'AGT-001', email: 'jean.dupont@example.com', role: 'agent' },
      { id: 2, first_name: 'Marie', last_name: 'Martin', employee_number: 'AGT-002', email: 'marie.martin@example.com', role: 'agent' },
      { id: 3, first_name: 'Pierre', last_name: 'Bernard', employee_number: 'AGT-003', email: 'pierre.bernard@example.com', role: 'agent' },
      { id: 4, first_name: 'Sophie', last_name: 'Dubois', employee_number: 'AGT-004', email: 'sophie.dubois@example.com', role: 'agent' },
      { id: 5, first_name: 'Luc', last_name: 'Moreau', employee_number: 'AGT-005', email: 'luc.moreau@example.com', role: 'agent' },
      { id: 6, first_name: 'Claire', last_name: 'Simon', employee_number: 'AGT-006', email: 'claire.simon@example.com', role: 'agent' },
      { id: 7, first_name: 'Thomas', last_name: 'Laurent', employee_number: 'AGT-007', email: 'thomas.laurent@example.com', role: 'agent' },
      { id: 8, first_name: 'Emma', last_name: 'Lefevre', employee_number: 'AGT-008', email: 'emma.lefevre@example.com', role: 'agent' }
    ]

    # Demo sites
    @sample_sites = [
      { id: 1, name: 'Site Nucléaire Paris Nord', code: 'SPN-001', address: '123 Rue de la République, 75001 Paris', active: true },
      { id: 2, name: 'Centrale de Lyon', code: 'CLY-002', address: '456 Avenue du Rhône, 69001 Lyon', active: true },
      { id: 3, name: 'Station Marseille', code: 'SMA-003', address: '789 Boulevard Maritime, 13001 Marseille', active: true },
      { id: 4, name: 'Centre Toulouse', code: 'CTO-004', address: '321 Rue Capitole, 31000 Toulouse', active: true },
      { id: 5, name: 'Unité Bordeaux', code: 'UBO-005', address: '654 Quai de la Garonne, 33000 Bordeaux', active: true }
    ]

    # Demo time entries
    @all_time_entries = [
      {
        id: 1,
        user: @sample_users[0],
        site: @sample_sites[0],
        clocked_in_at: Time.parse('2025-11-06 08:00:00'),
        clocked_out_at: Time.parse('2025-11-06 17:30:00'),
        duration_minutes: 570,
        status: 'completed',
        ip_address_in: '192.168.1.45',
        ip_address_out: '192.168.1.45',
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        user_agent_out: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        notes: nil,
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      },
      {
        id: 2,
        user: @sample_users[1],
        site: @sample_sites[1],
        clocked_in_at: Time.parse('2025-11-06 07:45:00'),
        clocked_out_at: Time.parse('2025-11-06 16:15:00'),
        duration_minutes: 510,
        status: 'completed',
        ip_address_in: '192.168.1.78',
        ip_address_out: '192.168.1.78',
        user_agent_in: 'Mozilla/5.0 (Android 12; Mobile)',
        user_agent_out: 'Mozilla/5.0 (Android 12; Mobile)',
        notes: nil,
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      },
      {
        id: 3,
        user: @sample_users[2],
        site: @sample_sites[2],
        clocked_in_at: Time.parse('2025-11-06 09:00:00'),
        clocked_out_at: nil,
        duration_minutes: nil,
        status: 'active',
        ip_address_in: '192.168.1.92',
        ip_address_out: nil,
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)',
        user_agent_out: nil,
        notes: nil,
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      },
      {
        id: 4,
        user: @sample_users[3],
        site: @sample_sites[0],
        clocked_in_at: Time.parse('2025-11-05 08:30:00'),
        clocked_out_at: Time.parse('2025-11-05 18:00:00'),
        duration_minutes: 570,
        status: 'completed',
        ip_address_in: '192.168.1.55',
        ip_address_out: '192.168.1.55',
        user_agent_in: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        user_agent_out: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        notes: nil,
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      },
      {
        id: 5,
        user: @sample_users[4],
        site: @sample_sites[3],
        clocked_in_at: Time.parse('2025-11-04 08:00:00'),
        clocked_out_at: nil,
        duration_minutes: nil,
        status: 'anomaly',
        ip_address_in: '192.168.1.120',
        ip_address_out: nil,
        user_agent_in: 'Mozilla/5.0 (Android 11; Mobile)',
        user_agent_out: nil,
        notes: 'Anomalie détectée: pas de pointage de départ depuis plus de 24h',
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      },
      {
        id: 6,
        user: @sample_users[5],
        site: @sample_sites[1],
        clocked_in_at: Time.parse('2025-11-05 07:30:00'),
        clocked_out_at: Time.parse('2025-11-05 16:45:00'),
        duration_minutes: 555,
        status: 'completed',
        ip_address_in: '192.168.1.88',
        ip_address_out: '192.168.1.88',
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X)',
        user_agent_out: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_5 like Mac OS X)',
        notes: 'Correction manuelle suite à oubli de pointage',
        manually_corrected: true,
        corrected_by: { id: 1, first_name: 'Admin', last_name: 'User', email: 'admin@example.com' },
        corrected_at: Time.parse('2025-11-05 18:00:00')
      },
      {
        id: 7,
        user: @sample_users[6],
        site: @sample_sites[4],
        clocked_in_at: Time.parse('2025-11-06 08:15:00'),
        clocked_out_at: Time.parse('2025-11-06 17:00:00'),
        duration_minutes: 525,
        status: 'completed',
        ip_address_in: '192.168.1.101',
        ip_address_out: '192.168.1.101',
        user_agent_in: 'Mozilla/5.0 (Android 13; Mobile)',
        user_agent_out: 'Mozilla/5.0 (Android 13; Mobile)',
        notes: nil,
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      },
      {
        id: 8,
        user: @sample_users[7],
        site: @sample_sites[2],
        clocked_in_at: Time.parse('2025-11-06 07:00:00'),
        clocked_out_at: Time.parse('2025-11-06 15:30:00'),
        duration_minutes: 510,
        status: 'completed',
        ip_address_in: '192.168.1.75',
        ip_address_out: '192.168.1.75',
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_1 like Mac OS X)',
        user_agent_out: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_1 like Mac OS X)',
        notes: nil,
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      },
      {
        id: 9,
        user: @sample_users[0],
        site: @sample_sites[3],
        clocked_in_at: Time.parse('2025-11-05 09:30:00'),
        clocked_out_at: Time.parse('2025-11-05 18:15:00'),
        duration_minutes: 525,
        status: 'completed',
        ip_address_in: '192.168.1.45',
        ip_address_out: '192.168.1.45',
        user_agent_in: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        user_agent_out: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        notes: nil,
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      },
      {
        id: 10,
        user: @sample_users[1],
        site: @sample_sites[0],
        clocked_in_at: Time.parse('2025-11-04 08:00:00'),
        clocked_out_at: Time.parse('2025-11-04 17:30:00'),
        duration_minutes: 570,
        status: 'completed',
        ip_address_in: '192.168.1.78',
        ip_address_out: '192.168.1.78',
        user_agent_in: 'Mozilla/5.0 (Android 12; Mobile)',
        user_agent_out: 'Mozilla/5.0 (Android 12; Mobile)',
        notes: nil,
        manually_corrected: false,
        corrected_by: nil,
        corrected_at: nil
      }
    ]
  end

  def calculate_duration(clock_in, clock_out)
    return nil unless clock_in && clock_out
    ((clock_out - clock_in) / 60).to_i
  end

  def generate_csv(time_entries)
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'Agent', 'Numéro Employé', 'Site', 'Arrivée', 'Départ', 'Durée (minutes)', 'Statut', 'IP Arrivée', 'Corrigé Manuellement', 'Notes']
      
      time_entries.each do |entry|
        csv << [
          entry[:id],
          "#{entry[:user][:first_name]} #{entry[:user][:last_name]}",
          entry[:user][:employee_number],
          entry[:site][:name],
          entry[:clocked_in_at]&.strftime('%d/%m/%Y %H:%M'),
          entry[:clocked_out_at]&.strftime('%d/%m/%Y %H:%M'),
          entry[:duration_minutes],
          entry[:status],
          entry[:ip_address_in],
          entry[:manually_corrected] ? 'Oui' : 'Non',
          entry[:notes]
        ]
      end
    end
  end
end
