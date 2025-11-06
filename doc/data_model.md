# Data Model - Time Tracking and HR Management System

## Overview

This document describes all the data models (ActiveRecord models) required for the Time Tracking and HR Management System. The system is designed to handle 100-140 field agents, 3 supervisors, and 8 management personnel.

---

## Core Models

### 1. User

The User model represents all system users with role-based access control.

**Purpose:** Authentication, authorization, and user management

**Attributes:**
- `id` (integer, primary key)
- `email` (string, required, unique, indexed)
- `encrypted_password` (string, required) - handled by devise/authentication gem
- `role` (enum: `admin`, `manager`, `agent`, required, default: `agent`, indexed)
- `first_name` (string, required)
- `last_name` (string, required)
- `employee_number` (string, unique, indexed) - for field agents identification
- `active` (boolean, default: true, indexed) - soft delete flag
- `phone_number` (string, optional)
- `manager_id` (integer, foreign key → users) - supervisor assigned to agent
- `created_at` (datetime)
- `updated_at` (datetime)

**Relationships:**
- `has_many :time_entries`
- `has_many :schedules` (as assigned agent)
- `has_many :absences`
- `has_many :managed_users, class_name: 'User', foreign_key: 'manager_id'` (for managers)
- `belongs_to :manager, class_name: 'User', optional: true`

**Validations:**
- Email format and uniqueness
- Presence of first_name, last_name, role
- Employee number uniqueness if present
- Manager must be role 'manager' if assigned

**Scopes:**
- `active` - only active users
- `agents` - role = 'agent'
- `managers` - role = 'manager'
- `admins` - role = 'admin'

**Methods:**
- `full_name` - returns "#{first_name} #{last_name}"
- `admin?`, `manager?`, `agent?` - role checkers
- `can_manage?(user)` - authorization logic

**Indexes:**
- `email` (unique)
- `employee_number` (unique, where not null)
- `role`
- `active`
- `manager_id`

---

### 2. Site

The Site model represents physical work locations where agents clock in/out.

**Purpose:** Manage work locations and generate QR codes

**Attributes:**
- `id` (integer, primary key)
- `name` (string, required, indexed)
- `code` (string, required, unique, indexed) - unique identifier for QR code
- `address` (text, optional)
- `description` (text, optional)
- `active` (boolean, default: true, indexed)
- `qr_code_token` (string, unique, indexed) - secure token for QR code URL
- `created_at` (datetime)
- `updated_at` (datetime)

**Relationships:**
- `has_many :time_entries`
- `has_many :schedules`

**Validations:**
- Presence of name, code
- Uniqueness of code, qr_code_token
- Code format (alphanumeric, no spaces)

**Scopes:**
- `active` - only active sites
- `alphabetical` - ordered by name

**Methods:**
- `generate_qr_code_token` - creates secure random token
- `qr_code_url` - returns full URL for QR code scanning
- `qr_code_image` - generates QR code image data
- `current_agents` - returns agents currently on site

**Indexes:**
- `name`
- `code` (unique)
- `qr_code_token` (unique)
- `active`

**Callbacks:**
- `before_create :generate_qr_code_token`

---

### 3. TimeEntry

The TimeEntry model records all clock-in and clock-out events.

**Purpose:** Track agent presence at sites with timestamps

**Attributes:**
- `id` (integer, primary key)
- `user_id` (integer, foreign key → users, required, indexed)
- `site_id` (integer, foreign key → sites, required, indexed)
- `clocked_in_at` (datetime, required, indexed)
- `clocked_out_at` (datetime, optional, indexed)
- `duration_minutes` (integer, optional) - calculated on clock-out
- `status` (enum: `active`, `completed`, `anomaly`, default: `active`, indexed)
- `ip_address_in` (string, optional) - anti-fraud tracking
- `ip_address_out` (string, optional)
- `user_agent_in` (string, optional) - browser/device info
- `user_agent_out` (string, optional)
- `notes` (text, optional) - for admin corrections
- `manually_corrected` (boolean, default: false, indexed)
- `corrected_by_id` (integer, foreign key → users, optional) - admin who corrected
- `corrected_at` (datetime, optional)
- `created_at` (datetime)
- `updated_at` (datetime)

