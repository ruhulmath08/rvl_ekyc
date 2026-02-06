class EmailValidator {
  static RegExp emailRegExp = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  static EmailValidationError? getValidationError(String? email) {
    if (email == null) return null;
    if (email.isEmpty) return EmailValidationError.empty;
    if (!emailRegExp.hasMatch(email)) return EmailValidationError.invalid;
    return null;
  }

  static bool isValid(String? email) {
    if (email == null) return false;
    return getValidationError(email) == null;
  }
}

enum EmailValidationError {
  empty,
  invalid,
}
