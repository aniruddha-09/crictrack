// lib/data/models/session.dart
// Immutable session model.

import 'enums.dart';
import 'delivery.dart';

class CricketSession {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final SessionType type;
  final List<Delivery> deliveries;
  final bool isProcessed;

  const CricketSession({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.type,
    required this.deliveries,
    this.isProcessed = true,
  });

  // ─── Computed stats (only from ACCEPTED deliveries) ───────────────────────
  List<Delivery> get acceptedDeliveries =>
      deliveries.where((d) => d.status == DeliveryStatus.accepted).toList();

  List<Delivery> get uncertainDeliveries =>
      deliveries.where((d) => d.status == DeliveryStatus.uncertain).toList();

  List<Delivery> get rejectedDeliveries =>
      deliveries.where((d) => d.status == DeliveryStatus.rejected).toList();

  int get totalBalls => deliveries.length;
  int get acceptedCount => acceptedDeliveries.length;
  int get uncertainCount => uncertainDeliveries.length;
  int get rejectedCount => rejectedDeliveries.length;

  double get avgSpeed {
    if (acceptedDeliveries.isEmpty) return 0;
    return acceptedDeliveries.map((d) => d.speedKmh).reduce((a, b) => a + b) /
        acceptedDeliveries.length;
  }

  double get maxSpeed {
    if (acceptedDeliveries.isEmpty) return 0;
    return acceptedDeliveries.map((d) => d.speedKmh).reduce(
          (a, b) => a > b ? a : b,
        );
  }

  double get avgSpin {
    if (acceptedDeliveries.isEmpty) return 0;
    return acceptedDeliveries.map((d) => d.spinRpm).reduce((a, b) => a + b) /
        acceptedDeliveries.length;
  }

  CricketSession copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? location,
    SessionType? type,
    List<Delivery>? deliveries,
    bool? isProcessed,
  }) {
    return CricketSession(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      type: type ?? this.type,
      deliveries: deliveries ?? this.deliveries,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}
