import '../models/booking.dart';
import '../models/market_price.dart';
import '../models/procurement.dart';
import '../models/queue.dart';
import '../models/slot.dart';

class MandiGateStatus {
  final String gateName;
  final String crop;
  final int currentCount;
  final int totalCapacity;
  final String statusText;
  final bool isHighCrowd;

  const MandiGateStatus({
    required this.gateName,
    required this.crop,
    required this.currentCount,
    required this.totalCapacity,
    required this.statusText,
    required this.isHighCrowd,
  });

  double get progress => (currentCount / totalCapacity).clamp(0.0, 1.0);
}

class MockDataService {
  static final DateTime today = DateTime.now();
  static final DateTime tomorrow = today.add(const Duration(days: 1));
  static final DateTime dayAfter = today.add(const Duration(days: 2));

  // Default active booking for farmer Rajesh Kumar
  Booking activeBooking = Booking(
    id: 'AQ-2026-8821',
    tokenNumber: 'A-125',
    farmerId: 'FID-UP-78219',
    farmerName: 'Rajesh Kumar',
    mandiId: 'MND-LKO-01',
    mandiName: 'Lucknow Central Mandi',
    crop: 'wheat',
    date: today,
    timeRange: '07:00 AM – 09:00 AM',
    gate: 'Gate 2',
    status: BookingStatus.inQueue,
    createdAt: today.subtract(const Duration(hours: 3)),
    estimatedQuantityQuintal: 45.0,
  );

  final List<Booking> _bookingHistory = [
    Booking(
      id: 'AQ-2026-7412',
      tokenNumber: 'W-084',
      farmerId: 'FID-UP-78219',
      farmerName: 'Rajesh Kumar',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      crop: 'mustard',
      date: today.subtract(const Duration(days: 12)),
      timeRange: '09:00 AM – 11:00 AM',
      gate: 'Gate 1',
      status: BookingStatus.completed,
      createdAt: today.subtract(const Duration(days: 13)),
      estimatedQuantityQuintal: 25.0,
    ),
    Booking(
      id: 'AQ-2026-5901',
      tokenNumber: 'P-112',
      farmerId: 'FID-UP-78219',
      farmerName: 'Rajesh Kumar',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      crop: 'paddy',
      date: today.subtract(const Duration(days: 28)),
      timeRange: '11:00 AM – 01:00 PM',
      gate: 'Gate 4',
      status: BookingStatus.completed,
      createdAt: today.subtract(const Duration(days: 29)),
      estimatedQuantityQuintal: 60.0,
    ),
  ];

  /// All bookings in the system, with the active booking first. The active
  /// booking is never duplicated: ids are de-duplicated defensively so a
  /// booking cannot appear both as [activeBooking] and in the history list.
  List<Booking> get allBookings {
    final seenIds = <String>{activeBooking.id};
    return [activeBooking, ..._bookingHistory.where((b) => seenIds.add(b.id))];
  }

  // Live gate crowd statuses
  final List<MandiGateStatus> gateStatuses = const [
    MandiGateStatus(
      gateName: 'Gate 2',
      crop: 'wheat',
      currentCount: 350,
      totalCapacity: 600,
      statusText: 'active',
      isHighCrowd: false,
    ),
    MandiGateStatus(
      gateName: 'Gate 4',
      crop: 'paddy',
      currentCount: 520,
      totalCapacity: 600,
      statusText: 'high_crowd',
      isHighCrowd: true,
    ),
    MandiGateStatus(
      gateName: 'Gate 1',
      crop: 'mustard',
      currentCount: 180,
      totalCapacity: 500,
      statusText: 'smooth',
      isHighCrowd: false,
    ),
  ];

