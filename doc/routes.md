# Routes Documentation - Time Tracking and HR Management System

## Overview

This document describes all routes organized by user journey and namespace. Routes follow RESTful conventions and KISS (Keep It Simple, Stupid) principles.

---

## Route Namespaces

1. **Public Routes** - Authentication, agent clock-in (no namespace)
2. **Admin Routes** - `/admin` namespace - Full system access
3. **Manager Routes** - `/manager` namespace - Team management
4. **Dashboard Routes** - `/dashboard` namespace - Common authenticated views

---

## Authentication Routes (Public)

### Session Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/login` | `sessions#new` | Display login form |
| POST | `/login` | `sessions#create` | Process login credentials |
| DELETE | `/logout` | `sessions#destroy` | Log out current user |
| GET | `/` | `pages#home` | Public home page (redirect if authenticated) |

**Notes:**
- Login page accessible to all users (admin, manager, agent)
- After login, redirect based on role:
  - Admin → `/admin/dashboard`
  - Manager → `/manager/dashboard`
  - Agent → Not allowed (agents use separate domain)
- Session timeout after 8 hours of inactivity

---

## Agent Clock-In Routes (Separate Domain - Public)

**Domain:** `clock.example.com` (separate from admin domain)

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/c/:qr_code_token` | `clock#show` | Display clock-in page for site |
| POST | `/c/:qr_code_token/in` | `clock#clock_in` | Process clock-in |
| POST | `/c/:qr_code_token/out` | `clock#clock_out` | Process clock-out |
| GET | `/clock/auth` | `clock#authenticate` | Agent authentication page |
| POST | `/clock/auth` | `clock#verify` | Verify agent credentials |

**Notes:**
- Ultra-minimalist interface
- No navigation, no company info visible
- QR code token in URL is unguessable
- Agent authenticates with employee_number + PIN/password
- Session stored in cookie for 24 hours
- Response shows only: "Pointage validé" or "Dépointage validé"
- Track IP address and user agent for fraud detection

**Flow:**
1. Agent scans QR code → `/c/abc123xyz`
2. If not authenticated → redirect to `/clock/auth`
3. After auth → return to `/c/abc123xyz`
4. Agent clicks "Pointer Arrivée" → POST `/c/abc123xyz/in`
5. Success page shows "Pointage validé ✓"
6. Later: Agent clicks "Pointer Départ" → POST `/c/abc123xyz/out`
7. Success page shows "Dépointage validé ✓"

---

## Admin Routes

**Namespace:** `/admin`

**Authorization:** Only users with `role: admin`

### Dashboard

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin` | `admin/dashboard#index` | Main admin dashboard |
| GET | `/admin/dashboard` | `admin/dashboard#index` | Same as above (alias) |

**Functionality:**
- Real-time overview of system status
- Current agents on sites (live count)
- Today's statistics (clock-ins, clock-outs)
- Anomaly count (unresolved)
- Quick links to all sections
- Recent activity feed (last 10 events)

---

### Time Entries Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin/time_entries` | `admin/time_entries#index` | List all time entries with filters |
| GET | `/admin/time_entries/:id` | `admin/time_entries#show` | View single time entry details |
| GET | `/admin/time_entries/:id/edit` | `admin/time_entries#edit` | Form to edit/correct time entry |
| PATCH | `/admin/time_entries/:id` | `admin/time_entries#update` | Update time entry (manual correction) |
| DELETE | `/admin/time_entries/:id` | `admin/time_entries#destroy` | Delete time entry |
| GET | `/admin/time_entries/export` | `admin/time_entries#export` | Export time entries (CSV/Excel) |

**Functionality:**

**Index (`/admin/time_entries`):**
- Paginated list of all time entries
- Filters: agent, site, date range, status
- Real-time view toggle (show only active entries)
- Columns: Agent, Site, Clock-in, Clock-out, Duration, Status
- Color coding: active (blue), completed (green), anomaly (red)
- Export button

**Show (`/admin/time_entries/:id`):**
- Full entry details
- Clock-in/out timestamps
- Duration calculation
- IP addresses and user agents (anti-fraud)
- Associated schedule (if any)
- Correction history
- Action buttons: Edit, Delete

**Edit (`/admin/time_entries/:id/edit`):**
- Form to modify clock-in time
- Form to modify clock-out time
- Notes field (required for manual corrections)
- Warning: "Manual correction will be logged"
- Preview of duration calculation

**Export (`/admin/time_entries/export`):**
- Query params: format (csv/xlsx), date_range, user_id, site_id
- Generates downloadable file
- Includes: Agent, Site, Date, Clock-in, Clock-out, Duration, Status

