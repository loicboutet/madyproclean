# Field Agent Routes Analysis
**Date:** November 15, 2025  
**Based on:** specification.md Section 2.1.2 Field Agent Features

## Executive Summary

✅ **Field Agent Role:** EXISTS (as `agent` in User model)  
✅ **Required Routes:** ALL DEFINED in config/routes.rb  
⚠️ **Implementation Status:** Routes exist but controller and views are incomplete

---

## Section 2.1.2 Field Agent Features Requirements

According to the specification, Field Agents (100-140 people) need to:

1. **Scan QR code** with smartphone
2. **Clock in** arrival 
3. **Clock out** departure
4. **Receive simple confirmation:** "Clock-in validated" or "Clock-out validated"
5. **See NO information** (no schedule, no cumulative time, no company name, nothing in URL)

### Additional Technical Requirements:
- Secure authentication by identifier
- Separate domain name for agent clock-ins
- Anti-fraud system: IP tracking + cookies to detect multiple clock-ins
- Ultra-minimalist interface: no visible info except clock-in confirmation

---

## Current Implementation Status

### 1. Role Definition ✅ COMPLETE

**Location:** `app/models/user.rb`

```ruby
enum :role, { agent: 'agent', manager: 'manager', admin: 'admin' }, default: 'agent'
```

The `agent` role is properly defined and set as the default role for new users.

---

### 2. Routes Definition ✅ COMPLETE

**Location:** `config/routes.rb`

All required routes are defined with proper subdomain constraint:

```ruby
constraints subdomain: 'clock' do
  get 'c/:qr_code_token', to: 'clock#show'              # QR code landing page
  post 'c/:qr_code_token/in', to: 'clock#clock_in'     # Clock IN action
  post 'c/:qr_code_token/out', to: 'clock#clock_out'   # Clock OUT action
  get 'clock/auth', to: 'clock#authenticate'            # Authentication page
  post 'clock/auth', to: 'clock#verify'                 # Verify credentials
end
```

#### Route Mapping to Requirements:

| Requirement | Route | Status |
|-------------|-------|--------|
| Scan QR code | `GET c/:qr_code_token` | ✅ Defined |
| Clock in arrival | `POST c/:qr_code_token/in` | ✅ Defined |
| Clock out departure | `POST c/:qr_code_token/out` | ✅ Defined |
| Agent authentication | `GET/POST clock/auth` | ✅ Defined |
| Separate domain | `subdomain: 'clock'` constraint | ✅ Defined |

---

### 3. Controller Implementation ⚠️ INCOMPLETE

**Location:** `app/controllers/clock_controller.rb`

**Current State:** Controller exists but only contains empty method stubs:

```ruby
class ClockController < ApplicationController
  def show
  end

  def clock_in
  end

  def clock_out
  end

  def authenticate
  end

  def verify
  end
end
```

**Missing Implementation:**
- [ ] Authentication logic for field agents
- [ ] QR code token validation
- [ ] Time entry creation (clock in/out)
- [ ] IP address tracking for anti-fraud
- [ ] Cookie-based duplicate detection
- [ ] Confirmation message rendering
- [ ] Error handling

---

### 4. Views ❌ MISSING

**Expected Location:** `app/views/clock/`

**Status:** Directory does not exist

**Required Views:**
- [ ] `authenticate.html.erb` - Minimal login page for agents
- [ ] `show.html.erb` - QR code scan page with clock in/out buttons
- [ ] Confirmation partials/messages

**Design Requirements:**
- Ultra-minimalist design
- No company information
- No schedule information
- No cumulative time display
- Only show confirmation: "Clock-in validated" or "Clock-out validated"

---

## What's Missing for Full Implementation?

### High Priority

1. **Clock Controller Logic**
   - Implement `authenticate` and `verify` methods for agent login
   - Implement `show` method to display QR code page
   - Implement `clock_in` and `clock_out` methods to create TimeEntry records
   - Add anti-fraud measures (IP tracking, cookie validation)
   - Implement proper error handling and validation

2. **Create Views**
   - Create `app/views/clock/` directory
   - Build minimal authentication page
   - Build minimal QR code/clock in-out page
   - Design confirmation messages (absolutely minimal)

3. **Security & Anti-Fraud**
   - IP address logging on each clock-in/out
   - Cookie-based detection of simultaneous clock-ins
   - QR code token validation
   - Prevent access to any other information

### Medium Priority

4. **Subdomain Configuration**
   - Configure subdomain routing in production/development
   - Set up separate domain (e.g., clock.madyproclean.com)
   - Test subdomain constraint functionality

5. **Testing**
   - Integration tests for clock in/out flow
   - Security tests for anti-fraud measures
   - Validation that no information leaks to agents

---

## Comparison: Specification vs Implementation

| Feature | Specification 2.1.2 | Current Status | Gap |
|---------|-------------------|----------------|-----|
| Agent Role | Required | ✅ Exists | None |
| Scan QR Code | Required | ✅ Route exists | Implementation needed |
| Clock In | Required | ✅ Route exists | Implementation needed |
| Clock Out | Required | ✅ Route exists | Implementation needed |
| Confirmation Messages | Required | ❌ Missing | Views needed |
| No Info Visibility | Required | ❌ Not enforced | Views + logic needed |
| Authentication | Required | ✅ Route exists | Implementation needed |
| Separate Domain | Required | ✅ Route constraint | Config/testing needed |
| IP Tracking | Required | ❌ Missing | Implementation needed |
| Cookie Anti-Fraud | Required | ❌ Missing | Implementation needed |

---

## Recommendations

### Immediate Actions

1. **Implement Clock Controller:**
   - Start with authentication (verify agent credentials)
   - Implement time entry creation for clock in/out
   - Add basic anti-fraud measures

2. **Create Minimal Views:**
   - Follow specification: absolutely minimal design
   - No branding, no extra information
   - Only essential elements: login, clock in/out buttons, confirmation

3. **Test Subdomain:**
   - Verify subdomain routing works in development
   - Plan production subdomain configuration

### Future Enhancements

- Add rate limiting to prevent abuse
- Implement more sophisticated anti-fraud detection
- Add logging and monitoring for security events
- Consider adding success/error flash messages
- Mobile-responsive design optimization

---

## Conclusion

**Routes Status:** ✅ All routes required by Section 2.1.2 are properly defined in `config/routes.rb`

**Role Status:** ✅ Field Agent role (`agent`) exists in the system

**Overall Implementation Status:** ⚠️ **25% Complete**
- Routes: 100% ✅
- Role: 100% ✅  
- Controller: 0% (stubs only)
- Views: 0% (missing)
- Security: 0% (missing)

**Next Steps:** Implement controller logic and create minimal views to complete the Field Agent functionality as specified in Section 2.1.2.