  // Available procurement slots
  late final List<MandiSlot> _availableSlots = [
    // Today
    MandiSlot(
      id: 'SLOT-101',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: today,
      timeRange: '07:00 AM – 09:00 AM',
      crop: 'wheat',
      gate: 'Gate 2',
      totalCapacity: 600,
      bookedCount: 350,
      status: SlotStatus.available,
    ),
    MandiSlot(
      id: 'SLOT-102',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: today,
      timeRange: '09:00 AM – 11:00 AM',
      crop: 'wheat',
      gate: 'Gate 2',
      totalCapacity: 600,
      bookedCount: 540,
      status: SlotStatus.fillingFast,
    ),
    MandiSlot(
      id: 'SLOT-103',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: today,
      timeRange: '11:00 AM – 01:00 PM',
      crop: 'wheat',
      gate: 'Gate 2',
      totalCapacity: 600,
      bookedCount: 350,
      status: SlotStatus.available,
    ),
    MandiSlot(
      id: 'SLOT-104',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: today,
      timeRange: '02:00 PM – 04:00 PM',
      crop: 'paddy',
      gate: 'Gate 4',
      totalCapacity: 600,
      bookedCount: 520,
      status: SlotStatus.fillingFast,
    ),
    MandiSlot(
      id: 'SLOT-105',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: today,
      timeRange: '04:00 PM – 06:00 PM',
      crop: 'mustard',
      gate: 'Gate 1',
      totalCapacity: 500,
      bookedCount: 180,
      status: SlotStatus.available,
    ),
    // Tomorrow
    MandiSlot(
      id: 'SLOT-201',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: tomorrow,
      timeRange: '07:00 AM – 09:00 AM',
      crop: 'wheat',
      gate: 'Gate 2',
      totalCapacity: 600,
      bookedCount: 120,
      status: SlotStatus.available,
    ),
    MandiSlot(
      id: 'SLOT-202',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: tomorrow,
      timeRange: '09:00 AM – 11:00 AM',
      crop: 'wheat',
      gate: 'Gate 2',
      totalCapacity: 600,
      bookedCount: 210,
      status: SlotStatus.available,
    ),
    MandiSlot(
      id: 'SLOT-203',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: tomorrow,
      timeRange: '11:00 AM – 01:00 PM',
      crop: 'paddy',
      gate: 'Gate 4',
      totalCapacity: 600,
      bookedCount: 410,
      status: SlotStatus.fillingFast,
    ),
    MandiSlot(
      id: 'SLOT-204',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: tomorrow,
      timeRange: '02:00 PM – 04:00 PM',
      crop: 'maize',
      gate: 'Gate 3',
      totalCapacity: 500,
      bookedCount: 140,
      status: SlotStatus.available,
    ),
    // Day After Tomorrow
    MandiSlot(
      id: 'SLOT-301',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: dayAfter,
      timeRange: '07:00 AM – 09:00 AM',
      crop: 'wheat',
      gate: 'Gate 2',
      totalCapacity: 600,
      bookedCount: 80,
      status: SlotStatus.available,
    ),
    MandiSlot(
      id: 'SLOT-302',
      mandiId: 'MND-LKO-01',
      mandiName: 'Lucknow Central Mandi',
      date: dayAfter,
      timeRange: '11:00 AM – 01:00 PM',
      crop: 'sugarcane',
      gate: 'Gate 5',
      totalCapacity: 700,
      bookedCount: 220,
      status: SlotStatus.available,
    ),
  ];

  List<MandiSlot> get availableSlots => List.unmodifiable(_availableSlots);

  // Live Queue Information
  int _queueRefreshCount = 0;

  LiveQueueData getLiveQueueData() {
    _queueRefreshCount = (_queueRefreshCount + 1) % 12;
    final farmersAhead = 169 - _queueRefreshCount * 3;
    final estWait = 162 - _queueRefreshCount * 6;

    final completedSteps = _queueRefreshCount % 4;

    return LiveQueueData(
      tokenNumber: activeBooking.tokenNumber,
      gate: activeBooking.gate,
      crop: activeBooking.crop,
      mandiName: activeBooking.mandiName,
      farmersAhead: farmersAhead,
      estimatedWaitMinutes: estWait,
      totalDailyCapacity: 600,
      currentGateProcessing: 350,
      steps: [
        QueueStep(
          titleKey: 'step_booked',
          descriptionKey: 'step_booked_desc',
          isCompleted: true,
          time: '06:30 AM',
        ),
        QueueStep(
          titleKey: 'step_arrived',
          descriptionKey: 'step_arrived_desc',
          isCompleted: true,
          time: '07:15 AM',
        ),
        QueueStep(
          titleKey: 'step_in_queue',
          descriptionKey: 'step_in_queue_desc',
          isCompleted: completedSteps >= 2,
          isCurrent: completedSteps < 2,
          time: '07:45 AM',
        ),
        QueueStep(
          titleKey: 'step_at_gate',
          descriptionKey: 'step_at_gate_desc',
          isCompleted: completedSteps >= 3,
          isCurrent: completedSteps >= 2,
        ),
        QueueStep(
          titleKey: 'step_procurement',
          descriptionKey: 'step_procurement_desc',
          isCompleted: completedSteps >= 4,
          isCurrent: completedSteps >= 3,
        ),
        QueueStep(
          titleKey: 'step_completed',
          descriptionKey: 'step_completed_desc',
          isCompleted: false,
          isCurrent: false,
        ),
      ],
    );
  }

