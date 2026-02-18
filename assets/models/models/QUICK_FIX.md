# ⚠️ QUICK FIX: Missing TFLite Model

## The Problem
The app is looking for `mobilefacenet.tflite` but the file doesn't exist.

## Quick Solution

### Step 1: Download the Model

**Option A: Use this GitHub repository**
```bash
# Navigate to assets/models directory
cd assets/models

# Download MobileFaceNet TFLite model (example - replace with actual URL)
# You can search GitHub for "mobilefacenet tflite" and download from a trusted source
```

**Option B: Search and Download**
1. Go to: https://github.com/search?q=mobilefacenet+tflite
2. Find a repository with the model file
3. Download `mobilefacenet.tflite` or similar
4. Place it in `assets/models/` directory

### Step 2: Verify File Location

The file should be at:
```
assets/models/mobilefacenet.tflite
```

### Step 3: Rebuild App

```bash
flutter clean
flutter pub get
flutter run
```

## Alternative: Use Different Model Name

If you have a model with a different name:

1. Update `data/lib/services/tflite/face_embedding_service.dart`:
   ```dart
   static const String _modelPath = 'assets/models/your_model_name.tflite';
   ```

2. Update input/output sizes if different from MobileFaceNet (112x112 input, 192-dim output)

## Model Requirements

- **Format**: `.tflite` (TensorFlow Lite)
- **Input**: 112x112 RGB image
- **Output**: 192-dimensional embedding vector
- **Purpose**: Face recognition/embedding generation

## Still Having Issues?

1. Check `pubspec.yaml` includes:
   ```yaml
   flutter:
     assets:
       - assets/models/
   ```

2. Verify file exists:
   ```bash
   ls -lh assets/models/mobilefacenet.tflite
   ```

3. Check file permissions (should be readable)

4. Run `flutter clean` before rebuilding

---

**Note**: The model file is typically 1-5 MB in size. Make sure it's not corrupted.
