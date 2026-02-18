# eKYC Implementation Guide

## Overview

This document describes the on-device eKYC (electronic Know Your Customer) verification system implemented in this Flutter application. The system performs complete identity verification without requiring backend connectivity.

## Architecture

The implementation follows Clean Architecture principles with three main layers:

### Domain Layer (`domain/lib/`)
- **Models**: Business entities (`DocumentInfo`, `FaceEmbedding`, `VerificationResult`, etc.)
- **Repository Interfaces**: `EkycRepository` - defines contract for eKYC operations
- **Use Cases**: Business logic for document capture, selfie capture, liveness detection, and verification
- **Exceptions**: Domain-specific exceptions

### Data Layer (`data/lib/`)
- **ML Kit Services**: 
  - `OcrService` - Text recognition from documents
  - `FaceDetectionService` - Face detection and landmark extraction
- **TFLite Service**: 
  - `FaceEmbeddingService` - Generates face embeddings using MobileFaceNet
- **Liveness Detection**: 
  - `LivenessDetectionService` - Active liveness checks
- **Repository Implementation**: `EkycRepositoryImpl` - Implements domain repository interface

### Presentation Layer (`lib/presentation/feature/ekyc/`)
- **ViewModels**: `EkycViewModel` - Manages UI state and business logic
- **Screens**: Mobile portrait/landscape views
- **Widgets**: Camera preview, document capture, selfie capture, result display

## Verification Flow

1. **Document Capture**
   - User captures ID document using back camera
   - System validates image quality
   - Extracts text using OCR (Google ML Kit)
   - Detects face in document (must be exactly one face)

2. **Document Review**
   - Displays captured document image
   - Shows extracted information
   - Confirms face detection success

3. **Selfie Capture**
   - Switches to front camera
   - User captures selfie
   - Validates: exactly one face, centered, eyes open

4. **Liveness Detection**
   - Performs active liveness checks:
     - Blink detection
     - Head turn left
     - Head turn right
   - Ensures person is live and present

5. **Face Verification**
   - Generates face embeddings for both document face and selfie
   - Calculates cosine similarity
   - Compares against threshold (0.65)

6. **Final Result**
   - Verification succeeds only if:
     - Document info extracted successfully
     - Face detected in document
     - Face detected in selfie
     - Liveness checks passed
     - Face match score >= threshold

## Thresholds and Configuration

### Face Match Threshold
- **Current Value**: 0.65 (cosine similarity)
- **Range**: 0.0 to 1.0 (1.0 = identical faces)
- **Recommendation**: 
  - 0.60-0.65: Balanced (recommended for MVP)
  - 0.65-0.70: More strict (fewer false positives, more false negatives)
  - 0.55-0.60: More lenient (more false positives, fewer false negatives)

**Location**: `domain/lib/use_case/verify_face_use_case.dart`

```dart
static const double faceMatchThreshold = 0.65;
```

### Liveness Detection Thresholds
- **Eye Open Probability**: > 0.5 (both eyes)
- **Face Centered**: Within 30% of image center
- **Head Turn**: Detected if offset > 0.1 from center

**Note**: Current implementation uses simplified liveness detection. Production systems should analyze video sequences for more robust detection.

## TFLite Model Setup

### Model Requirements
- **Model**: MobileFaceNet (or compatible face recognition model)
- **Input Size**: 112x112 pixels
- **Output Size**: 192-dimensional embedding vector
- **Format**: TensorFlow Lite (.tflite)

### Setup Instructions

1. **Download Model**
   - Download MobileFaceNet model from a trusted source
   - Or train your own model using face recognition datasets

2. **Place Model File**
   ```
   assets/models/mobilefacenet.tflite
   ```

3. **Update pubspec.yaml** (already done)
   ```yaml
   flutter:
     assets:
       - assets/models/
   ```

4. **Model Path Configuration**
   - Location: `data/lib/local/tflite/face_embedding_service.dart`
   - Current path: `'assets/models/mobilefacenet.tflite'`
   - Update if using different model name

### Model Alternatives
- **ArcFace**: Higher accuracy, larger model size
- **FaceNet**: Google's face recognition model
- **Custom Models**: Train on specific demographic data

## Security Considerations

### ⚠️ Important Security Limitations

This implementation is designed for **MVP/Demo purposes** and has significant security limitations:

#### 1. **On-Device Processing Only**
- ✅ No data sent to servers
- ✅ Privacy-preserving
- ❌ No centralized fraud detection
- ❌ No cross-device verification history

#### 2. **Image Storage**
- ✅ Raw images deleted after verification
- ✅ Only embeddings stored (if needed)
- ⚠️ Images exist in memory during processing
- ⚠️ No encryption at rest for temporary data

#### 3. **Liveness Detection**
- ⚠️ Simplified implementation
- ⚠️ Single-frame analysis (not video sequence)
- ⚠️ Vulnerable to sophisticated spoofing attacks
- ⚠️ No 3D face analysis

