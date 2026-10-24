import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/tokens.dart';
import '../core/utils.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

enum DemoWorkerMode { mixed, alwaysAccept, alwaysCounter, alwaysDecline, noResponse }

enum ForcedOutcome { verified, pending, rejected }

/// Single in-memory source of truth for the whole prototype. Everything is simulated.
class AppState extends ChangeNotifier {
  AppState({this.autoRespond = true, this.fastTiming = false}) {
    _seed();
  }

  // ---- demo controls -------------------------------------------------------
  bool autoRespond;
  bool fastTiming;
  DemoWorkerMode workerMode = DemoWorkerMode.mixed;
  ForcedOutcome outcome = ForcedOutcome.verified;

  // ---- session -------------------------------------------------------------
  bool splashSeen = false;
  ThemeMode themeMode = ThemeMode.dark;
  UserRole? role;
  Customer? customer;
  Worker? meWorker;
  Student? meStudent;
  int tab = 0;
  String? discoverCategory;

  final accounts = <Account>[];
  final workers = <Worker>[];
  final bookings = <Booking>[];
  final notifications = <AppNotification>[];
  final studentJobs = <StudentJob>[];
  final applications = <JobApplication>[];

  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  final Map<String, List<Timer>> _timers = {};
  int _seq = 100;
  bool _demoDeclineUsed = false;
  bool _disposed = false;
  final _rng = Random(7);

