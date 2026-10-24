// lib/data/models/delivery.dart
// Immutable delivery model. The FinalTrajectory is the single source of truth.

import 'enums.dart';
import 'trajectory_point.dart';

class Delivery {
  final String id;
  final String sessionId;
  final int number; // Delivery number in session
  final DateTime timestamp;
  final FinalTrajectory trajectory;
  final bool isLbwCandidate;
  final String clipUrl; // Placeholder asset path

  const Delivery({
    required this.id,
    required this.sessionId,
    required this.number,
    required this.timestamp,
    required this.trajectory,
    this.isLbwCandidate = false,
    this.clipUrl = 'assets/images/clip_placeholder.png',
  });

  // Convenience getters that delegate to trajectory.metrics
  double get speedKmh => trajectory.metrics.speedKmh;
  double get spinRpm => trajectory.metrics.spinRpm;
  double get swingDeg => trajectory.metrics.swingDeg;
  DeliveryLine get line => _parseLine(trajectory.metrics.line);
  DeliveryLength get length => _parseLength(trajectory.metrics.length);
  DeliveryStatus get status => trajectory.status;

  static DeliveryLine _parseLine(String s) {
    switch (s) {
      case 'OFF':
        return DeliveryLine.off;
      case 'LEG':
        return DeliveryLine.leg;
      default:
        return DeliveryLine.middle;
    }
  }

  static DeliveryLength _parseLength(String s) {
    switch (s) {
      case 'YORKER':
        return DeliveryLength.yorker;
      case 'FULL':
        return DeliveryLength.full;
      case 'SHORT':
        return DeliveryLength.short;
      default:
        return DeliveryLength.good;
    }
  }

  Delivery copyWith({
    String? id,
    String? sessionId,
    int? number,
    DateTime? timestamp,
    FinalTrajectory? trajectory,
    bool? isLbwCandidate,
    String? clipUrl,
  }) {
    return Delivery(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      number: number ?? this.number,
      timestamp: timestamp ?? this.timestamp,
      trajectory: trajectory ?? this.trajectory,
      isLbwCandidate: isLbwCandidate ?? this.isLbwCandidate,
      clipUrl: clipUrl ?? this.clipUrl,
    );
  }
}