**Relationships:**
- `belongs_to :user`
- `belongs_to :site`
- `belongs_to :corrected_by, class_name: 'User', optional: true`

**Validations:**
- Presence of user_id, site_id, clocked_in_at
- clocked_out_at must be after clocked_in_at if present
- User cannot have multiple active entries simultaneously (anti-fraud)

**Scopes:**
- `active` - status = 'active' (not clocked out)
- `completed` - status = 'completed'
- `anomalies` - status = 'anomaly'
- `for_date(date)` - entries for specific date
- `for_date_range(start_date, end_date)`
- `for_user(user)`
- `for_site(site)`
- `recent` - ordered by clocked_in_at desc
- `over_24_hours` - active entries older than 24h

**Methods:**
- `clock_out!(time = Time.current)` - records clock-out
- `calculate_duration` - calculates duration in minutes
- `detect_anomaly` - checks for anomalies (>24h, etc.)
- `mark_as_anomaly(reason)` - flags entry as anomaly
- `correct(admin, attributes)` - manual correction by admin
- `active?`, `completed?`, `anomaly?` - status checkers

**Indexes:**
- `user_id`
- `site_id`
- `clocked_in_at`
- `clocked_out_at`
- `status`
- `manually_corrected`
- `[user_id, clocked_in_at]` (composite)
- `[site_id, clocked_in_at]` (composite)

**Callbacks:**
- `before_save :calculate_duration` (if clocked_out_at changed)
- `after_save :detect_anomaly`

**Anti-Fraud Notes:**
- IP tracking detects multiple simultaneous clock-ins from different locations
- User agent tracking helps identify suspicious patterns
- Validation prevents multiple active entries per user
- Cookie-based session tracking handled by Rails

---

### 4. Schedule

The Schedule model manages planned work assignments.

**Purpose:** Plan agent assignments to sites with dates and times

**Attributes:**
- `id` (integer, primary key)
- `user_id` (integer, foreign key → users, required, indexed)
- `site_id` (integer, foreign key → sites, required, indexed)
- `scheduled_date` (date, required, indexed)
- `start_time` (time, required)
- `end_time` (time, required)
- `notes` (text, optional)
- `status` (enum: `scheduled`, `completed`, `missed`, `cancelled`, default: `scheduled`, indexed)
- `created_by_id` (integer, foreign key → users, required) - admin who created
- `replaced_by_id` (integer, foreign key → users, optional) - replacement agent
- `replacement_reason` (text, optional)
- `created_at` (datetime)
- `updated_at` (datetime)

**Relationships:**
- `belongs_to :user`
- `belongs_to :site`
- `belongs_to :created_by, class_name: 'User'`
- `belongs_to :replaced_by, class_name: 'User', optional: true`
- `has_many :time_entries` (through user and date matching)

**Validations:**
- Presence of user_id, site_id, scheduled_date, start_time, end_time
- end_time must be after start_time
- User cannot have overlapping schedules on same date

**Scopes:**
- `for_date(date)`
- `for_date_range(start_date, end_date)`
- `for_user(user)`
- `for_site(site)`
- `upcoming` - scheduled_date >= today
- `past` - scheduled_date < today
- `scheduled` - status = 'scheduled'
- `missed` - status = 'missed'
- `by_date` - ordered by scheduled_date

**Methods:**
- `check_completion` - verifies if agent clocked in/out as scheduled
- `mark_as_missed` - flags schedule as missed
- `mark_as_completed` - flags schedule as completed
- `assign_replacement(new_agent, reason)` - assigns replacement agent
- `time_entry_exists?` - checks if corresponding time entry exists

**Indexes:**
- `user_id`
- `site_id`
- `scheduled_date`
- `status`
- `created_by_id`
- `replaced_by_id`
- `[user_id, scheduled_date]` (composite)
- `[site_id, scheduled_date]` (composite)

---

### 5. Absence

The Absence model tracks agent unavailability.

**Purpose:** Manage and track agent absences

**Attributes:**
- `id` (integer, primary key)
- `user_id` (integer, foreign key → users, required, indexed)
- `absence_type` (enum: `vacation`, `sick_leave`, `training`, `unpaid_leave`, `other`, required, indexed)
- `start_date` (date, required, indexed)
- `end_date` (date, required, indexed)
- `reason` (text, optional)
- `declared_by_id` (integer, foreign key → users, required) - manager who declared
- `notes` (text, optional)
- `created_at` (datetime)
- `updated_at` (datetime)

