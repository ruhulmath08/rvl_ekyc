# eKYC Quick Start Guide

## Prerequisites

1. **Flutter SDK**: 3.35.4 or higher
2. **Dart SDK**: 3.9.2 or higher
3. **Device**: Physical device with camera (Android/iOS)
4. **TFLite Model**: MobileFaceNet model file

## Setup Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Add TFLite Model

1. Download MobileFaceNet TFLite model
2. Place it at: `assets/models/mobilefacenet.tflite`
3. Ensure the file is included in `pubspec.yaml` assets

### 3. Configure Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.camera.front" android:required="true" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for identity verification</string>
```

### 4. Initialize Data Module

Ensure `DataModule` is initialized in your app startup:

```dart
// In main.dart or app initialization
await DataModule().injectDependencies();
```

### 5. Navigate to eKYC Screen

```dart
import 'package:hello_flutter/presentation/feature/ekyc/route/ekyc_route.dart';
import 'package:hello_flutter/presentation/feature/ekyc/route/ekyc_argument.dart';
import 'package:hello_flutter/presentation/navigation/app_router.dart';

// Navigate to eKYC
AppRouter.navigateTo(
  context: context,
  appRoute: EkycRoute(arguments: const EkycArgument()),
);
```

## Testing the Implementation

### Basic Test Flow

1. **Launch App**: Navigate to eKYC screen
2. **Document Capture**: 
   - Point camera at ID document
   - Ensure good lighting
   - Tap capture button
3. **Review Document**: 
   - Verify extracted information
   - Confirm face detected
   - Tap "Continue"
4. **Selfie Capture**:
   - Front camera should activate
   - Position face in oval guide
   - Tap capture button
5. **Liveness Detection**:
   - System performs checks automatically
   - Wait for completion
6. **Verification**:
   - System compares faces
   - Displays result

### Expected Results

- **Success**: Green checkmark, verification successful
- **Failure**: Red error, reason displayed

## Troubleshooting

### Model Not Found Error

```
Error: Failed to load TFLite model
```

**Solution**: 
- Verify model file exists at `assets/models/mobilefacenet.tflite`
- Run `flutter clean && flutter pub get`
- Rebuild app

### Camera Not Initializing

```
Error: Camera not initialized
```

**Solution**:
- Check camera permissions granted
- Verify device has camera
- Check AndroidManifest.xml / Info.plist permissions

### Face Detection Fails

**Solution**:
- Ensure good lighting
- Face clearly visible
- No obstructions (mask, sunglasses)
- Try different angle

### Low Face Match Score

**Solution**:
- Ensure same person in document and selfie
- Check image quality
- Consider adjusting threshold in `VerifyFaceUseCase`

## Customization

### Adjust Face Match Threshold

Edit `domain/lib/use_case/verify_face_use_case.dart`:

```dart
static const double faceMatchThreshold = 0.65; // Change this value
```

### Modify Liveness Checks

Edit `domain/lib/use_case/perform_liveness_use_case.dart`:

```dart
const requiredChecks = [
  LivenessCheckType.blink,
  LivenessCheckType.headTurnLeft,
  LivenessCheckType.headTurnRight,
  // Add or remove checks
];
```

### Custom OCR Parsing

Edit `data/lib/local/ml_kit/ocr_service.dart`:

```dart
DocumentInfo _parseDocumentInfo(String rawText) {
  // Customize parsing logic for your document format
}
```

## Next Steps

1. **Test with Real Documents**: Verify with actual ID documents
2. **Adjust Thresholds**: Fine-tune based on test results
3. **Enhance UI**: Customize widgets for your brand
4. **Add Analytics**: Track verification success rates
5. **Security Review**: Review security considerations in main documentation

## Support

For detailed information, see:
- [eKYC Implementation Guide](./ekyc-implementation.md)
- [Architecture Documentation](../reference/architecture.md)

---

**Note**: This is an MVP implementation. For production use, review security limitations and compliance requirements.
