/// Face embedding vector for face matching
class FaceEmbeddingEntity {
  final List<double> vector;
  final DateTime timestamp;

  FaceEmbeddingEntity({
    required this.vector,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Calculate Euclidean distance to another embedding
  double euclideanDistance(FaceEmbeddingEntity other) {
    if (vector.length != other.vector.length) {
      throw ArgumentError('Embeddings must have the same dimension');
    }

    double sum = 0.0;
    for (int i = 0; i < vector.length; i++) {
      final diff = vector[i] - other.vector[i];
      sum += diff * diff;
    }
    return sum;
  }

  /// Calculate cosine similarity to another embedding
  /// Returns value between -1 and 1, where 1 is identical
  double cosineSimilarity(FaceEmbeddingEntity other) {
    if (vector.length != other.vector.length) {
      throw ArgumentError('Embeddings must have the same dimension');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < vector.length; i++) {
      dotProduct += vector[i] * other.vector[i];
      normA += vector[i] * vector[i];
      normB += other.vector[i] * other.vector[i];
    }

    if (normA == 0.0 || normB == 0.0) {
      return 0.0;
    }

    return dotProduct / (normA * normB);
  }
}
