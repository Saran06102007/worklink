import 'package:flutter_test/flutter_test.dart';
import 'package:worklink/data/mock_data.dart';
import 'package:worklink/models/models.dart';
import 'package:worklink/state/app_state.dart';

void main() {
  AppState _manual() => AppState(autoRespond: false, fastTiming: true);

  test('demo login enters customer role', () {
    final s = _manual();
    s.loginDemo(UserRole.customer);
    expect(s.role, UserRole.customer);
    expect(s.customer, isNotNull);
    s.dispose();
  });

  test('rank returns workers sorted by distance', () {
    final s = _manual()..loginDemo(UserRole.customer);
    final ranked = s.rank(categoryId: 'electrician', availableOnly: true);
    expect(ranked, isNotEmpty);
    for (var i = 1; i < ranked.length; i++) {
      expect(ranked[i].km >= ranked[i - 1].km, isTrue);
    }
    s.dispose();
  });

  test('changing area re-anchors mock workers', () {
    final s = _manual()..loginDemo(UserRole.customer);
    const area = Area('Adyar', GeoPoint(13.0067, 80.2570));
    s.setCustomerArea(area);
    expect(s.customer!.areaName, 'Adyar');
    final w = s.workerById('w01')!;
    expect(w.location.lat, closeTo(area.center.lat + w.offset.lat, 1e-9));
    s.dispose();
  });

  test('create booking starts awaiting worker', () {
    final s = _manual()..loginDemo(UserRole.customer);
    final w = s.workerById('w01')!;
    final b = s.createBooking(
      categoryId: w.categoryId,
      worker: w,
      details: 'Fix ceiling fan switch',
      address: 'Lake View',
      schedule: 'ASAP',
      offer: 400,
    );
    expect(b.status, BookingStatus.awaitingWorker);
    expect(s.customerBookings, isNotEmpty);
    s.dispose();
  });

  test('worker accept confirms booking', () {
    final s = _manual()..loginDemo(UserRole.worker);
    s.simulateIncomingRequest();
    final b = s.workerBookings.first;
    s.workerAccept(b.id);
    expect(s.bookingById(b.id)!.status, BookingStatus.confirmed);
    s.dispose();
  });
}