  @override
  void dispose() {
    _disposed = true;
    for (final l in _timers.values) {
      for (final t in l) {
        t.cancel();
      }
    }
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  // ---- helpers -------------------------------------------------------------
  String _id(String p) => '$p${_seq++}';

  Duration _d(int secs) => Duration(milliseconds: fastTiming ? secs * 350 : secs * 1000);

  void _later(String key, int secs, VoidCallback f) {
    final t = Timer(_d(secs), () {
      if (_disposed) return;
      f();
    });
    (_timers[key] ??= []).add(t);
  }

  void _clear(String key) {
    for (final t in _timers.remove(key) ?? <Timer>[]) {
      t.cancel();
    }
  }

  void toast(String msg, {bool error = false}) {
    final m = messengerKey.currentState;
    if (m == null) return;
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(
      content: Row(children: [
        Icon(error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: error ? Brand.danger : Brand.success, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: Brand.indigo,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rd.m)),
      duration: const Duration(seconds: 3),
    ));
  }

  void update(VoidCallback f) {
    f();
    notifyListeners();
  }

  void markSplashSeen() {
    splashSeen = true;
    notifyListeners();
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void openDiscover({String? categoryId}) {
    discoverCategory = categoryId;
    tab = 1;
    notifyListeners();
  }

  String? takeDiscoverCategory() {
    final c = discoverCategory;
    discoverCategory = null;
    return c;
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    notifyListeners();
  }

  void setDemo({bool? auto, bool? fast, DemoWorkerMode? mode, ForcedOutcome? forced}) {
    if (auto != null) autoRespond = auto;
    if (fast != null) fastTiming = fast;
    if (mode != null) workerMode = mode;
    if (forced != null) outcome = forced;
    notifyListeners();
  }

  // ---- seed ----------------------------------------------------------------
  void _seed() {
    workers.addAll(buildMockWorkers());
    studentJobs.addAll(buildStudentJobs());

    final c = Customer(
      id: 'c_demo',
      name: 'Aarav Menon',
      phone: '9000000001',
      email: 'aarav@demo.worklink',
      areaName: kAreas[0].name,
      location: kAreas[0].center,
      phoneVerified: true,
      address: 'Flat 4B, Lake View Apartments',
    );
    accounts.add(Account(role: UserRole.customer, email: c.email, phone: c.phone, password: 'demo123', demo: true, customer: c));

    final me = Worker(
      id: 'w_demo',
      name: 'Arjun Prasad',
      categoryId: 'electrician',
      skills: ['Wiring', 'Fan repair', 'Switchboards', 'Lighting'],
      years: 7,
      rating: 4.7,
      reviewCount: 58,
      price: 380,
      unit: 'visit',
      verification: Verification.verified,
      available: true,
      location: GeoPoint(kAreas[0].center.lat + 0.004, kAreas[0].center.lng + 0.003),
      areas: ['Velachery', 'Guindy'],
      bio: 'Residential electrician focused on safe, tidy wiring and quick fault-finding.',
      jobsDone: 143,
      portfolio: [const PortfolioItem('Full flat rewiring', '2BHK rewiring with new MCB board (sample).', Icons.electrical_services_rounded)],
      reviews: [
        Review(author: 'Divya S.', rating: 5, text: 'Found the fault in minutes. Very tidy work.', date: DateTime.now().subtract(const Duration(days: 9))),
        Review(author: 'Mohan L.', rating: 4, text: 'On time and fair price.', date: DateTime.now().subtract(const Duration(days: 25))),
      ],
      seed: 21,
      human: true,
      phone: '9000000002',
    );
    workers.add(me);
    accounts.add(Account(role: UserRole.worker, email: 'arjun@demo.worklink', phone: me.phone, password: 'demo123', demo: true, worker: me));

    final s = Student(
      id: 's_demo',
      name: 'Nisha Raman',
      phone: '9000000003',
      email: 'nisha@demo.worklink',
      college: 'Demo Institute of Technology',
      course: 'B.Com',
      year: '2nd year',
      verification: Verification.verified,
      interests: {'Tutoring', 'Data entry'},
      slots: {'Sat·Morning', 'Sat·Afternoon', 'Wed·Evening'},
    );
    accounts.add(Account(role: UserRole.student, email: s.email, phone: s.phone, password: 'demo123', demo: true, student: s));

    _reanchor();

    // Seeded history so dashboards are not empty (all simulated).
    _seedDone(c, workerById('w01')!, 'Ceiling fan wiring replaced', 420, 12, 5, 'Ravi was quick and tidy.');
    _seedDone(c, workerById('w12')!, 'Kitchen tap leak', 330, 31, 5, 'Fixed on the first visit.');
    _seedDone(c, me, 'Switchboard repair', 450, 5, 5, 'Safe work, explained everything.');
    const mock = [
      ('Meera Krishnan', 600, 2),
      ('Sanjay Patel', 380, 3),
      ('Lakshmi Iyer', 850, 4),
      ('Bala Murugan', 520, 6),
      ('Rekha Das', 700, 8),
    ];
    for (final m in mock) {
      final b = Booking(
        id: _id('BK'),
        customerId: 'mock_${m.$1.split(' ').first.toLowerCase()}',
        customerName: m.$1,
        customerArea: 'Velachery',
        customerLoc: kAreas[0].center,
        workerId: me.id,
        categoryId: 'electrician',
        details: 'Routine electrical job (sample history).',
        address: 'Velachery (sample)',
        schedule: 'Completed',
        createdAt: DateTime.now().subtract(Duration(days: m.$3)),
        status: BookingStatus.completed,
        agreedPrice: m.$2,
        paid: true,
        rating: 5,
        doneAt: DateTime.now().subtract(Duration(days: m.$3)),
      );
      b.offers.add(Offer(Party.customer, m.$2));
      bookings.add(b);
    }
  }

  void _seedDone(Customer c, Worker w, String title, int price, int daysAgo, int rating, String review) {
    final when = DateTime.now().subtract(Duration(days: daysAgo));
    final b = Booking(
      id: _id('BK'),
      customerId: c.id,
      customerName: c.name,
      customerArea: c.areaName,
      customerLoc: c.location,
      workerId: w.id,
      categoryId: w.categoryId,
      details: title,
      address: c.address,
      schedule: 'Completed',
      createdAt: when,
      status: BookingStatus.completed,
      agreedPrice: price,
      paid: true,
      rating: rating,
      review: review,
      doneAt: when,
    );
    b.offers.add(Offer(Party.customer, price));
    bookings.add(b);
  }

  // ---- lookups -------------------------------------------------------------
  Worker? workerById(String id) {
    for (final w in workers) {
      if (w.id == id) return w;
    }
    return null;
  }

  Booking? bookingById(String id) {
    for (final b in bookings) {
      if (b.id == id) return b;
    }
    return null;
  }

  List<Booking> get customerBookings =>
      bookings.where((b) => b.customerId == customer?.id).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Booking> get workerBookings =>
      bookings.where((b) => b.workerId == meWorker?.id).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  GeoPoint get userLocation => customer?.location ?? kAreas.first.center;

  void _reanchor() {
    final a = userLocation;
    for (final w in workers) {
      if (!w.human) w.location = GeoPoint(a.lat + w.offset.lat, a.lng + w.offset.lng);
    }
  }

  void setCustomerArea(Area area) {
    final c = customer;
    if (c == null) return;
    c.areaName = area.name;
    c.location = area.center;
    _reanchor();
    notifyListeners();
  }

  /// Ranks workers by distance from the customer's (mock) location.
  List<RankedWorker> rank({
    String? categoryId,
    bool availableOnly = false,
    bool verifiedOnly = false,
    double maxKm = 25,
    String query = '',
  }) {
    final from = userLocation;
    final q = query.trim().toLowerCase();
    final out = <RankedWorker>[];
    for (final w in workers) {
      if (w.verification == Verification.rejected) continue;
      if (categoryId != null && w.categoryId != categoryId) continue;
      if (availableOnly && !w.available) continue;
      if (verifiedOnly && w.verification != Verification.verified) continue;
      if (q.isNotEmpty) {
        final hay = '${w.name} ${categoryById(w.categoryId).name} ${w.skills.join(' ')}'.toLowerCase();
        if (!hay.contains(q)) continue;
      }
      final km = distanceKm(from, w.location);
      if (km > maxKm) continue;
      out.add(RankedWorker(w, km, etaMinutes(km)));
    }
    out.sort((a, b) => a.km.compareTo(b.km));
    return out;
  }

  /// Workers suitable for "request nearest": available, verified, right category.
  List<RankedWorker> eligibleFor(String categoryId) =>
      rank(categoryId: categoryId, availableOnly: true, verifiedOnly: true);

  // ---- notifications -------------------------------------------------------
  void _notify(UserRole r, String title, String body, {String? bookingId}) {
    notifications.insert(0, AppNotification(_id('n'), r, title, body, bookingId: bookingId));
    if (role == r) toast(title);
  }

  List<AppNotification> notificationsFor(UserRole r) => notifications.where((n) => n.role == r).toList();
  int unread(UserRole r) => notifications.where((n) => n.role == r && !n.read).length;

  void markAllRead(UserRole r) {
    for (final n in notifications) {
      if (n.role == r) n.read = true;
    }
    notifyListeners();
  }

  // ---- auth ----------------------------------------------------------------
  Account? findAccount(UserRole r, String login, String pw) {
    final l = login.trim().toLowerCase();
    for (final a in accounts) {
      if (a.role == r && a.password == pw && (a.email.toLowerCase() == l || a.phone == l)) return a;
    }
    return null;
  }

  bool login(UserRole r, String login, String pw) {
    final a = findAccount(r, login, pw);
    if (a == null) return false;
    _enter(a);
    return true;
  }

  void loginDemo(UserRole r) => _enter(accounts.firstWhere((a) => a.role == r && a.demo));

  void _enter(Account a) {
    role = a.role;
    customer = a.customer;
    meWorker = a.worker;
    meStudent = a.student;
    tab = 0;
    _reanchor();
    notifyListeners();
  }

  void logout() {
    role = null;
    customer = null;
    meWorker = null;
    meStudent = null;
    tab = 0;
    notifyListeners();
  }

  bool accountExists(UserRole r, String email, String phone) => accounts.any(
      (a) => a.role == r && (a.email.toLowerCase() == email.trim().toLowerCase() || a.phone == phone.trim()));

  Customer registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required Area area,
  }) {
    final c = Customer(
      id: _id('c'),
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      areaName: area.name,
      location: area.center,
      phoneVerified: true,
    );
    final a = Account(role: UserRole.customer, email: c.email, phone: c.phone, password: password, customer: c);
    accounts.add(a);
    _enter(a);
    _notify(UserRole.customer, 'Welcome to ${AppConfig.brand}', 'Account created. Phone verified with a simulated OTP.');
    return c;
  }

