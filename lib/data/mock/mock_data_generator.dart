// lib/data/mock/mock_data_generator.dart
// Generates realistic cricket delivery data with physics-based trajectories.
// ~75% ACCEPTED, ~15% UNCERTAIN, ~10% REJECTED per session.

import 'dart:math';
import '../models/enums.dart';
import '../models/trajectory_point.dart';
import '../models/delivery.dart';
import '../models/session.dart';
import '../models/user_profile.dart';

class MockDataGenerator {
  MockDataGenerator._();

  static final _rng = Random(42); // Fixed seed for reproducibility

  // ─── Pitch Constants (ICC standard) ──────────────────────────────────────
  static const pitchLength = 20.12; // metres
  static const stumpWidth = 0.711; // metres
  static const stumpHeight = 0.711; // metres

  // ─── Top-level generator ─────────────────────────────────────────────────
  static List<CricketSession> generateSessions() {
    return [
      _makeSession(
        id: 'session_001',
        title: 'Morning Practice',
        daysAgo: 1,
        location: 'MCA Ground, Pune',
        type: SessionType.practice,
        count: 28,
      ),
      _makeSession(
        id: 'session_002',
        title: 'Net Session - Pace',
        daysAgo: 3,
        location: 'Wankhede Stadium Nets',
        type: SessionType.practice,
        count: 35,
      ),
      _makeSession(
        id: 'session_003',
        title: 'Club Match – 1st Innings',
        daysAgo: 7,
        location: 'Shivaji Park, Mumbai',
        type: SessionType.match,
        count: 24,
      ),
      _makeSession(
        id: 'session_004',
        title: 'Spin Bowling Analysis',
        daysAgo: 14,
        location: 'BCCI Academy, Chennai',
        type: SessionType.practice,
        count: 30,
      ),
    ];
  }

