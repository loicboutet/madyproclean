class Admin::TimeEntriesController < ApplicationController
  layout 'admin'
  
  def index
    # Sample Users (Agents)
    @sample_users = [
      { id: 1, first_name: 'Martin', last_name: 'Dupont', employee_number: 'EMP001' },
      { id: 2, first_name: 'Sophie', last_name: 'Bernard', employee_number: 'EMP002' },
      { id: 3, first_name: 'Jean', last_name: 'Moreau', employee_number: 'EMP003' },
      { id: 4, first_name: 'Pierre', last_name: 'Lefebvre', employee_number: 'EMP004' },
      { id: 5, first_name: 'Marie', last_name: 'Curie', employee_number: 'EMP005' },
      { id: 6, first_name: 'Luc', last_name: 'Fontaine', employee_number: 'EMP006' }
    ]

    # Sample Sites
    @sample_sites = [
      { id: 1, name: 'Site Nucléaire A', code: 'SNA-001' },
      { id: 2, name: 'Site Nucléaire B', code: 'SNB-002' },
      { id: 3, name: 'Site Nucléaire C', code: 'SNC-003' },
      { id: 4, name: 'Site Nucléaire D', code: 'SND-004' }
    ]

    # Sample Time Entries with various statuses
    @sample_time_entries = [
      {
        id: 1,
        user: @sample_users[0],
        site: @sample_sites[0],
        clocked_in_at: Time.zone.parse('2025-11-06 08:00'),
        clocked_out_at: Time.zone.parse('2025-11-06 17:00'),
        duration_minutes: 540,
        status: 'completed',
        ip_address_in: '192.168.1.10',
        manually_corrected: false
      },
      {
        id: 2,
        user: @sample_users[1],
        site: @sample_sites[1],
        clocked_in_at: Time.zone.parse('2025-11-06 08:15'),
        clocked_out_at: Time.zone.parse('2025-11-06 17:10'),
        duration_minutes: 535,
        status: 'completed',
        ip_address_in: '192.168.1.11',
        manually_corrected: false
      },
      {
        id: 3,
        user: @sample_users[2],
        site: @sample_sites[2],
        clocked_in_at: Time.zone.parse('2025-11-06 08:30'),
        clocked_out_at: nil,
        duration_minutes: nil,
        status: 'active',
        ip_address_in: '192.168.1.12',
        manually_corrected: false
      },
      {
        id: 4,
        user: @sample_users[3],
        site: @sample_sites[0],
        clocked_in_at: Time.zone.parse('2025-11-05 08:00'),
        clocked_out_at: nil,
        duration_minutes: nil,
        status: 'anomaly',
        ip_address_in: '192.168.1.13',
        manually_corrected: false
      },
      {
        id: 5,
        user: @sample_users[4],
        site: @sample_sites[3],
        clocked_in_at: Time.zone.parse('2025-11-06 07:45'),
        clocked_out_at: Time.zone.parse('2025-11-06 16:50'),
        duration_minutes: 545,
        status: 'completed',
        ip_address_in: '192.168.1.14',
        manually_corrected: true
      },
      {
        id: 6,
        user: @sample_users[5],
        site: @sample_sites[1],
        clocked_in_at: Time.zone.parse('2025-11-06 09:00'),
        clocked_out_at: Time.zone.parse('2025-11-06 18:00'),
        duration_minutes: 540,
        status: 'completed',
        ip_address_in: '192.168.1.15',
        manually_corrected: false
      },
      {
        id: 7,
        user: @sample_users[0],
        site: @sample_sites[2],
        clocked_in_at: Time.zone.parse('2025-11-05 08:00'),
        clocked_out_at: Time.zone.parse('2025-11-05 17:00'),
        duration_minutes: 540,
        status: 'completed',
        ip_address_in: '192.168.1.10',
        manually_corrected: false
      },
      {
        id: 8,
        user: @sample_users[1],
        site: @sample_sites[0],
        clocked_in_at: Time.zone.parse('2025-11-04 08:30'),
        clocked_out_at: nil,
        duration_minutes: nil,
        status: 'anomaly',
        ip_address_in: '192.168.1.11',
        manually_corrected: false
      }
    ]
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def export
  end
end
