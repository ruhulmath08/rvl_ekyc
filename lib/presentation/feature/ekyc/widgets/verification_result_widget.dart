import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_view_model.dart';
import 'package:domain/model/verification_result_entity.dart';

class VerificationResultWidget extends StatelessWidget {
  final EkycViewModel viewModel;

  const VerificationResultWidget({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel.verificationResult,
      builder: (context, result, _) {
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isSuccess = result.verified;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result icon
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                size: 100,
                color: isSuccess ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 24),

              // Result title
              Text(
                isSuccess ? 'Verification Successful' : 'Verification Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Failure reason if failed
              if (!isSuccess && result.failureReason != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      result.failureReason!,
                      style: TextStyle(color: Colors.red.shade900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Liveness result
              if (result.livenessResult != null)
                _buildLivenessCard(result.livenessResult!),

              const SizedBox(height: 16),

              // Face match score
              if (result.faceMatchScore != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Face Match Score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: result.faceMatchScore,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            result.faceMatchScore! >= 0.65
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(result.faceMatchScore! * 100).toStringAsFixed(1)}% similarity',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Document info summary (BD NID format)
              if (result.documentInfo != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'জাতীয় পরিচয়পত্র / National ID Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (result.documentInfo!.displayName != null)
                          Text('Name: ${result.documentInfo!.displayName}'),
                        if (result.documentInfo!.formattedNidNumber != null)
                          Text('NID No: ${result.documentInfo!.formattedNidNumber}'),
                        if (result.documentInfo!.address != null)
                          Text(
                            'Address: ${result.documentInfo!.address}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Show Result Details button
              ElevatedButton.icon(
                onPressed: () => VerificationResultWidget._showResultDialog(context, result),
                icon: Icon(isSuccess ? Icons.info_outline : Icons.error_outline),
                label: const Text('Show Result Details'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isSuccess ? Colors.blue : Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              ElevatedButton(
                onPressed: () => viewModel.retry(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isSuccess ? 'Start New Verification' : 'Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLivenessCard(livenessResult) {
    return Card(
      color: livenessResult.passed ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  livenessResult.passed ? Icons.check_circle : Icons.error,
                  color: livenessResult.passed ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Liveness Detection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              livenessResult.passed
                  ? 'All liveness checks passed'
                  : 'Liveness check failed',
              style: TextStyle(
                color: livenessResult.passed
                    ? Colors.green.shade900
                    : Colors.red.shade900,
              ),
            ),
            // if (livenessResult.checks.isNotEmpty) ...[
            //   const SizedBox(height: 8),
            //   ...livenessResult.checks.map<Widget>((check) {
            //     return Padding(
            //       padding: const EdgeInsets.only(left: 8, top: 4),
            //       child: Row(
            //         children: [
            //           Icon(
            //             check.passed ? Icons.check : Icons.close,
            //             size: 16,
            //             color: check.passed ? Colors.green : Colors.red,
            //           ),
            //           const SizedBox(width: 4),
            //           Text(
            //             '${check.type.toString().split('.').last}: ${check.passed ? "Passed" : "Failed"}',
            //             style: const TextStyle(fontSize: 12),
            //           ),
            //         ],
            //       ),
            //     );
            //   }),
            // ],
          ],
        ),
      ),
    );
  }

  /// Show result dialog with success or fail details
  static void _showResultDialog(BuildContext context, VerificationResultEntity result) {
    final isSuccess = result.verified;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                isSuccess ? 'Verification Success' : 'Verification Failed',
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle : Icons.cancel,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSuccess
                              ? 'Your identity has been successfully verified!'
                              : (result.failureReason ?? 'Verification failed'),
                          style: TextStyle(
                            color: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Face Match Score
                if (result.faceMatchScore != null) ...[
                  const Text(
                    'Face Match Score:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: result.faceMatchScore,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      result.faceMatchScore! >= 0.65 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(result.faceMatchScore! * 100).toStringAsFixed(1)}% similarity',
                    style: TextStyle(
                      fontSize: 14,
                      color: result.faceMatchScore! >= 0.65 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Liveness Status
                if (result.livenessResult != null) ...[
                  const Text(
                    'Liveness Detection:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: result.livenessResult!.passed
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          result.livenessResult!.passed ? Icons.check : Icons.close,
                          color: result.livenessResult!.passed ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.livenessResult!.passed
                                ? 'All checks passed'
                                : 'Some checks failed',
                            style: TextStyle(
                              color: result.livenessResult!.passed
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Document Info (BD NID format)
                if (result.documentInfo != null) ...[
                  const Text(
                    'জাতীয় পরিচয়পত্র / National ID Card',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (result.documentInfo!.displayName != null)
                    Text('Name: ${result.documentInfo!.displayName}'),
                  if (result.documentInfo!.formattedNidNumber != null)
                    Text('NID No: ${result.documentInfo!.formattedNidNumber}'),
                  if (result.documentInfo!.address != null)
                    Text('Address: ${result.documentInfo!.address}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
