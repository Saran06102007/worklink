# WorkLink

Hyperlocal on-demand blue-collar services marketplace — **Flutter prototype** with fully simulated data.

## Roles

| Role | Demo login | Password |
|------|------------|----------|
| Customer | `aarav@demo.worklink` or `9000000001` | `demo123` |
| Worker | `arjun@demo.worklink` or `9000000002` | `demo123` |
| Student | `nisha@demo.worklink` or `9000000003` | `demo123` |

Or tap **Demo** on the role-select screen.

## Features

- **Customer**: browse categories, discover ranked workers by distance, request bookings, negotiate price, track status, chat, pay & review (all simulated).
- **Worker**: online/offline, incoming requests (incl. simulator button), accept / counter / decline, advance job stages, earnings chart.
- **Student**: browse campus-style gigs, apply, shortlist → hire simulation, availability slots, earnings.
- **Shared**: dark/light theme, glass UI, staggered motion, verification KYC simulation, demo controls (auto-respond, worker reply mode, forced verification outcome).

## Run

```bash
cd worklink
flutter pub get
flutter run
```

Requires Flutter 3.22+ / Dart 3.5+.

## Architecture

```
lib/
  core/       tokens, theme, motion, utils, config
  models/     domain types
  data/       mock workers, jobs, categories (Chennai areas)
  state/      AppState (ChangeNotifier) — single source of truth
  widgets/    glass UI kit, forms, worker cards
  screens/    splash, welcome, auth, customer/, worker/, student/, common/
```

Everything is in-memory. No network, no real payments, no real KYC documents.

## Demo controls

From role select or Profile → **Demo controls**:

- Auto-respond on/off  
- Fast timing (×3)  
- Worker mode: mixed / always accept / always counter / always decline / no response  
- Forced verification outcome  
- Theme: dark / light / system  
