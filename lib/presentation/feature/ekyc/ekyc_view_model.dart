import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:domain/model/captured_image_entity.dart';
import 'package:domain/model/document_info_entity.dart';
import 'package:domain/model/document_side.dart';
import 'package:domain/model/face_detection_result_entity.dart';
import 'package:domain/model/liveness_result_entity.dart';
import 'package:domain/model/verification_result_entity.dart';
import 'package:domain/repository/ekyc_repository.dart';
import 'package:domain/util/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:hello_flutter/presentation/base/base_viewmodel.dart';
import 'package:hello_flutter/presentation/feature/ekyc/route/ekyc_argument.dart';
import 'package:image/image.dart' as img;

enum EkycStep {
  documentCaptureFront,
  documentCaptureBack,
  documentReview,
  selfieCapture,
  livenessDetection,
  verification,
  result,
}

class EkycViewModel extends BaseViewModel<EkycArgument> {
  final EkycRepository ekycRepository;

  final ValueNotifier<EkycStep> _currentStep = ValueNotifier(
    EkycStep.documentCaptureFront,
  );

  ValueListenable<EkycStep> get currentStep => _currentStep;

  final ValueNotifier<CameraController?> _cameraController = ValueNotifier(
    null,
  );

  ValueListenable<CameraController?> get cameraController => _cameraController;

  final ValueNotifier<List<CameraDescription>> _cameras = ValueNotifier([]);

  ValueListenable<List<CameraDescription>> get cameras => _cameras;

  final ValueNotifier<Uint8List?> _documentImage = ValueNotifier(null);

  ValueListenable<Uint8List?> get documentImage => _documentImage;

  final ValueNotifier<DocumentInfoEntity?> _documentInfo = ValueNotifier(null);

  ValueListenable<DocumentInfoEntity?> get documentInfo => _documentInfo;

  // Store front and back side data separately
  final ValueNotifier<DocumentInfoEntity?> _frontSideInfo = ValueNotifier(null);
  final ValueNotifier<DocumentInfoEntity?> _backSideInfo = ValueNotifier(null);

  ValueListenable<DocumentInfoEntity?> get frontSideInfo => _frontSideInfo;
  ValueListenable<DocumentInfoEntity?> get backSideInfo => _backSideInfo;

  final ValueNotifier<FaceDetectionResultEntity?> _documentFaceResult =
      ValueNotifier(null);

  ValueListenable<FaceDetectionResultEntity?> get documentFaceResult =>
      _documentFaceResult;

  final ValueNotifier<Uint8List?> _selfieImage = ValueNotifier(null);

  ValueListenable<Uint8List?> get selfieImage => _selfieImage;

  final ValueNotifier<FaceDetectionResultEntity?> _selfieFaceResult =
      ValueNotifier(null);

  ValueListenable<FaceDetectionResultEntity?> get selfieFaceResult =>
      _selfieFaceResult;

  final ValueNotifier<LivenessResultEntity?> _livenessResult = ValueNotifier(
    null,
  );

  ValueListenable<LivenessResultEntity?> get livenessResult => _livenessResult;

  final ValueNotifier<VerificationResultEntity?> _verificationResult =
      ValueNotifier(null);

  ValueListenable<VerificationResultEntity?> get verificationResult =>
      _verificationResult;

  final ValueNotifier<String?> _errorMessage = ValueNotifier(null);

  ValueListenable<String?> get errorMessage => _errorMessage;

  // Flag to track if camera is processing (to pause preview)
  final ValueNotifier<bool> _isProcessing = ValueNotifier(false);

  ValueListenable<bool> get isProcessing => _isProcessing;

  // Real-time liveness detection state
  final ValueNotifier<bool> _isRealtimeLivenessActive = ValueNotifier(false);
  ValueListenable<bool> get isRealtimeLivenessActive =>
      _isRealtimeLivenessActive;

  final ValueNotifier<bool?> _realtimeFaceDetected = ValueNotifier(null);
  ValueListenable<bool?> get realtimeFaceDetected => _realtimeFaceDetected;

