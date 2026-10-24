import 'package:flutter/material.dart';

import '../models/models.dart';

const kCategories = <ServiceCategory>[
  ServiceCategory('electrician', 'Electrician', Icons.electrical_services_rounded, 350, 'visit', 'Wiring, fans, switches'),
  ServiceCategory('plumber', 'Plumber', Icons.plumbing_rounded, 300, 'visit', 'Leaks, taps, pipes'),
  ServiceCategory('carpenter', 'Carpenter', Icons.carpenter_rounded, 800, 'day', 'Furniture, doors, repairs'),
  ServiceCategory('painter', 'Painter', Icons.format_paint_rounded, 900, 'day', 'Walls, ceilings, touch-ups'),
  ServiceCategory('cleaner', 'Cleaner', Icons.cleaning_services_rounded, 250, 'hour', 'Deep and regular cleaning'),
  ServiceCategory('cook', 'Cook', Icons.restaurant_rounded, 450, 'hour', 'Home cooking, events'),
  ServiceCategory('maid', 'Maid', Icons.home_rounded, 200, 'hour', 'Daily household help'),
  ServiceCategory('appliance', 'Appliance Repair', Icons.build_circle_rounded, 400, 'visit', 'AC, washer, fridge'),
  ServiceCategory('gardener', 'Gardener', Icons.yard_rounded, 500, 'visit', 'Lawn, plants, pruning'),
];

ServiceCategory categoryById(String id) => kCategories.firstWhere((c) => c.id == id, orElse: () => kCategories.first);

const Map<String, List<String>> kSkills = {
  'electrician': ['Wiring', 'Fan repair', 'Switchboards', 'Inverter setup', 'Lighting', 'MCB / fuse'],
  'plumber': ['Leak repair', 'Tap fitting', 'Drain cleaning', 'Water tank', 'Bathroom fittings', 'Pipe laying'],
  'carpenter': ['Furniture repair', 'Door fitting', 'Modular units', 'Polishing', 'Wardrobes', 'Wood carving'],
  'painter': ['Interior', 'Exterior', 'Texture finish', 'Waterproofing', 'Wood polish', 'Touch-ups'],
  'cleaner': ['Deep cleaning', 'Kitchen', 'Bathroom', 'Sofa / carpet', 'Windows', 'Move-in cleaning'],
  'cook': ['South Indian', 'North Indian', 'Party catering', 'Tiffin', 'Baking', 'Vegan'],
  'maid': ['Sweeping & mopping', 'Dishes', 'Laundry', 'Elder care help', 'Child care help', 'Organising'],
  'appliance': ['AC service', 'Washing machine', 'Refrigerator', 'Microwave', 'Water purifier', 'TV'],
  'gardener': ['Lawn care', 'Pruning', 'Terrace garden', 'Pest control', 'Planting', 'Composting'],
};

/// Demo coordinates only. Workers are placed relative to the selected area.
const kAreas = <Area>[
  Area('Velachery', GeoPoint(12.9815, 80.2180)),
  Area('Adyar', GeoPoint(13.0067, 80.2570)),
  Area('T. Nagar', GeoPoint(13.0418, 80.2341)),
  Area('Tambaram', GeoPoint(12.9249, 80.1000)),
  Area('Guindy', GeoPoint(13.0067, 80.2206)),
  Area('Anna Nagar', GeoPoint(13.0850, 80.2101)),
];

const kSimulatedLocation = Area('Current location (simulated)', GeoPoint(12.9815, 80.2180));

const kStudentTypes = ['Tutoring', 'Events', 'Delivery', 'Data entry', 'Shop assistance'];
const kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const kSlots = ['Morning', 'Afternoon', 'Evening'];

List<Review> _reviews(int seed) {
  const names = ['Anitha R.', 'Vijay K.', 'Sneha P.', 'Rohit S.', 'Deepa M.', 'Karan T.', 'Meera V.'];
  const texts = [
    'Arrived on time and explained the work clearly before starting.',
    'Fair price and a neat finish. Would book again.',
    'Professional, polite and quick. Cleaned up after the job.',
    'Good work, took a little longer than estimated.',
    'Very reliable. Fixed the issue the same day.',
  ];
  return List.generate(
    3,
    (i) => Review(
      author: names[(seed + i * 2) % names.length],
      rating: i == 2 ? 4 : 5,
      text: texts[(seed + i) % texts.length],
      date: DateTime.now().subtract(Duration(days: 6 + i * 11 + seed)),
    ),
  );
}