  Worker registerWorker({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String categoryId,
    required int years,
    required List<String> skills,
    required List<String> areaNames,
    required int price,
    required String unit,
    required String bio,
  }) {
    final area = kAreas.firstWhere((a) => areaNames.contains(a.name), orElse: () => kAreas.first);
    final w = Worker(
      id: _id('w'),
      name: name.trim(),
      categoryId: categoryId,
      skills: skills,
      years: years,
      rating: 0,
      reviewCount: 0,
      price: price,
      unit: unit,
      verification: Verification.notStarted,
      available: true,
      location: GeoPoint(area.center.lat + 0.003, area.center.lng - 0.002),
      areas: areaNames,
      bio: bio.trim(),
      jobsDone: 0,
      seed: _seq,
      human: true,
      phone: phone.trim(),
    );
    workers.add(w);
    final a = Account(role: UserRole.worker, email: email.trim(), phone: phone.trim(), password: password, worker: w);
    accounts.add(a);
    _enter(a);
    submitVerification(UserRole.worker);
    return w;
  }

  Student registerStudent({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String college,
    required String course,
    required String year,
    required Set<String> interests,
    required Set<String> slots,
  }) {
    final s = Student(
      id: _id('s'),
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      college: college.trim(),
      course: course.trim(),
      year: year,
      interests: interests,
      slots: slots,
    );
    final a = Account(role: UserRole.student, email: s.email, phone: s.phone, password: password, student: s);
    accounts.add(a);
    _enter(a);
    submitVerification(UserRole.student);
    return s;
  }