  final ValueNotifier<bool?> _realtimeEyesOpen = ValueNotifier(null);
  ValueListenable<bool?> get realtimeEyesOpen => _realtimeEyesOpen;

  final ValueNotifier<bool?> _realtimeFaceCentered = ValueNotifier(null);
  ValueListenable<bool?> get realtimeFaceCentered => _realtimeFaceCentered;

  bool _isProcessingFrame = false;

  EkycViewModel({required this.ekycRepository});

  @override
  void onViewReady({EkycArgument? argument}) {
    Logger.debug('EkycViewModel: onViewReady');
    // Initialize camera after a short delay to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeCamera();
    });

    // Listen to step changes to stop real-time liveness when leaving selfie capture
    _currentStep.addListener(_onStepChanged);
  }

  void _onStepChanged() {
    // Stop real-time liveness detection when leaving selfie capture step
    if (_currentStep.value != EkycStep.selfieCapture) {
      stopRealtimeLivenessDetection();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final camerasList = await availableCameras();
      _cameras.value = camerasList;

      if (camerasList.isNotEmpty) {
        // Use back camera for document, front camera for selfie
        final backCamera = camerasList.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => camerasList.first,
        );

        final controller = CameraController(
          backCamera,
          ResolutionPreset
              .medium, // Use medium instead of high to reduce buffer pressure
          enableAudio: false,
        );

        await controller.initialize();
        _cameraController.value = controller;
      }
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to initialize camera, \n Error: $e \n StackTrace: $stackTrace',
      );
      _errorMessage.value = 'Failed to initialize camera: ${e.toString()}';
    }
  }

  Future<void> switchToFrontCamera() async {
    try {
      await _cameraController.value?.dispose();
      _cameraController.value = null;

      final frontCamera = _cameras.value.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.value.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset
            .medium, // Use medium instead of high to reduce buffer pressure
        enableAudio: false,
      );

      await controller.initialize();
      _cameraController.value = controller;
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to switch camera , \n Error: $e \n StackTrace: $stackTrace',
      );
      _errorMessage.value = 'Failed to switch camera: ${e.toString()}';
    }
  }

  Future<void> captureDocument() async {
    CameraController? controller;
    CameraDescription? camera;

    try {
      controller = _cameraController.value;
      if (controller == null || !controller.value.isInitialized) {
        _errorMessage.value = 'Camera not initialized';
        return;
      }

      // Save camera reference before disposing
      camera = controller.description;

      // Set processing flag to pause preview
      _isProcessing.value = true;

      // Completely stop and dispose camera to free all buffers
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        await controller.dispose();
      } catch (_) {
        // Ignore errors during cleanup
      }
      _cameraController.value = null;

      // Longer delay to ensure buffers are fully released
      await Future.delayed(const Duration(milliseconds: 300));

      // Recreate camera controller for capture (camera is guaranteed to be set here)
      final newController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await newController.initialize();
      _cameraController.value = newController;

      // Small delay after initialization
      await Future.delayed(const Duration(milliseconds: 100));

      final image = await newController.takePicture();
      final imageBytes = await image.readAsBytes();

      // Validate captured image
      if (imageBytes.isEmpty) {
        _errorMessage.value = 'Failed to capture image - empty data';
        _isProcessing.value = false;
        await _recreateCamera(camera);
        return;
      }

      // Dispose controller again after capture to free buffers
      try {
        await newController.dispose();
        _cameraController.value = null;
      } catch (_) {
        // Ignore errors
      }

      // Decode to get dimensions
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        _errorMessage.value =
            'Failed to decode image. Please try capturing again.';
        _isProcessing.value = false;
        // Recreate camera for next capture
        await _recreateCamera(camera);
        return;
      }

      // Validate image dimensions
      if (decodedImage.width <= 0 || decodedImage.height <= 0) {
        _errorMessage.value =
            'Invalid image dimensions. Please try capturing again.';
        _isProcessing.value = false;
        await _recreateCamera(camera);
        return;
      }

      _documentImage.value = imageBytes;

      // Determine which side is being captured
      final currentSide = _currentStep.value == EkycStep.documentCaptureFront
          ? DocumentSide.front
          : DocumentSide.back;

      // Process document
      await _processDocument(
        imageBytes,
        decodedImage.width,
        decodedImage.height,
        side: currentSide,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to capture document , \n Error: $e \n StackTrace: $stackTrace',
      );
      _errorMessage.value = 'Failed to capture document: ${e.toString()}';
      _isProcessing.value = false; // Reset processing flag on error
      // Recreate camera for next capture
      if (camera != null) {
        await _recreateCamera(camera);
      }
    }
  }

  Future<void> _processDocument(
    Uint8List imageBytes,
    int width,
    int height, {
    required DocumentSide side,
  }) async {
    showLoadingDialog();

    try {
      // Additional delay to ensure buffers are fully released before ML Kit processing
      await Future.delayed(const Duration(milliseconds: 100));

      final capturedImage = CapturedImageEntity(
        bytes: imageBytes,
        width: width,
        height: height,
        source: ImageSource.document,
      );

      // Extract document text using repository with side information
      final docInfo = await loadData(
        ekycRepository.extractDocumentText(capturedImage, side: side),
      );
      if (!docInfo.isValid) {
        _errorMessage.value = 'Failed to extract text from document';
        dismissLoadingDialog();
        _isProcessing.value = false;
        return;
      }

      // Store side-specific data
      if (side == DocumentSide.front) {
        _frontSideInfo.value = docInfo;

        // Small delay before face detection to allow OCR buffers to be released
        await Future.delayed(const Duration(milliseconds: 150));

        // Detect face only on front side
        final faceResult = await loadData(
          ekycRepository.detectDocumentFace(capturedImage),
        );
        _documentFaceResult.value = faceResult;

        if (!faceResult.faceDetected || faceResult.faceCount != 1) {
          // Provide more detailed error message
          String errorMsg;
          if (!faceResult.faceDetected) {
            errorMsg =
                faceResult.errorMessage ??
                'No face detected in document photo. Please ensure:\n'
                    '• The photo is clear and well-lit\n'
                    '• Your face is fully visible\n'
                    '• The document is not blurry\n'
                    '• Try capturing again';
          } else if (faceResult.faceCount > 1) {
            errorMsg =
                'Multiple faces detected in document. Please ensure only one face is visible.';
          } else {
            errorMsg = 'Face detection failed in document';
          }

          _errorMessage.value = errorMsg;
          dismissLoadingDialog();
          _isProcessing.value = false;
          return;
        }

        // Recreate camera for next capture
        final backCamera = _cameras.value.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.value.first,
        );
        await _recreateCamera(backCamera);

        // Move to back side capture
        dismissLoadingDialog();
        _currentStep.value = EkycStep.documentCaptureBack;
      } else {
        // Back side captured
        _backSideInfo.value = docInfo;

        // Merge front and back side data
        _documentInfo.value = _mergeDocumentInfo(
          _frontSideInfo.value,
          _backSideInfo.value,
        );

        dismissLoadingDialog();
        _isProcessing.value = false; // Reset processing flag
        _currentStep.value = EkycStep.documentReview;
      }
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to process document , \n Error: $e \n StackTrace: $stackTrace',
      );
      _errorMessage.value = 'Failed to process document: ${e.toString()}';
      dismissLoadingDialog();
      _isProcessing.value = false; // Reset processing flag on error
    }
  }

  /// Merge front and back side document information (BD NID format)
  DocumentInfoEntity _mergeDocumentInfo(
    DocumentInfoEntity? front,
    DocumentInfoEntity? back,
  ) {
    final frontRaw = front?.rawText ?? '';
    final backRaw = back?.rawText ?? '';
    final mergedRaw = '$frontRaw\n\n$backRaw';

    return DocumentInfoEntity(
      rawText: mergedRaw,
      name: front?.name,
      nameBangla: front?.nameBangla,
      documentNumber: front?.documentNumber ?? back?.documentNumber,
      dateOfBirth: front?.dateOfBirth,
      fatherName: front?.fatherName,
      motherName: front?.motherName,
      address: back?.address ?? front?.address,
      houseHolding: back?.houseHolding ?? front?.houseHolding,
      villageRoad: back?.villageRoad ?? front?.villageRoad,
      postOffice: back?.postOffice ?? front?.postOffice,
      district: back?.district ?? front?.district,
      bloodGroup: back?.bloodGroup,
      placeOfBirth: back?.placeOfBirth,
      issueDate: back?.issueDate,
      expiryDate: back?.expiryDate ?? front?.expiryDate,
    );
  }

  Future<void> proceedToSelfieCapture() async {
    await switchToFrontCamera();
    _currentStep.value = EkycStep.selfieCapture;
    // Start real-time liveness detection after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      startRealtimeLivenessDetection();
    });
  }

  /// Start real-time liveness detection using camera image stream
  void startRealtimeLivenessDetection() {
    final controller = _cameraController.value;
    if (controller == null || !controller.value.isInitialized) {
      Logger.debug(
        'EkycViewModel: Cannot start realtime liveness - camera not initialized',
      );
      return;
    }

    if (_isRealtimeLivenessActive.value) {
      Logger.debug('EkycViewModel: Realtime liveness already active');
      return; // Already running
    }

    _isRealtimeLivenessActive.value = true;
    _realtimeFaceDetected.value = null;
    _realtimeEyesOpen.value = null;
    _realtimeFaceCentered.value = null;

    // Process frames periodically (every 1000ms to avoid performance issues)
    DateTime? lastProcessTime;
    try {
      controller
          .startImageStream((CameraImage image) async {
            if (!_isRealtimeLivenessActive.value) {
              return;
            }

            // Throttle processing to avoid overwhelming the system
            final now = DateTime.now();
            if (lastProcessTime != null &&
                now.difference(lastProcessTime!).inMilliseconds < 1000) {
              return;
            }

            if (_isProcessingFrame) {
              return; // Skip if still processing previous frame
            }

            lastProcessTime = now;
            _isProcessingFrame = true;

            try {
              await _processRealtimeLivenessFrame(image);
            } catch (e, stackTrace) {
              Logger.error(
                'EkycViewModel: Error processing realtime frame: $e\n$stackTrace',
              );
              _realtimeFaceDetected.value = false;
            } finally {
              _isProcessingFrame = false;
            }
          })
          .catchError((error) {
            Logger.error('EkycViewModel: Error starting image stream: $error');
            _isRealtimeLivenessActive.value = false;
          });
    } catch (e) {
      Logger.error('EkycViewModel: Failed to start image stream: $e');
      _isRealtimeLivenessActive.value = false;
    }
  }

  /// Stop real-time liveness detection
  void stopRealtimeLivenessDetection() {
    _isRealtimeLivenessActive.value = false;
    final controller = _cameraController.value;
    if (controller != null && controller.value.isStreamingImages) {
      controller.stopImageStream().catchError((_) {
        // Ignore errors
      });
    }
    _realtimeFaceDetected.value = null;
    _realtimeEyesOpen.value = null;
    _realtimeFaceCentered.value = null;
  }

  /// Process a single camera frame for real-time liveness detection
  Future<void> _processRealtimeLivenessFrame(CameraImage image) async {
    try {
      // Convert CameraImage to Uint8List
      final imageBytes = await _convertCameraImageToBytes(image);
      if (imageBytes == null) {
        Logger.debug('EkycViewModel: Failed to convert CameraImage to bytes');
        _realtimeFaceDetected.value = false;
        return;
      }

      // Detect face using NV21 format (native ML Kit format, faster)
      // Note: We need to call the service directly with format info
      // For now, detectFaces will auto-detect NV21 format
      final faceResult = await ekycRepository.detectSelfieFace(
        CapturedImageEntity(
          bytes: imageBytes,
          width: image.width,
          height: image.height,
          source: ImageSource.selfie,
        ),
      );

      _realtimeFaceDetected.value = faceResult.faceDetected;

      if (!faceResult.faceDetected) {
        _realtimeEyesOpen.value = null;
        _realtimeFaceCentered.value = null;
        Logger.debug(
          'EkycViewModel: No face detected in frame. Error: ${faceResult.errorMessage}',
        );
        return;
      }

      // Check if face is centered
      if (faceResult.bounds != null) {
        _realtimeFaceCentered.value = faceResult.bounds!.isCentered(
          image.width.toDouble(),
          image.height.toDouble(),
        );
      }

      // Eyes-open verification: only from phone front camera (selfie camera)
      // ML Kit eye probabilities: leftEyeOpenProbability, rightEyeOpenProbability (0.0-1.0)
      final controller = _cameraController.value;
      if (controller?.description.lensDirection == CameraLensDirection.front) {
        _realtimeEyesOpen.value = faceResult.eyesOpen;
      } else {
        _realtimeEyesOpen.value = null; // Not front camera - cannot verify eyes
      }
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Error in realtime liveness: $e\n$stackTrace',
      );
      _realtimeFaceDetected.value = false;
    }
  }

  /// Convert CameraImage YUV420 to NV21 format (ML Kit native format)
  /// NV21 is much faster than converting to JPEG and more reliable
  /// Note: CameraImage uses YUV420 format with separate U and V planes
  /// NV21 requires interleaved VU plane (V first, then U)
  Future<Uint8List?> _convertCameraImageToBytes(CameraImage image) async {
    try {
      // Validate image planes
      if (image.planes.length < 3) {
        Logger.error(
          'EkycViewModel: Invalid CameraImage format - expected 3 planes, got ${image.planes.length}',
        );
        return null;
      }

      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      // Get actual bytes and stride information
      final yBuffer = yPlane.bytes;
      final uBuffer = uPlane.bytes;
      final vBuffer = vPlane.bytes;

      final yStride = yPlane.bytesPerRow;
      final uStride = uPlane.bytesPerRow;
      final vStride = vPlane.bytesPerRow;

      // NV21 format: Y plane followed by interleaved VU plane
      // Size: width * height (Y) + width * height / 2 (VU interleaved)
      final ySize = image.width * image.height;
      final uvSize = (image.width * image.height) ~/ 2;
      final nv21Buffer = Uint8List(ySize + uvSize);

      // Copy Y plane, handling stride (bytesPerRow might be larger than width)
      int yOffset = 0;
      int nv21YOffset = 0;
      for (int y = 0; y < image.height; y++) {
        final yRowLength = image.width;
        nv21Buffer.setRange(
          nv21YOffset,
          nv21YOffset + yRowLength,
          yBuffer,
          yOffset,
        );
        yOffset += yStride;
        nv21YOffset += yRowLength;
      }

      // Convert UV planes to interleaved VU format (NV21)
      // NV21: V and U are interleaved, with V first
      // YUV420: U and V are separate planes, each subsampled by 2x2
      int nv21UvOffset = ySize;

      // UV planes are half the size of Y plane (subsampled 2x2)
      final uvWidth = image.width ~/ 2;
      final uvHeight = image.height ~/ 2;

      for (int y = 0; y < uvHeight; y++) {
        for (int x = 0; x < uvWidth; x++) {
          final uIndex = y * uStride + x;
          final vIndex = y * vStride + x;

          if (uIndex < uBuffer.length && vIndex < vBuffer.length) {
            // NV21 format: VU interleaved (V first, then U)
            nv21Buffer[nv21UvOffset++] = vBuffer[vIndex];
            nv21Buffer[nv21UvOffset++] = uBuffer[uIndex];
          }
        }
      }

      return nv21Buffer;
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to convert CameraImage to NV21: $e\n$stackTrace',
      );
      return null;
    }
  }

  Future<void> captureSelfie() async {
    // Stop real-time liveness detection before capture
    stopRealtimeLivenessDetection();

    CameraController? controller;
    CameraDescription? camera;

    try {
      controller = _cameraController.value;
      if (controller == null || !controller.value.isInitialized) {
        _errorMessage.value = 'Camera not initialized';
        return;
      }

      // Save camera reference before disposing
      camera = controller.description;

      // Set processing flag to pause preview
      _isProcessing.value = true;

      // Completely stop and dispose camera to free all buffers
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        await controller.dispose();
      } catch (_) {
        // Ignore errors during cleanup
      }
      _cameraController.value = null;

      // Longer delay to ensure buffers are fully released
      await Future.delayed(const Duration(milliseconds: 400));

      // Recreate camera controller for capture (camera is guaranteed to be set here)
      final newController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await newController.initialize();
      _cameraController.value = newController;

      // Small delay after initialization
      await Future.delayed(const Duration(milliseconds: 150));

      // Restart real-time liveness detection if we're still on selfie capture step
      if (_currentStep.value == EkycStep.selfieCapture) {
        Future.delayed(const Duration(milliseconds: 300), () {
          startRealtimeLivenessDetection();
        });
      }

      final image = await newController.takePicture();
      final imageBytes = await image.readAsBytes();

      // Dispose controller again after capture to free buffers
      try {
        await newController.dispose();
        _cameraController.value = null;
      } catch (_) {
        // Ignore errors
      }

      // Decode to get dimensions
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        _errorMessage.value = 'Failed to decode image';
        _isProcessing.value = false;
        // Recreate camera for next capture
        await _recreateCamera(camera);
        return;
      }

      _selfieImage.value = imageBytes;

      // Process selfie
      await _processSelfie(imageBytes, decodedImage.width, decodedImage.height);
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to capture selfie , \n Error: $e \n StackTrace: $stackTrace',
      );
      _errorMessage.value = 'Failed to capture selfie: ${e.toString()}';
      _isProcessing.value = false; // Reset processing flag on error
      // Recreate camera for next capture
      if (camera != null) {
        await _recreateCamera(camera);
      }
    }
  }

  /// Recreate camera controller after processing
  Future<void> _recreateCamera(CameraDescription camera) async {
    try {
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      _cameraController.value = controller;
      _isProcessing.value = false;
    } catch (e) {
      Logger.error('EkycViewModel: Failed to recreate camera: $e');
      _isProcessing.value = false;
    }
  }

  Future<void> _processSelfie(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    showLoadingDialog();

    try {
      // Additional delay to ensure buffers are fully released before ML Kit processing
      await Future.delayed(const Duration(milliseconds: 150));

      final capturedImage = CapturedImageEntity(
        bytes: imageBytes,
        width: width,
        height: height,
        source: ImageSource.selfie,
      );

      // Detect face in selfie using repository
      final faceResult = await loadData(
        ekycRepository.detectSelfieFace(capturedImage),
      );
      _selfieFaceResult.value = faceResult;

      if (!faceResult.faceDetected || faceResult.faceCount != 1) {
        _errorMessage.value =
            faceResult.errorMessage ?? 'Face detection failed in selfie';
        dismissLoadingDialog();
        _isProcessing.value = false;
        return;
      }

      // Small delay before liveness detection
      await Future.delayed(const Duration(milliseconds: 100));

      dismissLoadingDialog();
      _isProcessing.value = false; // Reset processing flag
      _currentStep.value = EkycStep.livenessDetection;

      // Small delay to let the UI update and show the liveness detection widget
      await Future.delayed(const Duration(milliseconds: 300));

      // Then perform liveness detection
      await performLiveness();
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to process selfie , \n Error: $e \n StackTrace: $stackTrace',
      );
      _errorMessage.value = 'Failed to process selfie: ${e.toString()}';
      dismissLoadingDialog();
      _isProcessing.value = false; // Reset processing flag on error
    }
  }

  Future<void> performLiveness() async {
    if (_selfieImage.value == null) {
      _errorMessage.value = 'Selfie image not available';
      return;
    }

    // Don't show loading dialog - let the widget display the progress
    // showLoadingDialog();

    try {
      final decodedImage = img.decodeImage(_selfieImage.value!);
      if (decodedImage == null) {
        _errorMessage.value = 'Failed to decode selfie image';
        // dismissLoadingDialog();
        return;
      }

      final capturedImage = CapturedImageEntity(
        bytes: _selfieImage.value!,
        width: decodedImage.width,
        height: decodedImage.height,
        source: ImageSource.selfie,
      );

      const requiredChecks = [
        LivenessCheckType.blink,
        LivenessCheckType.headTurnLeft,
        LivenessCheckType.headTurnRight,
      ];

      final result = await loadData(
        ekycRepository.performLivenessDetection(capturedImage, requiredChecks),
      );
      _livenessResult.value = result;

      if (!result.passed) {
        _errorMessage.value =
            result.failureReason ?? 'Liveness detection failed';
        // dismissLoadingDialog();
        return;
      }

      // Small delay to show the success result before moving to verification
      await Future.delayed(const Duration(milliseconds: 1500));

      // dismissLoadingDialog();
      _currentStep.value = EkycStep.verification;
      await performVerification();
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to perform liveness , \n Error: $e \n StackTrace: $stackTrace',
      );
      _errorMessage.value = 'Failed to perform liveness: ${e.toString()}';
      // dismissLoadingDialog();
    }
  }

  Future<void> performVerification() async {
    if (_documentImage.value == null || _selfieImage.value == null) {
      _errorMessage.value = 'Document or selfie image not available';
      return;
    }

    showLoadingDialog();

    try {
      final docDecoded = img.decodeImage(_documentImage.value!);
      final selfieDecoded = img.decodeImage(_selfieImage.value!);

      if (docDecoded == null || selfieDecoded == null) {
        _errorMessage.value = 'Failed to decode images';
        dismissLoadingDialog();
        return;
      }

      final documentImage = CapturedImageEntity(
        bytes: _documentImage.value!,
        width: docDecoded.width,
        height: docDecoded.height,
        source: ImageSource.document,
      );

      final selfieImage = CapturedImageEntity(
        bytes: _selfieImage.value!,
        width: selfieDecoded.width,
        height: selfieDecoded.height,
        source: ImageSource.selfie,
      );

      final result = await loadData(
        ekycRepository.performVerification(
          documentImage: documentImage,
          selfieImage: selfieImage,
        ),
      );

      _verificationResult.value = result;
      dismissLoadingDialog();
      _currentStep.value = EkycStep.result;
    } catch (e, stackTrace) {
      Logger.error(
        'EkycViewModel: Failed to perform verification , \n Error: $e \n StackTrace: $stackTrace',
      );
      _errorMessage.value = 'Failed to perform verification: ${e.toString()}';
      dismissLoadingDialog();
    }
  }

  void retry() {
    _currentStep.value = EkycStep.documentCaptureFront;
    _documentImage.value = null;
    _documentInfo.value = null;
    _frontSideInfo.value = null;
    _backSideInfo.value = null;
    _documentFaceResult.value = null;
    _selfieImage.value = null;
    _selfieFaceResult.value = null;
    _livenessResult.value = null;
    _verificationResult.value = null;
    _errorMessage.value = null;
    _initializeCamera();
  }

  @override
  void onDispose() {
    // Remove listener
    _currentStep.removeListener(_onStepChanged);

    // Stop real-time liveness detection
    stopRealtimeLivenessDetection();

    // Properly dispose camera controller
    final controller = _cameraController.value;
    if (controller != null) {
      // Stop image stream if running to free buffers
      if (controller.value.isStreamingImages) {
        controller.stopImageStream().catchError((_) {
          // Ignore errors during cleanup
        });
      }
      controller.dispose();
    }
    _cameraController.value = null;

    _currentStep.dispose();
    _cameras.dispose();
    _documentImage.dispose();
    _documentInfo.dispose();
    _frontSideInfo.dispose();
    _backSideInfo.dispose();
    _documentFaceResult.dispose();
    _selfieImage.dispose();
    _selfieFaceResult.dispose();
    _livenessResult.dispose();
    _verificationResult.dispose();
    _errorMessage.dispose();
    _isProcessing.dispose();
    _isRealtimeLivenessActive.dispose();
    _realtimeFaceDetected.dispose();
    _realtimeEyesOpen.dispose();
    _realtimeFaceCentered.dispose();
    super.onDispose();
  }
}
