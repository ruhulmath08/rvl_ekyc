class PasswordValidator {
  static PasswordValidationError? getValidationError(String? password) {
    if (password == null) return null;
    if (password.isEmpty) return PasswordValidationError.empty;
    if (password.contains(' ')) {
      return PasswordValidationError.containsSpace;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return PasswordValidationError.noLowercase;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return PasswordValidationError.noUppercase;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return PasswordValidationError.noDigit;
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return PasswordValidationError.noSpecialChar;
    }
    if (password.length < 8) {
      return PasswordValidationError.tooShort;
    }
    return null;
  }

  static bool isValid(String? password) {
    if (password == null) return false;
    return getValidationError(password) == null;
  }
}

enum PasswordValidationError {
  empty,
  containsSpace,
  noDigit,
  noUppercase,
  noLowercase,
  noSpecialChar,
  tooShort,
}
