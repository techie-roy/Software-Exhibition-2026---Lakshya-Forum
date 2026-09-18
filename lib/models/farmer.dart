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
      };

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
        id: json['id'] as String? ?? 'FID-UP-78219',
        name: json['name'] as String? ?? 'Rajesh Kumar',
        mobile: json['mobile'] as String? ?? '+91 9876543210',
        mandiId: json['mandiId'] as String? ?? 'MND-LKO-01',
        mandiName: json['mandiName'] as String? ?? 'Lucknow Central Mandi',
        mandiAddress: json['mandiAddress'] as String? ?? 'Transport Nagar, Lucknow, UP',
        landSizeAcres: (json['landSizeAcres'] as num?)?.toDouble() ?? 6.5,
        village: json['village'] as String? ?? 'Malihabad',
        district: json['district'] as String? ?? 'Lucknow',
        state: json['state'] as String? ?? 'Uttar Pradesh',
        kisanCreditCard: json['kisanCreditCard'] as String? ?? 'KCC-8821-4412-9901',
        aadhaarMasked: json['aadhaarMasked'] as String? ?? 'XXXX-XXXX-4819',
        bankAccountMasked: json['bankAccountMasked'] as String? ?? 'SBI ••••••••3912',
        bankName: json['bankName'] as String? ?? 'State Bank of India',
        avatarInitials: json['avatarInitials'] as String? ?? 'RK',
      );

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
    );
  }
}