#### 4. **Face Matching**
- ⚠️ Threshold-based matching (not ML-based decision)
- ⚠️ No demographic-specific thresholds
- ⚠️ May have bias issues with certain demographics

#### 5. **Document Verification**
- ⚠️ OCR text extraction only (no document authenticity check)
- ⚠️ No hologram detection
- ⚠️ No security feature validation
- ⚠️ No database cross-reference

### Security Best Practices (Not Implemented)

For production use, consider:

1. **Backend Verification**
   - Centralized fraud detection
   - Document database validation
   - Cross-reference with government databases
   - Audit logging

2. **Enhanced Liveness**
   - Video sequence analysis
   - 3D face depth detection
   - Challenge-response mechanisms
   - Anti-spoofing ML models

3. **Document Security**
   - Hologram detection
   - UV light verification
   - Security feature validation
   - Document template matching

4. **Data Protection**
   - End-to-end encryption
   - Secure key management
   - Biometric data encryption
   - Compliance with GDPR/HIPAA

5. **Audit and Monitoring**
   - Verification attempt logging
   - Failure pattern detection
   - Anomaly detection
   - Rate limiting

## Regulatory Compliance

### ⚠️ Not Suitable For

- **Financial Services**: Banking, payment processing (requires KYC/AML compliance)
- **Healthcare**: HIPAA-regulated identity verification
- **Government Services**: Official ID verification
- **High-Risk Applications**: Where identity fraud has severe consequences

### ✅ Suitable For

- **MVP/Demo**: Proof of concept demonstrations
- **Low-Risk Applications**: Non-critical identity checks
- **Offline Scenarios**: Areas with limited connectivity
- **Privacy-Focused**: Applications requiring on-device processing

### Compliance Requirements

If deploying for production use:

1. **KYC/AML Compliance**
   - Implement backend verification
   - Maintain audit trails
   - Comply with local regulations
   - Regular compliance audits

2. **Data Privacy**
   - GDPR compliance (EU)
   - CCPA compliance (California)
   - Local data protection laws
   - User consent management

3. **Biometric Data**
   - Biometric data protection laws
   - User consent for biometric processing
   - Data retention policies
   - Right to deletion

## Performance Considerations

### Device Requirements
- **Minimum**: Android 5.0+ / iOS 11.0+
- **Recommended**: Android 8.0+ / iOS 13.0+
- **RAM**: 2GB+ recommended
- **Storage**: ~50MB for models and dependencies

### Processing Times (Approximate)
- **OCR**: 2-5 seconds
- **Face Detection**: 1-2 seconds
- **Face Embedding**: 0.5-1 second
- **Liveness Detection**: 2-3 seconds
- **Total Verification**: 8-15 seconds

### Optimization Tips
1. **Model Optimization**
   - Use quantized models (INT8) for faster inference
   - Consider model pruning for smaller size
   - Use GPU acceleration if available

2. **Image Processing**
   - Resize images before processing
   - Use appropriate image formats
   - Cache processed results

3. **Memory Management**
   - Dispose resources properly
   - Limit concurrent operations
   - Use streaming for large images

## Testing Recommendations

### Unit Tests
- Use case logic
- Repository implementations
- Model parsing

### Integration Tests
- End-to-end verification flow
- Error handling
- Edge cases

### Manual Testing Scenarios
1. **Valid Verification**
   - Clear document image
   - Good lighting
   - Same person in document and selfie

2. **Edge Cases**
   - Poor lighting
   - Blurry images
   - Different person in selfie
   - Multiple faces
   - No face detected

3. **Liveness Tests**
   - Blink detection
   - Head movement
   - Mask/sunglasses detection

## Troubleshooting

### Common Issues

1. **TFLite Model Not Found**
   - Ensure model file exists at `assets/models/mobilefacenet.tflite`
   - Run `flutter pub get`
   - Clean and rebuild: `flutter clean && flutter pub get`

2. **Camera Not Initializing**
   - Check camera permissions
   - Verify camera availability
   - Check device compatibility

3. **Face Detection Fails**
   - Ensure good lighting
   - Check face is clearly visible
   - Verify camera focus

4. **Low Face Match Score**
   - Check image quality
   - Ensure same person in both images
   - Consider adjusting threshold

## Future Enhancements

1. **Enhanced Liveness**
   - Video sequence analysis
   - 3D face detection
   - Challenge-response

2. **Document Verification**
   - Security feature detection
   - Template matching
   - Hologram detection

3. **Performance**
   - Model optimization
   - GPU acceleration
   - Caching strategies

4. **User Experience**
   - Real-time feedback
   - Better error messages
   - Progress indicators

## References

- [Google ML Kit Documentation](https://developers.google.com/ml-kit)
- [TensorFlow Lite](https://www.tensorflow.org/lite)
- [MobileFaceNet Paper](https://arxiv.org/abs/1804.07573)
- [KYC/AML Compliance Guide](https://www.fatf-gafi.org/)

---

**Last Updated**: February 2026
**Version**: 1.0.0
