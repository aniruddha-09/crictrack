// lib/data/models/enums.dart
// All cricket-domain enumerations.

enum DeliveryLine { off, middle, leg }

enum DeliveryLength { yorker, full, good, short }

enum DeliveryStatus { accepted, uncertain, rejected }

enum TrajectoryPhase { release, flight, bounce, postBounce }

enum UserRole { player, coach, analyst }

enum SessionType { practice, match }

enum ProcessingStage {
  ingestAndDiscovery,
  ballProposal,
  singleBallTracking,
  globalOptimization,
  smoothingAnd3D,
  finalAcceptance,
}

enum ProcessingStageStatus { pending, running, done, failed }

enum LbwVerdict { out, notOut, umpiresCall }

extension DeliveryLineExt on DeliveryLine {
  String get label {
    switch (this) {
      case DeliveryLine.off:
        return 'Off';
      case DeliveryLine.middle:
        return 'Middle';
      case DeliveryLine.leg:
        return 'Leg';
    }
  }
}

extension DeliveryLengthExt on DeliveryLength {
  String get label {
    switch (this) {
      case DeliveryLength.yorker:
        return 'Yorker';
      case DeliveryLength.full:
        return 'Full';
      case DeliveryLength.good:
        return 'Good';
      case DeliveryLength.short:
        return 'Short';
    }
  }
}

extension DeliveryStatusExt on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.accepted:
        return 'ACCEPTED';
      case DeliveryStatus.uncertain:
        return 'UNCERTAIN';
      case DeliveryStatus.rejected:
        return 'REJECTED';
    }
  }
}

extension ProcessingStageExt on ProcessingStage {
  String get label {
    switch (this) {
      case ProcessingStage.ingestAndDiscovery:
        return 'Ingest & Delivery Discovery';
      case ProcessingStage.ballProposal:
        return 'Ball Proposal & Center Refinement';
      case ProcessingStage.singleBallTracking:
        return 'Single-Ball Tracking & Temporal Identity';
      case ProcessingStage.globalOptimization:
        return 'Global Whole-Delivery Optimization';
      case ProcessingStage.smoothingAnd3D:
        return '2D Smoothing & Calibrated 3D Trajectory';
      case ProcessingStage.finalAcceptance:
        return 'Final Acceptance & Product Output';
    }
  }
}
