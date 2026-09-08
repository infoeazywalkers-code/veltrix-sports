# Fix Tracker - Veltrix Sports

> Generated: 2026-09-07 (updated 2026-09-07)
> Dart analyze: 0 errors, 0 warnings
> Flutter test: 1571+ passed, 56 failed (pre-existing)

---

## Fixed Issues

| # | File | Line | Issue | Priority | Status |
|---|------|------|-------|----------|--------|
| 1 | `lib/screens/coach_questionnaire_screen.dart` | 159, 178, 191 | `DropdownButtonFormField` uses `initialValue:` (correct for Flutter 3.33+, no change needed) | - | **No change needed** |
| 2 | `lib/widgets/workout_builder_dialog.dart` | 148 | `DropdownButtonFormField` uses `initialValue:` (correct for Flutter 3.33+, no change needed) | - | **No change needed** |
| 5 | `lib/services/ble_sensor_service.dart` | 25 | `_liveHeartRate = 145` hardcoded initial value | P0 | **Fixed** - Changed to `0` (only meaningful when BLE is connected) |
| 8 | `lib/services/workout_execution_service.dart` | 31-32 | Initial HR hardcoded to `142`, cadence to `172` | P0 | **Fixed** - Changed both to `0` (shows 0 until BLE reading arrives) |
| 28 | `lib/services/watch_sync_service.dart` | 72 | Unused private method `_simulateWatchSync` (dart analyze warning) | P3 | **Fixed** - Removed unused method and unused `uuid` import |

> **Note:** On this Flutter version (3.33+), `value:` is deprecated and `initialValue:` is the correct parameter. The original code was already correct.
> 
> **Note on P0 #6:** `getCurrentZone()` already uses `zones` parameter from `HeartRateZone` model - tracker description was outdated.

---

## Pending Issues - Hardcoded / Simulated Data (Documented for Coder)

### P0 - Critical (Blocks real functionality)

| # | File | Lines | Issue | What Needs to Change |
|---|------|-------|-------|---------------------|
| 3 | `lib/services/ble_sensor_service.dart` | 76-87 | `_simulateDiscoveredDevices()` returns fake BLE devices (Apple Watch, Garmin, Polar, Wahoo) when on web/unsupported | Remove simulation on production; keep as dev fallback only behind `kDebugMode` |
| 4 | `lib/services/ble_sensor_service.dart` | 89-101 | `connectToWatch()` starts a fake `Stream.periodic` timer generating HR values `140 + (i % 22)` instead of reading real BLE GATT data | Implement actual BLE GATT HR Service (UUID `0x180D`) / Characteristic (`0x2A37`) read subscription |
| 5 | `lib/services/ble_sensor_service.dart` | 25 | `_liveHeartRate = 145` hardcoded initial value | **Fixed** (see above) |
| 6 | `lib/services/workout_execution_service.dart` | 88-94 | `getCurrentZone()` uses `zones` parameter from `HeartRateZone` model | **Already correct** - uses user-specific zones |
| 7 | `lib/services/workout_execution_service.dart` | 98-103 | Simulated distance (`0.0032 km/s`), HR (`135 + elapsedSeconds % 25`), cadence (`172 + elapsedSeconds % 9 - 4`) | Only simulate when `isDemoMode` is true; connect to BLE sensor for real values in production |
| 8 | `lib/services/workout_execution_service.dart` | 31-32 | Initial HR hardcoded to `142`, cadence to `172` | **Fixed** (see above) |

### P1 - High Priority (Fake data fallbacks)

| # | File | Lines | Issue | What Needs to Change |
|---|------|-------|-------|---------------------|
| 9 | `lib/services/seed_data_service.dart` | 16-308 | `seedNewUser()` gives every new user fake training data: a hardcoded "Half Marathon Performance" plan, 7 pre-seeded workouts (4 completed, 2 pending), and 5 historical performance snapshots | Remove auto-seeding of fake data. New users should start with empty state or onboarding flow |
| 10 | `lib/services/training_plan_service.dart` | 14-72 | `demoPlans` static list of 3 fake training plans (Marathon Pro, Cycling Performance, Triathlon Base) | Remove static demo plans entirely |
| 11 | `lib/services/training_plan_service.dart` | 139-153 | `getFeaturedPlans()` falls back to `demoPlans` when Firestore is empty or errors | Return empty list on error/empty; remove fallback |
| 12 | `lib/services/coach_service.dart` | 14-48 | `featuredCoaches` static const list of 3 fake coaches (Priya, Amit, Vikram) | Remove static list entirely |
| 13 | `lib/services/coach_service.dart` | 50-62 | `fetchFeaturedCoaches()` falls back to `featuredCoaches` when Firestore is empty or errors | Return empty list on error/empty; remove fallback |
| 14 | `lib/services/coach_service.dart` | 64-73 | `fetchCoachById()` falls back to `featuredCoaches` for unknown IDs | Return null only; remove fallback loop |