  // Market Prices
  final List<MarketPrice> marketPrices = [
    MarketPrice(
      id: 'MP-01',
      cropName: 'wheat',
      category: 'cereals',
      currentPrice: 2125,
      minPrice: 2050,
      maxPrice: 2200,
      changePercentage: 1.2,
      trend: PriceTrend.up,
      mspPrice: 2275,
      mandiName: 'Lucknow Central Mandi',
      lastUpdated: DateTime.now(),
    ),
    MarketPrice(
      id: 'MP-02',
      cropName: 'paddy',
      category: 'cereals',
      currentPrice: 2183,
      minPrice: 2100,
      maxPrice: 2220,
      changePercentage: -0.4,
      trend: PriceTrend.down,
      mspPrice: 2183,
      mandiName: 'Lucknow Central Mandi',
      lastUpdated: DateTime.now(),
    ),
    MarketPrice(
      id: 'MP-03',
      cropName: 'maize',
      category: 'cereals',
      currentPrice: 1960,
      minPrice: 1880,
      maxPrice: 2020,
      changePercentage: 0.8,
      trend: PriceTrend.up,
      mspPrice: 2090,
      mandiName: 'Lucknow Central Mandi',
      lastUpdated: DateTime.now(),
    ),
    MarketPrice(
      id: 'MP-04',
      cropName: 'mustard',
      category: 'oilseeds',
      currentPrice: 5450,
      minPrice: 5200,
      maxPrice: 5600,
      changePercentage: 2.1,
      trend: PriceTrend.up,
      mspPrice: 5650,
      mandiName: 'Lucknow Central Mandi',
      lastUpdated: DateTime.now(),
    ),
    MarketPrice(
      id: 'MP-05',
      cropName: 'potato',
      category: 'vegetables',
      currentPrice: 1420,
      minPrice: 1300,
      maxPrice: 1550,
      changePercentage: -1.5,
      trend: PriceTrend.down,
      mspPrice: 1200,
      mandiName: 'Lucknow Central Mandi',
      lastUpdated: DateTime.now(),
    ),
    MarketPrice(
      id: 'MP-06',
      cropName: 'sugarcane',
      category: 'cash_crops',
      currentPrice: 350,
      minPrice: 340,
      maxPrice: 360,
      changePercentage: 0.0,
      trend: PriceTrend.stable,
      mspPrice: 340,
      mandiName: 'Lucknow Central Mandi',
      lastUpdated: DateTime.now(),
    ),
  ];

  // Procurement overview
  final ProcurementOverview procurementOverview = const ProcurementOverview(
    totalEarnings: 245000,
    paidAmount: 190000,
    processingAmount: 35000,
    pendingAmount: 20000,
  );

  // Procurement transactions
  final List<ProcurementTransaction> transactions = [
    ProcurementTransaction(
      id: 'TXN-994821',
      crop: 'wheat',
      quantityQuintals: 45,
      ratePerQuintal: 2125,
      totalAmount: 95625,
      date: DateTime.now().subtract(const Duration(days: 2)),
      transactionId: 'TXN-994821',
      status: PaymentStatus.paid,
      mandiName: 'Lucknow Central Mandi',
      bankAccountMasked: 'SBI ••••••••3912',
      utrNumber: 'SBIN240987123912',
    ),
    ProcurementTransaction(
      id: 'TXN-994105',
      crop: 'mustard',
      quantityQuintals: 18,
      ratePerQuintal: 5240,
      totalAmount: 94320,
      date: DateTime.now().subtract(const Duration(days: 8)),
      transactionId: 'TXN-994105',
      status: PaymentStatus.paid,
      mandiName: 'Lucknow Central Mandi',
      bankAccountMasked: 'SBI ••••••••3912',
      utrNumber: 'SBIN240987120199',
    ),
    ProcurementTransaction(
      id: 'TXN-994980',
      crop: 'paddy',
      quantityQuintals: 16,
      ratePerQuintal: 2183,
      totalAmount: 34928,
      date: DateTime.now().subtract(const Duration(days: 1)),
      transactionId: 'TXN-994980',
      status: PaymentStatus.processing,
      mandiName: 'Lucknow Central Mandi',
      bankAccountMasked: 'SBI ••••••••3912',
      utrNumber: 'PENDING_BANK_CLEARANCE',
    ),
    ProcurementTransaction(
      id: 'TXN-995011',
      crop: 'maize',
      quantityQuintals: 10,
      ratePerQuintal: 1960,
      totalAmount: 19600,
      date: DateTime.now().subtract(const Duration(hours: 18)),
      transactionId: 'TXN-995011',
      status: PaymentStatus.pending,
      mandiName: 'Lucknow Central Mandi',
      bankAccountMasked: 'SBI ••••••••3912',
      utrNumber: 'AWAITING_PROCUREMENT_SLIP',
    ),
  ];

