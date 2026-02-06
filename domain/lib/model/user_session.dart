class UserSession {
  String userId;
  String accessToken;
  String refreshToken;
  String? email;
  String? name;

  UserSession({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    this.email,
    this.name,
  }) {
    // Validate required fields
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (accessToken.isEmpty) throw ArgumentError('accessToken cannot be empty');
    if (refreshToken.isEmpty) {
      throw ArgumentError('refreshToken cannot be empty');
    }
  }
}
