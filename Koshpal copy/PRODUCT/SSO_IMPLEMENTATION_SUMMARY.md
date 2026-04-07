# Unified SSO Login System - Implementation Summary

## ✅ Completed Changes

### Backend (koshpal-backend)

**1. Updated Login API (`/api/v1/auth/login`)**
- ✅ Added `role` parameter to `LoginDto` (optional, validates against Role enum)
- ✅ Modified `auth.service.ts` to validate user has requested role
- ✅ Returns `redirectUrl` based on user role for seamless SSO redirect
- ✅ Updated cookie configuration to use `.koshpal.com` domain
- ✅ Added environment variables for portal URLs

**Response Structure:**
```json
{
  "user": { /* user data */ },
  "role": "EMPLOYEE",
  "redirectUrl": "https://employee.koshpal.com"
}
```

**Files Modified:**
- `src/auth/dto/login.dto.ts` - Added role field
- `src/auth/auth.service.ts` - Added role validation logic
- `src/auth/auth.controller.ts` - Added redirectUrl in response
- `.env` - Added EMPLOYEE_PORTAL_URL, HR_PORTAL_URL, COACH_PORTAL_URL, ADMIN_PORTAL_URL

### Frontend - Landing Page (koshpal.com)

**1. Created Unified Login Page**
- ✅ Created `/landing_page/src/pages/LoginPage.jsx`
- ✅ Includes email, password inputs
- ✅ Role selector dropdown (EMPLOYEE, HR, COACH, ADMIN)
- ✅ Auto-redirects if already authenticated
- ✅ Redirects to appropriate portal after successful login
- ✅ Added route `/login` to main.jsx

### Frontend - Employee Portal (employee.koshpal.com)

**1. Updated ProtectedRoute Component**
- ✅ Removed local login dependency
- ✅ Checks authentication via `/auth/me` with httpOnly cookies
- ✅ Validates EMPLOYEE role
- ✅ Redirects to `https://koshpal.com/login` if not authenticated

**2. Updated App.tsx**
- ✅ Removed `/login` route
- ✅ Root path redirects to `/dashboard`
- ✅ All routes protected by ProtectedRoute

### Frontend - HR Portal (hr.koshpal.com)

**1. Updated ProtectedRoute Component**
- ✅ Removed localStorage token logic
- ✅ Uses httpOnly cookies for authentication
- ✅ Validates HR role
- ✅ Redirects to unified login if not authenticated

**2. Updated App.jsx**
- ✅ Removed `/login` route
- ✅ All routes protected

### Frontend - Coach Portal (coach.koshpal.com)

**1. Updated ProtectedRoute Component**
- ✅ Removed localStorage token logic
- ✅ Uses httpOnly cookies for authentication
- ✅ Validates COACH role
- ✅ Redirects to unified login if not authenticated

**2. Updated App.jsx**
- ✅ Removed `/login` route
- ✅ All routes protected

---

## 🔐 Security Features

✅ **httpOnly Cookies** - Tokens stored in httpOnly cookies, not accessible via JavaScript
✅ **Secure flag** - Cookies only sent over HTTPS in production
✅ **SameSite: none** - Allows cross-subdomain cookie sharing
✅ **Domain: .koshpal.com** - Cookies shared across all koshpal subdomains
✅ **Role Validation** - Backend validates user has requested role
✅ **No tokens in localStorage** - Eliminates XSS attack vector
✅ **No tokens in URLs** - Prevents token leakage

---

## 📋 Deployment Checklist

### Backend
```bash
cd koshpal-backend
npm run build
rsync -avz --progress --exclude 'node_modules' --exclude '.git' -e "ssh -i ~/.ssh/id_ed25519" ./ root@139.59.75.121:~/Koshpal_backend/
ssh -i ~/.ssh/id_ed25519 root@139.59.75.121 "cd ~/Koshpal_backend && npm install && npx prisma generate && pm2 restart all"
```

### Landing Page
```bash
cd landing_page
npm run build
# Deploy dist/ to koshpal.com
```

