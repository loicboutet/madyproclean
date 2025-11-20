# DNS and Deployment Guide for Clock Subdomain

## Changes Made

1. **Routes Configuration** (`config/routes.rb`)
   - Updated to support clock-in from BOTH:
     - `https://madyproclean.5000.dev/c/:qr_code_token`
     - `https://clock.madyproclean.5000.dev/c/:qr_code_token`

2. **Production Configuration** (`config/environments/production.rb`)
   - Added host authorization for both main domain and clock subdomain
   - Prevents DNS rebinding attacks while allowing legitimate subdomain access

## DNS Configuration Required

You need to add a DNS record for the `clock` subdomain:

### Option 1: CNAME Record (Recommended)
```
Type: CNAME
Name: clock
Value: madyproclean.5000.dev
TTL: 3600 (or auto)
```

### Option 2: A Record
```
Type: A
Name: clock
Value: 141.94.197.228 (your server IP)
TTL: 3600 (or auto)
```

**Note:** If you're using a DNS provider like Cloudflare, ensure:
- SSL/TLS encryption mode is set to "Full" or "Full (strict)"
- The orange cloud (proxy) can be enabled for the subdomain

## Deployment Steps

1. **Commit the changes:**
   ```bash
   git add config/routes.rb config/environments/production.rb
   git commit -m "Enable clock-in from both main domain and clock subdomain"
   git push origin main
   ```

2. **Deploy with Kamal:**
   ```bash
   bin/kamal deploy
   ```

3. **Verify SSL certificates:**
   The Kamal proxy should automatically handle SSL for the subdomain. If you encounter any issues, you may need to:
   ```bash
   bin/kamal proxy boot
   ```

## Testing After Deployment

### Test 1: Main Domain Access
```bash
curl -I https://madyproclean.5000.dev/c/wAWxeXVjpjtnhOkN8mhGBEz4ppMn61IJ1YgGolTwZdU
```
Expected: Should return 200 OK (or redirect to auth)

### Test 2: Subdomain Access
```bash
curl -I https://clock.madyproclean.5000.dev/c/wAWxeXVjpjtnhOkN8mhGBEz4ppMn61IJ1YgGolTwZdU
```
Expected: Should return 200 OK (or redirect to auth)

### Test 3: Mobile QR Code Scan
- Scan QR code from http://localhost:3001/agent
- Should successfully clock in from mobile device

## Troubleshooting

### Issue: "page doesn't exist" error
- **Cause:** DNS not configured or not propagated
- **Solution:** Wait for DNS propagation (up to 48 hours, usually much faster) or check DNS records

### Issue: SSL certificate error
- **Cause:** Kamal proxy not configured for subdomain
- **Solution:** Restart the proxy: `bin/kamal proxy boot`

### Issue: Host authorization error
- **Cause:** Missing host in production.rb
- **Solution:** Already fixed in this commit, verify `config.hosts` includes the subdomain

### Verify DNS Propagation
```bash
# Check if DNS is propagated
nslookup clock.madyproclean.5000.dev

# Or use dig
dig clock.madyproclean.5000.dev
```

## QR Code Generation

After deployment, verify that QR codes generated at:
- Admin panel: `/admin/sites/:id/qr_code`
- Manager panel: `/manager/sites/:id/qr_code`

Should work with both URLs:
- `https://madyproclean.5000.dev/c/:token` ✅
- `https://clock.madyproclean.5000.dev/c/:token` ✅

## Summary

With these changes:
- 🎯 Clock-in works from main domain (immediate - no DNS needed)
- 🎯 Clock-in works from subdomain (requires DNS configuration)
- 🎯 Maximum flexibility and redundancy
- 🎯 Backward compatible with existing QR codes