  // ---- verification (simulated KYC) ---------------------------------------
  Verification verificationOf(UserRole r) {
    switch (r) {
      case UserRole.worker:
        return meWorker?.verification ?? Verification.notStarted;
      case UserRole.student:
        return meStudent?.verification ?? Verification.notStarted;
      case UserRole.customer:
        return customer?.phoneVerified == true ? Verification.verified : Verification.notStarted;
    }
  }

  String? verifyNoteOf(UserRole r) => r == UserRole.worker ? meWorker?.verifyNote : meStudent?.verifyNote;

  void _setVerification(UserRole r, Verification v, {String? note}) {
    if (r == UserRole.worker && meWorker != null) {
      meWorker!.verification = v;
      meWorker!.verifyNote = note;
      if (v == Verification.rejected) meWorker!.available = false;
    } else if (r == UserRole.student && meStudent != null) {
      meStudent!.verification = v;
      meStudent!.verifyNote = note;
    }
    notifyListeners();
  }

  /// Uploading a document never makes anyone "verified": it only starts a simulated review.
  void submitVerification(UserRole r) {
    _setVerification(r, Verification.pending, note: 'Simulated admin review in progress.');
    _notify(r, 'Verification submitted', 'A simulated admin review has started. No real documents are stored.');
    final key = 'verify_${r.name}';
    _clear(key);
    _later(key, 5, () => _resolveVerification(r));
  }

  void _resolveVerification(UserRole r) {
    if (verificationOf(r) != Verification.pending) return;
    switch (outcome) {
      case ForcedOutcome.verified:
        _setVerification(r, Verification.verified, note: 'Approved by simulated admin review.');
        _notify(r, 'You are verified (simulated)', 'Your profile now shows the verified badge.');
        break;
      case ForcedOutcome.rejected:
        _setVerification(r, Verification.rejected, note: 'Document image unclear (simulated reason). Please re-submit.');
        _notify(r, 'Verification rejected (simulated)', 'Re-submit your documents from the verification screen.');
        break;
      case ForcedOutcome.pending:
        _setVerification(r, Verification.pending, note: 'Held for manual review (simulated). Use demo controls to change.');
        break;
    }
  }

  /// Demo-only admin override.
  void forceVerification(UserRole r, Verification v) {
    _clear('verify_${r.name}');
    final note = v == Verification.rejected
        ? 'Rejected by demo admin override (simulated).'
        : v == Verification.verified
            ? 'Approved by demo admin override (simulated).'
            : 'Set to pending by demo admin override.';
    _setVerification(r, v, note: note);
    _notify(r, 'Verification ${v.label.toLowerCase()} (simulated)', note);
  }

  // ---- worker availability / profile --------------------------------------
  bool setAvailability(bool v) {
    final w = meWorker;
    if (w == null) return false;
    if (v && w.verification == Verification.rejected) {
      toast('Verification was rejected. Re-submit documents to go online.', error: true);
      return false;
    }
    w.available = v;
    notifyListeners();
    return true;
  }

  // ---- bookings & negotiation ---------------------------------------------
  Booking createBooking({
    required String categoryId,
    Worker? worker,
    required String details,
    required String address,
    required String schedule,
    required int offer,
    bool viaNearest = false,
  }) {
    final c = customer!;
    final cands = viaNearest
        ? eligibleFor(categoryId).map((r) => r.worker.id).toList()
        : <String>[worker!.id];
    final b = Booking(
      id: _id('BK'),
      customerId: c.id,
      customerName: c.name,
      customerArea: c.areaName,
      customerLoc: c.location,
      workerId: cands.first,
      categoryId: categoryId,
      details: details.trim(),
      address: address.trim(),
      schedule: schedule,
      createdAt: DateTime.now(),
      status: BookingStatus.awaitingWorker,
      candidates: cands,
      viaNearest: viaNearest,
    );
    b.offers.add(Offer(Party.customer, offer, note: 'Initial offer'));
    b.times[BookingStatus.awaitingWorker] = DateTime.now();
    bookings.insert(0, b);
    _dispatch(b);
    notifyListeners();
    return b;
  }