**Relationships:**
- `belongs_to :user`
- `belongs_to :declared_by, class_name: 'User'`

**Validations:**
- Presence of user_id, absence_type, start_date, end_date
- end_date must be >= start_date
- User cannot have overlapping absences

**Scopes:**
- `for_user(user)`
- `for_date_range(start_date, end_date)`
- `current` - absences covering today
- `upcoming` - start_date >= today
- `by_type(type)`
- `by_date` - ordered by start_date

**Methods:**
- `duration_days` - calculates total days of absence
- `overlaps_with?(other_absence)` - checks for date overlap
- `affects_date?(date)` - checks if absence covers specific date

**Indexes:**
- `user_id`
- `absence_type`
- `start_date`
- `end_date`
- `declared_by_id`
- `[user_id, start_date, end_date]` (composite)

**Note:** No approval workflow - absences are immediately active when declared by managers (per specifications).

---

### 6. AnomalyLog

The AnomalyLog model tracks detected system anomalies.

**Purpose:** Log and track anomalies for admin review

**Attributes:**
- `id` (integer, primary key)
- `anomaly_type` (enum: `missed_clock_in`, `missed_clock_out`, `over_24h`, `multiple_active`, `schedule_mismatch`, required, indexed)
- `severity` (enum: `low`, `medium`, `high`, default: `medium`, indexed)
- `user_id` (integer, foreign key → users, optional, indexed)
- `time_entry_id` (integer, foreign key → time_entries, optional, indexed)
- `schedule_id` (integer, foreign key → schedules, optional, indexed)
- `description` (text, required)
- `resolved` (boolean, default: false, indexed)
- `resolved_by_id` (integer, foreign key → users, optional)
- `resolved_at` (datetime, optional)
- `resolution_notes` (text, optional)
- `created_at` (datetime)
- `updated_at` (datetime)

**Relationships:**
- `belongs_to :user, optional: true`
- `belongs_to :time_entry, optional: true`
- `belongs_to :schedule, optional: true`
- `belongs_to :resolved_by, class_name: 'User', optional: true`

**Validations:**
- Presence of anomaly_type, description

**Scopes:**
- `unresolved` - resolved = false
- `resolved` - resolved = true
- `by_severity(severity)`
- `by_type(type)`
- `for_user(user)`
- `recent` - ordered by created_at desc

**Methods:**
- `resolve!(admin, notes)` - marks anomaly as resolved
- `auto_detect_and_create` - class method for anomaly detection

**Indexes:**
- `anomaly_type`
- `severity`
- `user_id`
- `time_entry_id`
- `schedule_id`
- `resolved`
- `resolved_by_id`
- `created_at`

---

## Enumerations Summary

### User Roles
```ruby
enum role: {
  agent: 'agent',
  manager: 'manager',
  admin: 'admin'
}
```

### TimeEntry Status
```ruby
enum status: {
  active: 'active',      # Currently clocked in
  completed: 'completed', # Clocked out normally
  anomaly: 'anomaly'      # Flagged for review
}
```

### Schedule Status
```ruby
enum status: {
  scheduled: 'scheduled',   # Upcoming/planned
  completed: 'completed',   # Agent showed up
  missed: 'missed',         # Agent didn't show
  cancelled: 'cancelled'    # Schedule cancelled
}
```

### Absence Type
```ruby
enum absence_type: {
  vacation: 'vacation',
  sick_leave: 'sick_leave',
  training: 'training',
  unpaid_leave: 'unpaid_leave',
  other: 'other'
}
```

### Anomaly Type
```ruby
enum anomaly_type: {
  missed_clock_in: 'missed_clock_in',
  missed_clock_out: 'missed_clock_out',
  over_24h: 'over_24h',
  multiple_active: 'multiple_active',
  schedule_mismatch: 'schedule_mismatch'
}
```

### Severity Level
```ruby
enum severity: {
  low: 'low',
  medium: 'medium',
  high: 'high'
}
```

---

## Database Relationships Diagram

