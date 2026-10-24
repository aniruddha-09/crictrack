// lib/data/models/trajectory_point.dart
// Immutable 3D point with uncertainty and phase info matching the V4 pipeline contract.

import 'enums.dart';

class TrajectoryPoint {
  final double x;
  final double y;
  final double z;
  final int frame;
  final double uncertaintyM;
  final TrajectoryPhase phase;

  const TrajectoryPoint({
    required this.x,
    required this.y,
    required this.z,
    required this.frame,
    this.uncertaintyM = 0.0,
    this.phase = TrajectoryPhase.flight,
  });

  TrajectoryPoint copyWith({
    double? x,
    double? y,
    double? z,
    int? frame,
    double? uncertaintyM,
    TrajectoryPhase? phase,
  }) {
    return TrajectoryPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      frame: frame ?? this.frame,
      uncertaintyM: uncertaintyM ?? this.uncertaintyM,
      phase: phase ?? this.phase,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'z': z,
        'frame': frame,
        'uncertaintyM': uncertaintyM,
        'phase': phase.name,
      };
}

class WicketPlaneData {
  final double impactX;
  final double impactY;
  final bool stumpsHit;
  final double confidence;

  const WicketPlaneData({
    required this.impactX,
    required this.impactY,
    required this.stumpsHit,
    required this.confidence,
  });

  WicketPlaneData copyWith({
    double? impactX,
    double? impactY,
    bool? stumpsHit,
    double? confidence,
  }) {
    return WicketPlaneData(
      impactX: impactX ?? this.impactX,
      impactY: impactY ?? this.impactY,
      stumpsHit: stumpsHit ?? this.stumpsHit,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() => {
        'impactX': impactX,
        'impactY': impactY,
        'stumpsHit': stumpsHit,
        'confidence': confidence,
      };
}

class DeliveryMetrics {
  final double speedKmh;
  final double spinRpm;
  final double swingDeg;
  final String line;
  final String length;

  const DeliveryMetrics({
    required this.speedKmh,
    required this.spinRpm,
    required this.swingDeg,
    required this.line,
    required this.length,
  });

  DeliveryMetrics copyWith({
    double? speedKmh,
    double? spinRpm,
    double? swingDeg,
    String? line,
    String? length,
  }) {
    return DeliveryMetrics(
      speedKmh: speedKmh ?? this.speedKmh,
      spinRpm: spinRpm ?? this.spinRpm,
      swingDeg: swingDeg ?? this.swingDeg,
      line: line ?? this.line,
      length: length ?? this.length,
    );
  }

  Map<String, dynamic> toJson() => {
        'speedKmh': speedKmh,
        'spinRpm': spinRpm,
        'swingDeg': swingDeg,
        'line': line,
        'length': length,
      };
}

/// The single source of truth for a delivery's trajectory.
/// All UI elements (3D viewer, pitch map, stats) read from this object.
class FinalTrajectory {
  final String deliveryId;
  final DeliveryStatus status;
  final double confidence;
  final String? rejectReason;
  final TrajectoryPoint release;
  final TrajectoryPoint bounce;
  final List<TrajectoryPoint> points;
  final WicketPlaneData wicketPlane;
  final DeliveryMetrics metrics;
  final List<double> trackHealth;

  const FinalTrajectory({
    required this.deliveryId,
    required this.status,
    required this.confidence,
    this.rejectReason,
    required this.release,
    required this.bounce,
    required this.points,
    required this.wicketPlane,
    required this.metrics,
    required this.trackHealth,
  });

  FinalTrajectory copyWith({
    String? deliveryId,
    DeliveryStatus? status,
    double? confidence,
    String? rejectReason,
    TrajectoryPoint? release,
    TrajectoryPoint? bounce,
    List<TrajectoryPoint>? points,
    WicketPlaneData? wicketPlane,
    DeliveryMetrics? metrics,
    List<double>? trackHealth,
  }) {
    return FinalTrajectory(
      deliveryId: deliveryId ?? this.deliveryId,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      rejectReason: rejectReason ?? this.rejectReason,
      release: release ?? this.release,
      bounce: bounce ?? this.bounce,
      points: points ?? this.points,
      wicketPlane: wicketPlane ?? this.wicketPlane,
      metrics: metrics ?? this.metrics,
      trackHealth: trackHealth ?? this.trackHealth,
    );
  }

  Map<String, dynamic> toJson() => {
        'deliveryId': deliveryId,
        'status': status.name.toUpperCase(),
        'confidence': confidence,
        'rejectReason': rejectReason,
        'release': release.toJson(),
        'bounce': bounce.toJson(),
        'points': points.map((p) => p.toJson()).toList(),
        'wicketPlane': wicketPlane.toJson(),
        'metrics': metrics.toJson(),
        'trackHealth': trackHealth,
      };
}