  void _dispatch(Booking b) {
    final w = workerById(b.workerId)!;
    b.distanceKm = distanceKm(b.customerLoc, w.location);
    b.etaMin = etaMinutes(b.distanceKm);
    if (w.human) {
      _notify(UserRole.worker, 'New job request',
          '${b.customerName} - ${categoryById(b.categoryId).name} - offer ${rupees(b.offers.last.amount)}',
          bookingId: b.id);
      return;
    }
    if (!autoRespond) return;
    if (workerMode == DemoWorkerMode.noResponse) {
      _later(b.id, 14, () => _decline(b, 'No response from ${w.name} (timed out)'));
    } else {
      _later(b.id, 4 + _rng.nextInt(3), () => _autoRespond(b.id));
    }
  }

  int _counterAmount(int offer, int ref) {
    final raw = round10(offer + (ref - offer) * 0.7);
    return max(offer + 10, min(ref, raw));
  }

  void _autoRespond(String id) {
    final b = bookingById(id);
    if (b == null || b.status != BookingStatus.awaitingWorker) return;
    final w = workerById(b.workerId);
    if (w == null || w.human) return;
    final amount = b.lastOffer!.amount;
    final lastW = b.lastWorkerOffer?.amount;
    final ref = lastW ?? w.price;
    final rounds = b.offers.where((o) => o.by == Party.worker).length;

    switch (workerMode) {
      case DemoWorkerMode.alwaysAccept:
        _confirm(b, amount);
        return;
      case DemoWorkerMode.alwaysDecline:
        _decline(b, 'Busy with another job');
        return;
      case DemoWorkerMode.alwaysCounter:
        if (rounds >= 2 || amount >= ref) {
          _confirm(b, amount);
        } else {
          _workerCounters(b, w, max(ref, amount + 10), 'My usual rate for this job.');
        }
        return;
      case DemoWorkerMode.noResponse:
        return;
      case DemoWorkerMode.mixed:
        if (b.viaNearest && b.candidateIndex == 0 && !_demoDeclineUsed && b.candidates.length > 1) {
          _demoDeclineUsed = true;
          _decline(b, 'Busy on another job');
          return;
        }
        if (amount >= ref * 0.9) {
          _confirm(b, amount);
        } else if (amount >= w.price * 0.55 && rounds < 2) {
          _workerCounters(b, w, _counterAmount(amount, ref), 'I can do it for this. Materials are included.');
        } else {
          _decline(b, 'The offer is too low for this job');
        }
        return;
    }
  }

  void _workerCounters(Booking b, Worker w, int amount, String note) {
    b.offers.add(Offer(Party.worker, amount, note: note));
    b.status = BookingStatus.counterReceived;
    b.times[BookingStatus.counterReceived] = DateTime.now();
    _notify(UserRole.customer, 'Counteroffer from ${w.name}', 'They proposed ${rupees(amount)}.', bookingId: b.id);
    notifyListeners();
  }

  void _decline(Booking b, String reason) {
    if (!b.status.isNegotiating) return;
    b.status = BookingStatus.rejected;
    b.rejectReason = reason;
    b.times[BookingStatus.rejected] = DateTime.now();
    _clear(b.id);
    final w = workerById(b.workerId);
    _notify(UserRole.customer, 'Request declined', '${w?.name ?? 'The worker'}: $reason', bookingId: b.id);
    notifyListeners();
  }

  void _confirm(Booking b, int amount) {
    if (!b.status.isNegotiating) return;
    _clear(b.id);
    final w = workerById(b.workerId)!;
    b.agreedPrice = amount;
    b.status = BookingStatus.confirmed;
    b.times[BookingStatus.confirmed] = DateTime.now();
    b.chat.add(ChatMsg('system', 'Booking confirmed at ${rupees(amount)} (simulated). You can chat here.'));
    _notify(UserRole.customer, 'Booking confirmed', '${w.name} accepted at ${rupees(amount)}.', bookingId: b.id);
    _notify(UserRole.worker, 'Job confirmed', '${b.customerName} - ${rupees(amount)}', bookingId: b.id);
    if (!w.human && autoRespond) {
      _later(b.id, 6, () => _advance(b.id, BookingStatus.confirmed, BookingStatus.onTheWay));
      _later(b.id, 14, () => _advance(b.id, BookingStatus.onTheWay, BookingStatus.workStarted));
      _later(b.id, 22, () => _advance(b.id, BookingStatus.workStarted, BookingStatus.completed));
    }
    notifyListeners();
  }

