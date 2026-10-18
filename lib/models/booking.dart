enum BookingStatus { confirmed, inQueue, completed, cancelled }

class Booking {
  final String id;
  final String tokenNumber;
  final String farmerId;
  final String farmerName;
  final String mandiId;
  final String mandiName;
  final String crop;
  final DateTime date;
  final String timeRange;
  final String gate;
  final BookingStatus status;
  final DateTime createdAt;
  final double estimatedQuantityQuintal;

  const Booking({
    required this.id,
    required this.tokenNumber,
    required this.farmerId,
    required this.farmerName,
    required this.mandiId,
    required this.mandiName,
    required this.crop,
    required this.date,
    required this.timeRange,
    required this.gate,
    required this.status,
    required this.createdAt,
    this.estimatedQuantityQuintal = 40.0,
  });

  Booking copyWith({
    String? id,
    String? tokenNumber,
    String? farmerId,
    String? farmerName,
    String? mandiId,
    String? mandiName,
    String? crop,
    DateTime? date,
    String? timeRange,
    String? gate,
    BookingStatus? status,
    DateTime? createdAt,
    double? estimatedQuantityQuintal,
  }) => Booking(
    id: id ?? this.id,
    tokenNumber: tokenNumber ?? this.tokenNumber,
    farmerId: farmerId ?? this.farmerId,
    farmerName: farmerName ?? this.farmerName,
    mandiId: mandiId ?? this.mandiId,
    mandiName: mandiName ?? this.mandiName,
    crop: crop ?? this.crop,
    date: date ?? this.date,
    timeRange: timeRange ?? this.timeRange,
    gate: gate ?? this.gate,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    estimatedQuantityQuintal:
        estimatedQuantityQuintal ?? this.estimatedQuantityQuintal,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tokenNumber': tokenNumber,
    'farmerId': farmerId,
    'farmerName': farmerName,
    'mandiId': mandiId,
    'mandiName': mandiName,
    'crop': crop,
    'date': date.toIso8601String(),
    'timeRange': timeRange,
    'gate': gate,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'estimatedQuantityQuintal': estimatedQuantityQuintal,
  };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    tokenNumber: json['tokenNumber'] as String,
    farmerId: json['farmerId'] as String,
    farmerName: json['farmerName'] as String,
    mandiId: json['mandiId'] as String,
    mandiName: json['mandiName'] as String,
    crop: json['crop'] as String,
    date: DateTime.parse(json['date'] as String),
    timeRange: json['timeRange'] as String,
    gate: json['gate'] as String,
    status: BookingStatus.values.byName(
      json['status'] as String? ?? 'confirmed',
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    estimatedQuantityQuintal:
        (json['estimatedQuantityQuintal'] as num?)?.toDouble() ?? 40.0,
  );
}
