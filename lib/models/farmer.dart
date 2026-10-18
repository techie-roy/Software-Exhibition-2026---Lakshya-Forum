class Farmer {
  final String id;
  final String name;
  final String mobile;
  final String mandiId;
  final String mandiName;
  final String mandiAddress;
  final double landSizeAcres;
  final String village;
  final String district;
  final String state;
  final String kisanCreditCard;
  final String aadhaarMasked;
  final String bankAccountMasked;
  final String bankName;
  final String avatarInitials;

  /// Optional profile-photo URL (e.g. the Google profile photo). Never a
  /// local file path or secret — plain https URL or null.
  final String? photoUrl;

  /// Optional email address associated with the account.
  final String? email;

  const Farmer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.mandiId,
    required this.mandiName,
    required this.mandiAddress,
    required this.landSizeAcres,
    required this.village,
    required this.district,
    required this.state,
    required this.kisanCreditCard,
    required this.aadhaarMasked,
    required this.bankAccountMasked,
    required this.bankName,
    required this.avatarInitials,
    this.photoUrl,
    this.email,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mobile': mobile,
    'mandiId': mandiId,
    'mandiName': mandiName,
    'mandiAddress': mandiAddress,
    'landSizeAcres': landSizeAcres,
    'village': village,
    'district': district,
    'state': state,
    'kisanCreditCard': kisanCreditCard,
    'aadhaarMasked': aadhaarMasked,
    'bankAccountMasked': bankAccountMasked,
    'bankName': bankName,
    'avatarInitials': avatarInitials,
    'photoUrl': photoUrl,
    'email': email,
  };

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    mobile: json['mobile'] as String? ?? '',
    mandiId: json['mandiId'] as String? ?? '',
    mandiName: json['mandiName'] as String? ?? '',
    mandiAddress: json['mandiAddress'] as String? ?? '',
    landSizeAcres: (json['landSizeAcres'] as num?)?.toDouble() ?? 0,
    village: json['village'] as String? ?? '',
    district: json['district'] as String? ?? '',
    state: json['state'] as String? ?? '',
    kisanCreditCard: json['kisanCreditCard'] as String? ?? '',
    aadhaarMasked: json['aadhaarMasked'] as String? ?? '',
    bankAccountMasked: json['bankAccountMasked'] as String? ?? '',
    bankName: json['bankName'] as String? ?? '',
    avatarInitials: json['avatarInitials'] as String? ?? 'F',
    photoUrl: json['photoUrl'] as String?,
    email: json['email'] as String?,
  );

  /// Builds a neutral profile for an account authenticated outside the mock
  /// database (e.g. a Firebase email/password or phone account). It never
  /// impersonates a seeded demo farmer: the name comes from [displayName],
  /// the email's local-part, or falls back to a neutral word, and all
  /// mandi/land/KYC fields start empty until the user provides them.
  ///
  /// [mobile] is set for phone-verified accounts (server number or user
  /// input); [photoUrl] carries the provider profile photo when available.
  factory Farmer.forExternalAccount({
    required String email,
    String? displayName,
    String mobile = '',
    String? photoUrl,
  }) {
    final trimmedDisplay = displayName?.trim() ?? '';
    final trimmedEmail = email.trim();
    final localPart = trimmedEmail.contains('@')
        ? trimmedEmail.split('@').first
        : trimmedEmail;
    final name = trimmedDisplay.isNotEmpty
        ? trimmedDisplay
        : _nameFromEmailLocalPart(localPart);
    // Key the stable id on the email when there is one, else the verified
    // phone number, so two phone accounts never collide on one id.
    final identityKey = trimmedEmail.isNotEmpty
        ? trimmedEmail.toLowerCase()
        : mobile.replaceAll(RegExp(r'\D'), '');
    return Farmer(
      id: 'FID-EXT-${_stableSuffix(identityKey)}',
      name: name,
      mobile: mobile,
      mandiId: '',
      mandiName: '',
      mandiAddress: '',
      landSizeAcres: 0,
      village: '',
      district: '',
      state: '',
      kisanCreditCard: '',
      aadhaarMasked: '',
      bankAccountMasked: '',
      bankName: '',
      avatarInitials: _initialsFromName(name),
      photoUrl: photoUrl,
      email: trimmedEmail.isNotEmpty ? trimmedEmail : null,
    );
  }

  static String _nameFromEmailLocalPart(String localPart) {
    final cleaned = localPart
        .split(RegExp(r'[._\-+]+'))
        .where((part) => part.isNotEmpty)
        .join(' ');
    if (cleaned.isEmpty) return 'Farmer';
    return cleaned
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'F';
    return parts.take(2).map((w) => w[0].toUpperCase()).join();
  }

  /// Deterministic short suffix (FNV-1a, 32-bit) so the same account always
  /// maps to the same id across restarts without exposing the raw email.
  static String _stableSuffix(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  Farmer copyWith({
    String? id,
    String? name,
    String? mobile,
    String? mandiId,
    String? mandiName,
    String? mandiAddress,
    double? landSizeAcres,
    String? village,
    String? district,
    String? state,
    String? kisanCreditCard,
    String? aadhaarMasked,
    String? bankAccountMasked,
    String? bankName,
    String? avatarInitials,
    String? photoUrl,
    String? email,
  }) {
    return Farmer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      mandiId: mandiId ?? this.mandiId,
      mandiName: mandiName ?? this.mandiName,
      mandiAddress: mandiAddress ?? this.mandiAddress,
      landSizeAcres: landSizeAcres ?? this.landSizeAcres,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      kisanCreditCard: kisanCreditCard ?? this.kisanCreditCard,
      aadhaarMasked: aadhaarMasked ?? this.aadhaarMasked,
      bankAccountMasked: bankAccountMasked ?? this.bankAccountMasked,
      bankName: bankName ?? this.bankName,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
    );
  }
}