  void _advance(String id, BookingStatus from, BookingStatus to) {
    final b = bookingById(id);
    if (b == null || b.status != from) return;
    b.status = to;
    b.times[to] = DateTime.now();
    final w = workerById(b.workerId);
    switch (to) {
      case BookingStatus.onTheWay:
        _notify(UserRole.customer, '${w?.name ?? 'Worker'} is on the way', 'ETA about ${b.etaMin} min (simulated).', bookingId: b.id);
        break;
      case BookingStatus.workStarted:
        _notify(UserRole.customer, 'Work started', 'Your ${categoryById(b.categoryId).name.toLowerCase()} job is in progress.', bookingId: b.id);
        break;
      case BookingStatus.completed:
        b.doneAt = DateTime.now();
        w?.jobsDone += 1;
        _notify(UserRole.customer, 'Job completed', 'Pay ${rupees(b.shownPrice)} (simulated) and leave a review.', bookingId: b.id);
        _notify(UserRole.worker, 'Job completed', '${rupees(b.shownPrice)} added to earnings (simulated).', bookingId: b.id);
        if (b.customerId.startsWith('mock_') && autoRespond) {
          _later(b.id, 3, () => payBooking(b.id, silent: true));
        }
        break;
      default:
        break;
    }
    notifyListeners();
  }

  // customer actions
  void customerAcceptCounter(String id) {
    final b = bookingById(id);
    if (b == null || b.status != BookingStatus.counterReceived) return;
    _confirm(b, b.lastWorkerOffer!.amount);
  }

  void customerCounter(String id, int amount, {String note = ''}) {
    final b = bookingById(id);
    if (b == null || !b.status.isNegotiating) return;
    b.offers.add(Offer(Party.customer, amount, note: note));
    b.status = BookingStatus.awaitingWorker;
    b.times[BookingStatus.awaitingWorker] = DateTime.now();
    _dispatch(b);
    notifyListeners();
  }

  void customerDecline(String id) {
    final b = bookingById(id);
    if (b == null) return;
    _decline(b, 'You declined the counteroffer');
  }

  Worker? nextCandidate(Booking b) {
    final i = b.candidateIndex + 1;
    if (!b.viaNearest || i >= b.candidates.length) return null;
    final w = workerById(b.candidates[i]);
    return (w != null && w.available) ? w : null;
  }

  void sendToNextCandidate(String id) {
    final b = bookingById(id);
    if (b == null) return;
    final next = nextCandidate(b);
    if (next == null) return;
    final first = b.firstCustomerOffer ?? b.offers.first;
    b.candidateIndex += 1;
    b.workerId = next.id;
    b.offers
      ..clear()
      ..add(first);
    b.rejectReason = null;
    b.status = BookingStatus.awaitingWorker;
    b.times[BookingStatus.awaitingWorker] = DateTime.now();
    _dispatch(b);
    notifyListeners();
  }

  // worker actions (human worker account)
  void workerAccept(String id) {
    final b = bookingById(id);
    if (b == null || b.status != BookingStatus.awaitingWorker) return;
    _confirm(b, b.lastOffer!.amount);
  }

  void workerCounter(String id, int amount, {String note = ''}) {
    final b = bookingById(id);
    final w = meWorker;
    if (b == null || w == null || b.status != BookingStatus.awaitingWorker) return;
    _workerCounters(b, w, amount, note.isEmpty ? 'Counteroffer' : note);
    if (b.customerId.startsWith('mock_') && autoRespond) {
      _later(b.id, 5, () => _mockCustomerRespond(b.id));
    }
  }

  void _mockCustomerRespond(String id) {
    final b = bookingById(id);
    if (b == null || b.status != BookingStatus.counterReceived) return;
    final first = b.firstCustomerOffer?.amount ?? 0;
    final c = b.lastWorkerOffer!.amount;
    if (c <= first * 1.3) {
      _confirm(b, c);
    } else {
      b.status = BookingStatus.cancelled;
      b.times[BookingStatus.cancelled] = DateTime.now();
      _notify(UserRole.worker, 'Customer declined your counteroffer', '${b.customerName} cancelled the request.', bookingId: b.id);
      notifyListeners();
    }
  }

  void workerDecline(String id, {String reason = 'Not available for this job'}) {
    final b = bookingById(id);
    if (b == null) return;
    _decline(b, reason);
  }

