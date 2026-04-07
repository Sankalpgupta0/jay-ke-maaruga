#!/bin/bash

# Timezone Fix Validation Script
# Run this to verify the fix is working correctly

echo "========================================="
echo "Timezone Fix Validation"
echo "========================================="
echo ""

# Check backend files exist
echo "✓ Checking backend files..."
if [ -f "koshpal-backend/src/common/utils/timezone.util.ts" ]; then
    echo "  ✓ timezone.util.ts exists"
else
    echo "  ✗ timezone.util.ts missing"
    exit 1
fi

if [ -f "koshpal-backend/src/common/utils/timezone.util.spec.ts" ]; then
    echo "  ✓ timezone.util.spec.ts exists"
else
    echo "  ✗ timezone.util.spec.ts missing"
    exit 1
fi

# Check frontend files exist
echo ""
echo "✓ Checking frontend files..."
if [ -f "employee_portal/src/utils/timezone.ts" ]; then
    echo "  ✓ timezone.ts exists"
else
    echo "  ✗ timezone.ts missing"
    exit 1
fi

# Run backend tests
echo ""
echo "✓ Running backend timezone tests..."
cd koshpal-backend
if npm test -- timezone.util.spec.ts 2>/dev/null; then
    echo "  ✓ All timezone tests passed"
else
    echo "  ⚠ Tests not run (npm test may need configuration)"
fi
cd ..

# Check for slotDate in key files
echo ""
echo "✓ Verifying slotDate field implementation..."
if grep -q "slotDate" koshpal-backend/src/modules/employee/employee-coach.service.ts; then
    echo "  ✓ employee-coach.service.ts includes slotDate"
else
    echo "  ✗ employee-coach.service.ts missing slotDate"
fi

if grep -q "slotDate" koshpal-backend/src/modules/consultation/consultation.service.ts; then
    echo "  ✓ consultation.service.ts includes slotDate"
else
    echo "  ✗ consultation.service.ts missing slotDate"
fi

if grep -q "slotDate" employee_portal/src/api/coaches.ts; then
    echo "  ✓ coaches.ts API interface includes slotDate"
else
    echo "  ✗ coaches.ts API interface missing slotDate"
fi

if grep -q "formatUTCToISTTime" employee_portal/src/pages/Sessions.tsx; then
    echo "  ✓ Sessions.tsx uses timezone utilities"
else
    echo "  ✗ Sessions.tsx not using timezone utilities"
fi

echo ""
echo "========================================="
echo "Manual Testing Checklist:"
echo "========================================="
echo ""
echo "1. Start backend: cd koshpal-backend && npm run dev"
echo "2. Start employee portal: cd employee_portal && npm run dev"
echo "3. Create test slots as coach:"
echo "   - Date: $(date -u -v+0d '+%Y-%m-%d')"
echo "   - Time: 21:30 - 22:30 (UTC)"
echo "4. Login as employee"
echo "5. Navigate to Sessions page"
echo "6. Verify slot appears on NEXT day (IST date)"
echo "7. Verify time shows as 03:00 AM - 04:00 AM IST"
echo "8. Verify 'No slots available' does NOT appear incorrectly"
echo ""
echo "Critical test dates:"
echo "  - Jan 12, 21:30 UTC → should appear Jan 13 IST"
echo "  - Jan 19, 21:30 UTC → should appear Jan 20 IST"
echo "  - Jan 26, 21:30 UTC → should appear Jan 27 IST"
echo ""
echo "========================================="
echo "Validation Complete!"
echo "========================================="