List<PortfolioItem> _portfolio(String cat, int seed) {
  final c = categoryById(cat);
  return [
    PortfolioItem('${c.name} project #${seed + 1}', 'Residential job, completed with customer sign-off (sample).', c.icon),
    PortfolioItem('Apartment makeover', 'Multi-day job for a 2BHK home (sample entry).', Icons.apartment_rounded),
    PortfolioItem('Quick-fix package', 'Same-day repair visit (sample entry).', Icons.bolt_rounded),
  ];
}

Worker _w(int i, String name, String cat, int years, double rating, int reviews, int price, String unit,
    Verification v, bool avail, double dLat, double dLng, List<String> areas, String bio, int jobs) {
  final skills = kSkills[cat]!;
  return Worker(
    id: 'w${i.toString().padLeft(2, '0')}',
    name: name,
    categoryId: cat,
    skills: [skills[i % skills.length], skills[(i + 2) % skills.length], skills[(i + 4) % skills.length]],
    years: years,
    rating: rating,
    reviewCount: reviews,
    price: price,
    unit: unit,
    verification: v,
    available: avail,
    location: const GeoPoint(0, 0),
    offset: GeoPoint(dLat, dLng),
    areas: areas,
    bio: bio,
    jobsDone: jobs,
    portfolio: _portfolio(cat, i),
    reviews: _reviews(i),
    seed: i,
    phone: '90000${(10000 + i * 137).toString()}',
  );
}

List<Worker> buildMockWorkers() => [
      _w(1, 'Ravi Kumar', 'electrician', 8, 4.8, 124, 350, 'visit', Verification.verified, true, 0.006, -0.004,
          ['Velachery', 'Guindy'], 'Licensed-style residential electrician. Neat wiring, honest quotes and same-day visits.', 410),
      _w(2, 'Karthik Raja', 'plumber', 6, 4.6, 88, 300, 'visit', Verification.verified, true, 0.012, 0.010,
          ['Velachery', 'Adyar'], 'Leaks, fittings and bathroom work. Brings his own spares and cleans up after.', 296),
      _w(3, 'Suresh Babu', 'carpenter', 15, 4.9, 212, 800, 'day', Verification.verified, true, -0.014, 0.008,
          ['Adyar', 'T. Nagar'], 'Fifteen years of furniture repair and custom woodwork for homes.', 640),
      _w(4, 'Imran Sheikh', 'painter', 10, 4.7, 156, 900, 'day', Verification.verified, true, 0.020, -0.012,
          ['Guindy', 'Velachery'], 'Interior and exterior painting with clean masking and quick turnaround.', 331),
      _w(5, 'Priya Selvam', 'cleaner', 4, 4.5, 64, 250, 'hour', Verification.verified, true, -0.006, -0.011,
          ['Velachery', 'Tambaram'], 'Deep cleaning for kitchens, bathrooms and move-in homes.', 189),
      _w(6, 'Anbu Chelvan', 'cook', 12, 4.9, 301, 500, 'hour', Verification.verified, true, 0.009, 0.016,
          ['Adyar', 'Guindy'], 'Home-style South Indian meals, tiffin and small-party catering.', 520),
      _w(7, 'Fatima Begum', 'maid', 7, 4.6, 97, 200, 'hour', Verification.verified, true, -0.018, 0.002,
          ['Velachery', 'Adyar'], 'Reliable daily help. Flexible morning and evening slots.', 402),
      _w(8, 'Dinesh Kumar', 'appliance', 5, 4.4, 53, 400, 'visit', Verification.pending, true, 0.025, 0.014,
          ['Guindy', 'T. Nagar'], 'AC and washing machine service. Verification review is in progress (simulated).', 120),
      _w(9, 'Murugan S', 'gardener', 9, 4.7, 76, 500, 'visit', Verification.verified, true, -0.024, -0.016,
          ['Tambaram', 'Velachery'], 'Lawn care, pruning and terrace gardens.', 210),
      _w(10, 'Gopal Raj', 'electrician', 3, 4.2, 21, 250, 'visit', Verification.pending, true, 0.016, 0.021,
          ['Adyar'], 'Newer electrician, quick on small fixes. Verification pending (simulated).', 44),
      _w(11, 'Selvi Arasu', 'cook', 6, 4.8, 110, 450, 'hour', Verification.verified, false, -0.010, 0.019,
          ['T. Nagar', 'Adyar'], 'Weekend cook for family functions. Currently unavailable.', 175),
      _w(12, 'Prakash M', 'plumber', 11, 4.9, 187, 350, 'visit', Verification.verified, true, 0.003, 0.007,
          ['Velachery', 'Guindy'], 'Eleven years on residential plumbing. Quick diagnosis, fair price.', 502),
      _w(13, 'Naveen Rao', 'painter', 2, 4.0, 12, 700, 'day', Verification.pending, true, -0.022, 0.020,
          ['Tambaram'], 'Junior painter building a portfolio. Pending verification (simulated).', 28),
      _w(14, 'Rahim Ali', 'appliance', 9, 4.8, 140, 450, 'visit', Verification.verified, true, 0.004, -0.017,
          ['Velachery', 'Adyar'], 'Fridge, AC and washing machine specialist. Genuine spares.', 388),
      _w(15, 'Kavitha N', 'maid', 3, 4.3, 31, 180, 'hour', Verification.verified, true, 0.021, -0.003,
          ['Guindy', 'Velachery'], 'Careful, punctual household help.', 96),
      _w(16, 'Ganesh P', 'carpenter', 7, 4.5, 69, 750, 'day', Verification.verified, true, -0.004, 0.024,
          ['T. Nagar', 'Adyar'], 'Doors, shelves and wardrobe fitting.', 205),
    ];