  static CricketSession _makeSession({
    required String id,
    required String title,
    required int daysAgo,
    required String location,
    required SessionType type,
    required int count,
  }) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    final deliveries = List.generate(
      count,
      (i) => _makeDelivery(
        sessionId: id,
        number: i + 1,
        baseTime: date.add(Duration(minutes: i * 2)),
        sessionSeed: id.hashCode,
      ),
    );
    return CricketSession(
      id: id,
      title: title,
      date: date,
      location: location,
      type: type,
      deliveries: deliveries,
      isProcessed: true,
    );
  }

  static Delivery _makeDelivery({
    required String sessionId,
    required int number,
    required DateTime baseTime,
    required int sessionSeed,
  }) {
    final id = '${sessionId}_d${number.toString().padLeft(3, '0')}';

    // Status distribution: 75% accepted, 15% uncertain, 10% rejected
    final statusRoll = _rng.nextDouble();
    final DeliveryStatus status;
    if (statusRoll < 0.75) {
      status = DeliveryStatus.accepted;
    } else if (statusRoll < 0.90) {
      status = DeliveryStatus.uncertain;
    } else {
      status = DeliveryStatus.rejected;
    }

    final confidence = _statusConfidence(status);
    final rejectReason = status == DeliveryStatus.rejected
        ? _pickRejectReason()
        : null;

    // Delivery metrics
    final speedKmh = 110 + _rng.nextDouble() * 35; // 110–145 km/h
    final spinRpm = _rng.nextDouble() * 2000; // 0–2000 rpm
    final swingDeg = _rng.nextDouble() * 8; // 0–8°
    final line = _pickLine();
    final length = _pickLength();

    // Generate physics-based trajectory
    final trajectory = _buildTrajectory(
      id: id,
      status: status,
      confidence: confidence,
      rejectReason: rejectReason,
      speedKmh: speedKmh,
      spinRpm: spinRpm,
      swingDeg: swingDeg,
      line: line,
      length: length,
    );

    final isLbw = status == DeliveryStatus.accepted &&
        line == DeliveryLine.middle &&
        (length == DeliveryLength.full || length == DeliveryLength.good) &&
        _rng.nextDouble() < 0.3;

    return Delivery(
      id: id,
      sessionId: sessionId,
      number: number,
      timestamp: baseTime,
      trajectory: trajectory,
      isLbwCandidate: isLbw,
    );
  }

  /// Builds a physics-like parabolic arc + Magnus drift trajectory.
  static FinalTrajectory _buildTrajectory({
    required String id,
    required DeliveryStatus status,
    required double confidence,
    required String? rejectReason,
    required double speedKmh,
    required double spinRpm,
    required double swingDeg,
    required DeliveryLine line,
    required DeliveryLength length,
  }) {
    // Coordinate system:
    // x = width (off=negative, leg=positive), y = height, z = distance from bowler (0→20.12)
    // Pitch 20.12 m long, stumps at z=0 (bowler end) and z=20.12 (batter end)

    // Release point: bowler's hand position
    const releaseZ = 1.5;
    final releaseX = _lineOffset(line) + (_rng.nextDouble() - 0.5) * 0.1;
    const releaseY = 2.1; // ~2.1 m height at release

    // Bounce point based on length
    final bounceZ = _bounceZ(length);
    final bounceX = releaseX + swingDeg * 0.02 * (_rng.nextDouble() > 0.5 ? 1 : -1);
    final bounceY = 0.0;

    // Wicket plane impact (z = 20.12)
    final impactX = bounceX + (_rng.nextDouble() - 0.5) * 0.3;
    final impactY = 0.3 + _rng.nextDouble() * 0.5; // 0.3–0.8 m (pad/stumps height)
    final stumpsHit = impactX.abs() < stumpWidth / 2 && impactY < stumpHeight;

    // Build points (30 total)
    const totalFrames = 30;
    final points = <TrajectoryPoint>[];
    final releaseFrame = 0;
    final bounceFrame = _bounceFrame(length);
    // ignore: unused_local_variable
    final impactFrame = 29;

    for (int i = 0; i <= totalFrames - 1; i++) {
      final t = i / (totalFrames - 1);
      final z = releaseZ + (pitchLength - releaseZ) * t;

      // Phase detection
      final TrajectoryPhase phase;
      if (i == 0) {
        phase = TrajectoryPhase.release;
      } else if (z < bounceZ) {
        phase = TrajectoryPhase.flight;
      } else if (i == bounceFrame) {
        phase = TrajectoryPhase.bounce;
      } else {
        phase = TrajectoryPhase.postBounce;
      }

      // Parabolic height
      final tNorm = (z - releaseZ) / (pitchLength - releaseZ);
      final y = _parabolicHeight(tNorm, releaseY, bounceZ, z, releaseZ, pitchLength);

      // Lateral drift (swing + Magnus)
      final x = _lateralDrift(tNorm, releaseX, impactX, swingDeg, spinRpm);

      // Uncertainty grows after bounce
      final uncertainty = phase == TrajectoryPhase.postBounce
          ? 0.05 + (tNorm - _bounceT(bounceZ, releaseZ, pitchLength)) * 0.3
          : 0.01 + _rng.nextDouble() * 0.02;

      points.add(TrajectoryPoint(
        x: x,
        y: y.clamp(0.0, 3.0),
        z: z,
        frame: i,
        uncertaintyM: uncertainty.clamp(0.01, 0.4),
        phase: phase,
      ));
    }

    // Build track health list
    final trackHealth = List.generate(
      totalFrames,
      (i) => _trackHealth(i, totalFrames, status),
    );

    final releasePt = TrajectoryPoint(
      x: releaseX,
      y: releaseY,
      z: releaseZ,
      frame: releaseFrame,
      uncertaintyM: 0.01,
      phase: TrajectoryPhase.release,
    );
    final bouncePt = TrajectoryPoint(
      x: bounceX,
      y: bounceY,
      z: bounceZ,
      frame: bounceFrame,
      uncertaintyM: 0.03,
      phase: TrajectoryPhase.bounce,
    );

    return FinalTrajectory(
      deliveryId: id,
      status: status,
      confidence: confidence,
      rejectReason: rejectReason,
      release: releasePt,
      bounce: bouncePt,
      points: points,
      wicketPlane: WicketPlaneData(
        impactX: impactX,
        impactY: impactY,
        stumpsHit: stumpsHit,
        confidence: confidence,
      ),
      metrics: DeliveryMetrics(
        speedKmh: speedKmh,
        spinRpm: spinRpm,
        swingDeg: swingDeg,
        line: _lineStr(line),
        length: _lengthStr(length),
      ),
      trackHealth: trackHealth,
    );
  }

  static double _parabolicHeight(
    double tNorm,
    double releaseY,
    double bounceZ,
    double z,
    double releaseZ,
    double pitchLen,
  ) {
    // Pre-bounce: downward parabola from releaseY to 0
    final bounceT = (bounceZ - releaseZ) / (pitchLen - releaseZ);
    if (tNorm <= bounceT) {
      final s = tNorm / bounceT;
      return releaseY * (1 - s * s);
    } else {
      // Post-bounce: shorter upward-then-downward arc
      final s = (tNorm - bounceT) / (1 - bounceT);
      return 0.4 * sin(s * pi);
    }
  }

  static double _lateralDrift(
    double t,
    double releaseX,
    double impactX,
    double swingDeg,
    double spinRpm,
  ) {
    // Linear base + sinusoidal swing curve
    final base = releaseX + (impactX - releaseX) * t;
    final swing = swingDeg * 0.005 * sin(t * pi * 0.8);
    return base + swing;
  }

  static double _trackHealth(int frame, int total, DeliveryStatus status) {
    // Rejected deliveries have bad health in the middle section
    if (status == DeliveryStatus.rejected) {
      if (frame > total * 0.3 && frame < total * 0.7) {
        return 0.2 + _rng.nextDouble() * 0.3;
      }
    }
    if (status == DeliveryStatus.uncertain) {
      if (frame > total * 0.5) {
        return 0.5 + _rng.nextDouble() * 0.4;
      }
    }
    return 0.85 + _rng.nextDouble() * 0.15;
  }

  static double _lineOffset(DeliveryLine line) {
    switch (line) {
      case DeliveryLine.off:
        return -0.25;
      case DeliveryLine.leg:
        return 0.25;
      case DeliveryLine.middle:
        return 0.0;
    }
  }

  static double _bounceZ(DeliveryLength length) {
    switch (length) {
      case DeliveryLength.yorker:
        return 17.5;
      case DeliveryLength.full:
        return 14.0;
      case DeliveryLength.good:
        return 11.0;
      case DeliveryLength.short:
        return 7.5;
    }
  }

  static int _bounceFrame(DeliveryLength length) {
    switch (length) {
      case DeliveryLength.yorker:
        return 25;
      case DeliveryLength.full:
        return 20;
      case DeliveryLength.good:
        return 15;
      case DeliveryLength.short:
        return 10;
    }
  }

  static double _bounceT(double bounceZ, double releaseZ, double pitchLen) {
    return (bounceZ - releaseZ) / (pitchLen - releaseZ);
  }

  static double _statusConfidence(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.accepted:
        return 0.80 + _rng.nextDouble() * 0.20; // 0.80–1.00
      case DeliveryStatus.uncertain:
        return 0.50 + _rng.nextDouble() * 0.29; // 0.50–0.79
      case DeliveryStatus.rejected:
        return _rng.nextDouble() * 0.49; // 0.00–0.49
    }
  }

  static String _pickRejectReason() {
    const reasons = [
      'Ball lost for 9 frames',
      'Camera moved during delivery',
      'Ball occluded by batsman',
      'Insufficient lighting',
      'Multiple balls detected',
      'Ball exited frame boundary',
    ];
    return reasons[_rng.nextInt(reasons.length)];
  }

  static DeliveryLine _pickLine() {
    final r = _rng.nextDouble();
    if (r < 0.33) return DeliveryLine.off;
    if (r < 0.66) return DeliveryLine.middle;
    return DeliveryLine.leg;
  }

  static DeliveryLength _pickLength() {
    final r = _rng.nextDouble();
    if (r < 0.10) return DeliveryLength.yorker;
    if (r < 0.35) return DeliveryLength.full;
    if (r < 0.70) return DeliveryLength.good;
    return DeliveryLength.short;
  }

  static String _lineStr(DeliveryLine l) {
    switch (l) {
      case DeliveryLine.off:
        return 'OFF';
      case DeliveryLine.middle:
        return 'MIDDLE';
      case DeliveryLine.leg:
        return 'LEG';
    }
  }

  static String _lengthStr(DeliveryLength l) {
    switch (l) {
      case DeliveryLength.yorker:
        return 'YORKER';
      case DeliveryLength.full:
        return 'FULL';
      case DeliveryLength.good:
        return 'GOOD';
      case DeliveryLength.short:
        return 'SHORT';
    }
  }

  // ─── Mock Teammates ───────────────────────────────────────────────────────
  static List<MockTeammate> generateTeammates() => [
        MockTeammate(
          id: 't1',
          name: 'Arjun Sharma',
          initials: 'AS',
          role: UserRole.player,
        ),
        MockTeammate(
          id: 't2',
          name: 'Priya Mehta',
          initials: 'PM',
          role: UserRole.coach,
        ),
        MockTeammate(
          id: 't3',
          name: 'Rohan Patel',
          initials: 'RP',
          role: UserRole.analyst,
        ),
        MockTeammate(
          id: 't4',
          name: 'Kavita Nair',
          initials: 'KN',
          role: UserRole.player,
        ),
        MockTeammate(
          id: 't5',
          name: 'Dev Gupta',
          initials: 'DG',
          role: UserRole.player,
        ),
      ];

  static UserProfile generateUserProfile(
    String phone,
    UserRole role,
  ) {
    return UserProfile(
      id: 'user_001',
      name: 'Rahul Yadav',
      phone: phone,
      role: role,
      avatarInitials: 'RY',
      isPro: false,
      storageUsedGb: 1.2,
      storageTotalGb: 5.0,
    );
  }
}
