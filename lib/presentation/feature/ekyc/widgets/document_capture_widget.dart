import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_view_model.dart';
import 'package:hello_flutter/presentation/feature/ekyc/widgets/document_guide_painter.dart';

class DocumentCaptureWidget extends StatelessWidget {
  final EkycViewModel viewModel;

  const DocumentCaptureWidget({
    required this.viewModel,
    super.key,
  });

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
          fit: StackFit.loose,
          children: [
            // Camera preview + overlay: use standard Transform.scale + AspectRatio
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final deviceRatio = size.width > 0 && size.height > 0
                      ? size.width / size.height
                      : 1.0;
                  final previewAspect = controller.value.aspectRatio > 0
                      ? controller.value.aspectRatio
                      : deviceRatio;

                  // scale to match the preview aspect ratio to device aspect ratio
                  double scale = previewAspect / deviceRatio;
                  // Avoid very small/huge scale values
                  if (scale.isInfinite || scale.isNaN) scale = 1.0;

                  return Transform.scale(
                    scale: 1,
                    alignment: Alignment.center,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Camera preview (or processing placeholder)
                        ValueListenableBuilder<bool>(
                          valueListenable: viewModel.isProcessing,
                          builder: (context, isProcessing, _) {
                            if (isProcessing) {
                              return Container(
                                color: Colors.black,
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              );
                            }
                            return CameraPreview(controller);
                          },
                        ),

                        // Overlay guide painted with the same size as the preview
                        CustomPaint(
                          painter: DocumentGuidePainter(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Instructions - positioned below AppBar
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 16,
              right: 16,
              child: ValueListenableBuilder<EkycStep>(
                valueListenable: viewModel.currentStep,
                builder: (context, step, _) {
                  final isFrontSide = step == EkycStep.documentCaptureFront;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isFrontSide
                          ? 'Capture the FRONT side of your NID card.\nPosition it within the frame.\nEnsure good lighting and no blur.'
                          : 'Capture the BACK side of your NID card.\nPosition it within the frame.\nEnsure good lighting and no blur.',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),

            // Capture button
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: () => viewModel.captureDocument(),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt, color: Colors.black),
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
