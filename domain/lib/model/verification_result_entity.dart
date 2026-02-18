import 'package:domain/model/document_info_entity.dart';
import 'package:domain/model/liveness_result_entity.dart';

/// Final eKYC verification result
class VerificationResultEntity {
  final bool verified;
  final DocumentInfoEntity? documentInfo;
  final LivenessResultEntity? livenessResult;
  final double? faceMatchScore;
  final String? failureReason;
  final DateTime timestamp;

  VerificationResultEntity({
    required this.verified,
    this.documentInfo,
    this.livenessResult,
    this.faceMatchScore,
    this.failureReason,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  VerificationResultEntity.success({
    required this.documentInfo,
    required this.livenessResult,
    required this.faceMatchScore,
  })  : verified = true,
        failureReason = null,
        timestamp = DateTime.now();

  VerificationResultEntity.failure({
    required String reason,
    this.documentInfo,
    this.livenessResult,
    this.faceMatchScore,
  })  : verified = false,
        failureReason = reason,
        timestamp = DateTime.now();
}