  void workerAdvance(String id) {
    final b = bookingById(id);
    if (b == null) return;
    switch (b.status) {
      case BookingStatus.confirmed:
        _advance(id, BookingStatus.confirmed, BookingStatus.onTheWay);
        break;
      case BookingStatus.onTheWay:
        _advance(id, BookingStatus.onTheWay, BookingStatus.workStarted);
        break;
      case BookingStatus.workStarted:
        _advance(id, BookingStatus.workStarted, BookingStatus.completed);
        break;
      default:
        break;
    }
  }

  void cancelBooking(String id, Party by, {String? reason}) {
    final b = bookingById(id);
    if (b == null || !b.status.isActive || b.status == BookingStatus.workStarted) return;
    _clear(b.id);
    b.status = BookingStatus.cancelled;
    b.rejectReason = reason ?? (by == Party.customer ? 'Cancelled by customer' : 'Cancelled by worker');
    b.times[BookingStatus.cancelled] = DateTime.now();
    if (by == Party.customer) {
      final w = workerById(b.workerId);
      if (w?.human == true) _notify(UserRole.worker, 'Request cancelled', '${b.customerName} cancelled.', bookingId: b.id);
    } else {
      _notify(UserRole.customer, 'Booking cancelled by worker', b.rejectReason!, bookingId: b.id);
    }
    notifyListeners();
  }

  void payBooking(String id, {bool silent = false}) {
    final b = bookingById(id);
    if (b == null || b.status != BookingStatus.completed || b.paid) return;
    b.paid = true;
    final w = workerById(b.workerId);
    if (w?.human == true) {
      _notify(UserRole.worker, 'Payment received (simulated)', '${rupees(b.shownPrice)} from ${b.customerName}.', bookingId: b.id);
    }
    if (!silent) toast('Payment of ${rupees(b.shownPrice)} recorded (simulated)');
    notifyListeners();
  }

  void submitReview(String id, int stars, String text) {
    final b = bookingById(id);
    final w = b == null ? null : workerById(b.workerId);
    if (b == null || w == null || b.rating != null) return;
    b.rating = stars;
    b.review = text.trim();
    w.reviews.insert(0, Review(author: b.customerName, rating: stars, text: text.trim().isEmpty ? 'Great service.' : text.trim(), date: DateTime.now()));
    w.rating = ((w.rating * w.reviewCount) + stars) / (w.reviewCount + 1);
    w.reviewCount += 1;
    if (w.human) _notify(UserRole.worker, 'New review', '${b.customerName} gave $stars stars.', bookingId: b.id);
    toast('Thanks for your review');
    notifyListeners();
  }

  // chat
  void sendMessage(String id, Party from, String text) {
    final b = bookingById(id);
    if (b == null || text.trim().isEmpty) return;
    b.chat.add(ChatMsg(from == Party.customer ? 'customer' : 'worker', text.trim()));
    final w = workerById(b.workerId);
    if (autoRespond && b.status.isActive) {
      if (from == Party.customer && w != null && !w.human) {
        b.typing = true;
        _later('chat_${b.id}', 3, () {
          b.typing = false;
          b.chat.add(ChatMsg('worker', _workerReply(text, b)));
          notifyListeners();
        });
      } else if (from == Party.worker && b.customerId.startsWith('mock_')) {
        b.typing = true;
        _later('chat_${b.id}', 3, () {
          b.typing = false;
          b.chat.add(ChatMsg('customer', 'Thanks! The address is correct. Please call when you reach the gate.'));
          notifyListeners();
        });
      }
    }
    notifyListeners();
  }

  String _workerReply(String q, Booking b) {
    final t = q.toLowerCase();
    if (t.contains('where') || t.contains('eta') || t.contains('when')) {
      return b.status == BookingStatus.onTheWay ? 'I am on the way, about ${max(3, b.etaMin - 6)} minutes out.' : 'I will start travel at the scheduled time.';
    }
    if (t.contains('price') || t.contains('final')) return 'The agreed price stays the same unless extra material is needed.';
    if (t.contains('earlier')) return 'I will try. Let me check my previous job.';
    return 'Got it. See you at the scheduled time.';
  }

  // incoming request simulator for the worker role
  static const _customers = ['Meera Krishnan', 'Sanjay Patel', 'Lakshmi Iyer', 'Bala Murugan'];
  int _incoming = 0;