---

### Sites Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin/sites` | `admin/sites#index` | List all sites |
| GET | `/admin/sites/new` | `admin/sites#new` | Form to create new site |
| POST | `/admin/sites` | `admin/sites#create` | Create new site |
| GET | `/admin/sites/:id` | `admin/sites#show` | View site details |
| GET | `/admin/sites/:id/edit` | `admin/sites#edit` | Form to edit site |
| PATCH | `/admin/sites/:id` | `admin/sites#update` | Update site |
| DELETE | `/admin/sites/:id` | `admin/sites#destroy` | Deactivate site (soft delete) |
| GET | `/admin/sites/:id/qr_code` | `admin/sites#qr_code` | Generate/download QR code |

**Functionality:**

**Index (`/admin/sites`):**
- List of all sites (active by default)
- Filter: show inactive sites
- Columns: Name, Code, Current Agents, Actions
- Quick view: agents currently on each site
- Action buttons: View, Edit, QR Code, Deactivate

**Show (`/admin/sites/:id`):**
- Site details (name, code, address, description)
- QR code display (with download button)
- Current agents on site (live, updated via Turbo Stream)
- Today's time entries for this site
- Schedule for today/this week
- Statistics: total visits, average duration
- Action buttons: Edit, Generate QR Code

**New/Create (`/admin/sites/new`):**
- Form fields: name, code, address, description
- Auto-generate code suggestion
- Preview QR code URL

**Edit/Update (`/admin/sites/:id/edit`):**
- Same fields as create
- Warning if changing code (existing QR codes invalid)
- Active/Inactive toggle

**QR Code (`/admin/sites/:id/qr_code`):**
- Download QR code as PNG or PDF
- Display QR code with site name for printing
- Multiple formats: Small (label), Medium (A5), Large (A4)

---

### Users Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin/users` | `admin/users#index` | List all users |
| GET | `/admin/users/new` | `admin/users#new` | Form to create new user |
| POST | `/admin/users` | `admin/users#create` | Create new user |
| GET | `/admin/users/:id` | `admin/users#show` | View user profile |
| GET | `/admin/users/:id/edit` | `admin/users#edit` | Form to edit user |
| PATCH | `/admin/users/:id` | `admin/users#update` | Update user |
| DELETE | `/admin/users/:id` | `admin/users#destroy` | Deactivate user (soft delete) |

**Functionality:**

**Index (`/admin/users`):**
- Paginated list of all users
- Filter by role (admin, manager, agent)
- Filter by status (active, inactive)
- Search by name, email, employee number
- Columns: Name, Role, Employee Number, Manager, Status
- Action buttons: View, Edit, Deactivate

**Show (`/admin/users/:id`):**
- User profile information
- Role and permissions
- Assigned manager (if agent)
- Current time entry status (if agent)
- Statistics: total hours, days worked, absences
- Recent time entries (last 10)
- Recent absences
- Action buttons: Edit

**New/Create (`/admin/users/new`):**
- Form fields: first_name, last_name, email, role, employee_number
- Manager assignment (if role is agent)
- Password generation (auto or manual)
- Active toggle

**Edit/Update (`/admin/users/:id/edit`):**
- Same fields as create
- Password change section (optional)
- Cannot change own role (prevent lockout)

---

### Schedules Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin/schedules` | `admin/schedules#index` | List schedules (calendar view) |
| GET | `/admin/schedules/new` | `admin/schedules#new` | Form to create schedule |
| POST | `/admin/schedules` | `admin/schedules#create` | Create schedule |
| GET | `/admin/schedules/:id` | `admin/schedules#show` | View schedule details |
| GET | `/admin/schedules/:id/edit` | `admin/schedules#edit` | Form to edit schedule |
| PATCH | `/admin/schedules/:id` | `admin/schedules#update` | Update schedule |
| DELETE | `/admin/schedules/:id` | `admin/schedules#destroy` | Delete schedule |
| POST | `/admin/schedules/:id/assign_replacement` | `admin/schedules#assign_replacement` | Assign replacement agent |
| GET | `/admin/schedules/export` | `admin/schedules#export` | Export schedules (PDF/Excel) |

**Functionality:**

**Index (`/admin/schedules`):**
- Calendar view (day/week/month toggle)
- Filter: agent, site, date range, status
- Color coding by status: scheduled (blue), completed (green), missed (red), cancelled (gray)
- Quick add button for each day
- View toggle: list view / calendar view

