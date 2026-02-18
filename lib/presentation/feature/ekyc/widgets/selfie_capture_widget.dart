import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_view_model.dart';

class SelfieCaptureWidget extends StatelessWidget {
  final EkycViewModel viewModel;

  const SelfieCaptureWidget({required this.viewModel, super.key});

  /// Helper widget to build status row for liveness checks
  static Widget _buildStatusRow(String label, bool? status) {
    IconData icon;
    Color color;
    String text;

    if (status == null) {
      icon = Icons.help_outline;
      color = Colors.grey;
      text = 'Checking...';
    } else if (status) {
      icon = Icons.check_circle;
      color = Colors.green;
      text = 'Passed';
    } else {
      icon = Icons.cancel;
      color = Colors.red;
      text = 'Failed';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraController?>(
      valueListenable: viewModel.cameraController,
      builder: (context, controller, _) {
        if (controller == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing camera...'),
              ],
            ),
          );
        }

        if (!controller.value.isInitialized) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Camera initializing...'),
              ],
            ),
          );
        }

        if (controller.value.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Camera error: ${controller.value.errorDescription}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.retry(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview - fill entire screen (only show when not processing)
            ValueListenableBuilder<bool>(
              valueListenable: viewModel.isProcessing,
              builder: (context, isProcessing, _) {
                if (isProcessing) {
                  // Show placeholder when processing to stop preview stream
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                return Positioned.fill(child: CameraPreview(controller));
              },
            ),

            // Overlay guide
            Positioned.fill(child: CustomPaint(painter: FaceGuidePainter())),

            // Instructions and real-time liveness status - positioned below AppBar
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Position your face within the oval.\nEnsure good lighting, eyes open, no mask.',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Real-time liveness status
                  ValueListenableBuilder<bool>(
                    valueListenable: viewModel.isRealtimeLivenessActive,
                    builder: (context, isActive, _) {
                      if (!isActive) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Liveness Detection',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Face detected status
                            ValueListenableBuilder<bool?>(
                              valueListenable: viewModel.realtimeFaceDetected,
                              builder: (context, faceDetected, _) {
                                return _buildStatusRow(
                                  'Face Detected',
                                  faceDetected,
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            // Eyes open status
                            ValueListenableBuilder<bool?>(
                              valueListenable: viewModel.realtimeEyesOpen,
                              builder: (context, eyesOpen, _) {
                                return _buildStatusRow('Eyes Open', eyesOpen);
                              },
                            ),
                            const SizedBox(height: 4),
                            // Face centered status
                            ValueListenableBuilder<bool?>(
                              valueListenable: viewModel.realtimeFaceCentered,
                              builder: (context, faceCentered, _) {
                                return _buildStatusRow(
                                  'Face Centered',
                                  faceCentered,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Capture button - enable only when liveness checks pass
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: ValueListenableBuilder<bool?>(
                  valueListenable: viewModel.realtimeFaceDetected,
                  builder: (context, faceDetected, _) {
                    return ValueListenableBuilder<bool?>(
                      valueListenable: viewModel.realtimeEyesOpen,
                      builder: (context, eyesOpen, _) {
                        return ValueListenableBuilder<bool?>(
                          valueListenable: viewModel.realtimeFaceCentered,
                          builder: (context, faceCentered, _) {
                            final canCapture =
                                faceDetected == true &&
                                eyesOpen == true &&
                                faceCentered == true;
                            return FloatingActionButton(
                              onPressed: canCapture
                                  ? () => viewModel.captureSelfie()
                                  : null,
                              backgroundColor: canCapture
                                  ? Colors.white
                                  : Colors.grey,
                              child: Icon(
                                Icons.camera_alt,
                                color: canCapture ? Colors.black : Colors.white,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Error message
            ValueListenableBuilder<String?>(
              valueListenable: viewModel.errorMessage,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();

                return Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter for face capture guide overlay
class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw oval guide (centered)
    final ovalWidth = size.width * 0.7;
    final ovalHeight = size.height * 0.5;
    final ovalLeft = (size.width - ovalWidth) / 2;
    final ovalTop = (size.height - ovalHeight) / 2;

    final rect = Rect.fromLTWH(ovalLeft, ovalTop, ovalWidth, ovalHeight);
    canvas.drawOval(rect, paint);

    // Draw center indicator
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