### Employee Portal
```bash
cd employee_portal
npm run build
# Deploy dist/ to employee.koshpal.com
```

### HR Portal
```bash
cd hr_portal
npm run build
# Deploy dist/ to hr.koshpal.com
```

### Coach Portal
```bash
cd coach_portal
npm run build
# Deploy dist/ to coach.koshpal.com
```

---

## 🧪 Testing the SSO Flow

### Test Scenario 1: Login from Landing Page
1. Go to `https://koshpal.com/login`
2. Enter credentials
3. Select role (e.g., EMPLOYEE)
4. Click "Sign In"
5. **Expected**: Automatically redirected to `https://employee.koshpal.com` and logged in

### Test Scenario 2: Direct Portal Access (Not Logged In)
1. Go directly to `https://employee.koshpal.com`
2. **Expected**: Automatically redirected to `https://koshpal.com/login`

### Test Scenario 3: Already Logged In
1. Log in as EMPLOYEE
2. Open new tab and go to `https://koshpal.com/login`
3. **Expected**: Automatically redirected to `https://employee.koshpal.com`

### Test Scenario 4: Wrong Role
1. Log in as EMPLOYEE from landing page
2. Select "HR" role
3. **Expected**: Error message "You do not have HR role access. Your role is EMPLOYEE."

### Test Scenario 5: Logout
1. Log in to any portal
2. Click logout
3. **Expected**: Logged out from all portals, redirected to login page

---

## 🔧 Environment Variables

### Backend (.env)
```env
# CORS - Include all portals and landing page
CORS_ORIGIN=https://koshpal.com,https://employee.koshpal.com,https://hr.koshpal.com,https://coach.koshpal.com

# Portal URLs for redirects
EMPLOYEE_PORTAL_URL=https://employee.koshpal.com
HR_PORTAL_URL=https://hr.koshpal.com
COACH_PORTAL_URL=https://coach.koshpal.com
ADMIN_PORTAL_URL=https://admin.koshpal.com
```

### Frontend Portals (.env)
```env
VITE_API_URL=https://api.koshpal.com/api/v1
```

---

## 📝 API Documentation Updates

### POST /api/v1/auth/login
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "role": "EMPLOYEE" // Optional: EMPLOYEE | HR | COACH | ADMIN
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "role": "EMPLOYEE",
    "companyId": "uuid",
    "name": "John Doe"
  },
  "role": "EMPLOYEE",
  "redirectUrl": "https://employee.koshpal.com"
}
```

**Cookies Set:**
- `accessToken` (httpOnly, 15 minutes)
- `refreshToken` (httpOnly, 7 days)

---

## 🎯 Benefits

✅ **Single Login** - Users log in once from koshpal.com
✅ **Seamless Experience** - No re-authentication needed across portals
✅ **Enhanced Security** - httpOnly cookies prevent XSS attacks
✅ **Centralized Auth** - All authentication logic in one place
✅ **Role Validation** - Backend enforces role-based access
✅ **Better UX** - Users don't need to remember which portal to use

---

## 🚨 Important Notes

1. **HTTPS Required** - Cookies with `secure: true` only work over HTTPS
2. **Domain Configuration** - All portals must be on `*.koshpal.com` subdomains
3. **Cookie Domain** - Set to `.koshpal.com` for cross-subdomain sharing
4. **CORS** - Backend must allow all portal origins
5. **No Local Login** - Portal-specific login pages removed/disabled

---

## 🔄 Migration Plan

1. Deploy backend first
2. Test login API manually (Postman)
3. Deploy landing page
4. Test unified login page
5. Deploy portals one by one (employee → hr → coach)
6. Test SSO flow for each portal
7. Monitor logs for any cookie/auth issues

---

## 📞 Support

For issues:
1. Check browser console for errors
2. Verify cookies are being set (DevTools → Application → Cookies)
3. Check backend logs for authentication errors
4. Ensure CORS is configured correctly
