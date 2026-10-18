class Validators {
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile number';
    }
    // Strip spaces, dashes, +91 prefix
    final clean = value.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    final tenDigit = clean.length > 10
        ? clean.substring(clean.length - 10)
        : clean;
    if (tenDigit.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(tenDigit)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String sanitizeMobile(String value) {
    final clean = value.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    return clean.length > 10 ? clean.substring(clean.length - 10) : clean;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid name';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Required-email variant used by Firebase email/password flows.
  /// Kept separate so the existing optional-email behaviour is untouched.
  static String? validateEmailRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    return validateEmail(value);
  }

  /// Firebase requires passwords of at least 6 characters.
  /// The legacy mock flow allows 4; this stricter check is only used
  /// for Firebase email/password registration and sign-in.
  static String? validateFirebasePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateDob(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your date of birth';
    }
    final dobRegex = RegExp(r'^(\d{2})[/\-](\d{2})[/\-](\d{4})$');
    final match = dobRegex.firstMatch(value.trim());
    if (match == null) {
      return 'Use DD/MM/YYYY format';
    }
    final day = int.tryParse(match.group(1)!) ?? 0;
    final month = int.tryParse(match.group(2)!) ?? 0;
    final year = int.tryParse(match.group(3)!) ?? 0;
    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31 ||
        year < 1900 ||
        year > DateTime.now().year) {
      return 'Please enter a valid date of birth';
    }
    return null;
  }
}
