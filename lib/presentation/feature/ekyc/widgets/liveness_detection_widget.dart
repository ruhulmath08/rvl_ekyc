import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:domain/model/liveness_result_entity.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_view_model.dart';

class LivenessDetectionWidget extends StatelessWidget {
  final EkycViewModel viewModel;

  const LivenessDetectionWidget({
    required this.viewModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Liveness Detection',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Selfie preview
          ValueListenableBuilder<Uint8List?>(
            valueListenable: viewModel.selfieImage,
            builder: (context, imageBytes, _) {
              if (imageBytes == null) {
                return const SizedBox.shrink();
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Selfie Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.contain,
                            height: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Liveness result or loading state
          ValueListenableBuilder<LivenessResultEntity?>(
            valueListenable: viewModel.livenessResult,
            builder: (context, result, _) {
              if (result == null) {
                // Show loading state with check list
                return _buildLoadingState();
              }

              // Show results
              return _buildResultState(result);
            },
          ),

          const SizedBox(height: 24),

          // Error message
          ValueListenableBuilder<String?>(
            valueListenable: viewModel.errorMessage,
            builder: (context, error, _) {
              if (error == null) return const SizedBox.shrink();

              return Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Action buttons
          ValueListenableBuilder<LivenessResultEntity?>(
            valueListenable: viewModel.livenessResult,
            builder: (context, result, _) {
              if (result == null) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  if (result.passed)
                    ElevatedButton(
                      onPressed: () {
                        // Verification will proceed automatically
                        // This button is for user confirmation if needed
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Continue'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => viewModel.retry(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Retry'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Performing Liveness Detection...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCheckItem(
              'Blink Detection',
              'Checking if eyes can blink',
              null,
            ),
            const SizedBox(height: 12),
            _buildCheckItem(
              'Head Turn Left',
              'Checking head movement to left',
              null,
            ),
            const SizedBox(height: 12),
            _buildCheckItem(
              'Head Turn Right',
              'Checking head movement to right',
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultState(LivenessResultEntity result) {
    return Card(
      color: result.passed ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.passed ? Icons.check_circle : Icons.error,
                  color: result.passed ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.passed
                        ? 'Liveness Detection Passed'
                        : 'Liveness Detection Failed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: result.passed
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                    ),
                  ),
                ),
              ],
            ),
            if (result.failureReason != null) ...[
              const SizedBox(height: 12),
              Text(
                result.failureReason!,
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Confidence score
            Row(
              children: [
                const Text(
                  'Confidence: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: result.confidence,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      result.confidence >= 0.7 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(result.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (result.checks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Check Details:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...result.checks.map((check) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCheckItem(
                    _getCheckDisplayName(check.type),
                    check.message ?? _getCheckDescription(check.type),
                    check.passed,
                    confidence: check.confidence,
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(
    String title,
    String description,
    bool? status, {
    double? confidence,
  }) {
    IconData icon;
    Color iconColor;
    String statusText;

    if (status == null) {
      // Loading state
      icon = Icons.hourglass_empty;
      iconColor = Colors.grey;
      statusText = 'Processing...';
    } else if (status) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
      statusText = 'Passed';
    } else {
      icon = Icons.cancel;
      iconColor = Colors.red;
      statusText = 'Failed';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              if (confidence != null) ...[
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    confidence >= 0.7 ? Colors.green : Colors.orange,
                  ),
                  minHeight: 4,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getCheckDisplayName(LivenessCheckType type) {
    switch (type) {
      case LivenessCheckType.blink:
        return 'Blink Detection';
      case LivenessCheckType.headTurnLeft:
        return 'Head Turn Left';
      case LivenessCheckType.headTurnRight:
        return 'Head Turn Right';
      case LivenessCheckType.faceCentered:
        return 'Face Centered';
      case LivenessCheckType.eyesOpen:
        return 'Eyes Open';
    }
  }

  String _getCheckDescription(LivenessCheckType type) {
    switch (type) {
      case LivenessCheckType.blink:
        return 'Verifying eye blink movement';
      case LivenessCheckType.headTurnLeft:
        return 'Verifying head turn to the left';
      case LivenessCheckType.headTurnRight:
        return 'Verifying head turn to the right';
      case LivenessCheckType.faceCentered:
        return 'Verifying face is centered in frame';
      case LivenessCheckType.eyesOpen:
        return 'Verifying eyes are open';
    }
  }
}
