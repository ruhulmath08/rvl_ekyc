/// Result of active liveness detection
class LivenessResultEntity {
  final bool passed;
  final double confidence;
  final List<LivenessCheckEntity> checks;
  final String? failureReason;

  LivenessResultEntity({
    required this.passed,
    required this.confidence,
    required this.checks,
    this.failureReason,
  });
}

/// Individual liveness check result
class LivenessCheckEntity {
  final LivenessCheckType type;
  final bool passed;
  final double confidence;
  final String? message;

  LivenessCheckEntity({
    required this.type,
    required this.passed,
    required this.confidence,
    this.message,
  });
}

enum LivenessCheckType {
  blink,
  headTurnLeft,
  headTurnRight,
  faceCentered,
  eyesOpen,
}
