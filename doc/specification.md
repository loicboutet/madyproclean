# Project Specifications - Time Tracking and HR Management System

## 1. General Project Description

### 1.1 Overview
Digital transformation of the time tracking and HR management system for a company in the nuclear industrial sector with:
- **100-140 field agents**
- **3 supervisors**
- **8 management/direction personnel**

### 1.2 Objective
Replace the current system based on WhatsApp and paper documentation with a modern, secure web solution hosted in France.

**Delivery deadline:** End of November 2025

---

## 2. Features to Develop

### BLOCK 1 - Time Tracking System

#### 2.1.1 Admin Features (Management + Supervisors)

As an admin, I can:
- ✅ View all time entries in real-time
- ✅ See who is on which site instantly
- ✅ Generate QR codes for each site
- ✅ Export time tracking data (CSV, Excel)
- ✅ View anomalies (missed clock-in, clock-in >24h)
- ✅ Manually correct time entries if necessary
- ✅ Generate monthly reports
- ✅ Filter by agent, date, site

#### 2.1.2 Field Agent Features (100-140 people)

As a field agent, I can:
- ✅ Scan the site's QR code with my smartphone
- ✅ Clock in my arrival and departure
- ✅ Receive simple confirmation: "Clock-in validated" or "Clock-out validated"
- ⛔ **I see NO information** (no schedule, no cumulative time, no company name, nothing in the URL)

#### 2.1.3 System Features - Block 1

**Authentication & Security:**
- Secure authentication by identifier (for agents)
- Separate domain name for agent clock-ins
- Anti-fraud system: IP tracking + cookies to detect multiple clock-ins

**QR Code System:**
- Automatic generation of unique QR codes per site
- Time-stamped clock-in with site detection

**Interface:**
- Responsive web interface (no mobile app required)
- Ultra-minimalist agent interface: no visible info except clock-in confirmation

**Admin Dashboard:**
- Real-time dashboard with advanced filters
- Data export (CSV, Excel)
- Monthly report generation
- Anomaly detection (missed clock-in, >24h clocked in)
- Manual correction of time entries by admin

---

### BLOCK 2 - HR Management and Planning

#### 2.2.1 Admin Features (Management)

As an admin, I can:
- ✅ Create and manage team schedules
- ✅ Assign agents to sites/work locations
- ✅ View an interactive global calendar
- ✅ Visualize workload per site
- ✅ Export schedules (PDF, Excel)
- ✅ View indicators: absence rate, team coverage

#### 2.2.2 Manager Features (3 supervisors)

As a manager, I can:
- ✅ Declare agent absences (vacation, sick leave, other)
- ✅ View my teams' schedules
- ✅ See site assignments
- ✅ Propose schedule adjustments
- ✅ Manage replacements

#### 2.2.3 Field Agent Features

**No access to Block 2:**
- ⛔ Agents see nothing of the schedule
- ⛔ All absence declarations are made through the manager

#### 2.2.4 System Features - Block 2

**Role Management:**
- Distinct Manager role with specific permissions
- Complete CRUD for schedules (admin only)

**Absence Management:**
- Absence declaration by managers (without validation workflow)
- Management of multiple absence types (vacation, sick leave, training, unpaid leave)
- Intelligent replacement system

**Planning & Calendar:**
- Calendar view with advanced filters (site, person, period)
- Automatic notification if clock-in not performed according to schedule
- Export schedules and HR statistics

**HR Indicators:**
- Absence rate
- Team coverage

---

## 3. Explicitly Excluded Elements

The following elements are **explicitly excluded** from the scope:

- ❌ Native mobile application (iOS/Android)
- ❌ Integration with external payroll software
- ❌ Physical badge reader or on-site hardware (beyond QR codes)
- ❌ GPS geolocation of agents
- ❌ Document management system
- ❌ Payroll system or salary calculations
- ❌ Client billing module