  void simulateIncomingRequest() {
    final w = meWorker;
    if (w == null) return;
    final cat = categoryById(w.categoryId);
    final name = _customers[_incoming % _customers.length];
    final b = Booking(
      id: _id('BK'),
      customerId: 'mock_${name.split(' ').first.toLowerCase()}',
      customerName: name,
      customerArea: kAreas[_incoming % kAreas.length].name,
      customerLoc: kAreas[_incoming % kAreas.length].center,
      workerId: w.id,
      categoryId: w.categoryId,
      details: 'Need a ${cat.name.toLowerCase()} for a small home job. Please bring basic tools. (simulated request)',
      address: '${kAreas[_incoming % kAreas.length].name} (sample address)',
      schedule: _incoming.isEven ? 'ASAP' : 'Today evening',
      createdAt: DateTime.now(),
      status: BookingStatus.awaitingWorker,
      candidates: [w.id],
    );
    _incoming++;
    b.offers.add(Offer(Party.customer, round10(w.price * (0.75 + 0.05 * (_incoming % 3))), note: 'Initial offer'));
    b.times[BookingStatus.awaitingWorker] = DateTime.now();
    b.distanceKm = 1.2 + _incoming * 0.7;
    b.etaMin = etaMinutes(b.distanceKm);
    bookings.insert(0, b);
    _notify(UserRole.worker, 'New job request', '$name - ${rupees(b.offers.last.amount)} offer', bookingId: b.id);
    notifyListeners();
  }

  // earnings
  List<Booking> get workerDone =>
      workerBookings.where((b) => b.status == BookingStatus.completed).toList();

  int get workerTotalEarned => workerDone.fold(0, (s, b) => s + b.shownPrice);

  int workerEarnedSince(Duration d) {
    final cut = DateTime.now().subtract(d);
    return workerDone.where((b) => (b.doneAt ?? b.createdAt).isAfter(cut)).fold(0, (s, b) => s + b.shownPrice);
  }

  /// Totals for the last 7 days, oldest first.
  List<int> workerDailyTotals() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final next = day.add(const Duration(days: 1));
      return workerDone.where((b) {
        final t = b.doneAt ?? b.createdAt;
        return !t.isBefore(day) && t.isBefore(next);
      }).fold(0, (s, b) => s + b.shownPrice);
    });
  }

  // ---- student -------------------------------------------------------------
  StudentJob? jobById(String id) {
    for (final j in studentJobs) {
      if (j.id == id) return j;
    }
    return null;
  }

  JobApplication? applicationFor(String jobId) {
    for (final a in applications) {
      if (a.jobId == jobId && a.status != AppStatus.withdrawn) return a;
    }
    return null;
  }

  void applyToJob(StudentJob j) {
    if (applicationFor(j.id) != null) return;
    final a = JobApplication(_id('AP'), j.id, AppStatus.applied, DateTime.now());
    applications.insert(0, a);
    _notify(UserRole.student, 'Application sent', '${j.title} at ${j.business}');
    if (autoRespond) {
      _later(a.id, 5, () {
        if (a.status == AppStatus.applied) {
          a.status = AppStatus.shortlisted;
          _notify(UserRole.student, 'You were shortlisted', '${j.business} wants to talk (simulated).');
          notifyListeners();
        }
      });
      _later(a.id, 11, () {
        if (a.status == AppStatus.shortlisted) {
          a.status = AppStatus.hired;
          _notify(UserRole.student, 'You got the job (simulated)', '${j.title} - ${j.schedule}');
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void withdrawApplication(String appId) {
    for (final a in applications) {
      if (a.id == appId && (a.status == AppStatus.applied || a.status == AppStatus.shortlisted)) {
        a.status = AppStatus.withdrawn;
        _clear(a.id);
      }
    }
    notifyListeners();
  }

  void completeShift(String appId) {
    for (final a in applications) {
      if (a.id == appId && a.status == AppStatus.hired) {
        a.status = AppStatus.completed;
        final j = jobById(a.jobId);
        _notify(UserRole.student, 'Shift completed (simulated)', '${rupees(j?.pay ?? 0)} added to earnings.');
      }
    }
    notifyListeners();
  }

  int get studentEarned => applications
      .where((a) => a.status == AppStatus.completed)
      .fold(0, (s, a) => s + (jobById(a.jobId)?.pay ?? 0));

  void toggleSlot(String slot) {
    final s = meStudent;
    if (s == null) return;
    s.slots.contains(slot) ? s.slots.remove(slot) : s.slots.add(slot);
    notifyListeners();
  }
}