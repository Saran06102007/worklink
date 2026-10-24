import 'package:flutter_test/flutter_test.dart';
import 'package:worklink/core/utils.dart';
import 'package:worklink/models/models.dart';

void main() {
  test('distanceKm is zero for same point', () {
    const a = GeoPoint(12.98, 80.22);
    expect(distanceKm(a, a), closeTo(0, 1e-9));
  });

  test('rupees formats with commas', () {
    expect(rupees(1250), contains('1,250'));
    expect(rupees(350), contains('350'));
  });

  test('phone validator', () {
    expect(vPhone('9000000001'), isNull);
    expect(vPhone('123'), isNotNull);
  });
}
