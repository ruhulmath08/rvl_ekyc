# TFLite Model Setup Instructions

## ⚠️ Required: Add MobileFaceNet Model

The eKYC feature requires a TFLite model file for face embedding generation.

## Quick Setup

### Option 1: Download Pre-trained Model (Recommended)

1. **Download MobileFaceNet TFLite model**
   - Search GitHub for "MobileFaceNet TFLite" or "mobilefacenet.tflite"
   - Recommended sources:
     - [TensorFlow Hub](https://tfhub.dev/)
     - [GitHub - MobileFaceNet](https://github.com/search?q=mobilefacenet+tflite)
   
2. **Place the model file**
   ```
   assets/models/mobilefacenet.tflite
   ```

3. **Verify the file exists**
   ```bash
   ls -lh assets/models/mobilefacenet.tflite
   ```

4. **Rebuild the app**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Option 2: Use Alternative Model

If you have a different face recognition model:

1. Update the model path in `data/lib/services/tflite/face_embedding_service.dart`:
   ```dart
   static const String _modelPath = 'assets/models/your_model.tflite';
   ```

2. Update input/output dimensions if different:
   ```dart
   static const int _inputSize = 112; // Your model input size
   static const int _embeddingSize = 192; // Your model output size
   ```

## Model Specifications

- **Format**: TensorFlow Lite (.tflite)
- **Input Size**: 112x112 pixels (RGB)
- **Output Size**: 192-dimensional embedding vector
- **Quantization**: FP32 or INT8 (INT8 recommended for performance)

## Model Sources

### Official Sources
- TensorFlow Lite Model Zoo
- TensorFlow Hub
- Research paper implementations

### GitHub Repositories
Search for:
- "MobileFaceNet TFLite"
- "face recognition tflite"
- "face embedding tflite"

## Verification

After adding the model, the app should:
1. Load without errors
2. Successfully initialize the face embedding service
3. Complete face verification flow

## Troubleshooting

### Error: "Unable to load asset"
- ✅ Check file exists at correct path
- ✅ Verify `pubspec.yaml` includes `assets/models/`
- ✅ Run `flutter clean && flutter pub get`
- ✅ Rebuild the app

### Error: "Failed to initialize interpreter"
- ✅ Verify model file is valid TFLite format
- ✅ Check model input/output dimensions match code
- ✅ Ensure model is not corrupted

### Model Not Found
- ✅ Check file name matches exactly: `mobilefacenet.tflite`
- ✅ Verify file is in `assets/models/` directory
- ✅ Check file permissions

## Testing Without Model (Development Only)

For development/testing without the model, you can temporarily modify the service to return mock embeddings. However, **face verification will not work correctly**.

## Security Note

- Only download models from trusted sources
- Verify model integrity (checksums if available)
- Be aware of potential model biases
- Test with diverse demographics

---

**Need Help?** See `docs/guides/ekyc-implementation.md` for detailed documentation.