**This feature list constitutes the contractual scope of developments to be carried out.**

---

## 4. User Roles Summary

| Role | Count | Access Level |
|------|-------|--------------|
| **Admin (Direction)** | 8 | Full access to Blocks 1 & 2 |
| **Supervisor** | 3 | Full access to Block 1, Limited access to Block 2 (view schedules, manage absences, replacements) |
| **Field Agent** | 100-140 | Block 1 only (minimal interface for clock-in/out) |

---

## 5. Technical Requirements

### 5.1 Infrastructure
- **Hosting:** France-based servers
- **Web-based:** Responsive web application (no native mobile app)
- **Security:** Secure authentication, anti-fraud measures

### 5.2 Data Export Formats
- CSV
- Excel
- PDF (for schedules)

### 5.3 Key Performance Indicators (KPIs)
- Real-time time tracking visibility
- Anomaly detection and alerts
- Absence rate tracking
- Team coverage metrics
- Monthly reporting capabilities

---

## 6. User Stories

### 6.1 Field Agent User Stories

**US-1.1:** As a field agent, when I arrive at a site, I scan the QR code with my smartphone and receive a "Clock-in validated" confirmation.

**US-1.2:** As a field agent, when I leave a site, I scan the QR code again and receive a "Clock-out validated" confirmation.

**US-1.3:** As a field agent, I use a minimal interface that shows no company information, no schedule, no cumulative time - only confirmation messages.

### 6.2 Admin User Stories

**US-2.1:** As an admin, I can view a real-time dashboard showing all agents and their current locations.

**US-2.2:** As an admin, I can generate and print QR codes for each work site.

**US-2.3:** As an admin, I can export time tracking data filtered by agent, date, or site in CSV or Excel format.

**US-2.4:** As an admin, I can see a list of anomalies (missed clock-ins, agents clocked in for >24h) and manually correct them.

**US-2.5:** As an admin, I can create team schedules and assign agents to specific sites.

**US-2.6:** As an admin, I can view HR indicators including absence rates and team coverage.

### 6.3 Manager User Stories

**US-3.1:** As a manager, I can declare absences for my team members with different absence types.

**US-3.2:** As a manager, I can view my teams' schedules and site assignments.

**US-3.3:** As a manager, I can propose schedule adjustments and manage replacements.

---

## 7. Security & Privacy Considerations

### 7.1 Agent Privacy
- Minimal information exposure for field agents
- Separate domain for agent clock-in interface
- No identifying information in URLs

### 7.2 Anti-Fraud Measures
- IP address tracking
- Cookie-based detection of multiple simultaneous clock-ins
- Timestamp verification

### 7.3 Data Security
- Secure authentication for all users
- Role-based access control (RBAC)
- French hosting for data sovereignty compliance

---

## 8. Reporting Requirements

### 8.1 Real-time Reports
- Current site occupancy
- Active agents by location
- Anomaly dashboard

### 8.2 Periodic Reports
- Monthly time tracking reports
- Absence rate reports
- Team coverage reports

### 8.3 Export Capabilities
- Time tracking data (CSV, Excel)
- Schedules (PDF, Excel)
- HR statistics and indicators

---

## 9. Success Criteria

The project will be considered successful when:

1. ✅ All 100-140 field agents can clock in/out via QR code scanning
2. ✅ Admin can view real-time location of all agents
3. ✅ QR codes can be generated for all sites
4. ✅ Anomaly detection is operational
5. ✅ Monthly reports can be generated and exported
6. ✅ Managers can declare absences and manage schedules
7. ✅ System is hosted in France and accessible via web browsers
8. ✅ Agent interface is minimal with no exposed information
9. ✅ Anti-fraud measures are implemented and functional
10. ✅ All data export features are operational

---

## 10. Timeline

**Target Delivery:** End of November 2025

---

*This specification document constitutes the contractual scope of work for the Time Tracking and HR Management System.*
