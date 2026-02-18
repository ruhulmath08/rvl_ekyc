import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/base_ui_state.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_view_model.dart';
import 'package:hello_flutter/presentation/feature/ekyc/widgets/document_capture_widget.dart';
import 'package:hello_flutter/presentation/feature/ekyc/widgets/document_review_widget.dart';
import 'package:hello_flutter/presentation/feature/ekyc/widgets/liveness_detection_widget.dart';
import 'package:hello_flutter/presentation/feature/ekyc/widgets/selfie_capture_widget.dart';
import 'package:hello_flutter/presentation/feature/ekyc/widgets/verification_result_widget.dart';

class EkycMobilePortrait extends StatefulWidget {
  final EkycViewModel viewModel;

  const EkycMobilePortrait({required this.viewModel, super.key});

  @override
  State<StatefulWidget> createState() => EkycMobilePortraitState();
}

class EkycMobilePortraitState extends BaseUiState<EkycMobilePortrait> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eKYC'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SizedBox.expand(
          child: ValueListenableBuilder<EkycStep>(
            valueListenable: widget.viewModel.currentStep,
            builder: (context, step, _) {
              switch (step) {
                case EkycStep.documentCaptureFront:
                case EkycStep.documentCaptureBack:
                  return DocumentCaptureWidget(viewModel: widget.viewModel);
                case EkycStep.documentReview:
                  return DocumentReviewWidget(viewModel: widget.viewModel);
                case EkycStep.selfieCapture:
                  return SelfieCaptureWidget(viewModel: widget.viewModel);
                case EkycStep.livenessDetection:
                  return LivenessDetectionWidget(viewModel: widget.viewModel);
                case EkycStep.verification:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case EkycStep.result:
                  return VerificationResultWidget(viewModel: widget.viewModel);
              }
            },
          ),
        ),
      ),
    );
  }
}
