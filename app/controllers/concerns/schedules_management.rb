# frozen_string_literal: true

# SchedulesManagement Concern
#
# This module extracts shared schedule management logic between Admin and Manager namespaces.
# It provides common methods for loading demo data, filtering schedules, and setting schedules.
#
# Usage:
#   class Admin::SchedulesController < ApplicationController
#     include SchedulesManagement
#
#     def schedules_index_path
#       admin_schedules_path
#     end
#
#     def schedule_path(id)
#       admin_schedule_path(id)
#     end
#   end
#
module SchedulesManagement
  extend ActiveSupport::Concern

  included do
    before_action :load_demo_data
  end

  # Load demo data for schedules
  # This method provides sample data for development and testing
  def load_demo_data
    # Demo users (agents)
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
    
    # Demo managers
    @demo_managers = [
      { id: 10, name: 'Responsable Principal', role: 'manager' },
      { id: 11, name: 'Superviseur Nord', role: 'manager' }
    ]
    
    # Demo schedules - Store in a consistent format
    @all_schedules = build_demo_schedules
  end

  # Set the schedule from the all_schedules array
  def set_schedule
    @schedule = @all_schedules.find { |s| s[:id] == params[:id].to_i }
    
    unless @schedule
      redirect_to schedules_index_path, alert: schedule_not_found_message
    end
  end

  # Filter schedules based on parameters
  # This method handles all common filtering logic
  def filter_schedules(schedules)
    filtered = schedules.dup
    
    # Filter by status
    if params[:status].present?
      filtered = filtered.select { |s| s[:status] == params[:status] }
    end
    
    # Filter by site
    if params[:site_id].present?
      filtered = filtered.select { |s| s[:site_id] == params[:site_id].to_i }
    end
    
    # Filter by user
    if params[:user_id].present?
      filtered = filtered.select { |s| s[:user_id] == params[:user_id].to_i }
    end
    
    # Filter by date range
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date])
      filtered = filtered.select { |s| s[:scheduled_date] >= start_date }
    end
    
    if params[:end_date].present?
      end_date = Date.parse(params[:end_date])
      filtered = filtered.select { |s| s[:scheduled_date] <= end_date }
    end
    
    # Search by notes or user name
    if params[:search].present?
      search_term = params[:search].downcase
      filtered = filtered.select do |s|
        (s[:notes] && s[:notes].downcase.include?(search_term)) ||
        s[:user_name].downcase.include?(search_term) ||
        s[:site_name].downcase.include?(search_term)
      end
    end
    
    filtered
  end

  private

  # Build demo schedules data
  def build_demo_schedules
    [
      {
        id: 1,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        site_id: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        scheduled_date: Date.today,
        start_time: '08:00',
        end_time: '16:00',
        notes: 'Maintenance préventive zone A',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-01-15 10:00:00'),
        updated_at: Time.parse('2025-01-15 10:00:00')
      },
      {
        id: 2,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        site_id: 2,
        site_name: 'Centrale de Lyon',
        site_code: 'CLY-002',
        scheduled_date: Date.today,
        start_time: '09:00',
        end_time: '17:00',
        notes: 'Inspection routine des installations',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-01-20 14:30:00'),
        updated_at: Time.parse('2025-01-20 14:30:00')
      },
      {
        id: 3,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        site_id: 1,
        site_name: 'Site Nucléaire Paris Nord',
        site_code: 'SPN-001',
        scheduled_date: Date.today + 1,
        start_time: '07:00',
        end_time: '15:00',
        notes: 'Contrôle de sécurité hebdomadaire',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 11:00:00'),
        updated_at: Time.parse('2025-02-01 11:00:00')
      },
      {
        id: 4,
        user_id: 1,
        user_name: 'Jean Dupont',
        employee_number: 'EMP001',
        site_id: 3,
        site_name: 'Station Marseille',
        site_code: 'SMA-003',
        scheduled_date: Date.today - 1,
        start_time: '08:00',
        end_time: '16:00',
        notes: 'Vérification équipements maritimes',
        status: 'completed',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-05 08:45:00'),
        updated_at: Time.parse('2025-02-06 16:30:00')
      },
      {
        id: 5,
        user_id: 4,
        user_name: 'Sophie Bernard',
        employee_number: 'EMP004',
        site_id: 4,
        site_name: 'Centre Toulouse',
        site_code: 'CTO-004',
        scheduled_date: Date.today - 2,
        start_time: '10:00',
        end_time: '18:00',
        notes: 'Formation nouveaux équipements',
        status: 'missed',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-10 13:00:00'),
        updated_at: Time.parse('2025-02-11 10:00:00')
      },
      {
        id: 6,
        user_id: 2,
        user_name: 'Marie Martin',
        employee_number: 'EMP002',
        site_id: 5,
        site_name: 'Unité Bordeaux',
        site_code: 'UBO-005',
        scheduled_date: Date.today + 2,
        start_time: '09:00',
        end_time: '17:00',
        notes: 'Intervention technique planifiée - Remplacée par Luc Petit suite à absence',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: 5,
        replaced_by_name: 'Luc Petit',
        replacement_reason: 'Absence maladie agent titulaire',
        created_at: Time.parse('2025-02-12 09:00:00'),
        updated_at: Time.parse('2025-02-14 11:30:00')
      },
      {
        id: 7,
        user_id: 5,
        user_name: 'Luc Petit',
        employee_number: 'EMP005',
        site_id: 2,
        site_name: 'Centrale de Lyon',
        site_code: 'CLY-002',
        scheduled_date: Date.today + 3,
        start_time: '08:30',
        end_time: '16:30',
        notes: 'Audit annuel des procédures',
        status: 'scheduled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-15 10:00:00'),
        updated_at: Time.parse('2025-02-15 10:00:00')
      },
      {
        id: 8,
        user_id: 3,
        user_name: 'Pierre Durand',
        employee_number: 'EMP003',
        site_id: 3,
        site_name: 'Station Marseille',
        site_code: 'SMA-003',
        scheduled_date: Date.today - 5,
        start_time: '07:00',
        end_time: '15:00',
        notes: 'Intervention annulée - Conditions météo défavorables',
        status: 'cancelled',
        created_by_id: 1,
        created_by_name: 'Admin',
        replaced_by_id: nil,
        replaced_by_name: nil,
        replacement_reason: nil,
        created_at: Time.parse('2025-02-01 08:00:00'),
        updated_at: Time.parse('2025-02-01 14:00:00')
      }
    ]
  end

  # Abstract methods that must be implemented by including controllers
  def schedules_index_path
    raise NotImplementedError, "#{self.class.name} must implement #schedules_index_path"
  end

  def schedule_path(id)
    raise NotImplementedError, "#{self.class.name} must implement #schedule_path"
  end

  def schedule_not_found_message
    raise NotImplementedError, "#{self.class.name} must implement #schedule_not_found_message"
  end
end
