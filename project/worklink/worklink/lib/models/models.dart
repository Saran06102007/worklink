import 'package:flutter/material.dart';

import '../core/tokens.dart';

class GeoPoint {
  final double lat, lng;
  const GeoPoint(this.lat, this.lng);
}

class Area {
  final String name;
  final GeoPoint center;
  const Area(this.name, this.center);
}

enum UserRole { customer, worker, student }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.worker:
        return 'Worker';
      case UserRole.student:
        return 'Student';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.customer:
        return Icons.person_search_rounded;
      case UserRole.worker:
        return Icons.engineering_rounded;
      case UserRole.student:
        return Icons.school_rounded;
    }
  }
}

enum Verification { notStarted, pending, verified, rejected }

extension VerificationX on Verification {
  String get label {
    switch (this) {
      case Verification.notStarted:
        return 'Unverified';
      case Verification.pending:
        return 'Pending';
      case Verification.verified:
        return 'Verified';
      case Verification.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case Verification.notStarted:
        return const Color(0xFF8A90B8);
      case Verification.pending:
        return Brand.warning;
      case Verification.verified:
        return Brand.success;
      case Verification.rejected:
        return Brand.danger;
    }
  }

  IconData get icon {
    switch (this) {
      case Verification.notStarted:
        return Icons.shield_outlined;
      case Verification.pending:
        return Icons.hourglass_top_rounded;
      case Verification.verified:
        return Icons.verified_rounded;
      case Verification.rejected:
        return Icons.error_outline_rounded;
    }
  }
}

enum Party { customer, worker }

enum BookingStatus { awaitingWorker, counterReceived, confirmed, onTheWay, workStarted, completed, cancelled, rejected }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.awaitingWorker:
        return 'Awaiting response';
      case BookingStatus.counterReceived:
        return 'Counteroffer received';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.onTheWay:
        return 'On the way';
      case BookingStatus.workStarted:
        return 'Work started';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Declined';
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.awaitingWorker:
        return Icons.hourglass_top_rounded;
      case BookingStatus.counterReceived:
        return Icons.swap_horiz_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.onTheWay:
        return Icons.two_wheeler_rounded;
      case BookingStatus.workStarted:
        return Icons.build_rounded;
      case BookingStatus.completed:
        return Icons.verified_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
      case BookingStatus.rejected:
        return Icons.do_not_disturb_on_rounded;
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.awaitingWorker:
        return Brand.warning;
      case BookingStatus.counterReceived:
        return Brand.violetSoft;
      case BookingStatus.confirmed:
      case BookingStatus.onTheWay:
      case BookingStatus.workStarted:
        return const Color(0xFF6EA8FF);
      case BookingStatus.completed:
        return Brand.success;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return Brand.danger;
    }
  }

  bool get isActive =>
      this != BookingStatus.completed && this != BookingStatus.cancelled && this != BookingStatus.rejected;
  bool get isNegotiating => this == BookingStatus.awaitingWorker || this == BookingStatus.counterReceived;
}

class ServiceCategory {
  final String id, name, unit, blurb;
  final IconData icon;
  final int basePrice;
  const ServiceCategory(this.id, this.name, this.icon, this.basePrice, this.unit, this.blurb);
}

class Review {
  final String author;
  final int rating;
  final String text;
  final DateTime date;
  final bool verifiedJob;
  Review({required this.author, required this.rating, required this.text, required this.date, this.verifiedJob = true});
}

class PortfolioItem {
  final String title, detail;
  final IconData icon;
  const PortfolioItem(this.title, this.detail, this.icon);
}

class Worker {
  final String id;
  String name, categoryId, bio, unit, phone;
  List<String> skills, areas, languages;
  int years, reviewCount, price, jobsDone;
  double rating;
  Verification verification;
  String? verifyNote;
  bool available;
  GeoPoint location;
  final GeoPoint offset;
  final List<PortfolioItem> portfolio;
  final List<Review> reviews;
  final int seed;

  /// true = controlled by a real person using the app (registered/demo worker account).
  final bool human;

  Worker({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.skills,
    required this.years,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.unit,
    required this.verification,
    required this.available,
    required this.location,
    this.offset = const GeoPoint(0, 0),
    required this.areas,
    required this.bio,
    required this.jobsDone,
    List<PortfolioItem>? portfolio,
    List<Review>? reviews,
    this.languages = const ['English', 'Tamil'],
    this.seed = 0,
    this.human = false,
    this.phone = '',
    this.verifyNote,
  })  : portfolio = portfolio ?? [],
        reviews = reviews ?? [];
}