**Show (`/admin/schedules/:id`):**
- Schedule details: agent, site, date, times
- Status and notes
- Replacement info (if applicable)
- Actual time entry (if completed)
- Discrepancy warning (if times don't match)
- Action buttons: Edit, Delete, Assign Replacement

**New/Create (`/admin/schedules/new`):**
- Form fields: user_id, site_id, scheduled_date, start_time, end_time, notes
- User dropdown: agents only
- Site dropdown: active sites only
- Date picker
- Time pickers
- Conflict detection (if agent already scheduled)

**Edit/Update (`/admin/schedules/:id/edit`):**
- Same fields as create
- Show if schedule already completed

**Assign Replacement (`/admin/schedules/:id/assign_replacement`):**
- Form to select replacement agent
- Reason field (required)
- Original agent info displayed
- Conflict detection for replacement agent

**Export (`/admin/schedules/export`):**
- Query params: format (pdf/xlsx), date_range, user_id, site_id
- PDF: Formatted for printing (weekly/monthly views)
- Excel: Data export for analysis

---

### Absences Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin/absences` | `admin/absences#index` | List all absences |
| GET | `/admin/absences/:id` | `admin/absences#show` | View absence details |
| DELETE | `/admin/absences/:id` | `admin/absences#destroy` | Delete absence |

**Functionality:**

**Index (`/admin/absences`):**
- List of all absences (paginated)
- Filter: agent, absence type, date range
- Columns: Agent, Type, Start Date, End Date, Duration, Declared By
- Action buttons: View, Delete
- Statistics: total days by type, absence rate

**Show (`/admin/absences/:id`):**
- Absence details
- Agent info
- Declared by (manager)
- Dates and duration
- Reason/notes
- Action buttons: Delete

**Note:** Admins can view and delete absences. Managers create them (see Manager routes). No approval workflow per specifications.

---

### Anomalies Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin/anomalies` | `admin/anomalies#index` | List all anomalies |
| GET | `/admin/anomalies/:id` | `admin/anomalies#show` | View anomaly details |
| POST | `/admin/anomalies/:id/resolve` | `admin/anomalies#resolve` | Mark anomaly as resolved |

**Functionality:**

**Index (`/admin/anomalies`):**
- List of all anomalies (unresolved first)
- Filter: type, severity, resolved status, date range, agent
- Color coding by severity: low (yellow), medium (orange), high (red)
- Columns: Type, Agent, Description, Severity, Created, Status
- Action buttons: View, Resolve

**Show (`/admin/anomalies/:id`):**
- Anomaly details
- Type, severity, description
- Related time entry (if applicable)
- Related schedule (if applicable)
- Agent info
- Resolution notes (if resolved)
- Action button: Resolve (if unresolved)

**Resolve (`/admin/anomalies/:id/resolve`):**
- Form with resolution notes field
- Automatically records resolved_by and resolved_at
- Redirects to anomalies list with success message

---

### Reports

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin/reports` | `admin/reports#index` | Reports dashboard |
| GET | `/admin/reports/monthly` | `admin/reports#monthly` | Generate monthly report |
| GET | `/admin/reports/hr` | `admin/reports#hr` | HR indicators (absences, coverage) |

**Functionality:**

**Index (`/admin/reports`):**
- Reports dashboard
- Quick links to pre-defined reports
- Custom report builder (date range, filters)

**Monthly (`/admin/reports/monthly`):**
- Query params: month, year, user_id (optional), site_id (optional)
- Display: total hours by agent, by site, anomalies, absences
- Export to PDF or Excel
- Charts: hours per day, agents per site

**HR Indicators (`/admin/reports/hr`):**
- Query params: date_range
- Display: 
  - Absence rate by agent and by type
  - Team coverage percentage
  - Site utilization
  - Schedule adherence rate
- Export to Excel

---

## Manager Routes

**Namespace:** `/manager`

**Authorization:** Users with `role: manager` or `role: admin`

### Dashboard

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/manager` | `manager/dashboard#index` | Manager dashboard |
| GET | `/manager/dashboard` | `manager/dashboard#index` | Same as above (alias) |

**Functionality:**
- Overview of managed team
- Today's scheduled agents and sites
- Current agents on sites (real-time)
- Quick actions: declare absence, view schedules

---

### Team Time Entries (Read-only)

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/manager/time_entries` | `manager/time_entries#index` | View team time entries |
| GET | `/manager/time_entries/:id` | `manager/time_entries#show` | View time entry details |

**Functionality:**

**Index (`/manager/time_entries`):**
- List time entries for manager's team only
- Filter: agent (from their team), date range, site
- Cannot edit or delete (read-only)
- Export button (their team only)

---

### Team Schedules (Read-only)

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/manager/schedules` | `manager/schedules#index` | View team schedules |
| GET | `/manager/schedules/:id` | `manager/schedules#show` | View schedule details |

**Functionality:**

**Index (`/manager/schedules`):**
- Calendar view of team schedules
- Filter: agent (from their team), date range, site
- Cannot create or edit directly (admin only)
- View-only access

**Show (`/manager/schedules/:id`):**
- Schedule details (their team only)
- View-only

**Note:** Managers can view schedules but only admins can create/edit them. Managers manage replacements (see below).

---

### Absences Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/manager/absences` | `manager/absences#index` | List team absences |
| GET | `/manager/absences/new` | `manager/absences#new` | Form to declare absence |
| POST | `/manager/absences` | `manager/absences#create` | Create absence |
| GET | `/manager/absences/:id` | `manager/absences#show` | View absence details |
| GET | `/manager/absences/:id/edit` | `manager/absences#edit` | Form to edit absence |
| PATCH | `/manager/absences/:id` | `manager/absences#update` | Update absence |
| DELETE | `/manager/absences/:id` | `manager/absences#destroy` | Delete absence |

**Functionality:**

**Index (`/manager/absences`):**
- List absences for their team only
- Filter: agent, absence type, date range
- Action buttons: View, Edit, Delete, New Absence

**New/Create (`/manager/absences/new`):**
- Form fields: user_id (dropdown of their team), absence_type, start_date, end_date, reason, notes
- Conflict detection (if agent already has absence)
- Automatic schedule conflict check
- Absence immediately active (no approval workflow per specifications)

**Show (`/manager/absences/:id`):**
- Absence details (their team only)
- Action buttons: Edit, Delete

**Edit/Update (`/manager/absences/:id/edit`):**
- Same fields as create
- Can only edit absences they declared

---

### Team Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/manager/team` | `manager/team#index` | View team members |
| GET | `/manager/team/:id` | `manager/team#show` | View agent profile |

**Functionality:**

**Index (`/manager/team`):**
- List of agents managed by this manager
- Columns: Name, Employee Number, Current Status, Today's Schedule
- Quick stats per agent: hours this week, absences this month
- Action button: View Profile

**Show (`/manager/team/:id`):**
- Agent profile (read-only)
- Current time entry status
- This week's schedule
- Recent absences
- Statistics: hours this month, absence days

---

### Replacements Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/manager/replacements` | `manager/replacements#index` | View replacement needs |
| POST | `/manager/replacements/assign` | `manager/replacements#assign` | Assign replacement to schedule |

**Functionality:**

**Index (`/manager/replacements`):**
- List of schedules needing replacements (due to absences)
- Filter: date range, site
- Shows: original agent, absence reason, schedule details
- Available agents for replacement (from their team)
- Action button: Assign Replacement

**Assign (`/manager/replacements/assign`):**
- Query params: schedule_id
- Select replacement agent from their team
- Reason field
- Conflict detection
- Updates schedule with replacement info

---

## Dashboard Routes (Common Authenticated)

**Namespace:** `/dashboard`

**Authorization:** Any authenticated user

### Profile Management

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/dashboard/profile` | `dashboard/profile#show` | View own profile |
| GET | `/dashboard/profile/edit` | `dashboard/profile#edit` | Edit own profile |
| PATCH | `/dashboard/profile` | `dashboard/profile#update` | Update own profile |
| GET | `/dashboard/password/edit` | `dashboard/passwords#edit` | Change password form |
| PATCH | `/dashboard/password` | `dashboard/passwords#update` | Update password |

**Functionality:**

**Profile Show/Edit:**
- View/edit: first_name, last_name, email, phone_number
- Cannot change: role, employee_number, manager
- Password change link

**Password Change:**
- Current password verification
- New password (with confirmation)
- Password strength indicator

---

## Route Constraints & Policies

### Authentication
- All `/admin/*` routes require authentication and `role: admin`
- All `/manager/*` routes require authentication and `role: manager` or `admin`
- All `/dashboard/*` routes require authentication
- Clock-in routes (`/c/*`) require agent authentication (separate session)
- Public routes: `/`, `/login`

### Authorization Checks
```ruby
# In controllers
before_action :authenticate_user! # All authenticated routes
before_action :require_admin # Admin namespace
before_action :require_manager_or_admin # Manager namespace
before_action :require_agent_auth # Clock namespace
```

### Rate Limiting (Anti-fraud)
- Clock-in routes: max 10 requests per minute per IP
- Login: max 5 failed attempts, then 15-minute lockout

---

## Redirect Rules

### After Login
```ruby
case current_user.role
when 'admin'
  redirect_to admin_dashboard_path
when 'manager'
  redirect_to manager_dashboard_path
when 'agent'
  redirect_to root_path, alert: "Agents must use the clock-in app"
end
```

### After Logout
```ruby
redirect_to root_path
```

### Root Path Behavior
```ruby
if user_signed_in?
  case current_user.role
  when 'admin'
    redirect_to admin_dashboard_path
  when 'manager'
    redirect_to manager_dashboard_path
  when 'agent'
    redirect_to root_path, alert: "Agents must use the clock-in app"
  end
else
  render 'pages/home' # Public landing page
end
```

---

## URL Examples

### Admin User Journey
```
1. Login: GET /login
2. Dashboard: GET /admin/dashboard
3. View time entries: GET /admin/time_entries
4. Filter by date: GET /admin/time_entries?start_date=2025-01-01&end_date=2025-01-31
5. Edit entry: GET /admin/time_entries/123/edit
6. View sites: GET /admin/sites
7. Generate QR code: GET /admin/sites/5/qr_code
8. View anomalies: GET /admin/anomalies
9. Create schedule: GET /admin/schedules/new
10. Export report: GET /admin/reports/monthly?month=1&year=2025
```

### Manager User Journey
```
1. Login: GET /login
2. Dashboard: GET /manager/dashboard
3. View team: GET /manager/team
4. Declare absence: GET /manager/absences/new
5. View schedules: GET /manager/schedules
6. Assign replacement: GET /manager/replacements
```

### Agent User Journey (Clock-in Domain)
```
1. Scan QR code: GET /c/abc123xyz (redirects to auth if needed)
2. Authenticate: GET /clock/auth
3. Submit credentials: POST /clock/auth
4. Return to clock page: GET /c/abc123xyz
5. Clock in: POST /c/abc123xyz/in
6. See confirmation: "Pointage validé ✓"
7. Later: Clock out: POST /c/abc123xyz/out
8. See confirmation: "Dépointage validé ✓"
```

---

## Rails Routes File Structure

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # Root
  root 'pages#home'
  
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
    
    resources :absences, only: [:index, :show, :destroy]
    
    resources :anomalies, only: [:index, :show] do
      member do
        post 'resolve'
      end
    end
    
    get 'reports', to: 'reports#index'
    get 'reports/monthly', to: 'reports#monthly'
    get 'reports/hr', to: 'reports#hr'
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
end
```

---

## HTTP Status Codes

### Success Responses
- `200 OK` - Successful GET, PATCH, PUT
- `201 Created` - Successful POST (resource created)
- `204 No Content` - Successful DELETE

### Redirect Responses
- `302 Found` - After successful POST/PATCH/DELETE (redirect to index/show)

### Client Error Responses
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Authenticated but not authorized
- `404 Not Found` - Resource doesn't exist
- `422 Unprocessable Entity` - Validation errors

### Error Handling
- Display flash messages for errors
- Render form again with errors for validation failures
- Log errors to system for debugging

---

## Query Parameters Standards

### Filters
```
?start_date=2025-01-01
?end_date=2025-01-31
?user_id=123
?site_id=456
?status=active
?role=agent
```

### Pagination
```
?page=2
?per_page=50
```

### Sorting
```
?sort=created_at
?order=desc
```

### Export
```
?format=csv
?format=xlsx
?format=pdf
```

### Combining
```
GET /admin/time_entries?user_id=123&start_date=2025-01-01&end_date=2025-01-31&format=csv
```

---

## Notes on KISS Principles Applied

1. **RESTful conventions followed** - Standard CRUD operations
2. **Meaningful route names** - Self-documenting URLs
3. **Consistent namespacing** - Clear separation by user role
4. **No unnecessary nesting** - Max 1 level of nesting
5. **Standard HTTP verbs** - GET, POST, PATCH, DELETE
6. **Query params for filters** - Not in URL path
7. **Collection actions use `/collection`** - e.g., `/export`
8. **Member actions use `/member`** - e.g., `/:id/qr_code`
9. **Singular resources for profiles** - `/dashboard/profile` not `/profiles/1`
10. **Clear action names** - `resolve`, `assign_replacement`, not cryptic codes
11. **No API namespace** - Using Turbo Streams for real-time updates (Rails 8 way)
12. **Simplified reports** - Combined into 2 clear endpoints

---

*This routes documentation serves as the API contract for frontend development.*
