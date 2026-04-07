/**
 * Test script to verify timezone calculations
 * Run: node test-timezone.mjs
 */

function getUTCRangeForISTDate(dateStr) {
  const [year, month, day] = dateStr.split('-').map(Number);
  
  // IST midnight (00:00) = UTC 18:30 previous day
  const startUTC = new Date(Date.UTC(year, month - 1, day - 1, 18, 30, 0, 0));
  // IST end of day (23:59:59) = UTC 18:29:59 same day
  const endUTC = new Date(Date.UTC(year, month - 1, day, 18, 29, 59, 999));
  
  return { startUTC, endUTC };
}

function getSlotDateInIST(utcDate) {
  const date = new Date(utcDate);
  // Convert to IST by adding 5.5 hours
  const istDate = new Date(date.getTime() + (5.5 * 60 * 60 * 1000));
  const year = istDate.getUTCFullYear();
  const month = String(istDate.getUTCMonth() + 1).padStart(2, '0');
  const day = String(istDate.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

console.log('=== Timezone Calculation Test ===\n');

// Test 1: Query for Jan 13 IST
console.log('Test 1: Query for Jan 13, 2026 (IST)');
const range1 = getUTCRangeForISTDate('2026-01-13');
console.log('UTC Range Start:', range1.startUTC.toISOString());
console.log('UTC Range End  :', range1.endUTC.toISOString());
console.log('');

// Test 2: Check if slot at Jan 12 21:30 UTC falls in Jan 13 IST range
console.log('Test 2: Slot at Jan 12, 2026 21:30 UTC');
const slotTime = new Date('2026-01-12T21:30:00.000Z');
const slotISTDate = getSlotDateInIST(slotTime);
console.log('Slot UTC Time :', slotTime.toISOString());
console.log('Slot IST Date :', slotISTDate);
console.log('Falls in Jan 13 IST range?', 
  slotTime >= range1.startUTC && slotTime <= range1.endUTC);
console.log('');

// Test 3: Check actual IST time
console.log('Test 3: What is Jan 12, 2026 21:30 UTC in IST?');
const istTime = new Date(slotTime.getTime() + (5.5 * 60 * 60 * 1000));
console.log('IST DateTime  :', istTime.toISOString().replace('Z', ' (as UTC+5:30)'));
console.log('Expected      : Jan 13, 2026 03:00 IST');
console.log('');

// Test 4: Check your actual consultation slot
console.log('Test 4: Your consultation slot');
const consultSlot = new Date('2026-01-02T03:30:00.000Z');
const consultIST = getSlotDateInIST(consultSlot);
console.log('Slot UTC Time :', consultSlot.toISOString());
console.log('Slot IST Date :', consultIST);
console.log('Slot IST Time :', new Date(consultSlot.getTime() + (5.5 * 60 * 60 * 1000)).toISOString().replace('Z', ' (as IST)'));

// Test query for Jan 2
const range2 = getUTCRangeForISTDate('2026-01-02');
console.log('Query for Jan 2 IST:');
console.log('  UTC Range Start:', range2.startUTC.toISOString());
console.log('  UTC Range End  :', range2.endUTC.toISOString());
console.log('  Slot in range? :', consultSlot >= range2.startUTC && consultSlot <= range2.endUTC);