class Customer {
  final String id;
  String name, phone, email, areaName;
  GeoPoint location;
  bool phoneVerified;
  String address;
  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.areaName,
    required this.location,
    this.phoneVerified = false,
    this.address = '',
  });
}

class Student {
  final String id;
  String name, phone, email, college, course, year;
  Verification verification;
  String? verifyNote;
  Set<String> interests;
  Set<String> slots;
  Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.college,
    required this.course,
    required this.year,
    this.verification = Verification.notStarted,
    Set<String>? interests,
    Set<String>? slots,
  })  : interests = interests ?? <String>{},
        slots = slots ?? <String>{};
}

class Account {
  final UserRole role;
  final String email, phone, password;
  final bool demo;
  final Customer? customer;
  final Worker? worker;
  final Student? student;
  Account({
    required this.role,
    required this.email,
    required this.phone,
    required this.password,
    this.demo = false,
    this.customer,
    this.worker,
    this.student,
  });
}

class RankedWorker {
  final Worker worker;
  final double km;
  final int eta;
  const RankedWorker(this.worker, this.km, this.eta);
}

class Offer {
  final Party by;
  final int amount;
  final String note;
  final DateTime at;
  Offer(this.by, this.amount, {this.note = '', DateTime? at}) : at = at ?? DateTime.now();
}

class ChatMsg {
  final String from; // 'customer' | 'worker' | 'system'
  final String text;
  final DateTime at;
  ChatMsg(this.from, this.text, {DateTime? at}) : at = at ?? DateTime.now();
}

class Booking {
  final String id, customerId, customerName, customerArea, categoryId;
  final GeoPoint customerLoc;
  String workerId, details, address, schedule;
  DateTime createdAt;
  DateTime? doneAt;
  BookingStatus status;
  final List<Offer> offers;
  final List<ChatMsg> chat;
  final Map<BookingStatus, DateTime> times;
  List<String> candidates;
  int candidateIndex;
  bool viaNearest, paid, typing;
  int? agreedPrice, rating;
  String? rejectReason, review;
  double distanceKm;
  int etaMin;

  Booking({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerArea,
    required this.customerLoc,
    required this.workerId,
    required this.categoryId,
    required this.details,
    required this.address,
    required this.schedule,
    required this.createdAt,
    required this.status,
    List<Offer>? offers,
    List<ChatMsg>? chat,
    List<String>? candidates,
    this.candidateIndex = 0,
    this.viaNearest = false,
    this.paid = false,
    this.typing = false,
    this.agreedPrice,
    this.rating,
    this.review,
    this.rejectReason,
    this.distanceKm = 0,
    this.etaMin = 0,
    this.doneAt,
  })  : offers = offers ?? [],
        chat = chat ?? [],
        candidates = candidates ?? [],
        times = {};

  Offer? get lastOffer => offers.isEmpty ? null : offers.last;
  Offer? get lastWorkerOffer {
    for (var i = offers.length - 1; i >= 0; i--) {
      if (offers[i].by == Party.worker) return offers[i];
    }
    return null;
  }

  Offer? get firstCustomerOffer {
    for (final o in offers) {
      if (o.by == Party.customer) return o;
    }
    return null;
  }

  int get shownPrice => agreedPrice ?? lastOffer?.amount ?? 0;
}

class AppNotification {
  final String id, title, body;
  final UserRole role;
  final DateTime time;
  final String? bookingId;
  bool read;
  AppNotification(this.id, this.role, this.title, this.body, {this.bookingId, this.read = false, DateTime? time})
      : time = time ?? DateTime.now();
}

class StudentJob {
  final String id, title, business, type, schedule, area, mode, description, payLabel;
  final int pay;
  final IconData icon;
  const StudentJob(this.id, this.title, this.business, this.type, this.pay, this.payLabel, this.schedule, this.area,
      this.mode, this.icon, this.description);
}

enum AppStatus { applied, shortlisted, hired, completed, withdrawn }

class JobApplication {
  final String id, jobId;
  AppStatus status;
  final DateTime appliedAt;
  JobApplication(this.id, this.jobId, this.status, this.appliedAt);
}