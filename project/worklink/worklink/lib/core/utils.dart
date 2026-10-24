import 'dart:math';

import '../models/models.dart';

double _rad(double d) => d * pi / 180;

double distanceKm(GeoPoint a, GeoPoint b) {
  const r = 6371.0;
  final dLat = _rad(b.lat - a.lat);
  final dLng = _rad(b.lng - a.lng);
  final h = pow(sin(dLat / 2), 2) + cos(_rad(a.lat)) * cos(_rad(b.lat)) * pow(sin(dLng / 2), 2);
  return 2 * r * asin(min(1.0, sqrt(h)));
}

int etaMinutes(double km) => max(8, (km / 22 * 60).round() + 6);

String distLabel(double km) => km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

String rupees(num n) {
  final s = n.round().abs().toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}\u20B9$out';
}

String clock(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
}

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 45) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  if (d.inDays == 1) return 'yesterday';
  return '${d.inDays} days ago';
}

int round10(num x) => (x / 10).round() * 10;

String? vRequired(String? v, [String label = 'This field']) =>
    (v == null || v.trim().isEmpty) ? '$label is required' : null;
String? vName(String? v) => (v == null || v.trim().length < 2) ? 'Enter your full name' : null;
String? vPhone(String? v) => RegExp(r'^[6-9]\d{9}$').hasMatch((v ?? '').trim()) ? null : 'Enter a 10-digit mobile number';
String? vEmail(String? v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim()) ? null : 'Enter a valid email address';
String? vPassword(String? v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null;
String? Function(String?) vMin(int n, String what) =>
    (v) => (v == null || v.trim().length < n) ? '$what must be at least $n characters' : null;
String? vAmount(String? v) {
  final n = int.tryParse((v ?? '').trim());
  return (n == null || n < 50 || n > 20000) ? 'Enter an amount between 50 and 20,000' : null;
}