  /// Issues a collision-free crop-prefix token like `W-001` or `P-001` for a
  /// booking at [slot]'s centre on [slot]'s date.
  ///
  /// Scope and collisions: numbering runs per crop-prefix inside the
  /// centre + date scope, and every candidate is re-checked against all
  /// tokens already issued in that scope — including different crops that
  /// share a first letter (maize vs mustard, potato vs paddy) — so a
  /// duplicate can never be handed out within the scope. Legacy-format seeds
  /// (e.g. `A-125`) are ignored by the counter because they predate the
  /// crop-prefix scheme, but they still exist as data.
  ///
  /// NOTE: this runs inside a single in-memory demo service instance. A local
  /// counter is NOT globally safe across devices or restarts — production
  /// must issue tokens server-side with an atomic counter scoped by
  /// centre + date + crop. That backend does not exist yet; this is a
  /// documented blocker, not a claim of distributed safety.
  String _issueTokenNumber(MandiSlot slot) {
    final prefix = slot.crop.substring(0, 1).toUpperCase();
    final scope = allBookings
        .where((b) => b.mandiId == slot.mandiId && _sameDay(b.date, slot.date))
        .toList();

    var highest = 0;
    for (final booking in scope) {
      final match = RegExp(r'^([A-Z])-(\d+)$').firstMatch(booking.tokenNumber);
      if (match != null && match.group(1) == prefix) {
        final value = int.tryParse(match.group(2) ?? '') ?? 0;
        if (value > highest) highest = value;
      }
    }

    var candidate = highest + 1;
    String token() => '$prefix-${candidate.toString().padLeft(3, '0')}';
    while (scope.any((b) => b.tokenNumber == token())) {
      candidate++;
    }
    return token();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Booking bookSlot({
    required MandiSlot slot,
    required String farmerId,
    required String farmerName,
  }) {
    // Enforce capacity against the shared slot list so repeated or concurrent
    // booking attempts can never exceed the configured capacity.
    final slotIndex = _availableSlots.indexWhere((s) => s.id == slot.id);
    final canonical = slotIndex == -1 ? slot : _availableSlots[slotIndex];
    if (canonical.availableCapacity <= 0) {
      throw StateError('Slot ${canonical.id} is at full capacity');
    }

    final newBookingId = 'AQ-2026-${(8800 + _bookingHistory.length + 1)}';
    final tokenNumber = _issueTokenNumber(canonical);

    final newBooking = Booking(
      id: newBookingId,
      tokenNumber: tokenNumber,
      farmerId: farmerId,
      farmerName: farmerName,
      mandiId: canonical.mandiId,
      mandiName: canonical.mandiName,
      crop: canonical.crop,
      date: canonical.date,
      timeRange: canonical.timeRange,
      gate: canonical.gate,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
    );

    if (slotIndex != -1) {
      _reserveSlotCapacity(slotIndex);
    }

    // Move the outgoing active booking into history so nothing is lost, and
    // ensure the same booking never lives in both activeBooking and history.
    final previousActive = activeBooking;
    activeBooking = newBooking;
    _bookingHistory.removeWhere(
      (b) => b.id == newBooking.id || b.id == previousActive.id,
    );
    _bookingHistory.insert(0, previousActive);

    return newBooking;
  }

  /// Cancels a booking by changing its status and releasing the slot capacity.
  /// Returns the updated booking, or null if the booking was not found.
  Booking? cancelBooking(String bookingId) {
    final index = allBookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return null;

    final target = allBookings[index];
    if (target.status == BookingStatus.cancelled ||
        target.status == BookingStatus.completed) {
      return null;
    }

    final updated = target.copyWith(status: BookingStatus.cancelled);
    _replaceBooking(updated);

    if (activeBooking.id == bookingId) {
      activeBooking = updated;
    }

    _releaseSlotCapacity(updated);
    return updated;
  }

  void _replaceBooking(Booking updated) {
    for (var i = 0; i < _bookingHistory.length; i++) {
      if (_bookingHistory[i].id == updated.id) {
        _bookingHistory[i] = updated;
        return;
      }
    }
  }

  void _reserveSlotCapacity(int index) {
    final slot = _availableSlots[index];
    final reserved = (slot.bookedCount + 1).clamp(0, slot.totalCapacity);
    _availableSlots[index] = slot.copyWith(
      bookedCount: reserved,
      status: _statusFor(reserved, slot.totalCapacity),
    );
  }

  void _releaseSlotCapacity(Booking booking) {
    for (var i = 0; i < _availableSlots.length; i++) {
      final slot = _availableSlots[i];
      if (slot.crop == booking.crop &&
          slot.timeRange == booking.timeRange &&
          _isSameDay(slot.date, booking.date)) {
        final freedCount = (slot.bookedCount - 1).clamp(0, slot.totalCapacity);
        _availableSlots[i] = slot.copyWith(
          bookedCount: freedCount,
          status: _statusFor(freedCount, slot.totalCapacity),
        );
        break;
      }
    }
  }

  SlotStatus _statusFor(int bookedCount, int totalCapacity) {
    if (bookedCount >= totalCapacity) return SlotStatus.full;
    if (bookedCount >= totalCapacity * 0.8) return SlotStatus.fillingFast;
    return SlotStatus.available;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
