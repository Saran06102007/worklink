# WorkLink

**Hyperlocal on-demand blue-collar services platform** built for the Vecnaverse National Level Hackathon (Social Impact domain).

WorkLink connects customers with nearby plumbers, electricians, painters, cleaners, maids, cooks and other local workers, with **worker-set rates, two-way price negotiation, distance-ranked discovery and verified profiles**. It also has a **Student** mode for campus-style gigs.

> Prototype note: all people, prices, ratings, payments and KYC verification are simulated. Everything runs in memory with no network access.

## Problem

Customers struggle to find reliable, affordable, nearby workers, and local skilled workers struggle to find steady work and reach nearby customers. WorkLink aims to put the right worker in front of the customer quickly (target: within about 30 minutes where distance and availability allow) with transparent, flexible pricing and trust built in.

## Features

| Role | What you can do |
|------|-----------------|
| **Customer** | Browse 9 service categories, discover workers ranked by distance with ETA, filter by availability and verification, request a booking, negotiate price (offer / counter-offer / accept), track status live, chat, pay and review |
| **Worker** | Go online or offline, receive job requests, accept / counter / decline, advance a job through its stages, view earnings chart, complete verification |
| **Student** | Browse gigs (tutoring, events, delivery, data entry, shop assistance), apply, get shortlisted and hired, set weekly availability slots, track earnings |
| **Shared** | Dark / light theme, notifications, in-app chat, simulated KYC verification, demo controls |

### What makes it different

- **Two-way pricing:** workers set their rate and customers can counter-offer instead of accepting a fixed price.
- **Trust first:** "request nearest" only dispatches to verified, available workers; unanswered requests roll to the next candidate.
- **Distance-ranked with ETA:** workers are sorted by distance, with an estimated arrival time.
- **Student gig mode:** a separate flow for short campus-style jobs.

## Tech stack

- Flutter (Dart 3.5+), Material 3
- `provider` for state management (`ChangeNotifier`)
- No backend: in-memory mock data (Chennai areas)

## Architecture

```
lib/
  core/       tokens, theme, motion, utils, config
  models/     domain types (Worker, Customer, Booking, Offer, StudentJob ...)
  data/       mock workers, jobs, categories (Chennai areas)
  state/      AppState - single source of truth and business logic
  widgets/    glass UI kit, forms, worker cards
  screens/    splash, welcome, auth, customer/, worker/, student/, common/
```

**Booking lifecycle:** `awaitingWorker` -> `counterReceived` (optional, repeats) -> `confirmed` -> `onTheWay` -> `workStarted` -> `completed` (or `cancelled` / `rejected`).

## Run it

Requires Flutter 3.22+ / Dart 3.5+.

```bash
cd worklink
flutter pub get
flutter run
```

Run the tests:

```bash
flutter test
```

## Demo logins

Tap **Demo** on the role-select screen, or sign in with:

| Role | Login | Password |
|------|-------|----------|
| Customer | `aarav@demo.worklink` or `9000000001` | `demo123` |
| Worker | `arjun@demo.worklink` or `9000000002` | `demo123` |
| Student | `nisha@demo.worklink` or `9000000003` | `demo123` |

Demo OTP: `123456`

## Demo controls

From role select or **Profile -> Demo controls**:

- Auto-respond on / off
- Fast timing (x3)
- Worker mode: mixed / always accept / always counter / always decline / no response
- Forced verification outcome
- Theme: dark / light / system

## Suggested 2-minute demo path

1. Role select -> **Customer demo** -> pick **Electrician** -> see ranked, verified workers with ETA.
2. Request a booking with a lower offer -> worker **counters** -> accept.
3. Watch status move: confirmed -> on the way -> work started -> completed -> pay and review.
4. Switch to **Worker** (Demo) -> use **Simulate incoming request** -> accept / counter, check earnings.
5. Switch to **Student** -> apply to a gig -> shortlist -> hire.

## Roadmap (production path)

- Cloud backend and database
- Live GPS and maps for real ETAs
- UPI payments with escrow
- e-KYC partner integration and push notifications
- Commission-based revenue model (proposed)

## Limitations

This is a hackathon prototype. Data resets on restart, and there are no real payments, documents, locations or users.