### P2 - Medium Priority (UI hardcoded data)

| # | File | Lines | Issue | What Needs to Change |
|---|------|-------|-------|---------------------|
| 15 | `lib/screens/home_screen.dart` | 111-204 | Hardcoded Mumbai Half Marathon event (title, date, location, progress 62%) | Wire to active training plan from Firestore via provider |
| 16 | `lib/screens/home_screen.dart` | 213-241 | Hardcoded "Aerobic endurance" workout (45 min, 7.2 km, 62 TSS, progress 0.68) | Wire to today's actual workout from `upcomingWorkoutsProvider` |
| 17 | `lib/screens/home_screen.dart` | 221-234 | Hardcoded `demoWorkout` object passed to WorkoutDetailsScreen | Replace with real workout from provider |
| 18 | `lib/screens/home_screen.dart` | 287-301 | Hardcoded "Coach Priya" note with fixed message | Wire to latest coach message from Firestore |
| 19 | `lib/mobile/screens/mobile_home.dart` | 133-236 | Same hardcoded Mumbai Half Marathon (duplicate of #15) | Wire to same provider as home_screen.dart |
| 20 | `lib/mobile/screens/mobile_home.dart` | 262-276 | Hardcoded demo workout fallback when workouts list is empty | Show "No workouts scheduled" or onboarding CTA instead |
| 21 | `lib/mobile/screens/mobile_home.dart` | 352-373 | Hardcoded Fitness/Fatigue/Form rings (showing `--` placeholders) | Wire to `latestPerformanceProvider` |
| 22 | `lib/mobile/screens/mobile_home.dart` | 466-508 | Hardcoded week stats (5 Workouts, 4h 35m, 286 TSS, bar chart heights) | Compute from `weekWorkoutsProvider` |
| 23 | `lib/widgets/status_card.dart` | 16-18 | Hardcoded Fitness=54, Fatigue=61, Form=-7 | Accept values from provider or constructor parameters |
| 24 | `lib/widgets/status_card.dart` | 34 | Hardcoded status message "Productive training - fitness is building steadily." | Compute from form/fitness values (e.g., if form > 0 = productive, form < -10 = overreaching) |
| 25 | `lib/widgets/week_card.dart` | 16-18 | Hardcoded week stats (5 Workouts, 4h 35m, 286 TSS) | Accept from provider or constructor params |
| 26 | `lib/widgets/week_card.dart` | 31 | Hardcoded bar chart heights `[30.0, 55.0, 18.0, 68.0, 42.0, 74.0, 25.0]` | Compute from actual daily TSS/duration |
| 27 | `lib/screens/progress_screen.dart` | 130-131 | Hardcoded personal bests: 5K run (21:42), 20 min power (278 W) | Compute from workout history by finding best pace/power per distance |

### P3 - Low Priority (Minor)

| # | File | Lines | Issue | What Needs to Change |
|---|------|-------|-------|---------------------|
| 28 | `lib/services/watch_sync_service.dart` | 72 | Unused private method `_simulateWatchSync` (dart analyze warning) | **Fixed** (see above) |

---

## Test Failure

| # | Test File | Test Name | Failure Reason |
|---|-----------|-----------|----------------|
| T1 | `test/mobile/mobile_home_coverage_test.dart:235` | `notification icon opens notifications page` | Expected to find widget with text "Notifications" but found 0. The `NotificationsScreen` is likely not rendering a "Notifications" text heading, or the badge icon tap doesn't navigate properly in test environment. |

---

## BLE GATT Protocol Reference (for Issue #4)

To implement real BLE HR reading in `ble_sensor_service.dart`:

```
HR Service UUID:     0x180D
HR Characteristic:   0x2A37 (notify)

Data format (first byte flags):
  Bit 0: HR format (0 = uint8, 1 = uint16)
  Bit 3: RR interval present
  
  If uint8: byte[1] = HR value
  If uint16: byte[1..2] = HR value (little-endian)
```

Implementation sketch:
```dart
final service = await device.discoverServices();
final hrService = service.firstWhere((s) => s.uuid == Guid('180D'));
final hrChar = hrService.characteristics.firstWhere((c) => c.uuid == Guid('2A37'));
await hrChar.setNotifyValue(true);
hrChar.lastValueStream.listen((data) {
  final hr = data[0] & 0x01 == 0 ? data[1] : data[1] | (data[2] << 8);
  _liveHeartRate = hr;
  notifyListeners();
});
```