```
┌─────────────┐
│    User     │
│  (roles)    │
└──────┬──────┘
       │
       │ has_many
       ├────────────────────┐
       │                    │
       ▼                    ▼
┌─────────────┐      ┌─────────────┐
│ TimeEntry   │      │  Schedule   │
└──────┬──────┘      └──────┬──────┘
       │                    │
       │ belongs_to         │ belongs_to
       │                    │
       ▼                    ▼
┌─────────────┐      ┌─────────────┐
│    Site     │◄─────┤    Site     │
└─────────────┘      └─────────────┘

┌─────────────┐
│    User     │
└──────┬──────┘
       │
       │ has_many
       │
       ▼
┌─────────────┐
│   Absence   │
└─────────────┘

┌─────────────┐
│    User     │
└──────┬──────┘
       │
       │ has_many
       │
       ▼
┌──────────────┐
│ AnomalyLog   │
└──────┬───────┘
       │
       │ belongs_to (optional)
       │
       ├─────────────┐
       │             │
       ▼             ▼
┌─────────────┐ ┌─────────────┐
│ TimeEntry   │ │  Schedule   │
└─────────────┘ └─────────────┘
```

---

## Key Design Decisions

### 1. Soft Deletes
- Users and Sites use `active` flag instead of hard deletes
- Preserves historical data integrity
- Maintains referential integrity

### 2. Audit Trail
- All modifications track `created_at` and `updated_at`
- Manual corrections track `corrected_by_id` and `corrected_at`
- Anomaly resolutions track `resolved_by_id` and `resolved_at`

### 3. Role-Based Access Control (RBAC)
- Single User model with role enum
- Three roles: admin, manager, agent
- Permissions enforced at controller and view levels

### 4. Anti-Fraud Measures
- IP address and user agent tracking on time entries
- Validation prevents multiple active entries per user
- Cookie-based session tracking (handled by framework)
- Simple and effective approach per specifications

### 5. Flexible Scheduling
- Schedules support replacements via `replaced_by_id`
- Status tracking for completion monitoring
- Automatic anomaly detection for missed schedules

### 6. Data Integrity
- Foreign keys with proper indexing
- Validations prevent overlapping schedules/absences
- Unique constraints on critical fields (email, employee_number, site codes)

### 7. Performance Optimization
- Strategic indexes on frequently queried fields
- Composite indexes for common query patterns
- Scopes for reusable query logic

### 8. No Approval Workflow
- Absences have no status field (per specifications)
- When manager declares absence, it's immediately active
- Simplifies model and aligns with "no workflow" requirement

---

## Migration Considerations

### Required Indexes
All foreign keys must be indexed for query performance:
- `user_id` on all related tables
- `site_id` on TimeEntry and Schedule
- Composite indexes for common date-range queries

### Timestamp Precision
- Use datetime (not date) for all timestamps
- PostgreSQL: `timestamp without time zone`
- Ensures accurate time tracking to the second

---

## Data Retention & Privacy

### Agent Privacy
- Agents cannot view their own time entries via UI
- Minimal data exposure in agent-facing views
- Separate domain prevents information leakage

### Data Retention
- Time entries: Keep indefinitely for legal compliance
- Anomaly logs: Archive after resolution (configurable)
- Audit trails: Never delete

### GDPR Compliance (if applicable)
- Export user data capability
- Anonymization for deleted users
- Data minimization principle applied

---

## Statistics & Reporting Data

### Calculated Metrics (Not Stored)
These should be calculated on-demand or cached:

1. **Real-time Metrics:**
   - Current agents on site
   - Active time entries count
   - Today's clock-ins/outs

2. **Period Metrics:**
   - Total hours worked per agent
   - Total hours worked per site
   - Average daily hours

3. **HR Metrics:**
   - Absence rate per agent
   - Team coverage percentage
   - Schedule adherence rate
   - Anomaly frequency

4. **Site Metrics:**
   - Site utilization rate
   - Average agents per day
   - Peak occupancy times

---

## Future Considerations

### Potential Additions (Not in MVP)
1. **Shift Model** - for recurring schedules
2. **Team Model** - for grouping agents
3. **Notification Model** - for email alerts
4. **AuditLog Model** - comprehensive audit trail
5. **Holiday Model** - for public holidays tracking

---

*This data model document serves as the single source of truth for database schema design.*