List<StudentJob> buildStudentJobs() => const [
      StudentJob('j1', 'Maths tutor for Class 8', 'Bright Steps Tuition', 'Tutoring', 1200, 'INR 1,200 / week', 'Evenings, 3 days', 'Velachery', 'On-site',
          Icons.school_rounded, 'Help two students with algebra and geometry practice.'),
      StudentJob('j2', 'Event registration desk', 'Spark Events', 'Events', 900, 'INR 900 / shift', 'Sat, 9 AM - 3 PM', 'Adyar', 'On-site',
          Icons.celebration_rounded, 'Greet guests and manage the check-in desk at a local expo.'),
      StudentJob('j3', 'Weekend grocery delivery', 'FreshBasket Mart', 'Delivery', 600, 'INR 600 / shift', 'Sun, 4 hrs', 'Guindy', 'On-site',
          Icons.delivery_dining_rounded, 'Deliver orders within 3 km on your own two-wheeler.'),
      StudentJob('j4', 'Product catalogue data entry', 'Nila Traders', 'Data entry', 800, 'INR 800 / project', 'Flexible, 2 days', 'Remote', 'Remote',
          Icons.keyboard_rounded, 'Enter 150 product listings into a spreadsheet.'),
      StudentJob('j5', 'Shop assistant (evenings)', 'Kumar Stationers', 'Shop assistance', 500, 'INR 500 / shift', 'Evenings, 4 hrs', 'T. Nagar', 'On-site',
          Icons.storefront_rounded, 'Billing counter and shelf organising during peak hours.'),
      StudentJob('j6', 'Science tutor for Class 10', 'Learn Lane', 'Tutoring', 1500, 'INR 1,500 / week', 'Weekends', 'Remote', 'Remote',
          Icons.school_rounded, 'Online physics and chemistry revision sessions.'),
      StudentJob('j7', 'Stage crew for college fest', 'Campus Live', 'Events', 700, 'INR 700 / shift', 'Fri evening', 'Tambaram', 'On-site',
          Icons.celebration_rounded, 'Help with set-up and cue sheets.'),
      StudentJob('j8', 'Invoice digitisation', 'Sai Hardware', 'Data entry', 650, 'INR 650 / project', 'Flexible, 1 day', 'Remote', 'Remote',
          Icons.keyboard_rounded, 'Type 100 handwritten invoices into a template.'),
    ];