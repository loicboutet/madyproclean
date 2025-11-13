# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_13_201847) do
  create_table "anomaly_logs", force: :cascade do |t|
    t.string "anomaly_type", null: false
    t.string "severity", default: "medium", null: false
    t.integer "user_id"
    t.integer "time_entry_id"
    t.integer "schedule_id"
    t.text "description", null: false
    t.boolean "resolved", default: false, null: false
    t.integer "resolved_by_id"
    t.datetime "resolved_at"
    t.text "resolution_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["anomaly_type"], name: "index_anomaly_logs_on_anomaly_type"
    t.index ["created_at"], name: "index_anomaly_logs_on_created_at"
    t.index ["resolved"], name: "index_anomaly_logs_on_resolved"
    t.index ["resolved_by_id"], name: "index_anomaly_logs_on_resolved_by_id"
    t.index ["schedule_id"], name: "index_anomaly_logs_on_schedule_id"
    t.index ["severity"], name: "index_anomaly_logs_on_severity"
    t.index ["time_entry_id"], name: "index_anomaly_logs_on_time_entry_id"
    t.index ["user_id"], name: "index_anomaly_logs_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "title", null: false
    t.string "report_type", null: false
    t.date "period_start"
    t.date "period_end"
    t.datetime "generated_at"
    t.integer "generated_by_id"
    t.string "status", default: "pending", null: false
    t.text "description"
    t.decimal "total_hours", precision: 10, scale: 2
    t.integer "total_agents"
    t.integer "total_sites"
    t.text "filters_applied"
    t.string "file_format"
    t.string "file_size"
    t.integer "total_absences"
    t.decimal "absence_rate", precision: 5, scale: 2
    t.decimal "coverage_rate", precision: 5, scale: 2
    t.integer "total_anomalies"
    t.integer "resolved_anomalies"
    t.integer "unresolved_anomalies"
    t.integer "total_schedules"
    t.integer "scheduled_count"
    t.integer "completed_count"
    t.integer "missed_count"
    t.string "site_name"
    t.string "site_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["generated_at"], name: "index_reports_on_generated_at"
    t.index ["generated_by_id"], name: "index_reports_on_generated_by_id"
    t.index ["period_start", "period_end"], name: "index_reports_on_period_start_and_period_end"
    t.index ["report_type"], name: "index_reports_on_report_type"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "site_id", null: false
    t.date "scheduled_date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.text "notes"
    t.string "status", default: "scheduled", null: false
    t.integer "created_by_id", null: false
    t.integer "replaced_by_id"
    t.text "replacement_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_schedules_on_created_by_id"
    t.index ["replaced_by_id"], name: "index_schedules_on_replaced_by_id"
    t.index ["scheduled_date"], name: "index_schedules_on_scheduled_date"
    t.index ["site_id", "scheduled_date"], name: "index_schedules_on_site_id_and_scheduled_date"
    t.index ["site_id"], name: "index_schedules_on_site_id"
    t.index ["status"], name: "index_schedules_on_status"
    t.index ["user_id", "scheduled_date"], name: "index_schedules_on_user_id_and_scheduled_date"
    t.index ["user_id"], name: "index_schedules_on_user_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "address"
    t.text "description"
    t.boolean "active", default: true, null: false
    t.string "qr_code_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_sites_on_active"
    t.index ["code"], name: "index_sites_on_code", unique: true
    t.index ["name"], name: "index_sites_on_name"
    t.index ["qr_code_token"], name: "index_sites_on_qr_code_token", unique: true
  end

  create_table "time_entries", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "site_id", null: false
    t.datetime "clocked_in_at", null: false
    t.datetime "clocked_out_at"
    t.integer "duration_minutes"
    t.string "status", default: "active", null: false
    t.string "ip_address_in"
    t.string "ip_address_out"
    t.string "user_agent_in"
    t.string "user_agent_out"
    t.text "notes"
    t.boolean "manually_corrected", default: false, null: false
    t.integer "corrected_by_id"
    t.datetime "corrected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clocked_in_at"], name: "index_time_entries_on_clocked_in_at"
    t.index ["clocked_out_at"], name: "index_time_entries_on_clocked_out_at"
    t.index ["corrected_by_id"], name: "index_time_entries_on_corrected_by_id"
    t.index ["manually_corrected"], name: "index_time_entries_on_manually_corrected"
    t.index ["site_id", "clocked_in_at"], name: "index_time_entries_on_site_id_and_clocked_in_at"
    t.index ["site_id"], name: "index_time_entries_on_site_id"
    t.index ["status"], name: "index_time_entries_on_status"
    t.index ["user_id", "clocked_in_at"], name: "index_time_entries_on_user_id_and_clocked_in_at"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "agent", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "employee_number"
    t.boolean "active", default: true, null: false
    t.string "phone_number"
    t.integer "manager_id"
    t.index ["active"], name: "index_users_on_active"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_number"], name: "index_users_on_employee_number", unique: true, where: "employee_number IS NOT NULL"
    t.index ["manager_id"], name: "index_users_on_manager_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "anomaly_logs", "schedules"
  add_foreign_key "anomaly_logs", "time_entries"
  add_foreign_key "anomaly_logs", "users"
  add_foreign_key "anomaly_logs", "users", column: "resolved_by_id"
  add_foreign_key "schedules", "sites"
  add_foreign_key "schedules", "users"
  add_foreign_key "schedules", "users", column: "created_by_id"
  add_foreign_key "schedules", "users", column: "replaced_by_id"
  add_foreign_key "time_entries", "sites"
  add_foreign_key "time_entries", "users"
  add_foreign_key "time_entries", "users", column: "corrected_by_id"
  add_foreign_key "users", "users", column: "manager_id"
end
