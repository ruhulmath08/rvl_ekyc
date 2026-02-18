# TFLite Model Directory

## Required Model

Place your MobileFaceNet TFLite model file here:

```
mobilefacenet.tflite
```

## Model Specifications

- **Input Size**: 112x112 pixels (RGB)
- **Output Size**: 192-dimensional embedding vector
- **Format**: TensorFlow Lite (.tflite)
- **Quantization**: FP32 or INT8 (recommended)

## Where to Get the Model

### Option 1: Download Pre-trained Model
- Search for "MobileFaceNet TFLite" on GitHub
- Ensure model matches specifications above
- Verify model source is trustworthy

### Option 2: Convert from TensorFlow
If you have a TensorFlow MobileFaceNet model:

```bash
# Install TensorFlow Lite Converter
pip install tensorflow

# Convert model
tflite_convert \
  --saved_model_dir=/path/to/saved_model \
  --output_file=./mobilefacenet.tflite \
  --target_ops=TFLITE_BUILTINS
```

### Option 3: Train Your Own
- Use face recognition datasets (e.g., VGGFace2, CASIA-WebFace)
- Train MobileFaceNet architecture
- Export to TFLite format

## Model Validation

After placing the model, verify it works:

1. Run the app
2. Navigate to eKYC verification
3. Complete verification flow
4. Check logs for any model loading errors

## Alternative Models

If using a different model, update the path in:
`data/lib/local/tflite/face_embedding_service.dart`

```dart
static const String _modelPath = 'assets/models/your_model.tflite';
```

Also update input/output dimensions if different from MobileFaceNet.

## Security Note

- Only use models from trusted sources
- Verify model integrity (checksums)
- Be aware of model biases
- Test with diverse demographics
