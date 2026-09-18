enum SlotStatus { available, fillingFast, full }

class MandiSlot {
  final String id;
  final String mandiId;
  final String mandiName;
  final DateTime date;
  final String timeRange; // e.g., "07:00 AM – 09:00 AM"
  final String crop;
  final String gate;
  final int totalCapacity;
  final int bookedCount;
  final SlotStatus status;

  const MandiSlot({
    required this.id,
    required this.mandiId,
    required this.mandiName,
    required this.date,
    required this.timeRange,
    required this.crop,
    required this.gate,
    required this.totalCapacity,
    required this.bookedCount,
    required this.status,
  });

  int get availableCapacity =>
      (totalCapacity - bookedCount).clamp(0, totalCapacity);
  double get occupancyRate => (bookedCount / totalCapacity).clamp(0.0, 1.0);

  MandiSlot copyWith({
    String? id,
    String? mandiId,
    String? mandiName,
    DateTime? date,
    String? timeRange,
    String? crop,
    String? gate,
    int? totalCapacity,
    int? bookedCount,
    SlotStatus? status,
  }) {
    return MandiSlot(
      id: id ?? this.id,
      mandiId: mandiId ?? this.mandiId,
      mandiName: mandiName ?? this.mandiName,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      crop: crop ?? this.crop,
      gate: gate ?? this.gate,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      bookedCount: bookedCount ?? this.bookedCount,
      status: status ?? this.status,
    );
  }
}
